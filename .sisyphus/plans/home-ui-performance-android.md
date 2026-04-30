# Android 홈 화면 상시 UI 성능 개선

## TL;DR
> **Summary**: Android 키오스크 홈 화면의 상시 버벅임을 줄이기 위해, 시작 속도는 제외하고 항상 보이는 위젯의 리빌드/레이아웃/페인트 병목만 정리한다.
> **Deliverables**:
> - Android 로컬 대체 타깃 기준 성능 베이스라인 및 재현 하네스
> - Timetable/Clock/Header/Home shell의 리빌드 폭 축소
> - MorphContainer/BlackOverlay의 비용 검증 및 필요한 범위의 최적화
> - 회귀 방지 테스트 + 증거 파일
> **Effort**: Large
> **Parallel**: YES - 2 waves
> **Critical Path**: 1 → 2 → 3/4/5 → 6/7 → 8

## Context
### Original Request
- 강의 등록/수정 등 목표 기능은 이미 정상 동작한다.
- 앱 속도는 조금 개선됐지만 여전히 많이 느리다.
- 가장 거슬리는 증상은 startup보다 홈 화면의 상시 버벅임이다.
- 실제 운영 타깃은 Android 키오스크다.
- 실 기기는 단독망 환경이라 에이전트가 직접 운영 기기에서 계측하기 어렵다.

### Interview Summary
- 이번 범위는 startup / splash / Google Sheets 초기화 / MQTT 연결 시간 단축이 아니라 **steady-state home UI jank**로 한정한다.
- 버벅임은 특정 서브영역보다 홈 전체에서 느껴진다.
- `black_overlay.dart`는 후보이지만 운영 중 자주 켜지지 않으므로 2차 우선순위다.
- 검증은 운영 실기기 대신 **로컬 Android 대체 타깃(연결된 Android 또는 에뮬레이터)** 기준으로 자동화한다.

### Metis Review (gaps addressed)
- 베이스라인 없이 추정 최적화를 하지 않도록 **재현 시나리오 + 계측 하네스**를 1순위로 고정했다.
- 항상 보이는 위젯(`Timetable`, `SimpleClock`, `HeaderLayout`, `DefaultLayout`, `MorphContainer`)을 overlay보다 우선한다.
- 각 최적화는 한 병목 가설씩 분리하고, 수정 후 반드시 재계측한다.
- startup, provider 전면 재설계, 비Android 플랫폼, 시각 디자인 전면 변경은 범위 밖으로 봉인한다.

## Work Objectives
### Core Objective
Android 키오스크 홈 화면이 유휴 상태와 경미한 데이터 갱신 상황에서 불필요한 전체 리빌드/서브트리 재생성/과도한 페인트 비용 없이 더 안정적으로 동작하게 만든다.

### Deliverables
- `integration_test/` 기반 홈 idle 성능 재현 하네스 및 evidence 저장 경로
- 홈 성능 회귀 방지 테스트 파일
- Timetable stable identity 및 레이아웃 비용 축소
- Clock/Header/Home shell 리빌드 범위 축소
- MorphContainer 비용 완화 또는 비용 근거에 따른 유지 결정
- BlackOverlay의 2차 최적화 또는 skip evidence

### Definition of Done (verifiable conditions with commands)
- `flutter analyze --fatal-infos`
- `flutter test test/timetable/component/timetable_refresh_policy_test.dart test/common/layout/default_layout_timetable_admin_entry_test.dart test/home/performance/home_rebuild_guard_test.dart test/home/performance/clock_header_isolation_test.dart test/home/performance/black_overlay_behavior_test.dart`
- `ANDROID_DEVICE_ID="$(flutter devices --machine | python3 - <<'PY'
import json,sys
data=json.load(sys.stdin)
android=[d for d in data if d.get('platform')=='android']
preferred=[d for d in android if d.get('emulator')]
pick=(preferred or android)
print(pick[0]['id'] if pick else '')
PY
)" && test -n "$ANDROID_DEVICE_ID" && flutter drive --profile -d "$ANDROID_DEVICE_ID" --driver integration_test/driver.dart --target integration_test/home_idle_perf_test.dart`
- `test -f .sisyphus/evidence/task-1-home-idle-baseline.json`
- `test -f .sisyphus/evidence/task-8-home-idle-after.json`

### Must Have
- 홈 화면 유휴 시나리오의 베이스라인과 변경 후 결과를 동일 조건으로 비교
- `Timetable` 갱신 시 전체 subtree를 불필요하게 폐기하지 않음
- 시계 갱신이 Header/Home 전체 리빌드로 퍼지지 않음
- `DefaultLayout`의 비핵심 상태 변경이 홈 전체 재빌드를 유발하지 않음
- 성능 개선 후 관리자 진입, 시간표 갱신, 헤더 메시지 순환, overlay 표시 동작이 유지됨

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- Startup/Splash/MQTT 연결 시간 단축 작업 포함 금지
- Riverpod/provider 구조 전면 개편 금지
- Web/Linux 성능 작업 포함 금지
- 근거 없는 `const everywhere`, `RepaintBoundary everywhere`, 전역 캐시 남발 금지
- MorphContainer 시각 스타일을 근거 없이 전면 교체 금지
- 운영 기기 미접속을 이유로 “체감상 빨라짐”만으로 완료 처리 금지

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: tests-after + Flutter widget/integration/profile verification
- QA policy: 모든 task는 happy path + edge/failure path를 포함한다.
- Local Android surrogate: `flutter devices --machine`로 첫 Android 타깃을 자동 선택하고, 에뮬레이터 우선 사용
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`
- Metrics policy:
  - 동일 Android 타깃 / 동일 home idle 시나리오 / profile mode 기준 비교
  - 성공 기준은 **baseline 대비 janky frame count 30% 이상 감소 또는 average/p95 build/raster 지표 20% 이상 개선** 중 하나 이상 충족
  - 절대 수치가 기준 미달이어도 상대 개선이 없으면 추가 최적화 없이 완료 금지

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extract shared dependencies as Wave-1 tasks for max parallelism.

Wave 1: baseline + behavior guards + 항상 보이는 subtree 병목 1차 정리 (Tasks 1-5)
Wave 2: home shell / paint cost / secondary overlay + re-profile (Tasks 6-8)

### Dependency Matrix (full, all tasks)
- 1 blocks: 2,3,4,5,6,7,8
- 2 blocks: 3,5,6,8
- 3 blocks: 4,8
- 4 blocks: 8
- 5 blocks: 6,8
- 6 blocks: 8
- 7 blocks: 8
- 8 blocks: F1-F4

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 5 tasks → `unspecified-high` x4, `quick` x1
- Wave 2 → 3 tasks → `unspecified-high` x3
- Final Verification → 4 tasks → `oracle`, `unspecified-high`, `unspecified-high`, `deep`

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [ ] 1. Android 홈 idle 성능 베이스라인 하네스 구축

  **What to do**: `integration_test/driver.dart`와 `integration_test/home_idle_perf_test.dart`를 추가해 Android profile mode에서 홈 화면 유휴 60초 시나리오를 자동 재현한다. 재현 시나리오는 `DefaultLayout` + `HeaderLayout` + `Timetable` + `MultimediaLayout`이 함께 뜨는 기본 홈 상태, 에디터 모드 OFF, overlay inactive, 시간표 데이터 6건 이상 고정, 메시지 0건/1건 두 케이스 중 기본 케이스는 0건으로 통일한다. 테스트는 baseline summary(JSON/텍스트)를 `.sisyphus/evidence/task-1-home-idle-baseline.json` 및 `.sisyphus/evidence/task-1-home-idle-baseline.txt`로 저장한다.
  **Must NOT do**: 운영 실기기 연결을 전제로 하지 말 것. startup 최적화나 네트워크 초기화 단축을 이 task에 섞지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: integration/perf harness와 evidence 저장 경로를 함께 설계해야 한다.
  - Skills: `[]` — 별도 전용 스킬 불필요.
  - Omitted: `["playwright"]` — 브라우저 검증이 아니라 Flutter Android profile 하네스가 핵심이다.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 2,3,4,5,6,7,8 | Blocked By: none

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/common/layout/default_layout.dart:99-314` — 실제 홈 화면 구조(헤더/시간표/멀티미디어/푸터) 기준 재현 시나리오를 맞춘다.
  - Pattern: `lib/header/header_layout.dart:210-245` — 홈 idle 중 상시 보이는 헤더 갱신 경로.
  - Pattern: `lib/timetable/component/timetable.dart:63-74` — 시간표 subtree 렌더링 시작점.
  - Pattern: `lib/common/component/morph_container.dart:46-57` — 항상 보이는 paint-cost 후보.
  - Test: `test/timetable/component/timetable_refresh_policy_test.dart:23-267` — Flutter widget test 스타일과 mock repository 패턴.
  - External: `https://docs.flutter.dev/cookbook/testing/integration/profiling` — `TimelineSummary` 기반 성능 evidence 작성 방식.
  - External: `https://docs.flutter.dev/tools/devtools/overview` — Performance/Timeline 확인 기준.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `test -f integration_test/home_idle_perf_test.dart && test -f integration_test/driver.dart`
  - [ ] `flutter analyze --fatal-infos`
  - [ ] `ANDROID_DEVICE_ID="$(flutter devices --machine | python3 - <<'PY'
import json,sys
data=json.load(sys.stdin)
android=[d for d in data if d.get('platform')=='android']
preferred=[d for d in android if d.get('emulator')]
pick=(preferred or android)
print(pick[0]['id'] if pick else '')
PY
)" && test -n "$ANDROID_DEVICE_ID" && flutter drive --profile -d "$ANDROID_DEVICE_ID" --driver integration_test/driver.dart --target integration_test/home_idle_perf_test.dart`
  - [ ] `test -f .sisyphus/evidence/task-1-home-idle-baseline.json && test -f .sisyphus/evidence/task-1-home-idle-baseline.txt`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Idle home baseline capture
    Tool: Bash
    Steps: Auto-select first Android target; run profile integration test for 60s idle home scenario; persist summary JSON/TXT evidence.
    Expected: Test exits 0; evidence files exist; summary contains frame timing metrics and target device id.
    Evidence: .sisyphus/evidence/task-1-home-idle-baseline.json

  Scenario: No Android target available
    Tool: Bash
    Steps: Run the same device-detection command in an environment without Android devices/emulators.
    Expected: Command fails fast with explicit non-empty target check; no partial success is reported.
    Evidence: .sisyphus/evidence/task-1-home-idle-baseline.txt
  ```

  **Commit**: YES | Message: `test(home): Android 홈 성능 베이스라인과 회귀 가드 추가` | Files: `integration_test/driver.dart`, `integration_test/home_idle_perf_test.dart`, `.sisyphus/evidence/task-1-home-idle-baseline.*`

- [ ] 2. 홈 성능 회귀 가드 테스트 추가

  **What to do**: `test/home/performance/` 아래에 회귀 가드를 추가한다. 최소 포함 범위는 (a) `Timetable` 갱신 시 `TimetableLayout` identity가 불필요하게 새로 만들어지지 않는지, (b) `SimpleClock` tick이 `HeaderLayout`/`DefaultLayout` 전체 rebuild로 퍼지지 않는지, (c) `BlackoutOverlay`가 수정되더라도 표시/해제 동작이 깨지지 않는지다. 기존 테스트 스타일(Given/When/Then 주석, GetIt mock repository)을 따른다.
  **Must NOT do**: 성능 수치 assertion을 widget test에서 직접 하려 하지 말 것. startup / router / admin flow 회귀까지 범위를 넓히지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 테스트 추가가 중심이며 구조 변경은 최소다.
  - Skills: `[]` — 기존 test 패턴만 따르면 된다.
  - Omitted: `["playwright"]` — 위젯 테스트로 해결 가능한 범위다.

  **Parallelization**: Can Parallel: PARTIAL | Wave 1 | Blocks: 3,5,6,8 | Blocked By: 1

  **References** (executor has NO interview context — be exhaustive):
  - Test: `test/timetable/component/timetable_refresh_policy_test.dart:23-344` — GetIt mock repository 및 widget test 구조.
  - Test: `test/common/layout/default_layout_timetable_admin_entry_test.dart:20-118` — Given/When/Then 한국어 테스트 스타일.
  - Pattern: `lib/timetable/component/timetable.dart:63-74` — stable identity 회귀 대상.
  - Pattern: `lib/header/component/simple_clock.dart:19-33` — 1초 timer tick 회귀 대상.
  - Pattern: `lib/common/component/black_overlay.dart:35-137` — overlay 동작 회귀 대상.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `test -f test/home/performance/home_rebuild_guard_test.dart`
  - [ ] `test -f test/home/performance/clock_header_isolation_test.dart`
  - [ ] `test -f test/home/performance/black_overlay_behavior_test.dart`
  - [ ] `flutter test test/home/performance/home_rebuild_guard_test.dart test/home/performance/clock_header_isolation_test.dart test/home/performance/black_overlay_behavior_test.dart`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Timetable identity guard
    Tool: Bash
    Steps: Run home_rebuild_guard_test.dart and simulate timetableUpdater changes with a mock repository.
    Expected: TimetableLayout instance identity remains stable unless lecture data itself changes.
    Evidence: .sisyphus/evidence/task-2-home-rebuild-guard.txt

  Scenario: Overlay behavior parity
    Tool: Bash
    Steps: Run black_overlay_behavior_test.dart with overlay shown/hidden lifecycle.
    Expected: Overlay still mounts, animates, and disposes without ticker/timer leaks.
    Evidence: .sisyphus/evidence/task-2-black-overlay-guard.txt
  ```

  **Commit**: YES | Message: `test(home): 상시 UI 성능 회귀 가드 추가` | Files: `test/home/performance/*.dart`

- [ ] 3. Timetable stable identity로 subtree 재생성 제거

  **What to do**: `Timetable`에서 `Key(timetableWatcher.toString())` 기반 identity churn을 제거한다. `timetableUpdater`가 바뀌어도 lecture data 변경이 반영되면서 기존 `TimetableLayout` subtree는 최대한 재사용되도록 수정한다. 변경 후에도 background refresh 정책(`supportsBackgroundRefresh`)과 lecture rendering은 기존과 동일해야 한다.
  **Must NOT do**: refresh timer 주기, repository contract, polling 정책 자체를 바꾸지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 동작 보존과 subtree identity 안정화를 함께 다뤄야 한다.
  - Skills: `[]`
  - Omitted: `["refactor"]` — 이번 범위는 전면 리팩터가 아니라 한 hotspot 제거다.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 4,8 | Blocked By: 1,2

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/timetable/component/timetable.dart:63-74` — 현재 `Key(timetableWatcher.toString())`가 subtree 재생성을 강제한다.
  - Pattern: `lib/timetable/timetable_layout.dart:21-31` — `TimetableLayout` constructor와 identity 보존 대상.
  - Test: `test/timetable/component/timetable_refresh_policy_test.dart:23-344` — polling 정책 보존 테스트.
  - Test: `test/home/performance/home_rebuild_guard_test.dart` — 새 identity 가드 테스트.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/timetable/component/timetable_refresh_policy_test.dart test/home/performance/home_rebuild_guard_test.dart`
  - [ ] `flutter analyze --fatal-infos`
  - [ ] `grep -n "Key(timetableWatcher.toString())" lib/timetable/component/timetable.dart` returns no matches

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Timetable refresh without subtree disposal
    Tool: Bash
    Steps: Run home_rebuild_guard_test.dart and drive timetableUpdater changes with unchanged widget identity expectations.
    Expected: TimetableLayout is reused; rendered lectures still update correctly.
    Evidence: .sisyphus/evidence/task-3-timetable-identity.txt

  Scenario: Background refresh policy preserved
    Tool: Bash
    Steps: Run timetable_refresh_policy_test.dart for supportsBackgroundRefresh true/false cases.
    Expected: Polling behavior remains unchanged after identity stabilization.
    Evidence: .sisyphus/evidence/task-3-refresh-policy.txt
  ```

  **Commit**: YES | Message: `perf(timetable): 불필요한 subtree 재생성 제거` | Files: `lib/timetable/component/timetable.dart`, `test/home/performance/home_rebuild_guard_test.dart`

- [ ] 4. TimetableLayout의 per-build 작업량 축소

  **What to do**: `TimetableLayout`에서 build마다 반복 생성되는 리스트/열 계산 비용을 줄인다. 최소 범위는 `...List.generate(...).expand(...)` 구조 단순화, 요일별 lecture filtering의 불필요한 중간 리스트 재할당 제거, 필요 시 요일별 lecture grouping을 상위에서 한 번만 계산하도록 이동하는 것이다. 시각적 결과(요일 수, 시간축, 강의 박스 위치)는 동일해야 한다.
  **Must NOT do**: 시간표 UI 디자인, 요일 정책(`WeekendOption`), `LectureBox` 레이아웃 계약을 바꾸지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 레이아웃 비용을 줄이되 렌더링 결과를 보존해야 한다.
  - Skills: `[]`
  - Omitted: `["frontend-ui-ux"]` — 미적 개편이 아니라 계산량 축소가 목적이다.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 8 | Blocked By: 1,3

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/timetable/timetable_layout.dart:33-105` — 현재 전체 grid build와 `expand` 사용 지점.
  - Pattern: `lib/timetable/timetable_layout.dart:143-205` — 요일별 lectureBoxes 생성 루프.
  - API/Type: `lib/timetable/model/lecture.dart` — lecture grouping 대상 모델 계약.
  - Test: `test/timetable/component/timetable_refresh_policy_test.dart:126-152` — lecture 데이터 표시 보존 기준.
  - Test: `test/timetable/ui/timetable_local_empty_state_test.dart` — 시간표 UI 기본 동작 참고.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/timetable/component/timetable_refresh_policy_test.dart test/timetable/ui/timetable_local_empty_state_test.dart test/home/performance/home_rebuild_guard_test.dart`
  - [ ] `flutter analyze --fatal-infos`
  - [ ] `grep -n "expand((widgetList) => widgetList)" lib/timetable/timetable_layout.dart` returns no matches

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Timetable renders same lecture grid after layout-cost reduction
    Tool: Bash
    Steps: Run timetable widget tests covering empty state and populated lecture data.
    Expected: Lecture count, weekday headers, and refresh behavior remain unchanged.
    Evidence: .sisyphus/evidence/task-4-timetable-layout.txt

  Scenario: Lecture grouping edge case
    Tool: Bash
    Steps: Run tests with multiple lectures on the same weekday and no lectures on other weekdays.
    Expected: Same-day lectures still render; empty weekdays remain stable without exceptions.
    Evidence: .sisyphus/evidence/task-4-timetable-grouping.txt
  ```

  **Commit**: YES | Message: `perf(timetable): 레이아웃 계산 비용 축소` | Files: `lib/timetable/timetable_layout.dart`, related timetable tests

- [ ] 5. SimpleClock tick을 leaf subtree로 고립

  **What to do**: `SimpleClock`의 1초 timer 갱신이 `HeaderLayout` 또는 홈 상위 subtree 전체 리빌드로 퍼지지 않도록 구조를 고립한다. `Row`의 정적 부분(icon 등)은 재사용하고, 실제 시간 문자열만 갱신되는 leaf로 축소한다. 필요하면 `ValueNotifier`, `AnimatedBuilder`의 `child`, 또는 더 작은 stateful leaf를 사용하되 동작은 동일해야 한다.
  **Must NOT do**: 시계 포맷(HH:mm), 갱신 주기(1초), 헤더 배치 자체를 바꾸지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 항상 보이는 1Hz 갱신 경로를 안전하게 고립해야 한다.
  - Skills: `[]`
  - Omitted: `["frontend-ui-ux"]` — 레이아웃 변경이 아니라 rebuild isolation이 목적이다.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 6,8 | Blocked By: 1,2

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/header/component/simple_clock.dart:19-33` — 현재 1초마다 `setState()` 호출.
  - Pattern: `lib/header/component/simple_clock.dart:42-52` — 정적 icon + 동적 text가 한 subtree에 묶여 있다.
  - Pattern: `lib/header/header_layout.dart:248-264` — DefaultHeader 안에서 항상 보이는 시계 위치.
  - External: `https://docs.flutter.dev/perf/best-practices` — frequently changing state를 작은 subtree로 격리하는 원칙.
  - Test: `test/home/performance/clock_header_isolation_test.dart` — 회귀/격리 검증 기준.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/home/performance/clock_header_isolation_test.dart`
  - [ ] `flutter analyze --fatal-infos`
  - [ ] `test -f .sisyphus/evidence/task-5-clock-isolation.txt`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Clock tick updates only the time leaf
    Tool: Bash
    Steps: Run clock_header_isolation_test.dart with fake async time progression across multiple ticks.
    Expected: Time text changes; parent header subtree rebuild count stays within the test guard threshold.
    Evidence: .sisyphus/evidence/task-5-clock-isolation.txt

  Scenario: Minute rollover formatting
    Tool: Bash
    Steps: Simulate 09:59 -> 10:00 rollover in the same test file.
    Expected: Display remains HH:mm and no null/late-init errors occur.
    Evidence: .sisyphus/evidence/task-5-clock-rollover.txt
  ```

  **Commit**: YES | Message: `perf(home): 시계 갱신을 leaf subtree로 고립` | Files: `lib/header/component/simple_clock.dart`, `test/home/performance/clock_header_isolation_test.dart`

- [ ] 6. HeaderLayout와 DefaultLayout의 홈 리빌드 전파 축소

  **What to do**: 홈 shell에서 자주 바뀌지 않는 부분과 자주 바뀌는 부분을 분리해 `HeaderLayout`/`DefaultLayout`의 전체 rebuild 폭을 줄인다. `HeaderLayout`은 메시지 감시 범위를 필요한 subtree로만 내리고, `_childList` 재생성 폭을 최소화한다. `DefaultLayout`은 `assignContact()` 이후 전체 shell `setState()` 대신 footer/contact 국소 갱신으로 줄이고, gradient/고정 위젯은 가능한 한 안정적으로 재사용한다.
  **Must NOT do**: 관리자 버튼 표시 정책, 메시지 rotation 정책, footer 기능, editor mode 규칙을 바꾸지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 홈 전체 shell 전파를 줄이되 기능 회귀 위험이 있다.
  - Skills: `[]`
  - Omitted: `["refactor"]` — provider/architecture 전면 교체 금지.

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: 8 | Blocked By: 1,2,5

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/header/header_layout.dart:99-175` — 현재 children 리스트 재생성 및 message subtree 구성.
  - Pattern: `lib/header/header_layout.dart:178-223` — animation/status와 message watch가 결합된 갱신 경로.
  - Pattern: `lib/common/layout/default_layout.dart:80-88` — `assignContact()` 후 post-frame `setState()`.
  - Pattern: `lib/common/layout/default_layout.dart:99-125` — 홈 shell 최상위 구조.
  - Pattern: `lib/common/layout/default_layout.dart:240-307` — footer contact / editor mode 상호작용.
  - Test: `test/common/layout/default_layout_timetable_admin_entry_test.dart:20-118` — editor mode 관련 회귀 기준.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/common/layout/default_layout_timetable_admin_entry_test.dart test/home/performance/clock_header_isolation_test.dart test/home/performance/home_rebuild_guard_test.dart`
  - [ ] `flutter analyze --fatal-infos`
  - [ ] `test -f .sisyphus/evidence/task-6-home-shell-rebuild.txt`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Contact/footer update does not rebuild the whole home shell
    Tool: Bash
    Steps: Run a widget test that completes assignContact-like async update and records rebuild scope.
    Expected: Footer/contact region updates; timetable and multimedia subtree identities remain stable.
    Evidence: .sisyphus/evidence/task-6-home-shell-rebuild.txt

  Scenario: Editor mode entry remains intact
    Tool: Bash
    Steps: Run default_layout_timetable_admin_entry_test.dart after the rebuild-scope reduction.
    Expected: Hidden admin button gating logic still matches prior behavior.
    Evidence: .sisyphus/evidence/task-6-editor-mode-guard.txt
  ```

  **Commit**: YES | Message: `perf(home): 헤더와 홈 shell 리빌드 전파 축소` | Files: `lib/header/header_layout.dart`, `lib/common/layout/default_layout.dart`, related home performance tests

- [ ] 7. MorphContainer의 항상-보이는 paint 비용 완화

  **What to do**: 홈 화면에서 항상 보이는 `MorphContainer` 사용 지점(`HeaderLayout`, 시간표 wrapper, 멀티미디어 wrapper)을 기준으로 Neumorphic paint 비용을 줄인다. 기본 원칙은 전역 교체가 아니라 **홈에서 상시 노출되는 컨테이너만** 대상으로, `const` 가능 요소 재사용, 불필요한 style 객체 재생성 제거, 필요 시 홈 전용 단순 BoxDecoration 분기 추가까지 허용한다. 단, 시각적 인상은 “동일 계열”을 유지해야 한다.
  **Must NOT do**: 앱 전역에서 Neumorphic를 일괄 제거하지 말 것. 홈 외 화면까지 style 변경을 확장하지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: paint cost 감소와 시각적 parity를 함께 판단해야 한다.
  - Skills: `[]`
  - Omitted: `["frontend-ui-ux"]` — 미적 재디자인이 아니라 성능 목적의 제한적 완화다.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 8 | Blocked By: 1

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/common/component/morph_container.dart:46-57` — 현재 Neumorphic style 구성.
  - Pattern: `lib/common/layout/default_layout.dart:186-237` — 홈에서 상시 보이는 MorphContainer 사용 지점.
  - Pattern: `lib/header/header_layout.dart:248-268` — 기본 헤더의 상시 MorphContainer 사용.
  - External: `https://docs.flutter.dev/perf/best-practices` — 페인트/컴포지팅 비용이 큰 subtree 최소화 원칙.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter analyze --fatal-infos`
  - [ ] `flutter test test/home/performance/home_rebuild_guard_test.dart test/common/layout/default_layout_timetable_admin_entry_test.dart`
  - [ ] `test -f .sisyphus/evidence/task-7-morph-container-before-after.txt`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Always-visible home containers preserve layout and visuals
    Tool: Bash
    Steps: Run widget tests for home shell and capture golden-like structural assertions or screenshot evidence if added.
    Expected: Header, timetable wrapper, and multimedia wrapper remain present with no layout regressions.
    Evidence: .sisyphus/evidence/task-7-morph-container-before-after.txt

  Scenario: Optimization is scoped to home path only
    Tool: Bash
    Steps: Search changed files and run related tests to confirm no unrelated screens depend on a removed global style path.
    Expected: Only targeted home-visible uses are altered or branched; unrelated screens still compile and tests pass.
    Evidence: .sisyphus/evidence/task-7-home-only-scope.txt
  ```

  **Commit**: YES | Message: `perf(home): 항상 보이는 MorphContainer 비용 완화` | Files: `lib/common/component/morph_container.dart`, relevant home layout files/tests

- [ ] 8. Android 홈 성능 재계측 및 BlackOverlay 2차 최적화

  **What to do**: Tasks 3-7 완료 후 Task 1과 동일한 Android profile 시나리오를 다시 실행해 `.sisyphus/evidence/task-8-home-idle-after.json`과 `.txt`를 만든다. baseline 대비 개선 폭을 계산하기 위한 `scripts/compare_perf_summary.py`를 추가해 before/after summary를 자동 비교한다. 같은 evidence 절차로 overlay-active 보조 시나리오를 한 번 더 실행하고, 그 시나리오에서만 `BlackoutOverlay`가 여전히 의미 있는 비용 후보로 확인되면 `Ticker`/`Timer`가 전체 widget rebuild로 이어지지 않게 국소 최적화한다. overlay 영향이 미미하면 코드 변경 없이 skip evidence를 남기고 종료한다.
  **Must NOT do**: overlay를 근거 없이 먼저 손대지 말 것. 홈 idle 재계측 없이 완료 처리하지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 재계측, 비교, 조건부 overlay 최적화까지 한 task에서 닫아야 한다.
  - Skills: `[]`
  - Omitted: `["playwright"]` — Android profile evidence가 핵심이다.

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: F1-F4 | Blocked By: 1,2,3,4,5,6,7

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/common/component/black_overlay.dart:35-137` — 현재 60fps ticker + 1초 timer + 전체 setState 경로.
  - Evidence: `.sisyphus/evidence/task-1-home-idle-baseline.json` — 반드시 동일 시나리오와 비교.
  - External: `https://docs.flutter.dev/cookbook/testing/integration/profiling` — timeline summary 후처리 기준.
  - External: `https://docs.flutter.dev/tools/devtools/overview` — frame timing 확인 기준.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `ANDROID_DEVICE_ID="$(flutter devices --machine | python3 - <<'PY'
import json,sys
data=json.load(sys.stdin)
android=[d for d in data if d.get('platform')=='android']
preferred=[d for d in android if d.get('emulator')]
pick=(preferred or android)
print(pick[0]['id'] if pick else '')
PY
)" && test -n "$ANDROID_DEVICE_ID" && flutter drive --profile -d "$ANDROID_DEVICE_ID" --driver integration_test/driver.dart --target integration_test/home_idle_perf_test.dart`
  - [ ] `test -f .sisyphus/evidence/task-8-home-idle-after.json && test -f .sisyphus/evidence/task-8-home-idle-after.txt`
  - [ ] `python3 scripts/compare_perf_summary.py .sisyphus/evidence/task-1-home-idle-baseline.json .sisyphus/evidence/task-8-home-idle-after.json > .sisyphus/evidence/task-8-home-idle-diff.txt`
  - [ ] `test -f .sisyphus/evidence/task-8-home-idle-diff.txt`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Home idle after-profile improves versus baseline
    Tool: Bash
    Steps: Re-run the same Android profile scenario used for baseline; compare before/after summaries with the comparison script.
    Expected: Janky frame count improves by >=30% or build/raster metrics improve by >=20%; diff file states pass.
    Evidence: .sisyphus/evidence/task-8-home-idle-diff.txt

  Scenario: Overlay-active branch is evidence-driven
    Tool: Bash
    Steps: Run overlay-active variant once; if overlay still dominates, execute overlay behavior tests and the profile scenario again; otherwise write explicit skip evidence.
    Expected: Either (a) overlay optimization lands with passing overlay tests, or (b) skip evidence documents why no overlay code change was made.
    Evidence: .sisyphus/evidence/task-8-overlay-evaluation.txt
  ```

  **Commit**: YES | Message: `perf(overlay): 재계측 후 black overlay 부하를 정리` | Files: `.sisyphus/evidence/task-8-*`, `lib/common/component/black_overlay.dart` (if changed), `scripts/compare_perf_summary.py`, related tests

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [ ] F1. Plan Compliance Audit — oracle
- [ ] F2. Code Quality Review — unspecified-high
- [ ] F3. Real Manual QA — unspecified-high (+ playwright if UI)
- [ ] F4. Scope Fidelity Check — deep

## Commit Strategy
- Commit 1: `test(home): Android 홈 성능 베이스라인과 회귀 가드 추가`
- Commit 2: `perf(timetable): 불필요한 subtree 재생성 제거`
- Commit 3: `perf(home): 시계와 헤더 리빌드 범위 축소`
- Commit 4: `perf(home): 레이아웃 및 MorphContainer 비용 완화`
- Commit 5: `perf(overlay): black overlay 부하를 2차 최적화`
- 각 커밋 후 최소 `flutter analyze --fatal-infos` + 해당 task 테스트 + 필요한 profile 검증을 실행한다.

## Success Criteria
- 홈 idle profile evidence가 baseline 대비 개선된다.
- 관리자 모드 진입, 시간표 표시/갱신, 헤더 기본/메시지 표시, 딤 overlay 동작이 회귀하지 않는다.
- 성능 개선 근거와 skip 근거가 모두 `.sisyphus/evidence/`에 남는다.
