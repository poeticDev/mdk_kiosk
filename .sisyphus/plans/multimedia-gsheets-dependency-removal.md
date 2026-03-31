# Multimedia Google Sheets Dependency Removal

## TL;DR
> **Summary**: 멀티미디어 기능의 핵심 데이터 경로는 이미 MQTT + drift 구조이며, 실제 문제는 `DefaultMediaBox`가 시간표 구현체 `GoogleSheets`를 직접 참조하는 추상화 누수다. 이 작업은 멀티미디어의 시간표 표시 경로를 `TimetableRepository` 기반으로 정리하고, `Lecture` 도메인 모델에 남은 gsheets 흔적을 제거하는 범위로 제한한다.
> **Deliverables**:
> - `DefaultMediaBox`의 `GoogleSheets` 직접 의존 제거
> - 멀티미디어용 시간표 표시 경로를 `TimetableRepository`로 통일
> - `lecture.dart`의 gsheets-specific import/extension 정리
> - 멀티미디어/시간표 회귀 테스트 및 정적 의존 가드 추가
> **Effort**: Short
> **Parallel**: YES - 2 waves
> **Critical Path**: 1 → 2 → 4

## Context
### Original Request
- multimedia 섹션에서도 Google Sheets 관련 코드를 사용하고 있는 부분을 분석하고 싶다.
- 어떻게 변경하면 좋을지 의견을 제시해달라.
- 그 방향의 작업 계획을 정리해달라.

### Interview Summary
- 별도 인터뷰 질문 없이 저장소 탐색으로 사실관계를 확정했다.
- 문제의 본질은 “멀티미디어 기능이 Google Sheets를 쓴다”가 아니라, `DefaultMediaBox`가 시간표의 **구현체 타입**에 직접 의존한다는 점이다.
- Google Drive 다운로드 분기(`MediaFrom.gDrive`)는 다른 문제이므로 이번 범위에서 제외한다.
- Google Sheets 시간표 소스 자체는 아직 앱의 지원 소스이므로 제거하지 않는다.

### Metis Review (gaps addressed)
- `DefaultMediaBox`의 refresh 동작은 이번 작업에서 바꾸지 않고 유지한다.
- `lecture.dart`의 gsheets 정리는 같은 작업 묶음에 포함하되, 도메인 누수 제거에만 한정한다.
- 검증 범위는 `googleSheets`와 `localDb` 기준으로 두고, `localServer`는 초기화 계약의 fail-fast 유지 여부만 정적으로 확인한다.
- gDrive 다운로드/렌더링 경로는 범위 밖으로 명시한다.

## Work Objectives
### Core Objective
멀티미디어 섹션의 시간표 표시 경로가 `GoogleSheets` 구체 구현체를 직접 참조하지 않도록 정리해, 현재와 동일한 UI/refresh 동작을 유지하면서도 소스 선택(`googleSheets`/`localDb`/향후 `localServer`)에 독립적으로 동작하게 만든다.

### Deliverables
- `lib/multimedia/studio/default_media_box.dart`가 `TimetableRepository`만 의존하도록 변경
- `DefaultMediaBox` 동작을 잠그는 widget test 추가
- `lib/timetable/model/lecture.dart`에서 gsheets-specific import/extension 제거
- 멀티미디어 하위에 `GoogleSheets` 직접 import/조회가 남지 않음을 보장하는 정적 검증
- 기존 initializer/repository 계약 회귀 검증

### Definition of Done (verifiable conditions with commands)
- `grep -R -nE 'GetIt\.I<GoogleSheets>|package:mdk_kiosk/timetable/util/google_sheets\.dart' lib/multimedia`
- `grep -nE 'GsheetsMapper|LectureGsheetsExtension' lib/timetable/model/lecture.dart`
- `flutter test test/multimedia/studio/default_media_box_test.dart`
- `flutter test test/common/util/initializer_timetable_source_test.dart`
- `flutter test test/timetable/data/timetable_repository_contract_test.dart`
- `flutter test test/timetable/model/lecture_mapper_test.dart`
- `flutter analyze --fatal-infos`

### Must Have
- `DefaultMediaBox`는 `TimetableRepository`만 조회한다.
- 현재 00:00/12:00 refresh 예약 방식은 유지한다.
- `timetableUpdater` watch 기반 rebuild 유지
- `googleSheets`와 `localDb` 양쪽에서 `getLecturesForToday()` 사용 가능해야 한다.
- `lecture.dart`는 순수 도메인 모델로 유지되고 gsheets-specific API를 노출하지 않는다.

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- `GoogleSheets` 구현체 자체 삭제 금지
- `activeTimetableSource` 제거/변경 금지
- `DownloadManager`, `MediaFrom.gDrive`, `item_image.dart`, `item_video.dart` 리팩터링 금지
- `DefaultMediaBox`의 timer 주기/refresh 정책 변경 금지
- 멀티미디어 UI 레이아웃 변경 금지
- `localServer` 구현 추가 금지

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: tests-after + widget regression + static grep guard
- QA policy: Every task has agent-executed scenarios
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extract shared dependencies as Wave-1 tasks for max parallelism.

Wave 1: characterization tests, `DefaultMediaBox` repository refactor

Wave 2: lecture domain cleanup, static guard and regression consolidation

### Dependency Matrix (full, all tasks)
| Task | Depends On |
|---|---|
| 1 | - |
| 2 | 1 |
| 3 | 1 |
| 4 | 2, 3 |

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 2 tasks → unspecified-high
- Wave 2 → 2 tasks → unspecified-high / quick
- Final Verification → 4 review tasks in parallel

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [ ] 1. `DefaultMediaBox` 현재 동작을 characterization test로 잠그기

  **What to do**: `test/multimedia/studio/default_media_box_test.dart`를 새로 추가해 `DefaultMediaBox`가 `오늘의 강의실 스케쥴` 헤더와 오늘 강의 목록을 렌더링하는 현재 동작을 fake `TimetableRepository` 기준으로 검증한다. 테스트는 `googleSheets` 구현체를 등록하지 않고도 위젯이 동작하도록 설계해, 앞으로의 리팩터링이 concrete dependency 없이 가능하다는 사실을 먼저 증명한다. 타이머 로직은 구현을 바꾸지 않고, dispose 시 timer cancel로 예외 없이 종료되는지만 확인한다.
  **Must NOT do**: production code를 먼저 바꾸지 말 것. `DefaultMediaBox`의 refresh 정책을 이 테스트 단계에서 바꾸지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 위젯의 현재 동작을 안전하게 잠그는 characterization test 작성이 핵심이다.
  - Skills: `[]` — 기존 widget test 패턴과 fake repository로 충분하다.
  - Omitted: [`visual-engineering`] — UI 디자인 변경이 아니라 회귀 테스트 작성이다.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 2, 3 | Blocked By: none

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/multimedia/studio/default_media_box.dart:15-133` — 현재 위젯 구조, timer, `timetableUpdater` watch, `getLecturesForToday()` 사용 위치.
  - Pattern: `lib/timetable/component/timetable.dart:17-75` — `TimetableRepository`를 GetIt에서 읽는 패턴.
  - Pattern: `test/timetable/component/timetable_repository_widget_test.dart` — fake repository 기반 widget test 스타일.
  - API/Type: `lib/timetable/data/timetable_repository.dart:9-66` — fake가 구현해야 하는 계약.
  - UI: `lib/multimedia/studio/lecture_box_for_media_box.dart:6-49` — 렌더링되는 텍스트 구조.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/multimedia/studio/default_media_box_test.dart`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: repository-fed default media box renders today's lectures
    Tool: Bash
    Steps: run `flutter test test/multimedia/studio/default_media_box_test.dart`
    Expected: test passes with a fake TimetableRepository returning concrete lectures like Math / Physics, and the widget renders the header plus lecture rows without registering GoogleSheets
    Evidence: .sisyphus/evidence/task-1-default-media-box-test.log

  Scenario: empty lecture list remains safe
    Tool: Bash
    Steps: in the same test file, run the empty-list case where the fake repository returns []
    Expected: test passes, widget pumps without exception, and zero lecture rows are rendered
    Evidence: .sisyphus/evidence/task-1-default-media-box-empty.log
  ```

  **Commit**: YES | Message: `test(multimedia): lock default media box timetable behavior` | Files: `test/multimedia/studio/default_media_box_test.dart`

- [ ] 2. `DefaultMediaBox`를 `TimetableRepository` 기반으로 전환

  **What to do**: `lib/multimedia/studio/default_media_box.dart`에서 `GetIt.I<GoogleSheets>()`와 `package:mdk_kiosk/timetable/util/google_sheets.dart` import를 제거하고, `GetIt.I<TimetableRepository>()`를 사용하도록 바꾼다. `getLecturesForToday()` 호출 결과를 그대로 현재 UI에 전달하되, 00:00/12:00 refresh timer, `timetableUpdater` watch, header/lecture list UI는 그대로 유지한다. 이 작업은 “멀티미디어가 시간표 구현체를 모르는 상태”를 만드는 것이 목적이며, source selection은 initializer에 그대로 맡긴다.
  **Must NOT do**: `DefaultMediaBox`의 timer 주기/refresh 정책을 `supportsBackgroundRefresh` 기반으로 재설계하지 말 것. `MultimediaLayout`, `LectureBoxForMediaBox` 레이아웃을 건드리지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: behavior-preserving refactor로, 기존 표시/refresh 동작을 그대로 보존해야 한다.
  - Skills: `[]` — 현재 DI 패턴과 widget 구조 재사용이면 충분하다.
  - Omitted: [`quick`] — 단순 치환처럼 보이지만 regression 위험이 있어 더 신중한 실행이 필요하다.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 4 | Blocked By: 1

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/multimedia/studio/default_media_box.dart:22-80` — concrete dependency 제거 대상.
  - Pattern: `lib/timetable/component/timetable.dart:17-24` — `GetIt.I<TimetableRepository>()` 사용 패턴.
  - API/Type: `lib/timetable/data/timetable_repository.dart:20-38` — `getLecturesForToday()`, `refresh()`, `supportsBackgroundRefresh` 계약.
  - DI: `lib/common/util/initializer.dart:310-338` — source별 `TimetableRepository` 등록 지점.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `grep -R -nE 'GetIt\.I<GoogleSheets>|package:mdk_kiosk/timetable/util/google_sheets\.dart' lib/multimedia`
  - [ ] `flutter test test/multimedia/studio/default_media_box_test.dart`
  - [ ] `flutter analyze --fatal-infos`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: multimedia no longer imports or resolves GoogleSheets directly
    Tool: Bash
    Steps: run `grep -R -nE 'GetIt\.I<GoogleSheets>|package:mdk_kiosk/timetable/util/google_sheets\.dart' lib/multimedia`
    Expected: command returns no matches
    Evidence: .sisyphus/evidence/task-2-multimedia-grep.log

  Scenario: repository-backed media box preserves UI behavior
    Tool: Bash
    Steps: run `flutter test test/multimedia/studio/default_media_box_test.dart && flutter analyze --fatal-infos`
    Expected: tests pass and analyzer reports no issues after replacing concrete dependency with TimetableRepository
    Evidence: .sisyphus/evidence/task-2-default-media-box-regression.log
  ```

  **Commit**: YES | Message: `refactor(multimedia): use timetable repository in default media box` | Files: `lib/multimedia/studio/default_media_box.dart`, `test/multimedia/studio/default_media_box_test.dart`

- [ ] 3. `Lecture` 도메인 모델의 gsheets 누수 제거

  **What to do**: `lib/timetable/model/lecture.dart`에서 `GsheetsMapper` import와 `LectureGsheetsExtension`을 제거해 순수 도메인 모델로 만든다. 변경 전 `LectureGsheetsExtension` 참조를 전부 찾고, 필요한 경우 call site를 `GsheetsMapper` 직접 사용 또는 mapper 계층으로 이동시킨다. `Lecture`는 `Weekday`, `copyWith`, equality, 한국어 요일 getter만 유지한다.
  **Must NOT do**: `google_sheets.dart` 구현체 자체를 삭제하지 말 것. `Lecture`에 다른 source-specific helper를 다시 넣지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 도메인 순수성 회복과 call-site 정리가 필요하다.
  - Skills: `[]` — workspace reference 추적이면 충분하다.
  - Omitted: [`quick`] — 참조 누락 시 런타임/빌드 실패 위험이 있다.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 4 | Blocked By: 1

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/timetable/model/lecture.dart:1-112` — 제거 대상 import/extension과 유지해야 할 도메인 API.
  - Pattern: `lib/timetable/data/mappers/gsheets_mapper.dart` — gsheets 변환 로직이 남아야 할 유일한 위치.
  - Tooling: LSP references on `LectureGsheetsExtension`, `fromGsheets`, `toGsheets` — 변경 전 참조 전수조사 필수.
  - Contract: `lib/timetable/util/google_sheets.dart:63-80,163-173` — mapper를 직접 사용하는 기존 구현 참고.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `grep -nE 'GsheetsMapper|LectureGsheetsExtension' lib/timetable/model/lecture.dart`
  - [ ] `flutter test test/timetable/model/lecture_mapper_test.dart`
  - [ ] `flutter test test/timetable/data/timetable_repository_contract_test.dart`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: lecture domain no longer imports gsheets-specific helpers
    Tool: Bash
    Steps: run `grep -nE 'GsheetsMapper|LectureGsheetsExtension' lib/timetable/model/lecture.dart`
    Expected: command returns no matches
    Evidence: .sisyphus/evidence/task-3-lecture-domain-grep.log

  Scenario: mapper and contract regressions still pass after cleanup
    Tool: Bash
    Steps: run `flutter test test/timetable/model/lecture_mapper_test.dart && flutter test test/timetable/data/timetable_repository_contract_test.dart`
    Expected: both tests pass, proving gsheets conversion remains in mapper layer and contract remains intact
    Evidence: .sisyphus/evidence/task-3-lecture-domain-regression.log
  ```

  **Commit**: YES | Message: `refactor(timetable): remove gsheets leak from lecture model` | Files: `lib/timetable/model/lecture.dart`, related timetable call sites/tests only

- [ ] 4. 정적 의존 가드와 source 회귀 검증 정리

  **What to do**: 멀티미디어와 시간표 추상화가 다시 concrete dependency로 회귀하지 않도록 테스트/검증 경로를 정리한다. `test/common/util/initializer_timetable_source_test.dart`를 업데이트해 `googleSheets`와 `localDb`에서 `TimetableRepository`가 올바르게 resolve되는지 유지하고, `localServer`는 여전히 fail-fast임을 확인한다. 필요하면 `test/multimedia/studio/default_media_box_test.dart`에 source-agnostic fake 사용을 명시적으로 남기고, 멀티미디어 하위 `GoogleSheets` 직접 의존 0건을 CI 명령으로 검증 가능하게 문서화한다.
  **Must NOT do**: 실제 `googleSheets` 구현 제거 작업으로 확장하지 말 것. `item_image.dart`, `item_video.dart`, `download_manager.dart`를 이 task에 끌어들이지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 마지막 회귀 가드와 검증 경로 정리 작업이다.
  - Skills: `[]` — grep + existing tests 보강이면 충분하다.
  - Omitted: [`deep`] — 새로운 설계보다 안정화가 목적이다.

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: none | Blocked By: 2, 3

  **References** (executor has NO interview context — be exhaustive):
  - Test: `test/common/util/initializer_timetable_source_test.dart` — source resolution 회귀 검증 기준.
  - Test: `test/multimedia/studio/default_media_box_test.dart` — source-agnostic widget regression 기준.
  - DI: `lib/common/util/initializer.dart:316-337` — `googleSheets`/`localDb`/`localServer` 분기 계약.
  - Out-of-scope reminder: `lib/multimedia/component/item_image.dart:32-75`, `lib/multimedia/component/item_video.dart:34-84` — gDrive download branch는 이번 작업 대상이 아님.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/common/util/initializer_timetable_source_test.dart`
  - [ ] `flutter test test/multimedia/studio/default_media_box_test.dart`
  - [ ] `flutter analyze --fatal-infos`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: timetable sources still resolve correctly after multimedia refactor
    Tool: Bash
    Steps: run `flutter test test/common/util/initializer_timetable_source_test.dart`
    Expected: tests pass for googleSheets/localDb resolution and localServer fail-fast behavior
    Evidence: .sisyphus/evidence/task-4-source-resolution.log

  Scenario: full regression gate for multimedia timetable dependency cleanup
    Tool: Bash
    Steps: run `flutter test test/multimedia/studio/default_media_box_test.dart && flutter analyze --fatal-infos`
    Expected: multimedia timetable box remains source-agnostic and analyzer passes with no issues
    Evidence: .sisyphus/evidence/task-4-final-regression.log
  ```

  **Commit**: YES | Message: `test(multimedia): add dependency guard regressions` | Files: `test/multimedia/studio/**`, `test/common/util/**` only

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [ ] F1. Plan Compliance Audit — oracle

  **What to do**: oracle에게 이 플랜과 최종 diff를 비교시켜 Tasks 1-4의 구현 범위, Must NOT Have, acceptance criteria 준수 여부를 검토시킨다.
  **Acceptance Criteria**:
  - [ ] oracle가 `plan-compliant` verdict를 반환한다.
  **QA Scenario**:
  ```
  Scenario: implementation matches multimedia dependency cleanup plan
    Tool: task(oracle)
    Steps: review `.sisyphus/plans/multimedia-gsheets-dependency-removal.md`, final diff, and executed test outputs; compare implementation against Tasks 1-4 and all guardrails
    Expected: oracle approves or returns a bounded fix list; completion requires approval
    Evidence: .sisyphus/evidence/f1-plan-compliance.md
  ```

- [ ] F2. Code Quality Review — unspecified-high

  **What to do**: 별도 리뷰 에이전트가 abstraction boundary, timer 보존, fake-based widget tests, grep guard 적절성, 도메인 순수성 관점에서 코드 품질을 점검한다.
  **Acceptance Criteria**:
  - [ ] high-severity 이슈 0건으로 승인한다.
  **QA Scenario**:
  ```
  Scenario: code quality and maintainability review
    Tool: task(category="unspecified-high")
    Steps: inspect final code changes focusing on dependency inversion, refresh behavior preservation, test quality, and domain separation
    Expected: reviewer returns APPROVED or a severity-tagged fix list; completion requires no high-severity issue
    Evidence: .sisyphus/evidence/f2-code-quality.md
  ```

- [ ] F3. Real Manual QA — unspecified-high (+ playwright if UI)

  **What to do**: 에이전트가 앱을 실행해 멀티미디어 섹션의 `DefaultMediaBox`가 source 설정과 무관하게 깨지지 않는지 smoke QA를 수행한다. UI 실행이 필요하면 Playwright를 사용한다.
  **Acceptance Criteria**:
  - [ ] `flutter test test/multimedia/studio/default_media_box_test.dart`
  - [ ] `flutter test test/common/util/initializer_timetable_source_test.dart`
  - [ ] `flutter analyze --fatal-infos`
  - [ ] smoke QA 리포트가 happy/failure path 모두 통과다.
  **QA Scenario**:
  ```
  Scenario: end-to-end smoke for multimedia timetable box
    Tool: Bash + Playwright
    Steps: run the required tests and analyzer, then launch the app in localDb mode and verify the multimedia box renders the schedule section without GoogleSheets-specific crashes; repeat smoke verification in googleSheets mode if credentials are available in the environment
    Expected: commands succeed, multimedia box renders, and no direct GoogleSheets lookup error occurs
    Evidence: .sisyphus/evidence/f3-manual-qa.md
  ```

- [ ] F4. Scope Fidelity Check — deep

  **What to do**: deep reviewer가 실제 결과물이 멀티미디어 concrete dependency 제거 범위를 넘지 않았는지 점검한다. 특히 Google Sheets 전체 제거, gDrive 처리 리팩터링, refresh 정책 변경 여부를 확인한다.
  **Acceptance Criteria**:
  - [ ] deep reviewer가 `scope-clean` verdict를 반환한다.
  **QA Scenario**:
  ```
  Scenario: no out-of-scope multimedia transport changes shipped
    Tool: task(category="deep")
    Steps: compare final code and behavior against Must Have / Must NOT Have; flag any GoogleSheets source deletion, gDrive path refactor, media transport redesign, or refresh policy change in DefaultMediaBox
    Expected: reviewer confirms only approved scope was implemented, or returns a concrete remediation list
    Evidence: .sisyphus/evidence/f4-scope-fidelity.md
  ```

## Commit Strategy
- Commit 1: `test(multimedia): lock default media box timetable behavior`
- Commit 2: `refactor(multimedia): use timetable repository in default media box`
- Commit 3: `refactor(timetable): remove gsheets leak from lecture model`
- Commit 4: `test(multimedia): add dependency guard regressions`

## Success Criteria
- 멀티미디어 하위 코드에서 `GoogleSheets` 직접 의존이 0건이다.
- `DefaultMediaBox`는 `googleSheets`/`localDb` source 설정과 무관하게 동일한 UI 경로로 오늘 강의를 표시한다.
- `lecture.dart`는 gsheets 매퍼를 직접 import하지 않는다.
- gDrive 다운로드/미디어 렌더링 경로는 변경되지 않는다.
