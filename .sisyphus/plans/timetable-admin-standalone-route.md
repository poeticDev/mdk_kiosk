# Timetable Admin Standalone Route

## TL;DR
> **Summary**: 시간표 관리자 화면이 `DefaultLayout` 안에서 홈 화면 생명주기와 엮여 사라지는 문제를 해결하기 위해, `/admin/timetable`를 독립 전체화면 라우트로 분리하고 진입/복귀를 `push/pop` 기반으로 전환한다.
> **Deliverables**:
> - `/admin/timetable` 독립 라우트 전환
> - settings 버튼 `go → push` 변경
> - `TimetableAdminScreen` 명시적 뒤로가기 추가
> - 라우터/네비게이션 회귀 테스트 갱신
> - 임시 디버그 로그 정리
> **Effort**: Short
> **Parallel**: YES - 2 waves
> **Critical Path**: 1 → 2 → 3 → 4

## Context
### Original Request
- settings 아이콘으로 시간표 관리자 모드에 들어가면 `TimetableAdminScreen`이 잠깐 보였다가 사라진다.
- `DefaultLayout`의 `midChild`로 관리자 화면을 넣지 않고, 아예 새 페이지로 넘어가서 시간표를 관리하고 다시 원래 페이지로 돌아오게 하고 싶다.

### Interview Summary
- `/admin/timetable` 진입은 홈 화면에서 숨김 settings 버튼을 통해 발생한다.
- 현재 구현은 `DefaultLayout(midChild: TimetableAdminScreen())` 구조다.
- 로그상 settings 탭 직후 `TimetableAdminScreen initState/build` 다음에 `dispose`가 바로 발생한다.
- 사용자는 관리자 화면을 별도 페이지처럼 사용한 뒤 원래 화면으로 돌아오는 흐름을 선호한다.

### Metis Review (gaps addressed)
- 직접 진입(`/admin/timetable`) 시에는 `canPop == false`이면 `/home`으로 fallback 하도록 기본값 고정
- 숨김 settings 노출 조건(`localDb + editor mode`)은 유지
- CRUD/validation/business logic은 건드리지 않고 route composition만 수정
- 임시 디버그 로그는 같은 작업에서 제거

## Work Objectives
### Core Objective
시간표 관리자 화면을 홈 키오스크 레이아웃에서 분리해 독립 전체화면으로 표시하고, 스택 기반 네비게이션으로 안정적으로 진입/복귀하게 만든다.

### Deliverables
- `/admin/timetable`가 `TimetableAdminScreen` 단독 `Scaffold`를 렌더링
- 숨김 settings 버튼이 `context.push('/admin/timetable')` 사용
- `TimetableAdminScreen` AppBar에 `context.pop()` 우선, 불가 시 `/home` fallback 뒤로가기 추가
- 기존 `DefaultLayout` 기반 기대를 제거한 라우터/위젯 테스트
- 디버깅용 `print` 로그 제거

### Definition of Done (verifiable conditions with commands)
- `flutter test test/common/util/route/router_timetable_admin_test.dart`
- `flutter test test/common/layout/default_layout_timetable_admin_entry_test.dart`
- `flutter test test/timetable/admin/timetable_admin_screen_test.dart`
- `flutter test test/timetable/admin/timetable_admin_local_db_flow_test.dart`
- `flutter test test/timetable/admin/timetable_admin_validation_test.dart`
- `flutter analyze --fatal-infos`
- `flutter test`

### Must Have
- `/home`와 `/test`는 기존처럼 `DefaultLayout` 유지
- `/admin/timetable`는 `DefaultLayout` 없이 독립 화면
- settings 버튼은 여전히 `localDb + editor mode`에서만 보임
- 홈에서 관리자 화면 진입 후 뒤로가기로 원래 홈 화면 복귀 가능
- 직접 `/admin/timetable` 진입 시 뒤로가기는 `/home` fallback
- 관리자 화면 CRUD/validation/업데이트 동작은 기존과 동일

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- `DefaultLayout` 전면 리팩터링 금지
- `ShellRoute` 도입 금지
- editor mode 규칙(5회 탭, 30분 타이머) 변경 금지
- 시간표 데이터 소스/CRUD 비즈니스 로직 변경 금지
- `SplashScreen` 동작 변경 금지
- 멀티미디어/헤더/푸터 레이아웃 변경 금지

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: tests-after + focused route/widget regression + full suite
- QA policy: Every task has agent-executed scenarios
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extract shared dependencies as Wave-1 tasks for max parallelism.

Wave 1: route-behavior red tests, router contract refactor

Wave 2: admin screen back handling, hidden-entry regression, debug-log cleanup, full regression

### Dependency Matrix (full, all tasks)
| Task | Depends On |
|---|---|
| 1 | - |
| 2 | 1 |
| 3 | 2 |
| 4 | 2, 3 |

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 2 tasks → unspecified-high
- Wave 2 → 2 tasks → unspecified-high / quick
- Final Verification → 4 review tasks in parallel

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [x] 1. 관리자 라우트 기대 동작을 테스트로 먼저 고정

  **What to do**: `test/common/util/route/router_timetable_admin_test.dart`와 관련 라우터 테스트를 수정해 `/admin/timetable`가 더 이상 `DefaultLayout` 래퍼를 전제하지 않도록 바꾼다. 테스트는 경로 존재, 독립 화면 렌더링, `/home`은 여전히 `DefaultLayout` 사용, 직접 진입 시 뒤로가기 fallback 전제를 검증하도록 재구성한다.
  **Must NOT do**: production code를 먼저 수정하지 말 것. `DefaultLayout`을 요구하는 기존 잘못된 기대를 유지하지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 회귀 방지를 위해 route 기대 동작을 먼저 잠가야 한다.
  - Skills: `[]` — 기존 라우터 테스트 문맥으로 충분하다.
  - Omitted: [`visual-engineering`] — UI 변경이 아니라 계약 테스트 작업이다.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 2, 3, 4 | Blocked By: none

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/common/util/route/router.dart:8-34` — 현재 라우트 구조.
  - Pattern: `test/common/util/route/router_timetable_admin_test.dart:14-85` — 수정 대상 테스트.
  - Pattern: `lib/timetable/admin/timetable_admin_screen.dart:201-224` — 독립 화면으로 기대할 실제 위젯 구조.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/common/util/route/router_timetable_admin_test.dart`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: admin route contract reflects standalone page
    Tool: Bash
    Steps: run `flutter test test/common/util/route/router_timetable_admin_test.dart`
    Expected: tests pass asserting `/admin/timetable` exists, resolves to `TimetableAdminScreen`, and `/home` still resolves through `DefaultLayout`
    Evidence: .sisyphus/evidence/task-1-router-contract.log

  Scenario: direct-entry back expectation is encoded
    Tool: Bash
    Steps: in the same test file, assert direct entry to `/admin/timetable` uses `/home` fallback when no stack exists
    Expected: test passes with explicit direct-entry fallback behavior
    Evidence: .sisyphus/evidence/task-1-direct-entry-fallback.log
  ```

  **Commit**: YES | Message: `test(admin): standalone route expectations 고정` | Files: `test/common/util/route/**`

- [x] 2. `/admin/timetable`를 독립 전체화면 라우트로 전환

  **What to do**: `lib/common/util/route/router.dart`에서 `/admin/timetable` builder를 `DefaultLayout(midChild: TimetableAdminScreen())`에서 `const TimetableAdminScreen()`으로 바꾼다. `lib/common/layout/default_layout.dart`의 settings 버튼 네비게이션은 `context.go('/admin/timetable')`에서 `context.push('/admin/timetable')`로 변경한다. `/home`, `/test`, `/reinit`, `/splash`는 그대로 둔다.
  **Must NOT do**: `ShellRoute`를 새로 도입하지 말 것. `DefaultLayout` 내부의 다른 midChild 사용 경로를 바꾸지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: route composition과 back stack semantics를 동시에 바꾸는 핵심 수정이다.
  - Skills: `[]` — 현재 go_router 구조에 대한 국소 변경이면 충분하다.
  - Omitted: [`quick`] — navigation 회귀 위험이 있어 신중한 실행이 필요하다.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 3, 4 | Blocked By: 1

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/common/util/route/router.dart:21-33` — 수정 대상 route builder.
  - Pattern: `lib/common/layout/default_layout.dart:193-205` — 숨김 settings 버튼과 현행 `go` 호출.
  - Guidance: go_router stack navigation best practice — admin/detail screen은 `push`, 복귀는 `pop`.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/common/util/route/router_timetable_admin_test.dart`
  - [ ] `flutter test test/common/layout/default_layout_timetable_admin_entry_test.dart`
  - [ ] `flutter analyze --fatal-infos`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: hidden settings button pushes admin page
    Tool: Bash
    Steps: run `flutter test test/common/layout/default_layout_timetable_admin_entry_test.dart`
    Expected: tests pass showing the button only in localDb+editor mode and navigating to `/admin/timetable`
    Evidence: .sisyphus/evidence/task-2-settings-push.log

  Scenario: admin route no longer uses DefaultLayout
    Tool: Bash
    Steps: run `flutter test test/common/util/route/router_timetable_admin_test.dart && flutter analyze --fatal-infos`
    Expected: route tests and analyzer pass with `/admin/timetable` building `TimetableAdminScreen` directly
    Evidence: .sisyphus/evidence/task-2-standalone-route.log
  ```

  **Commit**: YES | Message: `refactor(admin): 시간표 관리자 화면을 독립 라우트로 분리` | Files: `lib/common/util/route/router.dart`, `lib/common/layout/default_layout.dart`, related route tests

- [x] 3. `TimetableAdminScreen`에 안전한 복귀 동작 추가

  **What to do**: `lib/timetable/admin/timetable_admin_screen.dart` AppBar에 명시적 뒤로가기 버튼을 추가한다. 동작은 `Navigator.canPop(context)` 또는 go_router 동등 API로 스택이 있으면 `context.pop()`, 없으면 `context.go('/home')` fallback으로 고정한다. 기존 refresh 액션, FAB, CRUD, SnackBar, `timetableUpdater` 트리거는 유지한다.
  **Must NOT do**: `TimetableAdminScreen`의 CRUD 비즈니스 로직을 손대지 말 것. 뒤로가기를 `/reinit`로 보내지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: direct-entry edge case까지 포함한 navigation safety가 필요하다.
  - Skills: `[]` — 기존 `Scaffold`/`AppBar` 문맥으로 충분하다.
  - Omitted: [`visual-engineering`] — 미관이 아니라 navigation semantics가 핵심이다.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 4 | Blocked By: 2

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/timetable/admin/timetable_admin_screen.dart:201-224` — 현재 AppBar/actions/FAB 구조.
  - Route: `lib/common/util/route/router.dart` — `/home` fallback 대상.
  - Test target: `test/timetable/admin/timetable_admin_screen_test.dart` — back navigation 회귀 검증 대상.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/timetable/admin/timetable_admin_screen_test.dart`
  - [ ] `flutter test test/timetable/admin/timetable_admin_local_db_flow_test.dart`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: stacked admin entry returns to home with pop
    Tool: Bash
    Steps: run `flutter test test/timetable/admin/timetable_admin_screen_test.dart`
    Expected: test passes showing entry from `/home` to admin via push and back returns to the previous screen
    Evidence: .sisyphus/evidence/task-3-admin-back-pop.log

  Scenario: direct admin entry falls back to /home
    Tool: Bash
    Steps: in the same test file, start directly at `/admin/timetable` with no back stack and trigger back
    Expected: test passes and lands on `/home`
    Evidence: .sisyphus/evidence/task-3-admin-back-fallback.log
  ```

  **Commit**: YES | Message: `feat(admin): 시간표 관리자 화면에 안전한 뒤로가기 추가` | Files: `lib/timetable/admin/timetable_admin_screen.dart`, `test/timetable/admin/**`

- [x] 4. 디버그 로그 제거 및 전체 회귀 검증

  **What to do**: `default_layout.dart`와 `timetable_admin_screen.dart`에 추가한 임시 `print` 디버그 로그를 제거하고, standalone route 기준으로 남은 테스트 명칭/주석을 정리한다. `default_layout_timetable_admin_entry_test.dart`, `router_timetable_admin_test.dart`, `timetable_admin_screen_test.dart`, `timetable_admin_local_db_flow_test.dart`, `timetable_admin_validation_test.dart`를 실행한 뒤 전체 `flutter test`와 `flutter analyze --fatal-infos`로 마감한다.
  **Must NOT do**: unrelated lint cleanup으로 범위를 확장하지 말 것. multimedia/timetable data source 로직까지 건드리지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 마감용 정리와 회귀 검증 작업이다.
  - Skills: `[]` — 테스트 실행과 국소 정리면 충분하다.
  - Omitted: [`deep`] — 새 설계보다 cleanup/verification이 목적이다.

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: none | Blocked By: 2, 3

  **References** (executor has NO interview context — be exhaustive):
  - Debug logs: `lib/common/layout/default_layout.dart:201-203`, `lib/timetable/admin/timetable_admin_screen.dart:34-35,191-200`
  - Regression tests: `test/common/layout/default_layout_timetable_admin_entry_test.dart`, `test/common/util/route/router_timetable_admin_test.dart`, `test/timetable/admin/timetable_admin_screen_test.dart`, `test/timetable/admin/timetable_admin_local_db_flow_test.dart`, `test/timetable/admin/timetable_admin_validation_test.dart`

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test`
  - [ ] `flutter analyze --fatal-infos`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: standalone admin route passes focused regression suite
    Tool: Bash
    Steps: run the focused admin/navigation test files listed above
    Expected: all targeted tests pass with no failing admin-route regressions
    Evidence: .sisyphus/evidence/task-4-focused-regression.log

  Scenario: full project remains green after route refactor
    Tool: Bash
    Steps: run `flutter test && flutter analyze --fatal-infos`
    Expected: all tests pass and analyzer exits successfully
    Evidence: .sisyphus/evidence/task-4-full-regression.log
  ```

  **Commit**: YES | Message: `test(admin): standalone 관리자 라우트 회귀 검증` | Files: relevant tests plus removal of temporary debug logs only

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [x] F1. Plan Compliance Audit — oracle

  **What to do**: oracle에게 플랜과 최종 diff를 비교시켜 standalone route 전환이 Tasks 1-4와 guardrails를 충족하는지 검토시킨다.
  **Acceptance Criteria**:
  - [ ] oracle가 `plan-compliant` verdict를 반환한다.
  **QA Scenario**:
  ```
  Scenario: implementation matches standalone admin route plan
    Tool: task(oracle)
    Steps: review `.sisyphus/plans/timetable-admin-standalone-route.md`, final diff, and executed test outputs; compare implementation against Tasks 1-4 and all guardrails
    Expected: oracle approves or returns a bounded remediation list
    Evidence: .sisyphus/evidence/f1-plan-compliance.md
  ```

- [x] F2. Code Quality Review — unspecified-high

  **What to do**: 리뷰 에이전트가 route composition, back-stack semantics, direct-entry fallback, test 품질을 점검한다.
  **Acceptance Criteria**:
  - [ ] high-severity 이슈 0건으로 승인한다.
  **QA Scenario**:
  ```
  Scenario: route and navigation quality review
    Tool: task(category="unspecified-high")
    Steps: inspect final code changes focusing on navigation semantics, route isolation, and regression test quality
    Expected: reviewer returns APPROVED or a severity-tagged fix list; completion requires no high-severity issue
    Evidence: .sisyphus/evidence/f2-code-quality.md
  ```

- [x] F3. Real Manual QA — unspecified-high (+ playwright if UI)

  **What to do**: 에이전트가 앱을 실행해 홈에서 settings 진입 → admin 화면 → 뒤로가기 복귀, 그리고 direct-entry fallback을 smoke QA로 검증한다.
  **Acceptance Criteria**:
  - [ ] `flutter test`
  - [ ] `flutter analyze --fatal-infos`
  - [ ] smoke QA가 stacked-entry와 direct-entry 모두 통과다.
  **QA Scenario**:
  ```
  Scenario: end-to-end admin navigation smoke test
    Tool: Bash + Playwright
    Steps: run full test/analyze, then verify from `/home` the hidden settings button opens the standalone admin page and back returns to home; separately verify direct `/admin/timetable` entry falls back to `/home`
    Expected: no disappearing screen, no stuck navigation, and CRUD screen renders stably
    Evidence: .sisyphus/evidence/f3-manual-qa.md
  ```

- [x] F4. Scope Fidelity Check — deep

  **What to do**: deep reviewer가 이번 변경이 route composition fix 범위를 넘지 않았는지 점검한다. 특히 `DefaultLayout` 전면 개편, ShellRoute 도입, editor mode 정책 변경 여부를 확인한다.
  **Acceptance Criteria**:
  - [ ] deep reviewer가 `scope-clean` verdict를 반환한다.
  **QA Scenario**:
  ```
  Scenario: no out-of-scope route architecture changes shipped
    Tool: task(category="deep")
    Steps: compare final code and behavior against Must Have / Must NOT Have; flag any ShellRoute introduction, DefaultLayout redesign, editor mode rule changes, or CRUD behavior changes
    Expected: reviewer confirms only approved scope was implemented, or returns a concrete remediation list
    Evidence: .sisyphus/evidence/f4-scope-fidelity.md
  ```

## Commit Strategy
- Commit 1: `test(admin): standalone route expectations 고정`
- Commit 2: `refactor(admin): 시간표 관리자 화면을 독립 라우트로 분리`
- Commit 3: `feat(admin): 시간표 관리자 화면에 안전한 뒤로가기 추가`
- Commit 4: `test(admin): standalone 관리자 라우트 회귀 검증`

## Success Criteria
- settings 버튼을 눌러도 `TimetableAdminScreen`이 즉시 사라지지 않는다.
- 관리자 화면은 `DefaultLayout` 없이 전체 화면으로 표시된다.
- 홈에서 진입한 경우 뒤로가기로 홈으로 복귀한다.
- 직접 `/admin/timetable` 진입 시 뒤로가기는 `/home`으로 fallback 한다.
- 숨김 settings 노출 조건과 CRUD 기능은 기존과 동일하다.
