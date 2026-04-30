# prompts/test_results 정리 계획

## TL;DR
> **Summary**: `prompts/test_results/`에 커밋된 대용량 성능 분석 산출물은 앱 동작에 필요하지 않으므로 저장소 추적 대상에서 제거하고, 핵심 근거는 문서에만 남긴다. 기본 경로는 HEAD 정리(`문서 보존 → 삭제/추적 해제 → ignore`)이며, history 재작성은 원격 푸시가 기존 blob 때문에 계속 막힐 때만 별도 조건부로 수행한다.
> **Deliverables**:
> - `prompts/test_results/` 원시 산출물의 정리 범위 확정
> - `prompts/jank_mitigation_plan.md`의 참조 보존/갱신 지침
> - 좁은 범위의 ignore 규칙
> - HEAD 정리 검증 커맨드 세트
> - 필요 시에만 실행되는 history 정리 조건부 경로
> **Effort**: Short
> **Parallel**: YES - 3 waves
> **Critical Path**: 1 → 2/3 → 4 → 5

## Context
### Original Request
- `prompts/test_results`의 테스트 결과 파일이 너무 커서 GitHub repository에 못 올라가는 문제를 검토한다.
- 필요성을 검토하고, 1) git ignore 처리, 2) 아예 삭제, 3) 다른 해결책을 비교한다.

### Interview Summary
- 조사 결과 `prompts/test_results/`의 4개 파일은 Android/Flutter 성능 분석 산출물(`adb shell top`, `dumpsys gfxinfo`, DevTools timeline/CPU profile`)이며 재생성 가능하다.
- 이 파일들은 코드, 테스트, CI 어디에서도 사용되지 않고 `prompts/jank_mitigation_plan.md`에서 근거 자료로만 참조된다.
- 사용자 선택 방향은 **삭제 + ignore** 이다.

### Metis Review (gaps addressed)
- HEAD 정리와 history 재작성은 절대 한 기본 작업으로 합치지 않는다.
- 문서 참조 정리를 파일 삭제와 같은 범위에 넣는다.
- `prompts/test_results/`만 기본 범위로 두고, `prompts/dart_devtools_2025-11-19_11_00_26.216.json`은 **옵션성 후속 작업**으로만 표시한다.
- `prompts/` 전체나 `*.json` 전체를 무시하는 과도한 ignore 패턴은 금지한다.

## Work Objectives
### Core Objective
- `prompts/test_results/`의 생성형 성능 산출물을 저장소 추적 대상에서 제거하고, 동일 유형의 파일이 다시 커밋되지 않도록 방지한다.

### Deliverables
- `prompts/test_results/` 파일별 처리 정책(삭제/보존/범위 제외)
- `prompts/jank_mitigation_plan.md`의 증거 보존 방식 정리
- `.gitignore`의 좁은 범위 패턴 추가안
- HEAD 기준 검증 커맨드 및 조건부 history 대응 지침

### Definition of Done (verifiable conditions with commands)
- `git ls-files -- "prompts/test_results"` 실행 시 출력이 비어 있다.
- `git check-ignore -v prompts/test_results/dart_devtools_2099-01-01_00_00_00.000.json` 실행 시 새 ignore 규칙이 경로와 함께 출력된다.
- `grep -RInE 'prompts/test_results|adb_shell_top_-H-p\\.txt|dumpsys_gfxinfo\\.txt|dart_devtools_2025-11-26_13_55_10\\.398\\.json|dart_devtools_2025-11-26_13_59_18\\.367\\.json' prompts` 실행 시 승인된 문서 표현만 남고, 삭제된 원시 파일에 대한 stale reference는 남지 않는다.
- `git status --short` 실행 시 계획 범위 밖 파일 변경이 없다.

### Must Have
- `prompts/test_results/` 4개 파일만 기본 정리 범위로 처리한다.
- 원시 데이터 삭제 전에 `prompts/jank_mitigation_plan.md`에 남겨야 할 핵심 수치/재수집 안내를 확정한다.
- `.gitignore`는 `prompts/test_results/` 하위의 생성 산출물만 막는 좁은 패턴을 사용한다.
- 원격 푸시가 여전히 실패할 때만 history 정리 경로를 연다.

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- `prompts/` 전체, `*.json` 전체, 또는 루트 `prompts/dart_devtools_2025-11-19_11_00_26.216.json`을 기본 범위에 포함하지 않는다.
- 앱 코드, 테스트 코드, CI 설정, 성능 개선 로직 자체는 수정하지 않는다.
- `coverage/lcov.info`, `build.yaml` 등 다른 생성 파일 정리로 범위를 확장하지 않는다.
- `.gitignore`만 추가하고 이미 추적 중인 파일을 그대로 두는 불완전한 정리를 하지 않는다.
- history 재작성은 기본 경로에 포함하지 않는다.

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: TDD (command-level red/green) + git/bash/grep verification
- QA policy: Every task includes command-based happy path and failure/edge-case scenarios
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`

## Execution Strategy
### File Scope Matrix
| Path | Classification | Default Action | Notes |
|---|---|---|---|
| `prompts/test_results/adb_shell_top_-H-p.txt` | generated profiling log | remove from tracking + ignore | 코드 의존성 없음 |
| `prompts/test_results/dumpsys_gfxinfo.txt` | generated profiling log | remove from tracking + ignore | 코드 의존성 없음 |
| `prompts/test_results/dart_devtools_2025-11-26_13_55_10.398.json` | generated DevTools timeline | remove from tracking + ignore | 103MB 핵심 문제 파일 |
| `prompts/test_results/dart_devtools_2025-11-26_13_59_18.367.json` | generated CPU profile | remove from tracking + ignore | 재생성 가능 |
| `prompts/jank_mitigation_plan.md` | documentation | keep + rewrite stale references | 핵심 수치는 문서에 잔존 |
| `prompts/dart_devtools_2025-11-19_11_00_26.216.json` | tracked profiling artifact | out of scope by default | 후속 선택 과제만 허용 |

### Parallel Execution Waves
Wave 1: 1번(기준선/범위 잠금)

Wave 2: 2번(문서 참조 보존) + 3번(ignore 규칙 추가)

Wave 3: 4번(HEAD 정리) + 5번(조건부 history 대응 판단)

### Dependency Matrix (full, all tasks)
| Task | Depends On | Blocks |
|---|---|---|
| 1 | - | 2, 3, 4, 5 |
| 2 | 1 | 4 |
| 3 | 1 | 4 |
| 4 | 2, 3 | 5, F1-F4 |
| 5 | 4 | F1-F4 |
| F1 | 1-5 | completion |
| F2 | 1-5 | completion |
| F3 | 1-5 | completion |
| F4 | 1-5 | completion |

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 1 task → `quick`
- Wave 2 → 2 tasks → `writing`, `quick`
- Wave 3 → 2 tasks → `quick`, `unspecified-low`
- Final Verification → 4 tasks → `oracle`, `unspecified-high`, `unspecified-high`, `deep`

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [ ] 1. 기준선 고정 및 정리 범위 잠금

  **What to do**: `prompts/test_results/` 4개 파일을 정리 대상 목록으로 고정하고, 현재 git 추적 상태/문서 참조 상태를 red 상태로 증거화한다. `prompts/dart_devtools_2025-11-19_11_00_26.216.json`은 존재만 확인하고 기본 범위 밖으로 명시한다.
  **Must NOT do**: 루트 `prompts/` 전체나 다른 생성 파일(`coverage/lcov.info`, `build.yaml`)로 범위를 넓히지 않는다.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 탐색/검증 중심의 단일 범위 잠금 작업이다.
  - Skills: [`git-master`] — git 추적 상태와 이후 cleanup 흐름을 정확히 다루기 위해 필요하다.
  - Omitted: [`update-omo-models`] — 모델 설정 작업과 무관하다.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 2, 3, 4, 5 | Blocked By: none

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `prompts/test_results/` — 정리 대상 디렉터리.
  - Pattern: `prompts/jank_mitigation_plan.md:3-7` — 삭제 대상 파일들이 문서에서 근거 자료로 인용되는 현재 상태.
  - Pattern: `.gitignore:1-49` — 현재 `prompts/test_results/` 관련 ignore 규칙이 전혀 없음.
  - Pattern: `prompts/dart_devtools_2025-11-19_11_00_26.216.json` — 존재하지만 이번 기본 정리 범위에서는 제외해야 하는 루트 산출물.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `git ls-files -- "prompts/test_results"` 실행 결과에 4개 파일이 모두 출력된다.
  - [ ] `grep -RInE 'prompts/test_results|adb_shell_top_-H-p\.txt|dumpsys_gfxinfo\.txt|dart_devtools_2025-11-26_13_55_10\.398\.json|dart_devtools_2025-11-26_13_59_18\.367\.json' prompts` 실행 결과에 `prompts/jank_mitigation_plan.md`의 관련 인용이 잡힌다.
  - [ ] `git ls-files -- "prompts/dart_devtools_2025-11-19_11_00_26.216.json"` 실행 결과에 해당 파일이 출력되더라도, 작업 범위 문서에는 "out of scope"로 기록된다.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Happy path baseline capture
    Tool: Bash
    Steps: 1) git ls-files -- "prompts/test_results"
           2) grep -RInE 'prompts/test_results|adb_shell_top_-H-p\.txt|dumpsys_gfxinfo\.txt|dart_devtools_2025-11-26_13_55_10\.398\.json|dart_devtools_2025-11-26_13_59_18\.367\.json' prompts
           3) Save outputs to .sisyphus/evidence/task-1-baseline.txt
    Expected: 네 개 파일이 추적 중이며, 문서 참조가 존재한다.
    Evidence: .sisyphus/evidence/task-1-baseline.txt

  Scenario: Failure/edge case - unintended scope expansion
    Tool: Bash
    Steps: 1) git ls-files -- "coverage/lcov.info" "build.yaml" "prompts/dart_devtools_2025-11-19_11_00_26.216.json"
           2) Compare planned scope list against these outputs
           3) Save check to .sisyphus/evidence/task-1-scope-guard.txt
    Expected: 루트 devtools JSON은 별도 후속 후보로만 기록되고, coverage/build.yaml은 이번 계획 대상에서 제외된다.
    Evidence: .sisyphus/evidence/task-1-scope-guard.txt
  ```

  **Commit**: NO | Message: `n/a` | Files: none

- [ ] 2. 문서에서 원시 파일 의존성 제거

  **What to do**: `prompts/jank_mitigation_plan.md`의 4개 원시 파일 직접 참조를, 핵심 수치 요약 + 재수집 방법 또는 "원시 산출물은 저장소 밖 보관" 문구로 바꾼다. 문서를 읽는 사람은 원시 파일 없이도 병목 근거를 이해할 수 있어야 한다.
  **Must NOT do**: 성능 개선 계획의 기술 내용 자체를 바꾸거나 새로운 분석 결론을 만들어내지 않는다.

  **Recommended Agent Profile**:
  - Category: `writing` — Reason: 문서 정확도와 보존성 중심 작업이다.
  - Skills: [`git-master`] — 삭제 전 문서 참조 제거가 커밋 원자성에 직접 연결된다.
  - Omitted: [`update-omo-models`] — 무관.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 4 | Blocked By: 1

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `prompts/jank_mitigation_plan.md:3-7` — 현재 원시 파일명 직접 인용 구간.
  - Pattern: `prompts/test_results/dumpsys_gfxinfo.txt` — 90.9% janky, 95 percentile 1.2초의 근거 파일명.
  - Pattern: `prompts/test_results/adb_shell_top_-H-p.txt` — Thread<00>~<05> CPU 점유 근거 파일명.
  - Pattern: `prompts/test_results/dart_devtools_2025-11-26_13_55_10.398.json` — 103MB timeline export.
  - Pattern: `prompts/test_results/dart_devtools_2025-11-26_13_59_18.367.json` — CPU profile export.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `grep -nE 'prompts/test_results|adb_shell_top_-H-p\.txt|dumpsys_gfxinfo\.txt|dart_devtools_2025-11-26_13_55_10\.398\.json|dart_devtools_2025-11-26_13_59_18\.367\.json' prompts/jank_mitigation_plan.md` 실행 시 삭제 대상 파일의 직접 경로 인용이 남지 않는다.
  - [ ] 문서에는 기존 수치(예: 90.9% janky, 95 percentile 1.2초, Thread<00>~<05> CPU 점유)가 유지되거나 재수집 방법이 명시된다.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Happy path documentation survives artifact deletion
    Tool: Bash
    Steps: 1) grep -nE '90\.9%|95퍼센타일 1\.2초|Thread<00>|_SimpleClockState\._updateTime|MqttManager\._pingCallback' prompts/jank_mitigation_plan.md
           2) grep -nE 'prompts/test_results|adb_shell_top_-H-p\.txt|dumpsys_gfxinfo\.txt|dart_devtools_2025-11-26_13_55_10\.398\.json|dart_devtools_2025-11-26_13_59_18\.367\.json' prompts/jank_mitigation_plan.md
           3) Save outputs to .sisyphus/evidence/task-2-docs.txt
    Expected: 핵심 수치/함수명은 남고, 삭제 대상 파일의 직접 경로는 제거된다.
    Evidence: .sisyphus/evidence/task-2-docs.txt

  Scenario: Failure/edge case - analysis drift
    Tool: Bash
    Steps: 1) git diff --unified=0 -- prompts/jank_mitigation_plan.md > .sisyphus/evidence/task-2-docs-drift.diff
           2) grep -nE '^[+-].*(동기 연산 인벤토리 작성|비동기 전환 설계|구현 및 의존성 주입 정리|회귀 방지 및 검증)' .sisyphus/evidence/task-2-docs-drift.diff || true
           3) Save grep result to .sisyphus/evidence/task-2-docs-drift.txt
    Expected: diff에 2~5번 작업 제목/내용 변경이 잡히지 않는다.
    Evidence: .sisyphus/evidence/task-2-docs-drift.txt
  ```

  **Commit**: YES | Message: `docs(prompts): preserve profiling findings without raw artifact dependency` | Files: `prompts/jank_mitigation_plan.md`

- [ ] 3. 좁은 범위의 ignore 규칙 추가

  **What to do**: `.gitignore`에 `prompts/test_results/` 하위의 생성형 profiling 산출물만 막는 규칙을 추가한다. 미래에 다시 생성될 DevTools JSON/텍스트 덤프가 자동 추적되지 않아야 한다.
  **Must NOT do**: `prompts/` 전체, `*.json` 전체, 또는 루트 `prompts/dart_devtools_2025-11-19_11_00_26.216.json`까지 가려지는 광범위 패턴을 넣지 않는다.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 단일 설정 파일의 정밀 수정 작업이다.
  - Skills: [`git-master`] — 추적 중 파일과 ignore 상호작용을 정확히 검증해야 한다.
  - Omitted: [`update-omo-models`] — 무관.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 4 | Blocked By: 1

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `.gitignore:1-49` — 현재 규칙의 전체 문맥.
  - Pattern: `prompts/test_results/` — ignore 대상 디렉터리.
  - Pattern: `prompts/dart_devtools_2025-11-19_11_00_26.216.json` — 가려지면 안 되는 루트 파일.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `.gitignore`에 `prompts/test_results/` 하위 생성물만 설명하는 주석과 규칙이 추가된다.
  - [ ] `git check-ignore -v prompts/test_results/dart_devtools_2099-01-01_00_00_00.000.json` 실행 시 새 규칙이 출력된다.
  - [ ] `git check-ignore -v prompts/dart_devtools_2025-11-19_11_00_26.216.json` 실행 시 출력이 없어야 한다.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Happy path ignore future profiling artifacts
    Tool: Bash
    Steps: 1) git check-ignore -v prompts/test_results/dart_devtools_2099-01-01_00_00_00.000.json
           2) git check-ignore -v prompts/test_results/future_capture.txt
           3) Save outputs to .sisyphus/evidence/task-3-ignore.txt
    Expected: 두 경로 모두 새 ignore 규칙에 의해 무시된다.
    Evidence: .sisyphus/evidence/task-3-ignore.txt

  Scenario: Failure/edge case - overly broad ignore
    Tool: Bash
    Steps: 1) git check-ignore -v prompts/dart_devtools_2025-11-19_11_00_26.216.json
           2) git check-ignore -v prompts/jank_mitigation_plan.md
           3) Save outputs to .sisyphus/evidence/task-3-ignore-guard.txt
    Expected: 두 경로 모두 ignore 되지 않는다.
    Evidence: .sisyphus/evidence/task-3-ignore-guard.txt
  ```

  **Commit**: NO | Message: `n/a` | Files: `.gitignore`

- [ ] 4. HEAD에서 산출물 추적 해제 및 삭제

  **What to do**: `prompts/test_results/`의 4개 파일을 저장소 추적 대상에서 제거한다. 작업 방식은 작업트리 보존이 필요한지 여부에 따라 `git rm --cached` 또는 실제 파일 삭제 중 하나를 택하되, 결과적으로 HEAD에서는 파일이 사라지고 git 추적도 없어야 한다.
  **Must NOT do**: 루트 `prompts/dart_devtools_2025-11-19_11_00_26.216.json`을 함께 지우지 않는다. `.gitignore` 추가 전에 삭제만 수행해 재생성 파일이 다시 잡히는 상태를 만들지 않는다.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 파일 범위가 작고 절차가 명확한 git 정리 작업이다.
  - Skills: [`git-master`] — `git rm`/`git rm --cached` 선택과 staged 상태 검증이 핵심이다.
  - Omitted: [`update-omo-models`] — 무관.

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: 5, F1-F4 | Blocked By: 2, 3

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `prompts/test_results/` — 삭제 대상 디렉터리.
  - Pattern: `prompts/jank_mitigation_plan.md:3-7` — 삭제 전 문서 보존이 선행되어야 하는 이유.
  - Pattern: `.gitignore:1-49` — ignore 규칙 추가 위치의 기존 문맥.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `git ls-files -- "prompts/test_results"` 실행 결과가 비어 있다.
  - [ ] `git status --short` 실행 결과에 `prompts/test_results/` 관련 삭제와 `.gitignore`/문서 변경만 나타난다.
  - [ ] `grep -RInE 'prompts/test_results|adb_shell_top_-H-p\.txt|dumpsys_gfxinfo\.txt|dart_devtools_2025-11-26_13_55_10\.398\.json|dart_devtools_2025-11-26_13_59_18\.367\.json' prompts` 실행 시 stale reference가 남지 않는다.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Happy path remove tracked artifacts from HEAD
    Tool: Bash
    Steps: 1) git ls-files -- "prompts/test_results"
           2) git status --short
           3) Save outputs to .sisyphus/evidence/task-4-head-cleanup.txt
    Expected: prompts/test_results 경로는 더 이상 tracked 목록에 없고, 작업트리 변경은 계획 범위 파일만 포함한다.
    Evidence: .sisyphus/evidence/task-4-head-cleanup.txt

  Scenario: Failure/edge case - out-of-scope artifact touched
    Tool: Bash
    Steps: 1) git status --short -- "prompts/dart_devtools_2025-11-19_11_00_26.216.json"
           2) git status --short -- "coverage/lcov.info" "build.yaml"
           3) Save outputs to .sisyphus/evidence/task-4-scope-guard.txt
    Expected: 위 세 경로에는 변경이 없어야 한다.
    Evidence: .sisyphus/evidence/task-4-scope-guard.txt
  ```

  **Commit**: YES | Message: `chore(repo): stop tracking generated profiling artifacts` | Files: `.gitignore`, `prompts/test_results/*`

- [ ] 5. 원격 거부 시에만 history 정리 경로 판단

  **What to do**: HEAD 정리 후에도 GitHub push가 기존 대용량 blob 때문에 거부될 가능성을 별도 검증한다. 거부가 재현되면 이 task는 즉시 "history rewrite 승인 필요" 상태로 종료하고, 승인 없는 이력 재작성은 수행하지 않는다.
  **Must NOT do**: 기본 cleanup 흐름 안에서 `git filter-repo`, BFG, force-push 같은 이력 파괴 작업을 자동 실행하지 않는다.

  **Recommended Agent Profile**:
  - Category: `unspecified-low` — Reason: 실행은 가볍지만 판단 게이트와 안전장치가 중요하다.
  - Skills: [`git-master`] — history/blob 검증과 안전한 의사결정 분리가 핵심이다.
  - Omitted: [`update-omo-models`] — 무관.

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: F1-F4 | Blocked By: 4

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `prompts/test_results/dart_devtools_2025-11-26_13_55_10.398.json` — 103MB로 GitHub 제한에 직접 걸릴 수 있는 파일.
  - Pattern: `prompts/test_results/` — history 검사 대상 prefix.
  - Pattern: `prompts/dart_devtools_2025-11-19_11_00_26.216.json` — 이번 기본 정리 범위 밖이지만, history 문제가 남는지 설명할 때 참고 가능.
  - External: `https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github` — GitHub large file 제약 참고.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `git rev-list --objects --all | grep -E 'prompts/test_results/|prompts/dart_devtools_2025-11-19_11_00_26\.216\.json'` 결과를 evidence로 남긴다.
  - [ ] HEAD 정리만으로 충분한지, 아니면 history rewrite 승인이 필요한지 결론이 작업 로그에 명시된다.
  - [ ] 승인 없는 history rewrite 명령은 실행되지 않는다.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Happy path no further remediation needed
    Tool: Bash
    Steps: 1) (git rev-list --objects --all | grep -E 'prompts/test_results/|prompts/dart_devtools_2025-11-19_11_00_26\.216\.json' || true) > .sisyphus/evidence/task-5-history-check.raw.txt
           2) Write one-line verdict file: `head-cleanup-sufficient` or `history-rewrite-approval-needed`
           3) Save verdict to .sisyphus/evidence/task-5-history-check.txt
    Expected: 원시 출력과 단일 verdict 파일이 모두 남고, 둘의 내용이 서로 모순되지 않는다.
    Evidence: .sisyphus/evidence/task-5-history-check.txt

  Scenario: Failure/edge case - remote still rejects large blob
    Tool: Bash
    Steps: 1) Capture push/error diagnostics without rewriting history
           2) Record exact offending blob/path if available
           3) Save escalation note to .sisyphus/evidence/task-5-history-escalation.txt
    Expected: 자동 이력 재작성 없이 승인 요청용 근거만 남긴다.
    Evidence: .sisyphus/evidence/task-5-history-escalation.txt
  ```

  **Commit**: NO | Message: `n/a` | Files: none

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [ ] F1. Plan Compliance Audit — oracle
- [ ] F2. Code Quality Review — unspecified-high
- [ ] F3. Real Manual QA — unspecified-high (+ playwright if UI)
- [ ] F4. Scope Fidelity Check — deep

## Commit Strategy
- Commit 1: `docs(prompts): preserve profiling findings without raw artifact dependency`
- Commit 2: `chore(repo): stop tracking generated profiling artifacts`
- History remediation(필요 시): **별도 승인 후 별도 절차**로 수행하며, 일반 commit 흐름에 섞지 않는다.

## Success Criteria
- 저장소는 `prompts/test_results/`의 원시 성능 산출물을 더 이상 추적하지 않는다.
- 문서는 원시 파일이 없어도 조사 근거를 이해할 수 있다.
- 동일 유형 파일이 다시 생성되어도 git이 자동 추적하지 않는다.
- 푸시 실패 원인이 HEAD 파일인지 history blob인지 명확히 구분된다.
