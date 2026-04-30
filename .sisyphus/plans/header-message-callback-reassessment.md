# Header/Message Callback 범위 재조정

> **SUPERSEDED** by `.sisyphus/plans/option1-commit-sequencing-remediation.md`
> 
> 이 플랜은 후속 플랜으로 대첸되어 종료되었습니다. 최종 결과는 remediation plan에서 확인하세요.

## TL;DR
> **Summary**: `MessageContainer`와 `HeaderLayout`의 build-time callback을 같은 문제로 취급하지 않는다. 이번 작업은 `MessageContainer`의 build-triggered post-frame scheduling만 제한적으로 정리하고, `HeaderLayout`은 동작 보존을 위한 parity test만 추가한 뒤 production 코드는 유지한다.
> **Deliverables**:
> - `MessageContainer` 자동 스크롤 동작을 고정하는 focused widget tests
> - `HeaderLayout` auto-slide parity smoke test
> - `MessageContainer`의 scroll scheduling을 `build()` 밖으로 이동한 제한적 리팩터
> - `mqtt_manager` cleanup 제외를 명시한 scope guard와 evidence
> **Effort**: Short
> **Parallel**: YES - 2 waves
> **Critical Path**: 1/2 → 3 → 4

## Context
### Original Request
- `MessageContainer`와 `HeaderLayout`에서 build-time callback 예약으로 했던 작업 의도를 먼저 확인하고, 제거해도 되는지 판단해달라.
- `mqtt_manager`의 print문은 큰 문제는 아닐 것 같다.
- 해당 범위 작업이 필요한지, 어디까지 해야 하는지 다시 계획을 세워달라.

### Interview Summary
- 조사 결과 `MessageContainer`의 callback은 “메시지 스크롤이 처음부터 시작하지 않는 오류”와 “메시지 안 흐름 버그”를 막기 위해 도입된 흔적이 있다.
- `MessageContainer`는 post-layout 시점에 `maxScrollExtent` 계산이 필요하므로 callback 자체를 없애는 것이 목적이 아니다. 문제는 `build()`에서 재예약하는 방식이다.
- `HeaderLayout`의 startup MQTT publish callback은 안전한 `initState` 계열 1회성 usage다.
- `HeaderLayout`의 child-count 대응 callback은 build 중 직접 상태를 바꾸지 않기 위한 guarded workaround로 보이며, 지금 당장 production 리팩터 대상으로 확정할 근거가 부족하다.
- `mqtt_manager` print cleanup은 이번 계획의 immediate scope에서 제외한다.

### Metis Review (gaps addressed)
- 이번 계획은 **MessageContainer-first**로 좁히고, `HeaderLayout` production 코드 변경은 금지한다.
- `MessageContainer`는 텍스트 변경뿐 아니라 **constraint-only 변경**도 검증해야 한다.
- 회귀 위험이 큰 만큼 테스트를 먼저 추가하고, 원래 버그 의도(처음부터 시작, overflow일 때만 스크롤, 메시지 변경 시 reset)를 고정한다.
- `mqtt_manager` cleanup, repo-wide callback cleanup, deprecated file 삭제는 scope creep로 봉인한다.

## Work Objectives
### Core Objective
`MessageContainer`의 자동 스크롤 동작을 유지하면서, build-triggered post-frame scheduling만 제거한다. `HeaderLayout`은 테스트로 parity를 보장하되 production 로직은 이번 작업에서 변경하지 않는다.

### Deliverables
- `test/header/component/message_container_test.dart`
- `test/header/header_layout_test.dart`
- `MessageContainer` lifecycle/size-aware one-shot scheduling 리팩터
- focused evidence logs in `.sisyphus/evidence/`

### Definition of Done (verifiable conditions with commands)
- `flutter test test/header/component/message_container_test.dart`
- `flutter test test/header/header_layout_test.dart`
- `flutter analyze --fatal-infos`
- `grep -n "_startScrollingIfNeeded();" lib/header/component/message_container.dart` returns no matches inside `build()`
- `grep -n "addPostFrameCallback" lib/header/header_layout.dart` still shows the existing guarded usages only

### Must Have
- 긴 메시지는 초기 offset `0.0`에서 시작하고, delay 후 실제로 스크롤한다.
- overflow가 없는 짧은 메시지는 스크롤하지 않는다.
- 메시지 text가 변경되면 scroll start position이 reset된다.
- **같은 메시지라도 width/constraint가 바뀌면** overflow 여부에 맞게 동작을 다시 계산한다.
- `HeaderLayout` auto-slide는 기존처럼 메시지 A → B로 넘어가는 parity를 유지한다.
- `HeaderLayout` production 코드와 `mqtt_manager.dart`는 이번 작업에서 수정하지 않는다.

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- `HeaderLayout` startup MQTT publish callback 제거 금지
- `HeaderLayout` child-count callback production 리팩터 금지
- `mqtt_manager.dart` print cleanup 포함 금지
- repo-wide `addPostFrameCallback` cleanup 금지
- `message_container_dep.dart` 삭제/정리 금지
- “앱 전체 성능 해결” 같은 과장된 완료 기준 금지

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: tests-after + focused widget regression
- QA policy: message scroll happy path + no-overflow + text-change + constraint-change + dispose safety를 모두 포함한다.
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`
- Scope policy: `git diff --name-only`에서 production 변경은 `lib/header/component/message_container.dart`만 허용한다. `HeaderLayout`은 테스트 파일만 변경 가능하다.

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.

Wave 1: focused characterization tests 추가 (Tasks 1-2)

Wave 2: `MessageContainer` 제한적 리팩터 + focused verification (Tasks 3-4)

### Dependency Matrix (full, all tasks)
| Task | Depends On |
|---|---|
| 1 | - |
| 2 | - |
| 3 | 1, 2 |
| 4 | 3 |

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 2 tasks → `unspecified-high`, `quick`
- Wave 2 → 2 tasks → `unspecified-high`, `quick`
- Final Verification → 4 tasks in parallel

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [x] 1. `MessageContainer` 자동 스크롤 특성 테스트를 먼저 고정

  **What to do**: `test/header/component/message_container_test.dart`를 새로 추가한다. 테스트는 반드시 (a) 짧은 메시지는 스크롤하지 않음, (b) 긴 메시지는 처음 `0.0`에서 시작하고 대기 후 스크롤 시작, (c) 긴 메시지 A에서 스크롤이 시작된 뒤 긴 메시지 B로 바꾸면 다시 `0.0`으로 reset 후 스크롤을 재시작, (d) 위젯 dispose 후 예외 없음 을 검증한다. 메시지 데이터는 구체 문자열과 고정 크기 constraint를 사용한다.
  **Must NOT do**: production 코드 변경을 먼저 하지 말 것. golden test나 수동 확인에 의존하지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 비동기 scroll timing과 dispose safety를 함께 고정해야 한다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 3 | Blocked By: -

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/header/component/message_container.dart:43-84` — 현재 scroll scheduling과 build 호출 위치
  - Pattern: `lib/header/model/message.dart:11-53` — 테스트용 메시지 모델 생성 계약
  - History: `git show 815467f -- lib/header/component/message_container.dart` — “메시지 스크롤이 처음부터 시작하지 않는 오류 수정” 의도
  - History: `git show 8f06c71 -- lib/header/component/message_container.dart` — Stateful 전환 후 “메세지 안 흐름 버그 수정” 의도
  - External: `https://api.flutter.dev/flutter/widgets/WidgetsBinding/drawFrame.html` — build/layout/post-frame 순서

  **Acceptance Criteria** (agent-executable only):
  - [ ] `test -f test/header/component/message_container_test.dart`
  - [ ] `flutter test test/header/component/message_container_test.dart`
  - [ ] test output proves: short message stays at `pixels == 0.0`, long message eventually reaches `pixels > 0.0`, changing message resets to `pixels == 0.0` before moving again

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: non-overflowing message does not scroll
    Tool: Bash
    Steps: run `flutter test test/header/component/message_container_test.dart --plain-name "non-overflowing message does not scroll"`
    Expected: test exits 0 and asserts the scroll position remains exactly 0.0 with maxScrollExtent 0.0
    Evidence: .sisyphus/evidence/task-1-message-no-overflow.log

  Scenario: overflowing message starts at zero then scrolls
    Tool: Bash
    Steps: run `flutter test test/header/component/message_container_test.dart --plain-name "overflowing message starts at zero then scrolls"`
    Expected: test exits 0 and proves initial pixels == 0.0 before later pixels > 0.0
    Evidence: .sisyphus/evidence/task-1-message-overflow.log
  ```

  **Commit**: YES | Message: `test(header): capture message scroll behavior` | Files: `test/header/component/message_container_test.dart`

- [x] 2. `HeaderLayout`는 production 변경 없이 auto-slide parity smoke test만 추가

  **What to do**: `test/header/header_layout_test.dart`를 새로 추가해, 메시지 2개(`Header A`, `Header B`)가 있는 상태에서 auto-slide 주기 후 표시 내용이 바뀌는지 확인하는 parity smoke test를 만든다. 이 테스트는 `HeaderLayout` production 코드를 바꾸기 위한 것이 아니라, `MessageContainer` 리팩터가 헤더 동작을 깨지 않음을 보장하기 위한 회귀 가드다. startup MQTT publish는 mock/stub provider로 흡수하고, 이 task에서는 `HeaderLayout` source 수정 금지다.
  **Must NOT do**: `HeaderLayout` production 로직을 정리하거나 callback을 제거하지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: smoke parity test 추가가 핵심이며 production 변경이 없다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 3 | Blocked By: -

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/header/header_layout.dart:75-90` — auto-slide timer 시작/중지
  - Pattern: `lib/header/header_layout.dart:178-207` — animation status와 child-count 동작
  - API/Type: `lib/header/message_controller.dart` — provider/watch source
  - API/Type: `lib/header/model/message.dart:11-53` — 메시지 생성 계약
  - External: `https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addPostFrameCallback.html` — one-shot callback semantics

  **Acceptance Criteria** (agent-executable only):
  - [ ] `test -f test/header/header_layout_test.dart`
  - [ ] `flutter test test/header/header_layout_test.dart`
  - [ ] test output proves `Header A` visible initially and `Header B` becomes visible after advancing the configured slide interval

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: header auto-slide parity remains intact
    Tool: Bash
    Steps: run `flutter test test/header/header_layout_test.dart --plain-name "auto-slide rotates from Header A to Header B"`
    Expected: test exits 0 and confirms the visible message changes after the timer/animation window
    Evidence: .sisyphus/evidence/task-2-header-parity.log

  Scenario: header smoke test does not require production refactor
    Tool: Bash
    Steps: run `git diff --name-only` after implementing this task
    Expected: changed files are limited to `test/header/header_layout_test.dart` (and helper test utilities if newly added)
    Evidence: .sisyphus/evidence/task-2-header-scope.log
  ```

  **Commit**: YES | Message: `test(header): add header auto-slide parity smoke test` | Files: `test/header/header_layout_test.dart`

- [x] 3. `MessageContainer`의 scheduling을 `build()` 밖으로 이동하되 post-layout 성질은 유지

  **What to do**: `lib/header/component/message_container.dart`만 수정한다. 정확한 구현 방식은 다음으로 고정한다: (a) `build()`에서 `_startScrollingIfNeeded()` 직접 호출을 제거, (b) `_scheduleScrollIfNeeded()`와 `_runScrollIfNeeded()`로 역할 분리, (c) `_scrollWorkQueued` boolean을 추가해 pending post-frame work가 중복 등록되지 않게 함, (d) 초기 mount 시 `initState()`에서 한 번 예약, (e) `didUpdateWidget`에서는 `messageData.content` 또는 `isFading` 변화 시 reset/재예약, (f) constraint-only 변경 대응을 위해 scroll 영역을 `SizeChangedLayoutNotifier` + `NotificationListener<SizeChangedLayoutNotification>`로 감싸고 size change 시 reset/재예약, (g) 실제 `jumpTo(0)` 및 `maxScrollExtent` 확인은 post-frame 콜백 내부에서만 수행한다. scroll delay/duration(3초/5초)은 유지한다.
  **Must NOT do**: `HeaderLayout`이나 `message_container_dep.dart`를 수정하지 말 것. `Timer.periodic` 기반 새 설계로 갈아엎지 말 것. UX 타이밍(3초 대기, 5초 이동)을 바꾸지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: lifecycle + size-change + async scroll 중복 예약을 함께 정리해야 한다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: 4 | Blocked By: 1, 2

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/header/component/message_container.dart:43-84` — 현재 build-triggered scheduling 제거 대상
  - Pattern: `lib/header/component/message_container.dart:67-73` — 현재 `didUpdateWidget` hook
  - History: `git show 848c673 -- lib/header/component/message_container.dart` — Stateful 전환 및 scroll controller 관리 의도
  - External: `https://api.flutter.dev/flutter/widgets/SizeChangedLayoutNotifier-class.html` — size change notification
  - External: `https://api.flutter.dev/flutter/widgets/WidgetsBinding/drawFrame.html` — post-layout 실행 시점
  - Test: `test/header/component/message_container_test.dart` — 반드시 이 테스트를 green으로 만드는 방식으로만 구현

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/header/component/message_container_test.dart`
  - [ ] `flutter test test/header/header_layout_test.dart`
  - [ ] `flutter analyze --fatal-infos`
  - [ ] `grep -n "_startScrollingIfNeeded();" lib/header/component/message_container.dart` returns no matches
  - [ ] `grep -n "WidgetsBinding.instance.addPostFrameCallback" lib/header/component/message_container.dart` shows callback registration only inside scheduling helpers, not from `build()`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: same message, narrower width, scroll recalculates without build-triggered scheduling
    Tool: Bash
    Steps: run `flutter test test/header/component/message_container_test.dart --plain-name "constraint-only change recalculates scrolling"`
    Expected: test exits 0 and proves a width change alone can cause scrolling behavior to re-evaluate
    Evidence: .sisyphus/evidence/task-3-message-constraint-change.log

  Scenario: dispose after pending post-frame work does not throw
    Tool: Bash
    Steps: run `flutter test test/header/component/message_container_test.dart --plain-name "disposing after scheduling does not throw"`
    Expected: test exits 0 and `tester.takeException()` remains null
    Evidence: .sisyphus/evidence/task-3-message-dispose.log
  ```

  **Commit**: YES | Message: `refactor(header): move message scroll scheduling out of build` | Files: `lib/header/component/message_container.dart`, `test/header/component/message_container_test.dart`

- [x] 4. focused verification으로 scope를 닫고 `HeaderLayout`/`mqtt_manager` 무변경을 증명

  **What to do**: focused verification만 수행한다. `git diff --name-only HEAD~1..HEAD` 또는 작업 트리 diff를 이용해 production 변경이 `lib/header/component/message_container.dart`로만 제한됐는지 확인하고, `lib/header/header_layout.dart`와 `lib/common/util/network/mqtt_manager.dart`가 이번 작업에서 수정되지 않았음을 evidence로 남긴다. 전체 검증은 header-focused test 2개와 analyzer까지만 수행하고, 이번 플랜에서 full-suite 확장은 하지 않는다.
  **Must NOT do**: 이 task에서 새 수정 작업을 끼워 넣지 말 것. `mqtt_manager` cleanup을 슬쩍 포함하지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 범위 검증과 evidence 정리가 중심이다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: Final only | Blocked By: 3

  **References** (executor has NO interview context — be exhaustive):
  - Plan: `.sisyphus/plans/header-message-callback-reassessment.md` — Must Have / Must NOT Have 기준
  - Target: `lib/header/component/message_container.dart`
  - Guard files: `lib/header/header_layout.dart`, `lib/common/util/network/mqtt_manager.dart`

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/header/component/message_container_test.dart test/header/header_layout_test.dart`
  - [ ] `flutter analyze --fatal-infos`
  - [ ] `git diff --name-only` shows only `lib/header/component/message_container.dart`, `test/header/component/message_container_test.dart`, `test/header/header_layout_test.dart`, and evidence files
  - [ ] `git diff --name-only | grep "lib/common/util/network/mqtt_manager.dart"` returns no matches
  - [ ] `git diff --name-only | grep "lib/header/header_layout.dart"` returns no matches

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: focused verification passes without widening scope
    Tool: Bash
    Steps: run `flutter test test/header/component/message_container_test.dart test/header/header_layout_test.dart` and `flutter analyze --fatal-infos`
    Expected: both commands exit 0
    Evidence: .sisyphus/evidence/task-4-focused-verification.log

  Scenario: scope guard confirms mqtt and HeaderLayout production files untouched
    Tool: Bash
    Steps: run `git diff --name-only`
    Expected: no matches for `lib/common/util/network/mqtt_manager.dart` or `lib/header/header_layout.dart`
    Evidence: .sisyphus/evidence/task-4-scope-guard.log
  ```

  **Commit**: YES | Message: `test(scope): verify callback refactor stayed narrow` | Files: `.sisyphus/evidence/task-4-*`

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [x] F1. Plan Compliance Audit — oracle (REJECT — known issues accepted via remediation)
- [x] F2. Code Quality Review — unspecified-high (completed/superseded by remediation)
- [x] F3. Real Manual QA — unspecified-high (completed/superseded by remediation)
- [x] F4. Scope Fidelity Check — deep (completed/superseded by remediation)

## Commit Strategy
- Commit 1: `test(header): capture message scroll behavior`
- Commit 2: `test(header): add header auto-slide parity smoke test`
- Commit 3: `refactor(header): move message scroll scheduling out of build`
- Commit 4: `test(scope): verify callback refactor stayed narrow`

## Success Criteria
- `MessageContainer`는 build-triggered scheduling 없이도 기존 marquee 동작을 유지한다.
- `HeaderLayout` auto-slide parity는 테스트로 유지됨이 증명된다.
- `HeaderLayout` production code와 `mqtt_manager.dart`는 이번 작업에서 변경되지 않는다.
- focused tests + analyzer가 모두 통과한다.
