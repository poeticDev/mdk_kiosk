# 키오스크 성능 저하 체크리스트

## 상황 요약
- 재현 대상: kiosk flavor `--release` 빌드(안드로이드 12 신규 디바이스)에서 전체 동작 버벅거림.
- 이전 정상 기준: 안드로이드 11 동일 기종, `release/ghu_self_studio` 이전 빌드.
- 추가 확인: 과거 정상 빌드(`release/ghu_self_studio`)를 Android 12 기기에 설치해도 동일 버벅거림 → 코드 변경 영향도 낮음, OS/펌웨어/빌드옵션 변수 우선 점검 필요.

## 변경사항 정리(의심도 우선순)
1) **런타임 환경 변화**: Android 12 업데이트 → 스케줄러/전력 정책, HWUI/Skia 드라이버, 백그라운드 제한 변경 가능성.
2) **엔진/의존성 메이저 업그레이드**: Flutter & 패키지 메이저 업데이트, Riverpod 3, Gradle/AGP 업그레이드 → AOT 코드, R8/ProGuard, JNI/so 번들 변화.
3) **앱 로직 변경**: MQTT 재연결/DimMode/Google Cloud 연동/레이아웃 수정/폰트 확대 → 렌더·네트워크·I/O 부하 증가 가능성.
4) **빌드 설정 차이**: profile 빌드 설치, `--web-renderer`/`--enable-impeller`/ABI 설정(arm64/armeabi-v7a) 누락, split-per-abi 미사용 등.

## 빠른 검증(10분 이내)
- `adb shell settings get global animator_duration_scale` 등 애니메이션 스케일 1x 확인. (Android 12에서 `null`이면 글로벌 키 미설정 상태 → 기본 1x로 간주. 필요 시 `settings put global animator_duration_scale 1` 및 `settings put global transition_animation_scale 1`, `settings put global window_animation_scale 1` 후 재부팅 없이 적용.)
- `adb shell dumpsys activity settings | grep mDeviceIdle` 로 배터리 절전/저전력 여부 확인. (Android 12에서 출력이 없으면 `adb shell dumpsys deviceidle` 또는 `adb shell cmd deviceidle enabled`/`force-idle`로 상태 확인.)
- `adb shell getprop ro.product.cpu.abi` / `cmd package dump com.<app>` 로 설치된 ABI 확인(arm64 권장). (현재 기기: `arm64-v8a` 확인됨 → ABI 문제 가능성 낮음)
- 디바이스 온도/스로틀: `adb shell dumpsys thermalservice`. (현재: `Thermal Status: 0`, `HAL Ready: false` → OS 보고상 스로틀 없음, 열로 인한 즉시 저하는 낮은 편)
- 빌드 타입 재확인: 설치 APK/OBB 이름에 `profile` 아닌지, `flutter build apk --release --flavor kiosk` 재빌드 후 비교.
- HWUI/SurfaceFlinger: `adb shell dumpsys SurfaceFlinger --latency-clear` 후 UI 조작 → `--latency` 값으로 프레임 드롭 여부 확인, `adb shell setprop debug.hwui.renderer skiagl`(임시)로 렌더러 강제 후 비교.

## 성능 프로파일링 절차
1) **Frame jank 측정**: `adb shell dumpsys gfxinfo com.<app>` → Janky frames %, 90th/95th percentile 파악.
   - 샘플1: 총 25프레임 jank 100%, 90/95%tile=89/109ms, GPU 95%tile=4950ms, Slow UI thread=8, High input latency=16 → 초반 프레임 메인 스레드/입력 지연 심각.
   - 샘플2(framestats): 총 5프레임 jank 80%, 90/95%tile=1200ms, GPU 95%tile=7ms → GPU는 정상, UI 스레드 1.2s 정체로 판단. 샘플 길이 부족하므로 300프레임 이상 재측정 필요.
   - 샘플3(framestats 재측정 후 30~60초 조작): 여전히 총 5프레임, jank 100%, 90/95%tile=1300ms, Slow UI thread=5 → 여전히 메인 스레드 장기 정체. 프레임 수가 늘지 않는 것은 UI가 거의 그려지지 않을 정도로 장시간 스톨되었음을 의미.
   - 측정 팁: `adb shell dumpsys gfxinfo com.<app> reset` 후 앱을 전면 표시한 채 30~60초 조작 → `gfxinfo` 또는 `gfxinfo ... framestats` 재실행. `Total frames rendered`가 0이면 전면 표시 여부를 다시 확인.
   - 프레임 수 미증가 시 추가 확인: `adb shell dumpsys SurfaceFlinger --latency-clear` 후 문제 화면에서 스크롤 등 연속 애니메이션 10초 이상 실행 → `adb shell dumpsys SurfaceFlinger --latency`로 전체 프레임 시간 확인(앱 레이어 vsync 수준에서 계측).
2) **GPU/Skia 추적**: `flutter run --profile --flavor kiosk --trace-skia --trace-systrace` → DevTools Timeline으로 레이아웃/빌드/래스터 타임 확인.
   - 다음 단계: run 로그에 표시된 `VM Service` 또는 `Observatory` URL을 복사 → 브라우저에서 DevTools 열기 → Timeline 탭에서 Record 시작 후 문제 화면 20~30초 조작 → Stop → `Export`로 JSON 저장(공유용).
   - DevTools가 안 열리면 별도 터미널에서 `flutter attach --profile --flavor kiosk --trace-skia --trace-systrace` 실행 후 동일 절차 진행.
   - 현재 수집한 CPU Sampler 상위 스택: `_BigIntImpl.*` → `RSAAlgorithm._modPow` → `googleapis_auth` → `GSheetsAuth.auth` → `GoogleSheets.reInitialize` → `AppInitializer.reinitAfterEditorMode`. 서비스 계정 JWT 서명(BigInt) 작업이 UI 스레드에서 실행되어 프레임 정체를 유발.
   - 코드 대응: `lib/timetable/util/google_sheets.dart`에서 GSheets 인증을 1회만 수행해 캐시하도록 변경, 동일 파일에서 `_ensureAuthInitialized`로 중복 JWT 서명 방지. (추가로 isolate 분리는 후속 과제)
3) **CPU 스케줄링 확인**: `adb shell top -Hp <pid>` 와 `adb shell schedtune cgroup`(가능 시)로 빌드/래스터 스레드 사용률 확인.
4) **Perfetto/atrace**: `perfetto -o trace.perfetto-trace -b 4096 -t 15s sched gfx view wm` 후 UI jank 구간 분석.
5) **메모리/GC**: DevTools Memory 탭, `adb shell dumpsys meminfo com.<app>` → 누수/과도한 GC 여부 확인.

## 코드/설정 점검 포인트
- Flutter/엔진: Android 12 + Flutter 업그레이드 후 `android:exported` 외 추가 설정 누락 여부, `hardwareAccelerated=true` 재확인.
- Android 12 정책: 포그라운드 서비스/백그라운드 제한, Doze 강화로 타이머/네트워크가 메인 스레드에 영향 주는지 확인(`adb shell cmd deviceidle enabled`).
- 렌더러: Impeller/Skia 선택 확인. Android에서 Impeller 미지원이면 강제 옵션 제거.
- R8/ProGuard: AGP 업그레이드 후 `proguard-rules.pro` 최적화로 인한 inlining/offline? → `-dontobfuscate` 임시 적용 빌드로 비교.
- Riverpod 3 마이그레이션: `ref.listen`/`ref.watch` 과도 호출로 rebuild 폭증 여부, `StateNotifier` → `Notifier` 전환 시 DI 누락.
- MQTT/네트워크 루프: 재연결 타이머/스트림이 메인 isolate에서 돌고 있는지 확인, 백오프 누락 여부.
- 레이아웃/폰트 확대: 텍스트 scale → 전체 리빌드/레이아웃 비용 상승. `const` 위젯/분리 렌더 적용 필요.
- 기본 스레드 우선순위: `ThreadPriority` 커스텀 사용 시 Android 12 정책과 충돌 여부.
- Google Sheets 인증: `GSheetsAuth.auth`/`GoogleSheets.reInitialize`에서 RSA(BigInt) 서명이 UI 스레드에서 수행됨 → (1단계) service account 클라이언트 싱글톤·캐시화 완료(`lib/timetable/util/google_sheets.dart`), (2단계) 가능하면 isolate/compute로 JWT 서명 분리, (3단계) 토큰 갱신을 사전 스케줄링해 UI 진입 시 재서명 방지.

## 비교 실험 플랜
- A/B 설치: (A) Android11 정상 빌드, (B) 동일 커밋을 Android12 기기 설치. 동일 시 OS 원인, 차이 시 코드/빌드 원인.
- 커밋 바이섹트는 우선순위 하향(과거 빌드도 동일 증상) → 필요 시 코드 요인 배제용으로만 수행.
- 빌드 옵션 비교: `--no-tree-shake-icons`, `--split-debug-info` 유무, `--target-platform=android-arm64` vs multi-abi.

## 데이터 수집 체크리스트(공유용)
- `gfxinfo` 결과(Janky %, 90/95퍼센타일) 스크린샷.
- DevTools Timeline 캡처(레이스터 vs 빌드 타임 상승 구간 표시).
- 로그캣 warn/error 중 scheduling, Choreographer, HWUI, `Skipped X frames` 메시지.
- Thermal/CPU load 출력.
- 문제 화면/동작 재현 단계와 발생 빈도.

## 우선 대응 제안
- 최신 release 빌드 arm64 전용으로 재빌드 후 설치 → ABI/빌드타입 변수 제거.
- 프로파일 빌드로 문제 화면 30초 기록 → Timeline에서 레이아웃/래스터 병목 식별.
- MQTT/Dim/Cloud 연동 비활성 플래그 빌드 1개 추가해 비교(네트워크/타이머 루프 영향 분리).
- 동일 APK를 Android 11/12 두 기기에 설치해 `gfxinfo` 수치 나란히 수집 → OS/드라이버 영향 계량화.
- `gfxinfo` 재측정 시 300프레임 이상(30초 이상) 확보하여 99%tile 안정화, GPU 4950ms 스파이크 재발 여부 확인. 절차:
  1) `adb shell dumpsys gfxinfo com.<app> reset` 로 기존 통계 초기화.
  2) 앱이 화면에 전면 표시된 상태에서 문제 화면을 30~60초 동안 실제 사용자 시나리오로 동작(백그라운드/홈화면 상태 금지).
  3) `adb shell dumpsys gfxinfo com.<app>` 재실행 → `Total frames`가 증가했는지 확인하고 퍼센타일/Histogram을 확인.
  4) 여전히 0프레임이면 `adb shell dumpsys gfxinfo com.<app> framestats`로 수집(안드로이드 12에서 일부 기기에서 기본 통계가 0으로 나올 수 있음).
- Google Sheets 인증 최적화(가장 빠른 완화책): ✅ 1단계 적용 — 인증 클라이언트 싱글톤·캐시화 완료. 추가로 isolate 분리는 선택적 후속 작업.
