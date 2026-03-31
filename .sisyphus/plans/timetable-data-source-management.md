# Timetable Data Source Management

## TL;DR
> **Summary**: 오프라인 디바이스에서도 시간표 기능을 유지하기 위해 현재 Google Sheets 직접 의존 구조를 백엔드 중립 시간표 리포지토리 구조로 리팩터링하고, drift 기반 로컬 DB 및 숨김 관리자 CRUD UI를 추가한다. 기존 시간표 표시 UI는 최대한 유지하고, 향후 localServer 소스는 내부 확장 포인트만 남긴다.
> **Deliverables**:
> - 개발자 상수 기반 시간표 소스 선택 구조 (`googleSheets` / `localDb` / `localServer`)
> - Google Sheets 어댑터 + drift 기반 로컬 시간표 저장소
> - 기존 UI를 유지하는 시간표 표시 계층 리팩터링
> - 숨김 관리자 진입 기반 로컬 시간표 CRUD UI
> - drift 마이그레이션 및 핵심 DB/위젯/통합 테스트
> **Effort**: Large
> **Parallel**: YES - 2 waves
> **Critical Path**: 1 → 2 → 3 → 6 → 7 → 8 → 9

## Context
### Original Request
- 현재 시간표 기능은 시간표 데이터 소스가 Google Sheets에 의존함
- 설치 디바이스는 웹 연결이 불가능하므로 새로운 시간표 입력 방법 필요
- UI는 최대한 현재 상태 유지
- 시간표 데이터는 인터페이스를 통해 갱신
- 개발자 설정으로 Google Sheets / 로컬 DB / 향후 로컬 서버 DB 방식 선택 가능해야 함
- 이번 구현 범위는 Google Sheets 유지 + drift 기반 로컬 DB 신규 구현 + 로컬 서버는 추후 확장 포인트만 확보
- 로컬 DB 사용 시 사용자가 디바이스에서 직접 관리할 시간표 관리 UI 필요
- 이번 관리 UI는 CRUD만 포함하고 가져오기/내보내기는 제외

### Interview Summary
- 시간표 소스 선택은 사용자 설정이 아니라 **개발자 상수**로 제어한다.
- 시간표 관리 UI 진입은 기존 화면을 어지럽히지 않도록 **숨김 관리자 진입**을 사용한다.
- 테스트는 저장소 전체 테스트 체계를 새로 만드는 대신 **핵심 drift/리포지토리 테스트 + 에이전트 QA**로 제한한다.
- localServer는 이번 릴리즈에서 **구현하지 않고 노출도 하지 않으며**, 내부 enum/분기/실패 처리만 만든다.

### Metis Review (gaps addressed)
- 데이터 소스 인터페이스에 `WidgetRef` 같은 Flutter 타입을 넣지 않는다.
- `Lecture` 도메인 모델에 Google Sheets 전용 매핑 로직을 계속 쌓지 않고, 소스별 매핑 계층으로 분리한다.
- drift는 기존 설치를 고려해 **schemaVersion 1 → 2 마이그레이션**을 포함한다.
- 기존 숨김 관리자 패턴(`appEditorManager`, `EditorWrapper`, `GoRouter`)을 재사용해 신규 진입 UX를 최소 변경으로 설계한다.
- localServer는 사용자에게 준비된 기능처럼 보이지 않게 하고, 선택 시 제어된 실패로 막는다.

## Work Objectives
### Core Objective
네트워크가 없는 디바이스에서도 시간표 표시 기능이 동일하게 동작하도록 시간표 데이터 소스를 추상화하고, `localDb` 모드에서 디바이스 내 CRUD 관리 UI를 제공한다.

### Deliverables
- `TimetableSourceType` 기반 개발자 설정 상수
- 백엔드 중립 `TimetableRepository` / `EditableTimetableRepository` 계약
- `GoogleSheets` 기반 어댑터 구현
- drift 시간표 테이블, 마이그레이션, CRUD 쿼리
- 로컬 DB 기반 시간표 관리 화면/다이얼로그/라우트
- localDb 모드 CRUD 후 즉시 시간표 반영
- unsupported `localServer` fail-fast 처리
- 핵심 테스트 및 에이전트 실행 QA 시나리오

### Definition of Done (verifiable conditions with commands)
- `flutter analyze --fatal-infos`
- `flutter test test/timetable`
- `flutter test test/common`
- `flutter test integration_test/timetable_admin_local_db_flow_test.dart -d chrome`
- `flutter test test/common/util/data/drift_migration_test.dart`

### Must Have
- 기존 `TimetableLayout` 기반 표시 UI 유지
- source selection은 개발자 상수에서만 제어
- `googleSheets` 모드의 현재 표시 동작 유지
- `localDb` 모드에서 숨김 관리자 UI로 생성/수정/삭제 가능
- local CRUD 결과가 시간표 표시 영역에 즉시 반영
- drift schema migration 포함
- roomId 스코프를 가진 로컬 시간표 저장 구조

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- 시간표 표시 레이아웃 전면 개편 금지
- source 선택 UI/토글을 사용자 또는 관리자 UI에 노출 금지
- import/export 구현 금지
- Google Sheets ↔ local DB 동기화 구현 금지
- localServer 실제 구현 금지
- `WidgetRef`를 repository/data source 인터페이스에 전달 금지
- unsupported source를 조용히 fallback 처리 금지

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: tests-after + Flutter `flutter_test` + drift migration tests + Chrome integration test
- QA policy: Every task has agent-executed scenarios
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extract shared dependencies as Wave-1 tasks for max parallelism.

Wave 1: source config/contract, Google adapter refactor, drift migration foundation, timetable DB persistence foundation, initializer wiring

Wave 2: timetable widget integration, hidden admin entry/route, local CRUD management UI, end-to-end validation

### Dependency Matrix (full, all tasks)
| Task | Depends On |
|---|---|
| 1 | - |
| 2 | 1 |
| 3 | 2 |
| 4 | 1 |
| 5 | 3, 4 |
| 6 | 3, 5 |
| 7 | 5, 6 |
| 8 | 5, 7 |
| 9 | 6, 8 |

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 5 tasks → quick / unspecified-low / unspecified-high
- Wave 2 → 4 tasks → unspecified-high / visual-engineering
- Final Verification → 4 review tasks in parallel

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [x] 1. 개발자 고정 시간표 소스 설정 추가

  **What to do**: `lib/timetable/config/timetable_source_config.dart`를 추가해 `TimetableSourceType { googleSheets, localDb, localServer }` enum과 `const activeTimetableSource`를 정의한다. 이 설정은 `BasicInfo` DB에 저장하지 말고 코드 상수로만 관리한다. `localServer`는 enum에는 포함하되 UI 노출 없이 내부 분기용으로만 유지한다.
  **Must NOT do**: source 선택값을 기존 `BasicInfo` 테이블 컬럼으로 추가하지 말 것. 관리자 UI에서 source를 바꾸게 만들지 말 것.

  **Recommended Agent Profile**:
  - Category: `quick` — Reason: 설정 상수와 enum 추가는 변경 범위가 작고 결정이 고정되어 있다.
  - Skills: `[]` — 별도 스킬 불필요.
  - Omitted: [`frontend-ui-ux`] — UI 작업이 아니다.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 2, 4, 5 | Blocked By: none

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/common/util/data/initial/initial_basic_info.dart:1-24` — 현장별 개발자 상수 정의 위치와 톤을 따른다.
  - Pattern: `lib/common/util/initializer.dart:38-100` — 초기화 시점에 설정값이 소비될 위치다.
  - API/Type: `lib/common/util/data/global_data.dart:34-49` — 런타임 DB 기반 값과 분리해야 할 데이터 경계다.
  - API/Type: `lib/common/util/data/model/basicInfo.dart:3-40` — BasicInfo 테이블에 source 컬럼을 추가하지 않도록 확인할 기준이다.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/timetable/config/timetable_source_config_test.dart`
  - [ ] `flutter analyze --fatal-infos`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: source enum and active source compile correctly
    Tool: Bash
    Steps: run `flutter test test/timetable/config/timetable_source_config_test.dart`
    Expected: test passes and verifies only `localDb` is marked editable, `localServer` is internal-only
    Evidence: .sisyphus/evidence/task-1-source-config.log

  Scenario: no BasicInfo persistence leakage
    Tool: Bash
    Steps: run `flutter analyze --fatal-infos`
    Expected: analyzer passes with no source-config-related type errors after keeping config outside `BasicInfo`
    Evidence: .sisyphus/evidence/task-1-source-config-analyze.log
  ```

  **Commit**: YES | Message: `feat(timetable): add source selection config` | Files: `lib/timetable/config/**`, `test/timetable/config/**`

- [x] 2. 중립 시간표 계약과 소스별 매퍼 분리

  **What to do**: `Lecture`는 표시 도메인 모델로 유지하되, `fromGsheets()` / `toGsheets()` / 시간 파싱 보조 로직을 Google Sheets 전용 매퍼 파일로 이동한다. 새 `TimetableRepository`는 `initialize()`, `List<Lecture> getLectures()`, `List<Lecture> getLecturesForToday()`, `Future<bool> refresh()`, `bool get supportsBackgroundRefresh`를 제공하고, 수정 가능 소스만 `EditableTimetableRepository`로 분리해 `createLecture`, `updateLecture`, `deleteLecture`를 노출한다. 모든 계약은 Flutter/Riverpod 타입 없이 순수 Dart 시그니처로 정의한다.
  **Must NOT do**: repository 인터페이스에 `WidgetRef`, `BuildContext`, `StateProvider`를 넣지 말 것. `Lecture`에 drift 전용 필드나 UI 전용 상태를 섞지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 도메인 경계와 향후 확장성을 결정하는 핵심 리팩터링이다.
  - Skills: `[]` — 저장소 패턴은 repo 문맥으로 충분하다.
  - Omitted: [`git-master`] — 구현 단계가 아니다.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 3, 5, 6, 8 | Blocked By: 1

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/timetable/model/lecture.dart:9-161` — 현재 도메인 모델과 Google Sheets 결합 지점을 분리해야 한다.
  - Pattern: `lib/timetable/util/google_sheets.dart:50-80` — 캐시/리프레시 책임이 새 repository 계약으로 이동할 지점이다.
  - Pattern: `lib/timetable/util/google_sheets.dart:147-187` — row insert/fetch/today filtering이 계약 분리 후에도 유지되어야 할 동작이다.
  - Pattern: `lib/timetable/component/timetable.dart:17-68` — UI가 의존하는 최소 읽기 계약을 역산할 기준이다.
  - Guardrail: `Metis review` — `WidgetRef`를 repository에 넣지 말고 source-specific mapper를 분리한다.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/timetable/model/lecture_mapper_test.dart`
  - [ ] `flutter test test/timetable/data/timetable_repository_contract_test.dart`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Google row maps to stable Lecture domain object
    Tool: Bash
    Steps: run `flutter test test/timetable/model/lecture_mapper_test.dart`
    Expected: test passes for sample row {id:1, lectureName:Math, instructorName:Kim, weekday:월, startAt:09:00, endAt:09:50, colorIndex:2}
    Evidence: .sisyphus/evidence/task-2-lecture-mapper.log

  Scenario: repository contract rejects Flutter-specific leakage
    Tool: Bash
    Steps: run `flutter test test/timetable/data/timetable_repository_contract_test.dart`
    Expected: contract tests pass and editable operations are only available through the editable sub-interface
    Evidence: .sisyphus/evidence/task-2-repository-contract.log
  ```

  **Commit**: YES | Message: `refactor(timetable): extract repository contract and mappers` | Files: `lib/timetable/model/**`, `lib/timetable/data/**`, `test/timetable/model/**`, `test/timetable/data/**`

- [x] 3. Google Sheets 구현을 repository 어댑터로 전환

  **What to do**: 현재 `GoogleSheets` 구현을 `TimetableRepository` 기반 어댑터로 바꾼다. `compareNFetchLectureCache(WidgetRef ref)`는 제거하고 `refresh()`가 변경 여부 `bool`을 반환하도록 바꾼다. 캐시는 repository 내부에만 두고, `googleSheets` 모드에서는 기존 10분 polling 동작을 유지할 수 있도록 `supportsBackgroundRefresh=true` 정책을 제공한다.
  **Must NOT do**: Google Sheets adapter가 직접 Riverpod state를 업데이트하지 말 것. 현재 spreadsheet id / credential path / roomId 기반 sheet title 동작을 바꾸지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 현재 핵심 기능을 깨뜨리지 않고 어댑터화해야 한다.
  - Skills: `[]` — 기존 코드 패턴만 따르면 된다.
  - Omitted: [`frontend-ui-ux`] — 표시 구조 변경이 핵심이 아니다.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 5, 6 | Blocked By: 2

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/timetable/util/google_sheets.dart:9-80` — 인증/worksheet 확보/캐시/변경감지 기존 구현.
  - Pattern: `lib/timetable/util/google_sheets.dart:105-187` — row 접근과 today filtering 동작.
  - Pattern: `lib/common/util/initializer.dart:91-96` — 현재 GoogleSheets 생성/초기화 등록 지점.
  - Pattern: `lib/timetable/component/timetable.dart:33-40` — 10분 주기 갱신 호출 위치.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/timetable/data/google_sheets_timetable_repository_test.dart`
  - [ ] `flutter test test/timetable/ui/timetable_google_source_preservation_test.dart`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: Google-backed repository preserves lecture cache behavior
    Tool: Bash
    Steps: run `flutter test test/timetable/data/google_sheets_timetable_repository_test.dart`
    Expected: test passes for initialize -> getLectures -> refresh changed/unchanged bool semantics using fake worksheet data
    Evidence: .sisyphus/evidence/task-3-google-repo.log

  Scenario: timetable render remains unchanged for Google mode
    Tool: Bash
    Steps: run `flutter test test/timetable/ui/timetable_google_source_preservation_test.dart`
    Expected: widget test passes and still renders Math / Kim in the expected timetable cell layout from repository-fed lectures
    Evidence: .sisyphus/evidence/task-3-google-ui.log
  ```

  **Commit**: YES | Message: `refactor(timetable): adapt google sheets repository` | Files: `lib/timetable/util/google_sheets.dart`, `lib/timetable/data/**`, `test/timetable/data/**`, `test/timetable/ui/**`

- [x] 4. drift 시간표 테이블과 v2 마이그레이션 추가

  **What to do**: 기존 `AppDatabase`에 시간표 테이블을 추가하고 `schemaVersion`을 2로 올린다. 테이블은 `id(autoIncrement)`, `roomId(text)`, `lectureName(text)`, `instructorName(text default '')`, `weekdayIndex(int)`, `startMinutes(int)`, `endMinutes(int)`, `colorIndex(int default 0)`, `createdAt(dateTime now)`를 사용한다. drift 권장 방식대로 `dart run drift_dev make-migrations`를 사용해 step-by-step migration 파일을 생성하고, `MigrationStrategy`를 구현해 v1 → v2 업그레이드를 검증한다.
  **Must NOT do**: 기존 `BasicInfo`, `Page`, `Button`, `MediaItem` 테이블을 깨뜨리거나 drop/recreate 하지 말 것. 시간 저장을 문자열로 중복 저장하지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 기존 설치 DB를 깨지 않게 drift 스키마를 확장해야 한다.
  - Skills: `[]` — drift 패턴은 문서와 기존 코드로 충분하다.
  - Omitted: [`frontend-ui-ux`] — 데이터 계층 작업이다.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 5, 9 | Blocked By: 1

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/common/util/data/drift.dart:12-40` — 현재 Drift DB 선언, `schemaVersion`, singleton 등록 위치.
  - Pattern: `lib/common/util/data/model/basicInfo.dart:3-40` — 기존 table 파일 작성 스타일.
  - External: `https://github.com/simolus3/drift/blob/develop/docs/content/migrations/index.md` — `make-migrations`와 step-by-step migration 작성 방식.
  - External: `https://github.com/simolus3/drift/blob/develop/docs/content/migrations/tests.md` — migration 검증 테스트 패턴.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `dart run drift_dev make-migrations`
  - [ ] `dart run build_runner build --delete-conflicting-outputs`
  - [ ] `flutter test test/common/util/data/drift_migration_test.dart`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: migration files generate cleanly for schema v2
    Tool: Bash
    Steps: run `dart run drift_dev make-migrations && dart run build_runner build --delete-conflicting-outputs`
    Expected: command succeeds and generates updated drift artifacts without conflicts
    Evidence: .sisyphus/evidence/task-4-drift-generation.log

  Scenario: v1 database migrates without losing existing tables
    Tool: Bash
    Steps: run `flutter test test/common/util/data/drift_migration_test.dart`
    Expected: test passes validating v1 -> v2 migration, new timetable table exists, old non-timetable tables remain queryable
    Evidence: .sisyphus/evidence/task-4-drift-migration.log
  ```

  **Commit**: YES | Message: `feat(drift): add timetable schema migration` | Files: `lib/common/util/data/drift.dart`, `lib/common/util/data/model/**`, generated drift migration files, `test/common/util/data/**`

- [x] 5. roomId 스코프 localDb repository와 source resolver 구현

  **What to do**: 새 timetable table을 대상으로 `AppDatabase`에 roomId 기준 CRUD/query 메서드를 추가하고, 이를 감싼 `DriftTimetableRepository`를 구현한다. query 정렬은 `weekdayIndex ASC, startMinutes ASC, id ASC`로 고정한다. `AppInitializer`에는 `activeTimetableSource`를 읽는 resolver/factory를 도입해 `googleSheets`면 Google adapter, `localDb`면 Drift repository를 등록하고, `localDb` 첫 사용 시에는 **빈 시간표로 시작**한다. `localServer`는 `UnsupportedError('Timetable source localServer is not implemented yet.')`로 fail-fast 한다.
  **Must NOT do**: roomId를 무시한 전역 시간표 테이블처럼 사용하지 말 것. `localServer`를 Google Sheets로 자동 fallback 하지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 저장소 구현과 초기화 분기, 실패 정책을 동시에 확정해야 한다.
  - Skills: `[]` — 기존 GetIt/initializer 패턴 재사용이면 충분하다.
  - Omitted: [`git-master`] — 구현과 무관하다.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 6, 7, 8, 9 | Blocked By: 3, 4

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/common/util/data/drift.dart:42-175` — 기존 CRUD 메서드와 DB 접근 스타일.
  - Pattern: `lib/common/util/initializer.dart:63-96` — DB open 후 서비스 초기화와 GetIt 등록 순서.
  - Pattern: `lib/common/util/initializer.dart:123-127` — reinit 시 동일한 registration 흐름을 맞춰야 한다.
  - API/Type: `lib/common/util/data/global_data.dart:13-18` — roomId를 현재 장비 컨텍스트로 읽을 위치.
  - API/Type: `lib/common/util/data/updaters.dart:5-18` — local CRUD 후 UI 갱신 신호를 보낼 기존 provider.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/timetable/data/drift_timetable_repository_test.dart`
  - [ ] `flutter test test/common/util/initializer_timetable_source_test.dart`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: localDb repository CRUD is room-scoped and ordered
    Tool: Bash
    Steps: run `flutter test test/timetable/data/drift_timetable_repository_test.dart`
    Expected: test passes confirming records for room A do not leak to room B and list order is weekday/start time ascending
    Evidence: .sisyphus/evidence/task-5-localdb-repo.log

  Scenario: source resolver registers the correct implementation and fails fast for localServer
    Tool: Bash
    Steps: run `flutter test test/common/util/initializer_timetable_source_test.dart`
    Expected: test passes for googleSheets/localDb resolution and asserts controlled failure for localServer selection
    Evidence: .sisyphus/evidence/task-5-source-resolver.log
  ```

  **Commit**: YES | Message: `feat(timetable): wire local db repository and source resolver` | Files: `lib/common/util/initializer.dart`, `lib/common/util/data/drift.dart`, `lib/timetable/data/**`, `test/timetable/data/**`, `test/common/util/**`

- [x] 6. Timetable 위젯을 repository 기반으로 전환하되 표시 UI 유지

  **What to do**: `Timetable`은 더 이상 `GetIt.I<GoogleSheets>()`에 직접 의존하지 않고 `GetIt.I<TimetableRepository>()`만 사용한다. `build()`는 repository가 제공하는 현재 lecture 목록을 그대로 `TimetableLayout`에 전달한다. `supportsBackgroundRefresh=true`인 source에서만 10분 polling timer를 시작하고, `refresh()`가 `true`를 반환할 때만 `timetableUpdater`를 갱신한다. `localDb`는 타이머를 시작하지 않고 CRUD 완료 시 갱신 notifier만 사용한다.
  **Must NOT do**: `TimetableLayout`이나 `LectureBox`의 레이아웃 계산식을 변경하지 말 것. localDb 모드에서 불필요한 10분 polling을 돌리지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 기존 화면을 그대로 유지하면서 의존성만 바꿔야 한다.
  - Skills: `[]` — 기존 위젯 구조 재사용.
  - Omitted: [`frontend-ui-ux`] — 시각 재설계가 아니라 보존 작업이다.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 7, 8, 9 | Blocked By: 3, 5

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/timetable/component/timetable.dart:10-68` — direct GoogleSheets 의존과 polling 위치.
  - Pattern: `lib/common/util/data/updaters.dart:5-18` — timetable rebuild 트리거 방식.
  - Pattern: `lib/timetable/timetable_layout.dart:21-207` — 최대한 유지해야 할 표시 경계.
  - Pattern: `lib/timetable/component/lecture_box.dart:31-98` — lecture 표시 계산식 보존 기준.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/timetable/component/timetable_repository_widget_test.dart`
  - [ ] `flutter test test/timetable/component/timetable_refresh_policy_test.dart`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: repository-backed timetable still renders lectures in current layout
    Tool: Bash
    Steps: run `flutter test test/timetable/component/timetable_repository_widget_test.dart`
    Expected: widget test passes and renders Math / Kim with unchanged timetable layout when repository returns lectures
    Evidence: .sisyphus/evidence/task-6-timetable-widget.log

  Scenario: refresh policy differs by source as designed
    Tool: Bash
    Steps: run `flutter test test/timetable/component/timetable_refresh_policy_test.dart`
    Expected: test passes asserting Google source starts polling and localDb source skips polling but still responds to notifier updates
    Evidence: .sisyphus/evidence/task-6-refresh-policy.log
  ```

  **Commit**: YES | Message: `refactor(timetable): consume repository in timetable widget` | Files: `lib/timetable/component/timetable.dart`, `test/timetable/component/**`

- [x] 7. localDb 전용 숨김 관리자 진입과 관리자 라우트 추가

  **What to do**: 기존 5회 탭 기반 `appEditorManager` 관리자 모드는 그대로 재사용한다. 여기에 더해 `activeTimetableSource == localDb && appEditorManager.isEditorModeOn`일 때만 시간표 영역에 작은 관리자 진입 버튼을 노출하고, 탭 시 `'/admin/timetable'`로 이동하게 한다. 이 버튼은 normal mode, `googleSheets`, `localServer`에서는 절대 보이지 않아야 한다.
  **Must NOT do**: 일반 사용자에게 항상 보이는 버튼이나 메뉴를 추가하지 말 것. Google Sheets 모드에서 CRUD UI 진입 경로를 열지 말 것.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` — Reason: 기존 레이아웃을 거의 유지하면서 admin-only affordance를 자연스럽게 얹어야 한다.
  - Skills: [] — 기존 레이아웃 패턴과 go_router만 사용한다.
  - Omitted: [`frontend-ui-ux`] — 별도 디자인 탐색보다 기존 UI 보존이 우선이다.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 8, 9 | Blocked By: 5, 6

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/common/util/app_editor_mode.dart:10-42` — 5회 탭 활성화/30분 유지 규칙.
  - Pattern: `lib/common/layout/default_layout.dart:184-186` — timetable이 렌더링되는 영역.
  - Pattern: `lib/common/layout/default_layout.dart:226-267` — 기존 관리자 모드 진입 트리거(로고 탭) 구현.
  - Pattern: `lib/common/util/route/router.dart:7-42` — hidden admin route를 추가할 라우터 위치.
  - Pattern: `lib/common/component/editor_dialog.dart:20-61` — editor mode일 때만 상호작용을 허용하는 기존 UX 사고방식.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/common/layout/default_layout_timetable_admin_entry_test.dart`
  - [ ] `flutter test test/common/util/route/router_timetable_admin_test.dart`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: admin entry appears only in localDb editor mode
    Tool: Bash
    Steps: run `flutter test test/common/layout/default_layout_timetable_admin_entry_test.dart`
    Expected: widget test passes showing the admin button only when source=localDb and editor mode is on
    Evidence: .sisyphus/evidence/task-7-admin-entry.log

  Scenario: hidden admin route is registered and navigable
    Tool: Bash
    Steps: run `flutter test test/common/util/route/router_timetable_admin_test.dart`
    Expected: router test passes and `/admin/timetable` resolves while remaining unreachable from non-admin affordances
    Evidence: .sisyphus/evidence/task-7-admin-route.log
  ```

  **Commit**: YES | Message: `feat(admin): add hidden timetable management entry` | Files: `lib/common/layout/default_layout.dart`, `lib/common/util/route/router.dart`, `test/common/layout/**`, `test/common/util/route/**`

- [x] 8. localDb 전용 시간표 관리 화면과 CRUD 폼 구현

  **What to do**: `'/admin/timetable'`는 정확히 `DefaultLayout(midChild: TimetableAdminScreen())`로 구성한다. `TimetableAdminScreen`은 현재 roomId 기준 시간표 목록을 정렬 표시하고, `추가`, `수정`, `삭제`를 제공한다. 편집 폼은 기존 `CustomDialog`, `CustomTextFormField` 스타일을 재사용하고, 필드는 `lectureName`, `instructorName`, `weekday`, `startAt(HH:mm)`, `endAt(HH:mm)`, `colorIndex(0-5)`로 고정한다. 저장/삭제 성공 시 repository를 호출한 뒤 `timetableUpdater`를 즉시 갱신하고 목록을 새로고침한다.
  **Must NOT do**: source 전환 토글, import/export, bulk edit를 추가하지 말 것. Google Sheets 또는 localServer 모드에서도 이 화면이 편집 가능하게 열리지 않게 할 것.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` — Reason: 관리자 UI는 새로 만들되 기존 디자인 컴포넌트 어법을 맞춰야 한다.
  - Skills: [] — 현재 custom dialog/form component 재사용이면 충분하다.
  - Omitted: [`frontend-ui-ux`] — 창의적 재디자인보다 일관성과 테스트 용이성이 중요하다.

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: 9 | Blocked By: 5, 7

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/common/component/editor_dialog.dart:64-311` — BasicInfo 편집 dialog 구조와 저장/취소 버튼 패턴.
  - Pattern: `lib/common/component/editor_dialog.dart:313-743` — DB-backed CRUD dialog와 toggle/form 처리 패턴.
  - Pattern: `lib/timetable/model/lecture.dart:10-27` — 편집 대상 도메인 필드.
  - Pattern: `lib/common/util/data/updaters.dart:13-18` — CRUD 후 홈 시간표 갱신 트리거.
  - Pattern: `lib/common/util/route/router.dart:27-38` — `DefaultLayout(midChild: ...)` 형태의 화면 구성 패턴.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/timetable/admin/timetable_admin_screen_test.dart`
  - [ ] `flutter test integration_test/timetable_admin_local_db_flow_test.dart -d chrome`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: localDb admin UI performs create-update-delete successfully
    Tool: Bash
    Steps: run `flutter test integration_test/timetable_admin_local_db_flow_test.dart -d chrome`
    Expected: integration test passes creating Math(월 09:00-09:50), editing it to Physics, then deleting it and confirming the home timetable updates each time
    Evidence: .sisyphus/evidence/task-8-admin-crud.log

  Scenario: admin screen widgets and test keys are stable
    Tool: Bash
    Steps: run `flutter test test/timetable/admin/timetable_admin_screen_test.dart`
    Expected: widget test passes and finds keys `timetable-admin-open-button`, `timetable-admin-add-button`, `timetable-admin-save-button`, `timetable-admin-delete-button`, `timetable-admin-lecture-name`, `timetable-admin-weekday`, `timetable-admin-start-at`, `timetable-admin-end-at`
    Evidence: .sisyphus/evidence/task-8-admin-screen.log
  ```

  **Commit**: YES | Message: `feat(timetable): add local timetable admin ui` | Files: `lib/timetable/admin/**`, `lib/common/util/route/router.dart`, `test/timetable/admin/**`, `integration_test/**`

- [x] 9. 빈 로컬 DB·유효성·모드 가드 엣지케이스 하드닝

  **What to do**: `localDb`가 비어 있을 때 홈 시간표는 crash 없이 빈 상태로 렌더링되고, 관리자 화면에는 명시적 empty state 문구를 보여준다. CRUD 폼은 `lectureName` 필수, `HH:mm` 파싱 성공, `endAt > startAt`, `colorIndex` 0~5 범위만 허용한다. `googleSheets`와 `localServer`에서는 관리자 버튼/편집 화면이 비활성 또는 미노출이어야 하고, unsupported `localServer`는 initializer 단위 테스트에서 fail-fast를 유지한다.
  **Must NOT do**: 빈 시간표일 때 임의 더미 데이터로 채우지 말 것. 잘못된 입력을 조용히 보정해서 저장하지 말 것.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: 실패 경로와 경계 조건을 명확히 잠그는 안정화 작업이다.
  - Skills: [] — 테스트 주도 hardening이면 충분하다.
  - Omitted: [`frontend-ui-ux`] — 시각 작업보다 validation/guardrail 중심이다.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: none | Blocked By: 4, 5, 6, 7, 8

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `lib/timetable/component/timetable.dart:52-68` — lecture list empty 시 현재 build 경계.
  - Pattern: `lib/timetable/timetable_layout.dart:157-200` — empty lecture list여도 Stack/Column이 안전하게 렌더링되는 구조.
  - Pattern: `lib/common/util/app_editor_mode.dart:14-42` — 관리자 모드 활성화/종료 수명주기.
  - Pattern: `lib/common/util/initializer.dart:91-96` — source 초기화 failure 경계.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `flutter test test/timetable/admin/timetable_admin_validation_test.dart`
  - [ ] `flutter test test/timetable/ui/timetable_local_empty_state_test.dart`
  - [ ] `flutter test test/common/layout/timetable_admin_visibility_guard_test.dart`

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```
  Scenario: empty local database is safe
    Tool: Bash
    Steps: run `flutter test test/timetable/ui/timetable_local_empty_state_test.dart`
    Expected: widget test passes and the home timetable renders without crash while the admin screen shows the configured empty-state text
    Evidence: .sisyphus/evidence/task-9-empty-localdb.log

  Scenario: invalid admin input is rejected and non-local modes stay hidden
    Tool: Bash
    Steps: run `flutter test test/timetable/admin/timetable_admin_validation_test.dart && flutter test test/common/layout/timetable_admin_visibility_guard_test.dart`
    Expected: tests pass rejecting empty title / malformed time / end-before-start and confirming admin affordance is hidden for googleSheets/localServer
    Evidence: .sisyphus/evidence/task-9-validation-guards.log
  ```

  **Commit**: YES | Message: `test(timetable): harden offline timetable edge cases` | Files: `lib/timetable/admin/**`, `test/timetable/admin/**`, `test/timetable/ui/**`, `test/common/layout/**`

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [x] F1. Plan Compliance Audit — oracle

  **What to do**: oracle에게 이 플랜 파일과 실제 변경 diff를 함께 검토시켜 Tasks 1-9의 계약, 가드레일, acceptance criteria, file reference 준수 여부를 대조한다.
  **Acceptance Criteria**:
  - [ ] oracle가 “plan-compliant” verdict를 반환한다.
  **QA Scenario**:
  ```
  Scenario: implementation matches Prometheus plan
    Tool: task(oracle)
    Steps: review `.sisyphus/plans/timetable-data-source-management.md`, final git diff, and executed test outputs; compare each implemented change against Tasks 1-9 and reject any missing guardrail or skipped acceptance criterion
    Expected: oracle report explicitly approves plan compliance or returns a concrete fix list
    Evidence: .sisyphus/evidence/f1-plan-compliance.md
  ```

- [x] F2. Code Quality Review — unspecified-high

  **What to do**: 별도 리뷰 에이전트가 drift migration 안전성, repository 경계, route gating, validation 누락, test quality를 코드 레벨에서 점검한다.
  **Acceptance Criteria**:
  - [ ] 리뷰 에이전트가 치명도 high 이슈 0건으로 승인한다.
  **QA Scenario**:
  ```
  Scenario: code quality and maintainability review
    Tool: task(category="unspecified-high")
    Steps: inspect final code changes focusing on repository abstraction boundaries, migration safety, duplicated logic, invalid UI coupling, and brittle tests
    Expected: reviewer returns APPROVED or a bounded fix list with severity tags; completion requires no remaining high-severity issue
    Evidence: .sisyphus/evidence/f2-code-quality.md
  ```

- [x] F3. Real Manual QA — unspecified-high (+ playwright if UI)

  **What to do**: 에이전트가 실제 앱을 실행해 `googleSheets`와 `localDb` 모드 핵심 사용자 흐름을 재검증한다. UI 상호작용이 포함되므로 필요 시 Playwright를 사용한다.
  **Acceptance Criteria**:
  - [ ] `flutter analyze --fatal-infos`
  - [ ] `flutter test`
  - [ ] `flutter test integration_test/timetable_admin_local_db_flow_test.dart -d chrome`
  - [ ] 수동 QA 리포트가 happy/failure path 모두 통과로 기록된다.
  **QA Scenario**:
  ```
  Scenario: end-to-end offline timetable verification
    Tool: Bash + Playwright
    Steps: run `flutter analyze --fatal-infos`, run `flutter test`, run `flutter test integration_test/timetable_admin_local_db_flow_test.dart -d chrome`, then launch the app in localDb mode and verify create/edit/delete plus hidden-admin visibility gating; repeat smoke verification in googleSheets mode
    Expected: all commands succeed, CRUD flow works in localDb, admin entry stays hidden in googleSheets, and no crash occurs on empty local timetable
    Evidence: .sisyphus/evidence/f3-manual-qa.md
  ```

- [x] F4. Scope Fidelity Check — deep

  **What to do**: deep reviewer가 실제 결과물이 “이번 범위”를 넘지 않았는지 검토한다. 특히 source switch UI 노출, import/export, sync, localServer 실제 구현, timetable UI 전면 개편 여부를 확인한다.
  **Acceptance Criteria**:
  - [ ] deep reviewer가 scope-clean verdict를 반환한다.
  **QA Scenario**:
  ```
  Scenario: no out-of-scope work shipped
    Tool: task(category="deep")
    Steps: compare final code and behavior against the Must Have / Must NOT Have sections; flag any import/export, sync, visible source selector, or localServer implementation beyond fail-fast stub
    Expected: reviewer confirms only approved scope was implemented, or returns a concrete out-of-scope remediation list
    Evidence: .sisyphus/evidence/f4-scope-fidelity.md
  ```

## Commit Strategy
- Commit 1: `feat(timetable): add source config and neutral repository contract`
- Commit 2: `refactor(timetable): adapt google sheets to repository abstraction`
- Commit 3: `feat(drift): add timetable schema and migration`
- Commit 4: `feat(timetable): wire source resolver and local db repository`
- Commit 5: `feat(admin): add hidden local timetable management ui`
- Commit 6: `test(timetable): cover offline timetable flows and migration`

## Success Criteria
- 홈 화면에서 기존 시간표 표시 방식이 유지된다.
- `googleSheets` 모드에서는 현재 데이터 표시 동작과 주기 갱신이 유지된다.
- `localDb` 모드에서는 네트워크 없이 시간표 CRUD 및 표시 갱신이 가능하다.
- `localServer`는 코드상 확장 포인트는 존재하지만 UI에 노출되지 않고 선택 시 제어된 실패를 낸다.
- drift DB 업그레이드가 기존 비-시간표 테이블을 손상시키지 않는다.
