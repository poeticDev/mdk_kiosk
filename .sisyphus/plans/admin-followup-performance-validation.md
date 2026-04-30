# Admin Follow-up Performance & Validation Fixes

## TL;DR
> **Summary**: 관리자 라우트 복귀 문제는 해결됐지만, 남은 후속 이슈 두 가지—강의명 검증 실패와 앱 전반의 체감 성능 저하—를 좁은 범위로 정리한다. 먼저 `LectureFormDialog`의 검증을 실제 입력값과 단일 소스로 맞추고, 이어서 `SplashScreen`, `MessageContainer`, `HeaderLayout`, `mqtt_manager.dart`의 치명적 핫스팟만 정리한다.
> **Deliverables**:
> - hidden `TextFormField` 제거 및 live lecture-name validation 복구
> - `CustomTextFormField`에 additive validator 경로 추가
> - placeholder 테스트 제거 및 lecture form 회귀 테스트 강화
> - `SplashScreen` build-time async setState 제거
> - `MessageContainer` per-build post-frame callback 제거
> - `HeaderLayout` build-time state cascade 정리
> - MQTT hot-path log spam 정리
> **Effort**: Medium
> **Parallel**: YES - 2 waves
> **Critical Path**: 1 → 2 → 3 → 4/5

## Context
### Original Request
- 앱 전체가 굉장히 느린 걸로 봐서, 어디선가 메인 스레드에 여전히 과도한 부하를 주고 있는 거 같아.
- '강의명 필수 검증을 위한 숨겨진 TextFormField'가 현재 코드에 있어. 실제 강의명 입력 필드에서 입력 후에도, 이 TextFormField가 여전히 initialValue를 값으로 가지고 있어서 검증에 실패하고 있어.

### Interview Summary
- 이전 관리자 화면 자동 복귀 문제는 해결되었다.
- 사용자는 검증 버그를 먼저 해결하고, 성능은 critical 범위만 정리하기를 원한다.
- 선택된 성능 범위는 `SplashScreen`, `MessageContainer`, `HeaderLayout`, `mqtt_manager.dart` + log spam cleanup이다.
- 테스트 전략은 `tests-after`로 고정한다.

### Metis Review (gaps addressed)
- `tests-after`를 공식 전략으로 명시해 TDD 혼선을 제거한다.
- `CustomTextFormField` 변경은 additive/backward-compatible로 제한한다.
- 성능 작업은 “글로벌 성능 해결”이 아니라 “확인된 critical 핫스팟 제거”로 표현한다.
- placeholder 테스트(`expect(true, isTrue)`) 제거를 반드시 포함한다.
- MQTT는 로깅만 정리하고, 연결/구독/파싱 동작은 바꾸지 않는다.

## Work Objectives
### Core Objective
강의명 검증을 실제 입력값 기준으로 복구하고, 앱 체감 성능을 해치는 가장 강한 UI-thread / rebuild / log-spam 핫스팟만 좁은 범위로 제거한다.

### Deliverables
- `LectureFormDialog`에서 hidden validator field 제거
- visible `CustomTextFormField`에 validator 연결
- 강의명 create/edit/whitespace 회귀 테스트 강화
- `SplashScreen`의 build-time async setState 제거 및 중복 navigation/log 정리
- `MessageContainer`의 per-build post-frame scheduling 제거
- `HeaderLayout`의 build-time state mutation / listener churn 제거
- `mqtt_manager.dart`의 raw print hot-path 제거 또는 debug-gated 처리

### Definition of Done (verifiable conditions with commands)
- `flutter test test/timetable/admin/lecture_form_dialog_test.dart`
- `flutter test test/common/view/splash_screen_test.dart`
- `flutter test test/header/component/message_container_test.dart`
- `flutter test test/header/header_layout_test.dart`
- `flutter test test/common/util/network/mqtt_manager_test.dart`
- `flutter analyze --fatal-infos`
- `flutter test`

### Must Have
- 강의명 빈값/공백 검증은 실제 visible 입력값 기준으로 동작
- create mode에서 유효한 강의명 입력 시 저장 콜백이 정확히 1회 호출
- edit mode에서 기존 강의명이 정상 초기화되고, 비우면 검증 에러가 표시됨
- `SplashScreen`에서 `build()` 내부 async `setState`가 제거됨
- `MessageContainer`는 rebuild마다 새로운 scroll post-frame callback을 누적 등록하지 않음
- `HeaderLayout`는 `build()` 중 `setState`를 호출하지 않음
- `mqtt_manager.dart`는 고빈도 message/connection hot path에서 raw `print(`를 남기지 않음

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- 새로운 로깅 프레임워크 도입 금지
- Header/Message architecture 전면 재설계 금지
- MQTT 파싱/구독/재연결 정책 변경 금지
- `CustomTextFormField`의 기존 호출부를 깨는 breaking API 변경 금지
- 벤치마크 없이 “앱 전체 성능 문제 해결” 같은 과장된 완료 기준 금지
- 이번 범위 밖 타이머/print cleanup 확장 금지

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: tests-after + focused regression + full suite
- QA policy: Every task includes binary widget/static verification
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.

Wave 1: field API impact mapping + lecture validation fix

Wave 2: splash hot-path cleanup, header/message scheduling cleanup, MQTT log cleanup

### Dependency Matrix (full, all tasks)
| Task | Depends On |
|---|---|
| 1 | - |
| 2 | 1 |
| 3 | 2 |
| 4 | 2 |
| 5 | 2 |

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 2 tasks → unspecified-high / quick
- Wave 2 → 3 tasks → unspecified-high
- Final Verification → 4 tasks in parallel

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [x] 1. `CustomTextFormField` 영향 범위를 매핑하고 additive validator 경로를 설계/적용

  **What to do**: `CustomTextFormField`의 모든 호출부를 확인한 뒤, 기존 API를 깨지 않는 additive 방식으로 `validator` 전달 경로만 추가한다. 이번 작업에서는 `controller` 외부 노출은 하지 않고, 최소 변경 원칙으로 `lecture_form_dialog.dart`가 visible field에서 직접 `Form.validate()`에 참여할 수 있게 만든다.
  **Must NOT do**: `CustomTextFormField`를 대규모 폼 프레임워크로 확장하지 말 것. 기존 필수 파라미터/호출부를 깨지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 공용 입력 컴포넌트 blast radius 점검이 필요함
  - Skills: `[]` — 공용 컴포넌트/호출부 정적 점검 위주
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 2 | Blocked By: -

  **References**:
  - Pattern: `lib/common/component/custom_text_form_field.dart:4-95` — 현재 내부 controller 생성 구조와 확장 지점
  - Pattern: `lib/common/component/editor_dialog.dart:102-218` — 기존 호출부가 모두 `initialValue` + `onChanged` 패턴을 사용함
  - API/Type: `lib/timetable/admin/lecture_form_dialog.dart:139-145` — visible lecture-name field의 현재 사용 방식
  - Test: `test/timetable/admin/lecture_form_dialog_test.dart:54-90` — 필수 입력 검증 패턴

  **Acceptance Criteria**:
  - [ ] `CustomTextFormField`가 additive 방식으로 validator를 받을 수 있다.
  - [ ] 기존 `editor_dialog.dart` 호출부는 수정 없이 계속 컴파일/동작한다.
  - [ ] `flutter analyze --fatal-infos`에서 새 이슈가 추가되지 않는다.

  **QA Scenarios**:
  ```
  Scenario: additive validator API does not break existing callers
    Tool: Bash
    Steps: run `flutter analyze --fatal-infos`
    Expected: analyzer exits 0 and reports no new issues caused by `CustomTextFormField` changes
    Evidence: .sisyphus/evidence/task-1-custom-text-field-analyze.log

  Scenario: existing caller pattern remains valid
    Tool: Bash
    Steps: run `flutter test test/timetable/admin/lecture_form_dialog_test.dart`
    Expected: test command passes with no compile/runtime error from legacy `CustomTextFormField` call sites
    Evidence: .sisyphus/evidence/task-1-custom-text-field-tests.log
  ```

  **Commit**: YES | Message: `refactor(form): add validator path to custom text field` | Files: `lib/common/component/custom_text_form_field.dart`

- [x] 2. `LectureFormDialog`의 hidden validator field를 제거하고 live lecture-name validation으로 교체

  **What to do**: `lecture_form_dialog.dart`에서 hidden `TextFormField`를 삭제하고, visible `CustomTextFormField`에 lecture-name required validator를 직접 연결한다. 검증은 `trim()` 기준으로 empty/whitespace를 모두 실패 처리한다. `lecture_form_dialog_test.dart`의 placeholder 성공 테스트를 실검증 테스트로 교체하고 create/edit/whitespace 케이스를 모두 고정한다.
  **Must NOT do**: hidden field를 controller 공유 방식으로 유지하지 말 것. 성공 테스트에 placeholder assertion을 남기지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 폼 상태/검증/테스트를 함께 재구성해야 함
  - Skills: `[]` — 기존 패턴과 회귀 테스트 직접 구성
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 3,4,5 | Blocked By: 1

  **References**:
  - Pattern: `lib/timetable/admin/lecture_form_dialog.dart:97-122` — save flow와 validate 진입점
  - Pattern: `lib/timetable/admin/lecture_form_dialog.dart:139-164` — visible field + hidden field의 현재 충돌 구조
  - Pattern: `lib/common/component/custom_text_form_field.dart:67-74` — visible TextFormField에 validator 연결 필요
  - Test: `test/timetable/admin/lecture_form_dialog_test.dart:92-146` — 현재 placeholder 성공 테스트 제거 대상
  - Test: `test/timetable/admin/lecture_form_dialog_test.dart:231-275` — edit mode prefill 확인 패턴
  - External: `https://api.flutter.dev/flutter/material/TextFormField-class.html` — `initialValue`는 one-shot이며 controller가 live source of truth임

  **Acceptance Criteria**:
  - [ ] 빈 강의명과 공백-only 강의명은 저장되지 않고 정확한 에러 문구를 표시한다.
  - [ ] 유효한 강의명 입력 시 저장 콜백이 정확히 1회 호출되고 dialog가 닫힌다.
  - [ ] edit mode에서 기존 강의명은 표시되고, 비우면 동일한 에러 문구가 표시된다.
  - [ ] `test/timetable/admin/lecture_form_dialog_test.dart`에 placeholder assertion이 남아 있지 않다.

  **QA Scenarios**:
  ```
  Scenario: valid lecture name saves successfully
    Tool: Bash
    Steps: run `flutter test test/timetable/admin/lecture_form_dialog_test.dart`
    Expected: test suite includes a success-path assertion that save callback receives `lectureName == '테스트 강의'` and all tests pass
    Evidence: .sisyphus/evidence/task-2-lecture-form-success.log

  Scenario: empty or whitespace-only lecture name is rejected
    Tool: Bash
    Steps: run `flutter test test/timetable/admin/lecture_form_dialog_test.dart`
    Expected: test suite proves the dialog remains open, save callback is not called, and validation message `강의명은 필수 입력 항목입니다.` is shown
    Evidence: .sisyphus/evidence/task-2-lecture-form-validation.log
  ```

  **Commit**: YES | Message: `fix(admin): validate lecture name from visible input` | Files: `lib/timetable/admin/lecture_form_dialog.dart`, `test/timetable/admin/lecture_form_dialog_test.dart`

- [x] 3. `SplashScreen`의 build-time async state mutation과 hot-path logging을 제거

  **What to do**: `SplashScreen`에서 `build()` 내부 `setState(() async { ... })` 패턴을 제거하고, loading wait는 `_onSplashing()`으로 이동한다. navigation은 `_hasNavigated` 같은 one-shot guard를 둔 명시적 lifecycle 경로로만 실행한다. `StreamBuilder` 내부 hot-path `print('snapshot.data...')`는 완전히 제거한다. 중복 navigation guard는 유지하되, build-time navigation scheduling이 반복되지 않게 한다.
  **Must NOT do**: splash routing semantics(`/`, `/reinit`, `/splash`)를 바꾸지 말 것. arbitrary delay 추가로 문제를 숨기지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: lifecycle / navigation / build-loop 정리가 필요함
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: Final only | Blocked By: 2

  **References**:
  - Pattern: `lib/common/view/splash_screen.dart:72-107` — post-frame navigation + build-time async setState + snapshot log
  - Test Pattern: `test/common/util/route/router_timetable_admin_test.dart:74-117` — route-focused regression 테스트 스타일

  **Acceptance Criteria**:
  - [ ] `lib/common/view/splash_screen.dart`에 `setState(() async` 패턴이 존재하지 않는다.
  - [ ] splash completion 후 navigation scheduling은 한 번만 발생한다.
  - [ ] splash hot path에서 raw snapshot print가 남아 있지 않다.

  **QA Scenarios**:
  ```
  Scenario: splash hot path no longer mutates state from build
    Tool: Bash
    Steps: run `grep -n "setState\(\(\) async" lib/common/view/splash_screen.dart`
    Expected: no matches
    Evidence: .sisyphus/evidence/task-3-splash-static-check.txt

  Scenario: splash focused regression passes
    Tool: Bash
    Steps: run `flutter test test/common/view/splash_screen_test.dart`
    Expected: test command passes and proves navigation scheduling occurs without build-loop side effects
    Evidence: .sisyphus/evidence/task-3-splash-tests.log
  ```

  **Commit**: YES | Message: `fix(splash): remove build-time async state mutation` | Files: `lib/common/view/splash_screen.dart`, `test/common/view/splash_screen_test.dart`

- [x] 4. `MessageContainer`와 `HeaderLayout`의 per-build callback / build-time state cascade를 정리

  **What to do**: `MessageContainer`에서 `build()`마다 `_startScrollingIfNeeded()`가 `addPostFrameCallback`를 등록하는 구조를 제거하고, 스크롤 예약은 `didUpdateWidget` 기반의 state-transition 경로(`isFading: true -> false`, message content/key 변경 시)에만 수행한다. `HeaderLayout`에서는 child count 변화에 대한 auto-slide 재설정을 전용 메서드로 분리하고, 그 메서드는 build 밖에서만 호출되게 만든다. listener 등록/해제와 timer 시작/중지는 중복 없이 단일 경로로 관리한다. 메시지 스크롤 동작과 헤더 자동 슬라이드는 유지하되, rebuild마다 새로운 callback/listener/timer가 쌓이지 않게 한다.
  **Must NOT do**: 헤더 UX 타이밍을 전면 재설계하지 말 것. Message 모델/Provider 구조를 바꾸지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: animation + scroll callback + provider rebuild 상호작용이 있음
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: Final only | Blocked By: 2

  **References**:
  - Pattern: `lib/header/component/message_container.dart:54-73` — build마다 post-frame scroll 예약
  - Pattern: `lib/header/header_layout.dart:182-220` — animation status setState cascade + build-time reconfiguration
  - API/Type: `lib/header/message_controller.dart` — 메시지 provider/watch source

  **Acceptance Criteria**:
  - [ ] `MessageContainer.build()`는 매 rebuild마다 새로운 `addPostFrameCallback`를 예약하지 않는다.
  - [ ] `HeaderLayout.build()`는 `setState`를 직접 호출하지 않는다.
  - [ ] header/message 동작 회귀 테스트가 통과한다.

  **QA Scenarios**:
  ```
  Scenario: repeated rebuilds do not queue duplicate message scroll work
    Tool: Bash
    Steps: run `flutter test test/header/component/message_container_test.dart`
    Expected: test passes and proves scroll scheduling is one-time/per-state-change rather than per-build
    Evidence: .sisyphus/evidence/task-4-message-container-tests.log

  Scenario: header rebuild path no longer mutates state from build
    Tool: Bash
    Steps: run `flutter test test/header/header_layout_test.dart`
    Expected: test passes and proves child-count changes / animation transitions do not rely on build-time `setState`
    Evidence: .sisyphus/evidence/task-4-header-layout-tests.log
  ```

  **Commit**: YES | Message: `fix(header): stop per-build callback and state churn` | Files: `lib/header/component/message_container.dart`, `lib/header/header_layout.dart`, `test/header/component/message_container_test.dart`, `test/header/header_layout_test.dart`

- [x] 5. `mqtt_manager.dart`의 hot-path raw print를 제거하고 focused regression으로 고정

  **What to do**: `mqtt_manager.dart`에서 payload/dataMap/message/media 관련 per-message raw `print(`는 완전히 제거한다. connection/subscription/retry lifecycle 로그가 꼭 필요하면 `kDebugMode` + `debugPrint`로만 남긴다. 로깅 정리는 `mqtt_manager.dart`에 한정하고, MQTT 연결/구독/재시도 로직 자체는 건드리지 않는다. focused 테스트와 정적 검사로 raw `print(` 부재를 고정한다.
  **Must NOT do**: logging abstraction 신규 도입 금지. MQTT payload 처리 흐름 변경 금지.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 범위가 파일 1개와 focused 검증으로 좁음
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: Final only | Blocked By: 2

  **References**:
  - Pattern: `lib/common/util/network/mqtt_manager.dart:63-117` — payload/dataMap/message/media hot-path print
  - Pattern: `lib/common/util/network/mqtt_manager.dart:270-319` — listen/connection/subscription ping-pong print
  - Pattern: `lib/common/util/network/mqtt_manager.dart:381-386` — retry print

  **Acceptance Criteria**:
  - [ ] `mqtt_manager.dart`에 hot-path raw `print(`가 남아 있지 않다.
  - [ ] MQTT 관련 focused regression이 통과한다.
  - [ ] analyzer/test가 기존 MQTT 동작을 깨지 않았음을 보장한다.

  **QA Scenarios**:
  ```
  Scenario: mqtt hot path no longer uses raw print
    Tool: Bash
    Steps: run `grep -n "print(" lib/common/util/network/mqtt_manager.dart`
    Expected: no matches, or only explicitly allowed debug-gated/log-safe lines documented in task output
    Evidence: .sisyphus/evidence/task-5-mqtt-static-check.txt

  Scenario: mqtt focused regression passes
    Tool: Bash
    Steps: run `flutter test test/common/util/network/mqtt_manager_test.dart`
    Expected: test command passes without changing MQTT functional behavior
    Evidence: .sisyphus/evidence/task-5-mqtt-tests.log
  ```

  **Commit**: YES | Message: `chore(mqtt): remove hot-path log spam` | Files: `lib/common/util/network/mqtt_manager.dart`, `test/common/util/network/mqtt_manager_test.dart`

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [ ] F1. Plan Compliance Audit — oracle

  **What to do**: oracle에게 플랜과 최종 diff를 비교시켜 validation fix + critical hotspot cleanup만 수행됐는지 검토시킨다.
  **Acceptance Criteria**:
  - [ ] oracle가 `plan-compliant` verdict를 반환한다.
  **QA Scenario**:
  ```
  Scenario: implementation matches validation + critical-hotspot plan
    Tool: task(oracle)
    Steps: review `.sisyphus/plans/admin-followup-performance-validation.md`, final diff, and executed test outputs; compare implementation against Tasks 1-5 and all guardrails
    Expected: oracle approves or returns a bounded remediation list
    Evidence: .sisyphus/evidence/f1-plan-compliance.md
  ```

- [ ] F2. Code Quality Review — unspecified-high

  **What to do**: 코드 리뷰 에이전트가 validator wiring, reusable field blast radius, splash/header/message lifecycle, MQTT logging cleanup 품질을 검토한다.
  **Acceptance Criteria**:
  - [ ] high-severity 이슈 0건으로 승인한다.
  **QA Scenario**:
  ```
  Scenario: validation and performance cleanup quality review
    Tool: task(category="unspecified-high")
    Steps: inspect final code changes focusing on validation correctness, lifecycle safety, callback/listener churn, and log cleanup scope
    Expected: reviewer returns APPROVED or a severity-tagged fix list; completion requires no high-severity issue
    Evidence: .sisyphus/evidence/f2-code-quality.md
  ```

- [ ] F3. Real Manual QA — unspecified-high

  **What to do**: 에이전트가 앱을 실행하거나 widget-driven smoke QA로 lecture dialog create/edit validation과 splash/header/message 주요 동작을 검증한다.
  **Acceptance Criteria**:
  - [ ] `flutter analyze --fatal-infos`
  - [ ] `flutter test`
  - [ ] lecture dialog save/fail 동작이 smoke QA를 통과한다.
  **QA Scenario**:
  ```
  Scenario: lecture dialog and critical hotspot smoke QA
    Tool: Bash
    Steps: run `flutter analyze --fatal-infos`, `flutter test`, then verify lecture dialog empty/valid/edit flows and confirm no immediate rebuild-loop/log-spam regressions in focused outputs
    Expected: commands exit 0, lecture dialog behavior is correct, and no targeted hotspot regression is observed
    Evidence: .sisyphus/evidence/f3-manual-qa.md
  ```

- [ ] F4. Scope Fidelity Check — deep

  **What to do**: deep reviewer가 이번 변경이 selected critical 범위를 넘지 않았는지 점검한다. 특히 broad performance refactor, logging framework 도입, MQTT behavior change 여부를 확인한다.
  **Acceptance Criteria**:
  - [ ] deep reviewer가 `scope-clean` verdict를 반환한다.
  **QA Scenario**:
  ```
  Scenario: no broad refactor beyond selected critical hotspots
    Tool: task(category="deep")
    Steps: compare final code and behavior against Must Have / Must NOT Have; flag any broad architecture refactor, logging framework addition, MQTT behavior change, or unrelated cleanup expansion
    Expected: reviewer confirms only approved scope was implemented, or returns a concrete remediation list
    Evidence: .sisyphus/evidence/f4-scope-fidelity.md
  ```

## Commit Strategy
- Commit 1: `refactor(form): add validator path to custom text field`
- Commit 2: `fix(admin): validate lecture name from visible input`
- Commit 3: `fix(splash): remove build-time async state mutation`
- Commit 4: `fix(header): stop per-build callback and state churn`
- Commit 5: `chore(mqtt): remove hot-path log spam`

## Success Criteria
- 강의명 입력 후 저장이 실제 입력값 기준으로 성공/실패한다.
- 빈값/공백값 검증이 정확한 에러 문구와 함께 동작한다.
- `SplashScreen`, `MessageContainer`, `HeaderLayout`에서 build-time state/callback churn이 제거된다.
- `mqtt_manager.dart`의 hot-path raw print가 제거된다.
- focused regression + full suite + analyze가 모두 통과한다.
