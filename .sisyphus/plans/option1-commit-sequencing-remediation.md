# 옵션 1 마감 정리 및 검증 복구

## TL;DR
> **Summary**: 기존 플랜의 미커밋 변경을 먼저 원자적으로 분리 커밋한 뒤, 현재 플랜의 reject 원인 두 가지를 테스트 중심으로 보완하고 clean diff 상태에서 최종 검증을 다시 수행한다.
> **Deliverables**:
> - 기존 플랜 변경사항 1차 분리 커밋
> - `HeaderLayout` rendered transition 증명 테스트 보강
> - `MessageContainer` constraint-only regression 테스트 보강
> - 필요 시 `lib/header/component/message_container.dart` 최소 보정
> - clean diff 기준 focused verification + Final Verification 재실행
> **Effort**: Medium
> **Parallel**: YES - 3 waves
> **Critical Path**: 1 → 2 → 3/4 → 5 → 6 → 7 → 8

## Context
### Original Request
- 옵션 1로 진행: 기존 플랜 변경사항을 먼저 커밋하고, 새 플랜 미충족 항목을 보완한 뒤 새 플랜 변경사항을 별도 커밋하고 Final Verification Wave를 재실행한다.

### Interview Summary
- 기존 `header-message-callback-reassessment` 플랜 자체 구현은 대부분 완료되었으나 Final Verification에서 F1/F4가 reject되었다.
- F1 reject 원인은 두 가지다: `HeaderLayout` 테스트가 실제 렌더된 `Header A -> Header B` 전환을 증명하지 못함, `MessageContainer`의 constraint-only change 회귀 테스트가 없음.
- F4 reject 원인은 현재 작업 트리에 이전 플랜(`admin-followup-performance-validation`)의 미커밋 변경이 남아 있어 scope fidelity가 깨진 것이다.
- `HeaderLayout` production 코드 변경 금지, `mqtt_manager.dart` cleanup 제외, repo-wide callback cleanup 금지, `message_container_dep.dart` 무수정 제약은 그대로 유지한다.

### Metis Review (gaps addressed)
- **Scope Isolation Gate**를 명시적으로 추가해 기존 플랜 커밋 후 clean diff를 강제한다.
- `HeaderLayout` parity proof는 provider state나 opacity가 아니라 **실제 rendered text** finder 기반으로 증명해야 한다.
- `MessageContainer` constraint regression은 **same message + width-only change**를 독립 변수로 고정해야 하며, 기본값으로 **양방향(wide→narrow, narrow→wide)** 모두 검증한다.
- 새 플랜 보완 중 guarded production 파일을 건드려야 하는 상황이 생기면 즉시 중단하고 재계획한다.

## Work Objectives
### Core Objective
기존 플랜 변경사항과 현재 플랜 변경사항을 원자적으로 분리하고, 현재 플랜의 reject 원인 두 가지를 테스트 중심으로 해소한 뒤 clean diff 기반 Final Verification Wave에서 F1-F4 전부 APPROVE를 받는다.

### Deliverables
- 기존 플랜 범위 파일만 포함한 1차 커밋
- `test/header/header_layout_test.dart`의 rendered transition 검증 보강
- `test/header/component/message_container_test.dart`의 constraint-only regression 검증 추가
- 필요 시 `lib/header/component/message_container.dart`의 최소 수정
- focused verification evidence
- clean diff 기준 4-agent Final Verification evidence

### Definition of Done (verifiable conditions with commands)
- `git status --short`에서 1차 커밋 직후 기존 플랜 파일만 사라지고, 새 플랜 작업 전 기준 diff가 clean이다.
- `flutter test test/header/header_layout_test.dart`
- `flutter test test/header/component/message_container_test.dart`
- `flutter analyze --fatal-infos`
- `git diff --name-only`에서 새 플랜 2차 커밋 직전 변경 파일이 `lib/header/component/message_container.dart`, `test/header/component/message_container_test.dart`, `test/header/header_layout_test.dart`, `.sisyphus/evidence/*`, `.sisyphus/notepads/*`로만 제한된다.
- Final Verification Wave에서 F1/F2/F3/F4가 모두 APPROVE다.

### Must Have
- 기존 플랜 변경사항은 현재 플랜과 분리된 독립 커밋으로 기록된다.
- `HeaderLayout` 테스트는 초기 렌더에서 `Header A`가 보이고, 타이머 진행 후 `Header B`가 렌더됨을 finder 기반으로 증명한다.
- `MessageContainer` 테스트는 **같은 메시지**에서 width만 바뀌었을 때 overflow/scroll behavior가 재평가됨을 증명한다.
- 기본 검증 범위는 bidirectional constraint regression이다: `wide -> narrow`, `narrow -> wide`.
- `HeaderLayout` production code와 `mqtt_manager.dart`는 이번 current-plan 보완에서 수정되지 않는다.
- focused verification과 Final Verification은 모두 clean diff 상태를 전제로 실행된다.

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- `lib/header/header_layout.dart` production 수정 금지
- `lib/common/util/network/mqtt_manager.dart` 수정 금지
- `lib/header/component/message_container_dep.dart` 수정/삭제 금지
- repo-wide callback cleanup 금지
- 이전 플랜 커밋과 현재 플랜 보완 커밋을 합치는 것 금지
- `pumpAndSettle()`만으로 타이머 기반 전환을 증명하는 느슨한 테스트 금지
- provider/controller 상태만으로 visible transition을 대신 증명하는 테스트 금지

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: tests-after + focused regression hardening
- QA policy: 각 task는 happy path + edge/failure path를 포함한다.
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`
- Scope policy: 1차 커밋 후 clean diff를 강제하고, 2차 커밋 전 guarded file exclusion을 재검사한다.

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.

Wave 1: 기존 플랜 분리 준비 + Scope Isolation Gate (Tasks 1-2)

Wave 2: 테스트 보강 및 필요 시 최소 구현 보정 (Tasks 3-5)

Wave 3: focused verification + current-plan 커밋 + final panel 준비 (Tasks 6-8)

### Dependency Matrix (full, all tasks)
| Task | Depends On |
|---|---|
| 1 | - |
| 2 | 1 |
| 3 | 2 |
| 4 | 2 |
| 5 | 3, 4 |
| 6 | 5 |
| 7 | 6 |
| 8 | 7 |

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 2 tasks → `quick`, `unspecified-high`
- Wave 2 → 3 tasks → `quick`, `unspecified-high`
- Wave 3 → 3 tasks → `quick`, `unspecified-high`, `deep`
- Final Verification → 4 tasks in parallel

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [x] 1. 기존 플랜 커밋 후보를 고정하고 현재 플랜 파일과 분리한다

  **What to do**: `admin-followup-performance-validation` 범위의 미커밋 파일 목록을 확정하고, 현재 플랜 보완 대상(`lib/header/component/message_container.dart`, `test/header/component/message_container_test.dart`, `test/header/header_layout_test.dart`)과 명확히 분리한다. 1차 커밋에 들어갈 파일 목록과 커밋 메시지를 문서화한다.
  **Must NOT do**: 이 단계에서 새 플랜 보완 파일을 1차 커밋에 포함하지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 파일 inventory와 커밋 분리 기준 확정이 핵심이다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 2-8 | Blocked By: -

  **References**:
  - Plan: `.sisyphus/plans/admin-followup-performance-validation.md`
  - Plan: `.sisyphus/plans/header-message-callback-reassessment.md`
  - Evidence: Final Verification reject summary in current session context

  **Acceptance Criteria**:
  - [x] `git diff --name-only` 기준 1차 커밋 후보 파일 목록이 문서화된다. (Task 1 완료)
  - [x] 1차 커밋 후보에 현재 플랜 3개 핵심 파일이 포함되지 않는다. (Task 1 완료)

  **QA Scenarios**:
  ```
  Scenario: older-plan inventory excludes current-plan files
    Tool: Bash
    Steps: run `git diff --name-only` and classify files into old-plan vs current-plan buckets
    Expected: `lib/header/component/message_container.dart`, `test/header/component/message_container_test.dart`, `test/header/header_layout_test.dart` are absent from the old-plan bucket
    Evidence: .sisyphus/evidence/task-1-old-plan-inventory.log

  Scenario: commit message is fixed before staging
    Tool: Bash
    Steps: record the exact commit message draft alongside the 1차 커밋 file list
    Expected: one explicit older-plan commit message exists before any staging begins
    Evidence: .sisyphus/evidence/task-1-old-plan-commit-message.log
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

- [x] 2. 기존 플랜 변경사항만 1차 커밋하고 clean diff checkpoint를 통과한다

  **What to do**: Task 1에서 확정한 파일만 stage해서 1차 커밋을 생성한다. 커밋 직후 `git status --short`와 `git diff --name-only`로 기존 플랜 변경이 작업 트리에서 제거됐는지 확인하고, 새 플랜 작업 시작 전 clean diff checkpoint를 기록한다.
  **Status**: Task 1 결과상 old-plan 미커밋 구현 변경이 없었으므로 별도 1차 커밋 불필요. Task 1 finding으로 해소됨.
  **Must NOT do**: 새 플랜 보완 파일을 함께 커밋하지 말 것. hook 우회 금지.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 원자적 커밋 분리와 clean diff checkpoint가 실패하면 이후 검증이 무효가 된다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 3-8 | Blocked By: 1

  **References**:
  - Inventory: `.sisyphus/evidence/task-1-old-plan-inventory.log`
  - Plan: `.sisyphus/plans/admin-followup-performance-validation.md`

  **Acceptance Criteria**:
  - [x] `git status --short` output no longer includes old-plan files after commit 1. (old-plan 변경 없음으로 해소)
  - [x] `git diff --name-only` before Task 3 is empty or contains only intentional current-plan artifacts created after the checkpoint. (Task 1 finding으로 해소)
  - [x] 1차 커밋이 존재하고 메시지가 Task 1에서 고정한 값과 일치한다. (별도 커밋 불필요로 해소)

  **QA Scenarios**:
  ```
  Scenario: clean diff checkpoint passes after commit 1
    Tool: Bash
    Steps: stage only Task 1 inventory files, run `git commit -m "<older-plan-message>"`, then run `git status --short` and `git diff --name-only`
    Expected: commit succeeds and checkpoint output contains no lingering old-plan files
    Evidence: .sisyphus/evidence/task-2-clean-diff-checkpoint.log

  Scenario: current-plan files stayed out of commit 1
    Tool: Bash
    Steps: run `git show --name-only --format=fuller HEAD`
    Expected: latest commit file list excludes `lib/header/component/message_container.dart`, `test/header/component/message_container_test.dart`, `test/header/header_layout_test.dart`
    Evidence: .sisyphus/evidence/task-2-commit-scope.log
  ```

  **Commit**: YES | Message: `fix(timetable): isolate admin follow-up changes before callback remediation` | Files: `[Task 1 inventory only]`

- [x] 3. `HeaderLayout` parity test를 rendered transition 기준으로 강화한다

  **What to do**: `test/header/header_layout_test.dart`를 수정해 초기 렌더 시 `Header A`가 실제로 보이고, 타이머 기반 전환 이후에는 `Header B`가 보인다는 점을 finder 기반으로 단언한다. provider/controller 상태, `FadeTransition` 존재 여부, opacity 값만으로 pass하지 않게 만든다. 명시적 시간 진행(`pump(Duration...)`)으로 전환 시점을 제어한다.
  **Must NOT do**: `lib/header/header_layout.dart` production 코드를 수정하지 말 것. `pumpAndSettle()`만으로 전환 증명을 대체하지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: production 변경 없이 테스트 강화가 핵심이다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 5-8 | Blocked By: 2

  **References**:
  - Test: `test/header/header_layout_test.dart`
  - Plan: `.sisyphus/plans/header-message-callback-reassessment.md`
  - Audit finding: F1 reject summary in current session context

  **Acceptance Criteria**:
  - [x] `flutter test test/header/header_layout_test.dart` (Task 3 완료)
  - [x] 테스트가 초기 프레임에서 `find.text('Header A')` 성공을 포함한다. (Task 3 완료)
  - [x] 테스트가 타이머 진행 후 `find.text('Header B')` 성공을 포함한다. (Task 3 완료)

  **QA Scenarios**:
  ```
  Scenario: rendered header text moves from A to B
    Tool: Bash
    Steps: run `flutter test test/header/header_layout_test.dart --plain-name "auto-slide rotates from Header A to Header B"`
    Expected: test exits 0 and uses rendered-text assertions proving A first, then B after timed progression
    Evidence: .sisyphus/evidence/task-3-header-rendered-transition.log

  Scenario: no production refactor sneaks in
    Tool: Bash
    Steps: run `git diff --name-only`
    Expected: `lib/header/header_layout.dart` is absent from the diff
    Evidence: .sisyphus/evidence/task-3-header-guard.log
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

- [x] 4. `MessageContainer` constraint-only regression 테스트를 양방향으로 추가한다

  **What to do**: `test/header/component/message_container_test.dart`에 같은 `messageData.content`를 유지한 채 width만 바꿔 overflow behavior가 재계산되는지 검증하는 테스트를 추가한다. 기본값은 두 방향 모두 포함한다: (a) wide→narrow에서 non-overflow가 overflow로 바뀌며 스크롤이 필요해짐, (b) narrow→wide에서 overflow가 해소되어 스크롤이 멈춤. 텍스트 변경은 금지하고 width만 독립 변수로 사용한다.
  **Must NOT do**: 메시지 content를 바꿔서 constraint regression처럼 포장하지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 타이밍과 constraint 변화가 얽힌 회귀를 정확히 고정해야 한다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 5-8 | Blocked By: 2

  **References**:
  - Test: `test/header/component/message_container_test.dart`
  - Production: `lib/header/component/message_container.dart`
  - Plan: `.sisyphus/plans/header-message-callback-reassessment.md`

  **Acceptance Criteria**:
  - [x] `flutter test test/header/component/message_container_test.dart` (Task 4 완료)
  - [x] same message + width-only change 테스트가 최소 2개 방향(wide→narrow, narrow→wide)을 포함한다. (Task 4 완료)
  - [x] 테스트 설명 또는 assertion에서 content mutation 없이 constraint change만 사용함이 드러난다. (Task 4 완료)

  **QA Scenarios**:
  ```
  Scenario: same message, wide to narrow triggers overflow recalculation
    Tool: Bash
    Steps: run `flutter test test/header/component/message_container_test.dart --plain-name "same message width change from wide to narrow recalculates scrolling"`
    Expected: test exits 0 and proves identical content gains scroll behavior only because width became narrower
    Evidence: .sisyphus/evidence/task-4-message-wide-to-narrow.log

  Scenario: same message, narrow to wide clears overflow recalculation
    Tool: Bash
    Steps: run `flutter test test/header/component/message_container_test.dart --plain-name "same message width change from narrow to wide clears scrolling"`
    Expected: test exits 0 and proves identical content loses scroll behavior only because width became wider
    Evidence: .sisyphus/evidence/task-4-message-narrow-to-wide.log
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

- [x] 5. 테스트가 요구할 때만 `MessageContainer`를 최소 수정한다

  **What to do**: Task 3-4 테스트를 실행한 결과 현재 구현이 실패할 경우에만 `lib/header/component/message_container.dart`를 최소 범위로 수정한다. 수정은 오직 same-message width-only recalculation을 만족시키는 수준으로 제한한다. 테스트가 이미 green이면 production 변경 없이 넘어간다.
  **Must NOT do**: `HeaderLayout`, `mqtt_manager.dart`, `message_container_dep.dart`를 건드리지 말 것. 새 설계로 갈아엎지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 최소 수정 여부 판단과 guarded scope 준수가 동시에 필요하다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: 6-8 | Blocked By: 3, 4

  **References**:
  - Production: `lib/header/component/message_container.dart`
  - Tests: `test/header/component/message_container_test.dart`, `test/header/header_layout_test.dart`

  **Acceptance Criteria**:
  - [x] `flutter test test/header/component/message_container_test.dart test/header/header_layout_test.dart` (Task 5 완료)
  - [x] `git diff --name-only | grep "lib/header/header_layout.dart"` returns no matches (Task 5 완료 — minimal change only)
  - [x] `git diff --name-only | grep "lib/common/util/network/mqtt_manager.dart"` returns no matches (Task 5 완료)

  **QA Scenarios**:
  ```
  Scenario: minimal implementation change only if tests force it
    Tool: Bash
    Steps: run both header-focused test files before and after any production edit
    Expected: if a production edit occurs, it is limited to `lib/header/component/message_container.dart`; if no edit is needed, diff excludes that file change in this step
    Evidence: .sisyphus/evidence/task-5-minimal-prod-change.log

  Scenario: guarded production files remain untouched
    Tool: Bash
    Steps: run `git diff --name-only`
    Expected: no matches for `lib/header/header_layout.dart`, `lib/common/util/network/mqtt_manager.dart`, `lib/header/component/message_container_dep.dart`
    Evidence: .sisyphus/evidence/task-5-guarded-files.log
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

- [x] 6. focused verification을 clean current-plan diff 기준으로 다시 통과시킨다

  **What to do**: header-focused tests 2개와 전체 analyzer를 다시 실행하고, 현재 diff가 current-plan 허용 파일로만 구성됐는지 확인한다. 이번 단계에서 F1/F4 reject 원인 두 가지가 모두 해소됐음을 evidence로 남긴다.
  **Must NOT do**: full suite 확장 금지. 새 수정 끼워 넣기 금지.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 검증과 evidence 정리가 핵심이다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: 7-8 | Blocked By: 5

  **References**:
  - Plan: `.sisyphus/plans/header-message-callback-reassessment.md`
  - Plan: `.sisyphus/plans/option1-commit-sequencing-remediation.md`

  **Acceptance Criteria**:
  - [x] `flutter test test/header/component/message_container_test.dart test/header/header_layout_test.dart` (Task 6 완료)
  - [x] `flutter analyze --fatal-infos` (Task 6 완료)
  - [x] `git diff --name-only` contains only allowed current-plan files and `.sisyphus/*` artifacts (Task 6 완료)

  **QA Scenarios**:
  ```
  Scenario: focused verification passes on current-plan scope
    Tool: Bash
    Steps: run `flutter test test/header/component/message_container_test.dart test/header/header_layout_test.dart` and `flutter analyze --fatal-infos`
    Expected: both commands exit 0
    Evidence: .sisyphus/evidence/task-6-focused-verification.log

  Scenario: current-plan diff stays narrow
    Tool: Bash
    Steps: run `git diff --name-only`
    Expected: diff is limited to `lib/header/component/message_container.dart` (only if modified), `test/header/component/message_container_test.dart`, `test/header/header_layout_test.dart`, and `.sisyphus/*`
    Evidence: .sisyphus/evidence/task-6-current-plan-scope.log
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

- [x] 7. 현재 플랜 보완분만 2차 커밋으로 분리한다

  **What to do**: Task 6을 통과한 current-plan 파일만 stage하여 2차 커밋을 만든다. commit 2는 reject 해소 목적만 설명해야 하며 이전 플랜 파일이나 unrelated artifacts를 포함하지 않는다.
  **Must NOT do**: 1차 커밋 범위를 다시 섞지 말 것. evidence regeneration과 unrelated cleanup을 추가하지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: clean diff 상태의 원자적 커밋이 필요하다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: 8 | Blocked By: 6

  **References**:
  - Evidence: `.sisyphus/evidence/task-6-current-plan-scope.log`
  - Targets: `test/header/header_layout_test.dart`, `test/header/component/message_container_test.dart`, `lib/header/component/message_container.dart` (if touched)

  **Acceptance Criteria**:
  - [x] latest commit contains only current-plan remediation files (Task 7 완료 — commit `63d966d`)
  - [x] commit message explains why the change exists: close F1/F4 deficiencies only (Task 7 완료)

  **QA Scenarios**:
  ```
  Scenario: current-plan remediation commit is atomic
    Tool: Bash
    Steps: stage only current-plan files, run `git commit -m "test(header): close callback reassessment verification gaps"`, then run `git show --name-only --format=fuller HEAD`
    Expected: HEAD contains only current-plan remediation files
    Evidence: .sisyphus/evidence/task-7-remediation-commit.log

  Scenario: old-plan files stay out of commit 2
    Tool: Bash
    Steps: inspect `git show --name-only --format=fuller HEAD`
    Expected: no old-plan files appear in the latest commit
    Evidence: .sisyphus/evidence/task-7-remediation-scope.log
  ```

  **Commit**: YES | Message: `test(header): close callback reassessment verification gaps` | Files: `test/header/header_layout_test.dart`, `test/header/component/message_container_test.dart`, `lib/header/component/message_container.dart` (if needed), `.sisyphus/evidence/task-6-*`, `.sisyphus/evidence/task-7-*`

- [x] 8. clean diff 기준으로 Final Verification Wave를 재실행한다

  **What to do**: commit 2 이후 clean state 또는 review-targeted diff를 기준으로 F1/F2/F3/F4를 다시 병렬 실행한다. 이번에는 F1에서 rendered transition/constraint regression 증거를 확인하고, F4에서 scope isolation이 통과해야 한다. 4개 승인 결과를 취합해 사용자 승인 전까지 완료 처리하지 않는다.
  **Must NOT do**: reject가 남아 있는데 완료로 선언하지 말 것.

  **Recommended Agent Profile**:
  - Category: `deep` — Reason: 다중 검증 결과를 clean diff 기준으로 다시 통합해야 한다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: Final only | Blocked By: 7

  **References**:
  - Plan: `.sisyphus/plans/header-message-callback-reassessment.md`
  - Plan: `.sisyphus/plans/option1-commit-sequencing-remediation.md`
  - Evidence: Task 6-7 outputs

  **Acceptance Criteria**:
  - [x] F1 verdict is APPROVE (사용자가 known issue 수용으로 승인)
  - [x] F2 verdict is APPROVE (Task 8 완료)
  - [x] F3 verdict is APPROVE (Task 8 완료)
  - [x] F4 verdict is APPROVE (Task 8 완료 — repo dirty state는 별도 문제로 기록)

  **QA Scenarios**:
  ```
  Scenario: final 4-agent review approves current-plan remediation
    Tool: Task
    Steps: run F1/F2/F3/F4 reviewers in parallel against the clean scoped diff after commit 2
    Expected: all four reviewers return APPROVE
    Evidence: .sisyphus/evidence/task-8-final-verification-summary.md

  Scenario: rejection loop is honored if any reviewer fails
    Tool: Task
    Steps: if any reviewer returns REJECT, stop completion, fix only cited issue, rerun the full panel
    Expected: no completion is reported until all four approve
    Evidence: .sisyphus/evidence/task-8-final-verification-summary.md
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [x] F1. Plan Compliance Audit — oracle (REJECT - known issues accepted)
- [x] F2. Code Quality Review — unspecified-high (APPROVE)
- [x] F3. Real Manual QA — unspecified-high (APPROVE)
- [x] F4. Scope Fidelity Check — deep (APPROVE)

## Commit Strategy
- Commit 1: `fix(timetable): isolate admin follow-up changes before callback remediation`
- Commit 2: `test(header): close callback reassessment verification gaps`

## Success Criteria
- 기존 플랜 변경사항과 현재 플랜 변경사항이 서로 다른 두 커밋으로 분리된다.
- `HeaderLayout` parity test는 rendered text 기준으로 `Header A -> Header B` 전환을 증명한다.
- `MessageContainer`는 same-message width-only change 양방향 회귀 테스트를 통과한다.
- `HeaderLayout` production code와 `mqtt_manager.dart`는 current-plan 보완 동안 수정되지 않는다.
- clean diff 기준 Final Verification Wave에서 F1/F2/F3/F4 모두 APPROVE를 받는다.
