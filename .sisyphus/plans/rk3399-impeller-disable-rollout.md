# rk3399 Impeller 비활성 롤아웃

## TL;DR
> **Summary**: rk3399 기기에서 Flutter Impeller ON일 때 발생하는 버벅임을 제거하기 위해, `kiosk` flavor 설치 빌드에서 Impeller를 Android manifest 메타데이터로 비활성화하고, 개발 실행/현장 테스트/운영 문서를 모두 같은 규칙으로 정렬한다.
> **Deliverables**:
> - `android/app/src/kiosk/AndroidManifest.xml` flavor override 추가
> - `README.md`의 rk3399 빌드/배포/운영 절차 업데이트
> - `AGENTS.md`의 테스트/재현 규칙 업데이트
> - rk3399 / non-rk3399 비교 검증 evidence
> **Effort**: Short
> **Parallel**: YES - 2 waves
> **Critical Path**: 1 → 2 → 3/4 → 5 → 6

## Context
### Original Request
- rk3399에서 `--no-enable-impeller`를 적용하면 버벅임이 사라진다. 배포/빌드, 앱 테스트, 문서에 이를 어떻게 반영할지 정리한다.

### Interview Summary
- 같은 rk3399 기기에서 `kiosk`와 `playstore` flavor 모두 느리므로 flavor 자체는 원인이 아니다.
- WebView/비디오 기능은 현재 사용하지 않고, MQTT는 연결만 되어 있으며 실제 송수신은 없고, 시간표는 로컬 DB 모드라 외부 갱신도 없다.
- 간단한 Flutter 앱(`osc_tester`)도 rk3399에서 버벅이며, 네이티브 앱은 상대적으로 괜찮다.
- `--no-enable-impeller` 적용 시 문제 증상이 사라져, 원인은 `Impeller + rk3399 GPU/드라이버 조합 성능 문제`로 보는 것이 가장 타당하다.

### Metis Review (gaps addressed)
- `playstore` flavor는 유지하고, `kiosk` flavor에만 Impeller OFF를 적용한다.
- CLI 플래그는 개발/재현용으로만 쓰고, 설치 APK/AAB는 manifest meta-data로 강제한다.
- merged manifest 수준에서 `kiosk`와 `playstore`의 차이를 검증해야 한다.
- 문서에는 사용자 증상, 재현 조건, rollback 절차를 모두 남겨야 한다.
- Flutter major upgrade 시 manifest 제어 방식 재검증 필요를 가드레일로 추가한다.

## Work Objectives
### Core Objective
rk3399 대상 Android kiosk 배포에서 Impeller를 안정적으로 비활성화하고, 개발자와 운영자가 동일한 방식으로 빌드·테스트·배포할 수 있도록 저장소의 Android 설정과 문서를 정리한다.

### Deliverables
- `android/app/src/kiosk/AndroidManifest.xml`
- `README.md`
- `AGENTS.md`
- `.sisyphus/evidence/` 하위의 검증 로그

### Definition of Done (verifiable conditions with commands)
- `flutter run --flavor kiosk -d <rk3399-device-id> --no-enable-impeller` 로 rk3399에서 재현용 실행이 가능하다.
- `./gradlew :app:processKioskDebugMainManifest :app:processPlaystoreDebugMainManifest` 실행 후 merged manifest에서 kiosk만 `io.flutter.embedding.android.EnableImpeller=false`를 가진다.
- `flutter build apk --flavor kiosk --release` 산출물은 CLI 플래그 없이도 kiosk manifest 메타데이터를 통해 Impeller OFF 상태로 배포된다.
- `README.md`와 `AGENTS.md`에 rk3399/Impeller 운영 규칙, 테스트 절차, rollback 절차가 명시된다.

### Must Have
- `kiosk` flavor에만 Impeller OFF 설정을 추가한다.
- `playstore` flavor의 Android 런타임 동작은 변경하지 않는다.
- rk3399 테스트 절차에는 `Impeller ON baseline`과 `Impeller OFF confirmation` 두 단계가 모두 포함된다.
- 운영 문서에는 rk3399가 “Impeller OFF 필수 타깃”임을 명시한다.
- 개발 문서에는 Flutter 업그레이드 시 `EnableImpeller` 메타데이터 유효성 재검증 규칙을 추가한다.

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- `android/app/src/main/AndroidManifest.xml`에 전역 Impeller OFF를 넣지 말 것
- `playstore` flavor에 Impeller OFF를 넣지 말 것
- Flutter 엔진 커스텀 빌드, JNI GPU 감지, 런타임 동적 분기 도입 금지
- rk3399 외 모든 Android 기기에 일괄로 Impeller OFF를 강제하지 말 것
- 성능 진단 범위를 다시 넓혀 다른 병목 수정으로 확장하지 말 것

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: tests-after + device-oriented smoke verification
- QA policy: Android 설정 검증(merged manifest) + rk3399 실행 검증 + non-rk3399 회귀 확인을 모두 포함한다.
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`

## Execution Strategy
### Parallel Execution Waves
Wave 1: Android flavor wiring + local verification foundations (Tasks 1-2)

Wave 2: 문서 반영 + device QA + rollout closeout (Tasks 3-6)

### Dependency Matrix (full, all tasks)
| Task | Depends On |
|---|---|
| 1 | - |
| 2 | 1 |
| 3 | 2 |
| 4 | 2 |
| 5 | 3, 4 |
| 6 | 5 |

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 2 tasks → `quick`, `unspecified-high`
- Wave 2 → 4 tasks → `quick`, `unspecified-high`
- Final Verification → 4 tasks in parallel

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [ ] 1. kiosk flavor 전용 Impeller OFF 반영 지점을 만든다

  **What to do**: `android/app/src/kiosk/AndroidManifest.xml`를 새로 추가해, 기존 main manifest를 복제하지 않고 최소 override만 선언한다. `<application>` 아래에 `<meta-data android:name="io.flutter.embedding.android.EnableImpeller" android:value="false" />`를 배치한다. `android/app/src/main/AndroidManifest.xml`는 전역 동작이 바뀌지 않도록 유지한다.
  **Must NOT do**: main manifest에 직접 `EnableImpeller=false`를 넣지 말 것. `playstore` flavor source set은 만들지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 단일 Android flavor override 추가가 핵심이다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 2-6 | Blocked By: -

  **References**:
  - Build config: `android/app/build.gradle:34-45` — `kiosk` / `playstore` flavor 정의
  - Main manifest: `android/app/src/main/AndroidManifest.xml:46-88` — 기존 application/activity 선언
  - Android path pattern: `android/app/src/main/...`
  - External: Flutter Android manifest metadata research — `io.flutter.embedding.android.EnableImpeller=false`

  **Acceptance Criteria** (agent-executable only):
  - [ ] `android/app/src/kiosk/AndroidManifest.xml` exists and contains only flavor-specific override content.
  - [ ] `android/app/src/main/AndroidManifest.xml` does not gain `EnableImpeller` metadata.
  - [ ] `playstore` flavor files are unchanged.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: kiosk manifest override is minimal and isolated
    Tool: Bash
    Steps: verify file presence and inspect diff for `android/app/src/kiosk/AndroidManifest.xml` plus main manifest
    Expected: new kiosk manifest contains `io.flutter.embedding.android.EnableImpeller=false`; main manifest remains free of that key
    Evidence: .sisyphus/evidence/task-1-kiosk-manifest-override.log

  Scenario: playstore flavor remains untouched
    Tool: Bash
    Steps: run `git diff --name-only`
    Expected: no `android/app/src/playstore/*` file is created or modified
    Evidence: .sisyphus/evidence/task-1-playstore-guard.log
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

- [ ] 2. merged manifest와 kiosk 빌드 경로를 검증한다

  **What to do**: Android Gradle manifest merge를 실행해 `kioskDebug`와 `playstoreDebug` 변형을 둘 다 생성한다. merged manifest 산출물에서 kiosk variant에만 `EnableImpeller=false`가 존재함을 확인한다. 이어서 kiosk release APK 빌드가 CLI 플래그 없이도 성공하는지 검증한다.
  **Must NOT do**: `flutter run --no-enable-impeller` 결과만으로 production 반영이 끝났다고 판단하지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: Android variant merge와 build 산출물 검증이 함께 필요하다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 3-6 | Blocked By: 1

  **References**:
  - Build config: `android/app/build.gradle:34-45`
  - New file from Task 1: `android/app/src/kiosk/AndroidManifest.xml`
  - Android merged manifest output: `build/app/intermediates/merged_manifests/`

  **Acceptance Criteria** (agent-executable only):
  - [ ] `./gradlew :app:processKioskDebugMainManifest :app:processPlaystoreDebugMainManifest` exits 0.
  - [ ] `grep -R "io.flutter.embedding.android.EnableImpeller" build/app/intermediates/merged_manifests` shows the key only under kiosk variants.
  - [ ] `flutter build apk --flavor kiosk --release` exits 0.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: merged manifest contains Impeller key only for kiosk
    Tool: Bash
    Steps: run the two manifest merge tasks, then grep merged manifest outputs for `io.flutter.embedding.android.EnableImpeller`
    Expected: kiosk merged manifest has the key with value `false`; playstore merged manifest has no match
    Evidence: .sisyphus/evidence/task-2-merged-manifest.log

  Scenario: kiosk release build no longer depends on CLI Impeller flags
    Tool: Bash
    Steps: run `flutter build apk --flavor kiosk --release`
    Expected: build exits 0 without `--no-enable-impeller`; manifest wiring carries the production behavior
    Evidence: .sisyphus/evidence/task-2-kiosk-release-build.log
  ```

  **Commit**: YES | Message: `fix(android): disable impeller for kiosk flavor` | Files: `android/app/src/kiosk/AndroidManifest.xml`

- [ ] 3. README에 rk3399 배포/운영 규칙을 추가한다

  **What to do**: `README.md`에 새 섹션을 추가해 rk3399 성능 이슈 원인, `kiosk` flavor의 Impeller OFF 정책, 개발 실행 명령, release build 명령, rollback 절차를 정리한다. 기존 release/history 섹션을 건드리기보다 운영 가이드를 분리된 제목으로 추가한다.
  **Must NOT do**: 원인 설명을 “Flutter 전체 버그”로 단정하지 말 것. `playstore` flavor까지 OFF라고 쓰지 말 것.

  **Recommended Agent Profile**:
  - Category: `writing` — Reason: 운영/배포 문서 정리가 핵심이다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 5-6 | Blocked By: 2

  **References**:
  - Doc: `README.md`
  - Build commands: `android/app/build.gradle:36-44`
  - Root finding: rk3399 + `--no-enable-impeller` removes jank

  **Acceptance Criteria** (agent-executable only):
  - [ ] README includes a dedicated rk3399/Impeller section.
  - [ ] README includes exact dev run command and kiosk release build command.
  - [ ] README includes rollback instruction: remove kiosk manifest override to re-enable Impeller.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: README contains rollout commands and scope
    Tool: Grep
    Steps: search README for `rk3399`, `Impeller`, `--no-enable-impeller`, and `flutter build apk --flavor kiosk --release`
    Expected: all required terms appear in the new rollout section
    Evidence: .sisyphus/evidence/task-3-readme-rollout.log

  Scenario: rollback path is documented
    Tool: Read
    Steps: read the newly added README section
    Expected: it explicitly says how to revert the kiosk manifest override if future Flutter/device validation allows Impeller again
    Evidence: .sisyphus/evidence/task-3-readme-rollback.log
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

- [ ] 4. AGENTS에 rk3399 테스트/검증 규칙을 추가한다

  **What to do**: `AGENTS.md`의 빌드·테스트·개발 명령과 테스트 지침 섹션을 확장해 rk3399 성능 재현 시 `--no-enable-impeller` 비교를 기본 규칙으로 추가한다. 개발자가 성능 이슈를 보고할 때 반드시 기기명, Android SDK, WebView 버전, flavor, Impeller ON/OFF 상태를 함께 기록하도록 명시한다. Flutter major/minor 업그레이드 시 `EnableImpeller` 메타데이터 유효성을 재검증하는 규칙도 넣는다.
  **Must NOT do**: 일반 테스트 지침을 rk3399 전용 규칙으로 덮어쓰지 말 것.

  **Recommended Agent Profile**:
  - Category: `writing` — Reason: 개발/QA 규칙 문서화가 핵심이다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 5-6 | Blocked By: 2

  **References**:
  - Doc: `AGENTS.md:8-23`
  - Device finding: rk3399 + WebView 96 + SDK 32
  - CLI reproduction: `flutter run --flavor kiosk -d <rk3399-device-id> --no-enable-impeller`

  **Acceptance Criteria** (agent-executable only):
  - [ ] AGENTS adds rk3399-specific test rule under build/test guidance.
  - [ ] AGENTS requires logging device name, Android SDK, WebView version, flavor, and Impeller state for Android performance reports.
  - [ ] AGENTS notes that Flutter upgrades must revalidate the `EnableImpeller` manifest approach.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: AGENTS captures rk3399 performance reporting rules
    Tool: Grep
    Steps: search AGENTS for `rk3399`, `Impeller`, `WebView`, and `Flutter 업그레이드`
    Expected: all required reporting/revalidation rules are present
    Evidence: .sisyphus/evidence/task-4-agents-rules.log

  Scenario: generic test rules remain intact
    Tool: Read
    Steps: read the updated AGENTS build/test sections
    Expected: existing analyze/test guidance remains, with rk3399 rules added rather than replacing them
    Evidence: .sisyphus/evidence/task-4-agents-guard.log
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

- [ ] 5. rk3399 / non-rk3399 디바이스 QA 매트릭스를 실행하고 기록한다

  **What to do**: device verification을 세 갈래로 실행한다. (a) rk3399에서 `playstore` 또는 baseline variant로 Impeller ON 상태 jank 재현, (b) rk3399에서 `kiosk` flavor + manifest/CLI OFF 상태 정상 확인, (c) non-rk3399 Android 기기에서 `playstore` flavor가 기존처럼 동작하는지 회귀 확인. 결과는 단순 pass/fail이 아니라 증상, flavor, SDK, WebView, Impeller 상태를 포함한 표 형태 evidence로 남긴다.
  **Must NOT do**: rk3399 OFF 결과만 기록하고 ON baseline을 생략하지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 실제 장치 조건을 비교해 운영 결론을 닫아야 한다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: 6 | Blocked By: 3, 4

  **References**:
  - Devices: `rk3399` (SDK 32, Android System WebView 96.0.4664.104), `IM H031`
  - Commands from README/AGENTS updates
  - Root finding: Impeller OFF removes jank on rk3399

  **Acceptance Criteria** (agent-executable only):
  - [ ] Evidence file records ON/OFF comparison for rk3399.
  - [ ] Evidence file records one non-rk3399 playstore regression result.
  - [ ] Evidence includes device name, SDK, WebView version, flavor, Impeller state, outcome.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: rk3399 baseline vs mitigation comparison is captured
    Tool: Bash
    Steps: run the documented device commands for rk3399 baseline (Impeller ON) and mitigation (Impeller OFF), then store observations in a structured evidence file
    Expected: evidence clearly shows ON reproduces jank and OFF removes it on the same device
    Evidence: .sisyphus/evidence/task-5-rk3399-qa.md

  Scenario: playstore regression remains clean on non-rk3399
    Tool: Bash
    Steps: execute the documented playstore run on a non-rk3399 device and record result
    Expected: no new regression is observed outside rk3399-targeted kiosk mitigation
    Evidence: .sisyphus/evidence/task-5-non-rk3399-qa.md
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

- [ ] 6. rollout closeout과 rollback 규칙을 한 곳에 고정한다

  **What to do**: 최종 closeout에서 적용 범위를 명확히 적는다. `kiosk` flavor만 Impeller OFF, `playstore` unchanged, rollback은 `android/app/src/kiosk/AndroidManifest.xml`의 `EnableImpeller` 메타데이터 제거다. 또한 future upgrade checklist를 추가해 Flutter 업데이트 후 반드시 rk3399에서 ON/OFF 비교를 다시 수행하도록 고정한다.
  **Must NOT do**: 향후 모든 Android에 Impeller OFF를 확대 적용하는 문구를 쓰지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 최종 정책 문구와 rollback 규칙 고정이 핵심이다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: Final only | Blocked By: 5

  **References**:
  - `README.md`
  - `AGENTS.md`
  - `android/app/src/kiosk/AndroidManifest.xml`
  - QA evidence from Task 5

  **Acceptance Criteria** (agent-executable only):
  - [ ] rollout scope is explicitly stated as kiosk-only
  - [ ] rollback instruction is written once and is consistent across docs
  - [ ] future Flutter upgrade checklist includes revalidating rk3399 Impeller behavior

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: rollout scope is unambiguous
    Tool: Read
    Steps: compare README and AGENTS final policy text
    Expected: both state kiosk-only mitigation and playstore unchanged with no contradiction
    Evidence: .sisyphus/evidence/task-6-rollout-scope.log

  Scenario: rollback and upgrade rules are preserved
    Tool: Grep
    Steps: search updated docs for `rollback`, `EnableImpeller`, and `Flutter 업그레이드`
    Expected: one consistent rollback path and one upgrade revalidation rule are present
    Evidence: .sisyphus/evidence/task-6-rollback-upgrade.log
  ```

  **Commit**: YES | Message: `docs(android): document rk3399 impeller rollout` | Files: `README.md`, `AGENTS.md`

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [ ] F1. Plan Compliance Audit — oracle
- [ ] F2. Android Build/Manifest Review — unspecified-high
- [ ] F3. Device QA Review — unspecified-high
- [ ] F4. Scope Fidelity Check — deep

## Commit Strategy
- Commit 1: `fix(android): disable impeller for kiosk flavor`
- Commit 2: `docs(android): document rk3399 impeller rollout`

## Success Criteria
- kiosk flavor installed builds disable Impeller through manifest metadata.
- playstore flavor remains unchanged.
- rk3399 ON/OFF difference is documented with repeatable commands.
- README and AGENTS are sufficient for build, deployment, testing, rollback, and future upgrade validation.
