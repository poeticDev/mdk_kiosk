# 키오스크 프레임 저하 대응 계획

- [x] **1. 기준선 확보 및 병목 추적** (완료: 2025-11-26)
  - `flutter run --profile --flavor kiosk -d rk3399`에서 수집한 `dumpsys gfxinfo` 결과: 총 11프레임 중 10프레임(90.9%)이 기한을 넘기고 95퍼센타일 1.2초, UI thread 지연 8회로 보고되어 메인 스레드 과부하가 확인됨. (원시 산출물은 `flutter run --profile` 후 DevTools/ADB 명령으로 재수집 가능)
  - DevTools 타임라인(2025-11-26 측정)에서 246프레임 중 245프레임이 16ms 초과, 평균 Build 18.5ms / 평균 Raster 1.19초, 최악 Build 0.71초·Raster 2.04초로 측정되어 Draw 명령 대기 시간이 병목으로 추정됨.
  - 동일 시점의 `adb shell top -H -p` 로그는 `Thread<00>`~`Thread<05>`가 각 24~33% CPU를 점유하고 `1.raster`는 7% 수준으로, GPU 병목이 아닌 메인 Isolate 다중 동기 작업임을 보여줌.
  - CPU 프로파일(2025-11-26 측정) 샘플에는 `_SimpleClockState._updateTime`·`MqttManager._pingCallback`이 포함되어 주기적 타이머/네트워크 핑이 UI Thread에서 동기 실행 중임을 확증함. 추가적인 장기 캡처가 필요함.

- [ ] **2. 동기 연산 인벤토리 작성**
  - `lib/`에서 `jsonDecode`, `DateTime.parse`, compute-intensive loops, DB/파일 IO를 전수 조사한다.
  - 각 후보에 대해 입력/출력 데이터 크기, 호출 빈도, UI 의존 여부를 표로 정리한다.
  - 메인 스레드 필수 로직(렌더, 컨트롤러 setState 등)을 제외하고도 되는 항목을 확정한다.

- [ ] **3. 비동기 전환 설계**
  - 고립 가능한 연산마다 `typedef` 기반 DTO를 정의하고, 순수 함수 형태로 분리한다.
  - 간단 계산은 `compute`, 대용량 스트림/IO는 `Isolate.run` 또는 전용 `Isolate` + `ReceivePort` 패턴으로 매핑한다.
  - 상태 관리(Riverpod Controller)는 Future 기반으로 리팩터링해 UI Thread는 결과만 수신하도록 한다.

- [ ] **4. 구현 및 의존성 주입 정리**
  - `lib/common/services/` (또는 기존 위치)에 `BackgroundTaskService`를 추가하고 getIt에 등록한다.
  - 각 컨트롤러에서 기존 동기 호출을 서비스 메서드로 교체하고, `AsyncValue`/`freezed` 상태를 업데이트한다.
  - JSON/미디어 프리로드 등 반복 연산은 캐싱 전략(메모리/LRU)으로 중복 compute 호출을 줄인다.

- [ ] **5. 회귀 방지 및 검증**
  - 단위 테스트에서 새 비동기 함수의 순수성, DTO 변환 정확성을 검증한다.
  - 위젯 테스트에서 컨트롤러 상태 전이를 Given-When-Then 패턴으로 확인한다.
  - 프로파일러로 다시 측정해 Janky Frame 비율(<1%)과 Frame build time(<16ms)을 확인하고 로그에 남긴다.
