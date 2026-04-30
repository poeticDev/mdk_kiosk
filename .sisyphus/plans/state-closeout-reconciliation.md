# .sisyphus 상태 마감 정합성 정리

## TL;DR
> **Summary**: 기능 작업은 끝났고 사용자 승인도 확보됐다. 남은 일은 `.sisyphus` 상태 파일 3종의 불일치를 정리해 문서상 종료 상태를 실제 상태와 맞추는 것이다.
> **Deliverables**:
> - `option1-commit-sequencing-remediation.md` 마감 상태 정리
> - `header-message-callback-reassessment.md` superseded/accepted 상태 정리
> - `.sisyphus/boulder.json` 종료 처리
> - closeout summary evidence
> **Effort**: Quick
> **Parallel**: NO
> **Critical Path**: 1 → 2 → 3 → 4

## Context
### Original Request
- 남은 문서 상태 정리만 하는 마감 플랜으로 닫는다.

### Interview Summary
- 실제 구현/테스트/커밋은 완료되었고 사용자는 “실제 목표달성에 문제가 없다면, 현재 상태를 최종 승인하자”라고 승인했다.
- `option1-commit-sequencing-remediation.md`에는 Task 2가 미체크로 남아 있다.
- `header-message-callback-reassessment.md`에는 F1-F4가 미체크로 남아 있다.
- `.sisyphus/boulder.json`은 아직 active plan 상태다.

### Metis Review (gaps addressed)
- closeout은 상태 정리만 다루고, 구현 정당성 재판정으로 확장하지 않는다.
- 삭제보다 **상태/사유 기록**을 우선한다.
- 각 파일에 최종 disposition(complete / superseded / accepted with known issue)을 명시해야 한다.
- boulder 종료는 다른 작업 재개를 막지 않는 최소 표현으로 처리해야 한다.

## Work Objectives
### Core Objective
`.sisyphus` 내부의 플랜/상태 파일이 실제 종료 상태와 일치하도록 정리해, 기능적으로 끝난 작업이 문서상으로도 닫힌 상태가 되게 한다.

### Deliverables
- `.sisyphus/plans/option1-commit-sequencing-remediation.md`
- `.sisyphus/plans/header-message-callback-reassessment.md`
- `.sisyphus/boulder.json`
- `.sisyphus/evidence/state-closeout-summary.md`

### Definition of Done (verifiable conditions with commands)
- `grep -n "^- \[[ x]\]" .sisyphus/plans/option1-commit-sequencing-remediation.md` 결과에 남은 의도치 않은 open checkbox가 없다.
- `grep -n "^- \[[ x]\]" .sisyphus/plans/header-message-callback-reassessment.md` 결과가 최종 disposition을 반영한다.
- `Read(.sisyphus/boulder.json)` 기준 active work session이 종료 상태로 표시되거나 파일이 제거되어 더 이상 active plan으로 해석되지 않는다.
- `Read(.sisyphus/evidence/state-closeout-summary.md)`에서 최종 disposition과 사용자 승인 근거가 확인된다.

### Must Have
- `option1-commit-sequencing-remediation.md`의 Task 2는 실제 판단과 일치하게 처리된다. 기본값은 **“Not needed after Task 1 finding”**를 명시하고 완료 처리다.
- `header-message-callback-reassessment.md`는 후속 플랜으로 대체되었고, 최종 상태가 **superseded by remediation plan**임이 드러나야 한다.
- `header-message-callback-reassessment.md`의 F1-F4는 실제 결과를 반영해 정리된다. 기본값은 `F1 rejected but later accepted by user via remediation outcome`, `F2/F3/F4 completed or superseded by later verification` 표기다.
- `.sisyphus/boulder.json`은 더 이상 active execution처럼 보이지 않게 종료 처리한다.
- closeout summary에는 사용자 최종 승인 문구와 known issue acceptance 맥락이 남아야 한다.

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- source code, test code, evidence 재생성 금지
- 새 verification 실행 금지
- 기존 판단을 미화하기 위해 과거 결과를 삭제하거나 왜곡 금지
- `.sisyphus/*` 바깥 파일 수정 금지
- 새 follow-up task 발명 금지

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: none (documentation/state closeout only)
- QA policy: 각 task는 file read/grep 기반 상태 검증을 포함한다.
- Evidence: `.sisyphus/evidence/state-closeout-summary.md`

## Execution Strategy
### Parallel Execution Waves
Wave 1: plan state reconciliation (Tasks 1-2)

Wave 2: boulder closeout + summary evidence (Tasks 3-4)

### Dependency Matrix (full, all tasks)
| Task | Depends On |
|---|---|
| 1 | - |
| 2 | 1 |
| 3 | 2 |
| 4 | 3 |

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 2 tasks → `quick`
- Wave 2 → 2 tasks → `quick`

## TODOs
> Implementation + Verification = ONE task.

- [x] 1. remediation plan의 미체크 항목을 실제 상태에 맞게 닫는다

  **What to do**: `.sisyphus/plans/option1-commit-sequencing-remediation.md`에서 Task 2 미체크를 정리한다. Task 1 결과상 old-plan 미커밋 구현 변경이 없었으므로, Task 2는 “실행 불필요 / Task 1 finding으로 해소됨”을 짧게 남기고 체크 상태를 완료로 바꾼다.
  **Must NOT do**: Task 2가 실제로 수행된 것처럼 허위로 기록하지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 단일 플랜 파일의 상태 정합성 수정이다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 2-4 | Blocked By: -

  **References**:
  - File: `.sisyphus/plans/option1-commit-sequencing-remediation.md:145-181`
  - Evidence: `.sisyphus/evidence/task-1-old-plan-inventory.log`
  - User decision: current state accepted

  **Acceptance Criteria**:
  - [ ] Task 2 checkbox is closed.
  - [ ] Adjacent text explains the closeout reason: not needed after Task 1 finding.

  **QA Scenarios**:
  ```
  Scenario: remediation plan no longer has unintended open Task 2
    Tool: Grep
    Steps: search the remediation plan for `- [ ] 2.`
    Expected: no match remains
    Evidence: .sisyphus/evidence/state-closeout-summary.md

  Scenario: closure rationale is preserved
    Tool: Read
    Steps: read the Task 2 block in the remediation plan
    Expected: the block explicitly says Task 2 became unnecessary because Task 1 found no old-plan uncommitted implementation changes
    Evidence: .sisyphus/evidence/state-closeout-summary.md
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

- [x] 2. original callback reassessment plan을 superseded 상태로 닫는다

  **What to do**: `.sisyphus/plans/header-message-callback-reassessment.md`에 후속 플랜으로 대체되었음을 명시한다. Final Verification 체크박스는 실제 결과와 연결되게 정리한다: F1은 remediation에서 known issue accepted로 귀결되었고, F2/F3/F4는 later verification outcome으로 정리되었음을 반영한다.
  **Must NOT do**: 원래 F1이 APPROVE였던 것처럼 바꾸지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: superseded 상태 표기와 verification disposition 정리가 핵심이다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 3-4 | Blocked By: 1

  **References**:
  - File: `.sisyphus/plans/header-message-callback-reassessment.md:265-284`
  - File: `.sisyphus/plans/option1-commit-sequencing-remediation.md:414-432`
  - User decision: final approval despite known F1 issue

  **Acceptance Criteria**:
  - [ ] `header-message-callback-reassessment.md` clearly states it was superseded.
  - [ ] F1-F4 are no longer left ambiguously open.
  - [ ] F1 text preserves that rejection existed before user acceptance.

  **QA Scenarios**:
  ```
  Scenario: superseded plan has no ambiguous final-verification state
    Tool: Grep
    Steps: search the original plan for `- [ ] F1` through `- [ ] F4`
    Expected: no open final verification checkboxes remain
    Evidence: .sisyphus/evidence/state-closeout-summary.md

  Scenario: rejection history is preserved
    Tool: Read
    Steps: read the final verification block in the original plan
    Expected: it references later remediation and user acceptance without rewriting history as full approval
    Evidence: .sisyphus/evidence/state-closeout-summary.md
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

- [x] 3. active boulder state를 종료 상태로 정리한다

  **What to do**: `.sisyphus/boulder.json`을 닫는다. 기본값은 파일 제거가 아니라 종료 메타데이터를 남기는 쪽을 우선 검토하되, 현재 체계가 active-plan semantics만 가진다면 파일 제거도 허용한다. 어떤 방식이든 읽는 주체가 더 이상 active work session으로 해석하지 않도록 만든다.
  **Must NOT do**: 여전히 active_plan이 살아 있는 상태로 남겨두지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 단일 상태 파일 closeout이다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: 4 | Blocked By: 2

  **References**:
  - File: `.sisyphus/boulder.json`
  - Active plan: `option1-commit-sequencing-remediation.md`

  **Acceptance Criteria**:
  - [ ] No remaining active plan state is readable from `.sisyphus/boulder.json`.
  - [ ] The closeout method (closed metadata or removal) is documented in the summary evidence.

  **QA Scenarios**:
  ```
  Scenario: boulder no longer represents an active session
    Tool: Read
    Steps: read `.sisyphus/boulder.json` if it exists
    Expected: it either does not exist or does not contain an active plan/session state
    Evidence: .sisyphus/evidence/state-closeout-summary.md

  Scenario: closeout remains auditable
    Tool: Read
    Steps: read the summary evidence file
    Expected: it states how boulder was closed and why
    Evidence: .sisyphus/evidence/state-closeout-summary.md
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

- [x] 4. 최종 closeout summary를 남기고 handoff를 종료한다

  **What to do**: `.sisyphus/evidence/state-closeout-summary.md`를 작성해 세 파일의 최종 disposition, 사용자 승인 문구, known issue accepted 맥락, closeout timestamp를 남긴다. 이후 `/start-work` 실행 없이도 종료 상태를 이해할 수 있어야 한다.
  **Must NOT do**: summary를 근거 없이 낙관적으로 쓰지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 최종 상태를 한 파일로 수렴시키는 문서 작업이다.
  - Skills: `[]`
  - Omitted: `update-omo-models` — 관련 없음

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: Final only | Blocked By: 3

  **References**:
  - File: `.sisyphus/plans/option1-commit-sequencing-remediation.md`
  - File: `.sisyphus/plans/header-message-callback-reassessment.md`
  - File: `.sisyphus/boulder.json`

  **Acceptance Criteria**:
  - [ ] summary lists each affected file and final disposition
  - [ ] summary quotes or paraphrases the user acceptance decision
  - [ ] summary explains known-issue acceptance for F1

  **QA Scenarios**:
  ```
  Scenario: closeout summary is self-sufficient
    Tool: Read
    Steps: read `.sisyphus/evidence/state-closeout-summary.md`
    Expected: a new reader can understand what was closed, why, and with what caveats without reopening old sessions
    Evidence: .sisyphus/evidence/state-closeout-summary.md

  Scenario: all target files agree with the summary
    Tool: Read
    Steps: compare summary text against the final contents of the two plan files and boulder state
    Expected: no contradiction exists between summary and file states
    Evidence: .sisyphus/evidence/state-closeout-summary.md
  ```

  **Commit**: NO | Message: `N/A` | Files: `N/A`

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> Documentation closeout review only.
- [x] F1. Plan State Consistency Audit — oracle (APPROVE — cosmetic checkbox cleanup completed)
- [x] F2. Closeout Record Quality Review — unspecified-high (APPROVE)
- [x] F3. Artifact Readability Check — unspecified-high (APPROVE)
- [x] F4. Scope Fidelity Check (`.sisyphus` only) — deep (REJECT — repo dirty state remains, documented as separate issue)

## Commit Strategy
- Optional single closeout commit after documentation reconciliation: `docs(sisyphus): reconcile closeout state for callback work`

## Success Criteria
- 두 플랜 파일과 boulder state가 실제 종료 상태와 일치한다.
- open checkbox가 의도치 않게 남아 있지 않다.
- rejection history와 user acceptance가 동시에 보존된다.
- 새 작업 없이 문서상 closeout이 완결된다.
