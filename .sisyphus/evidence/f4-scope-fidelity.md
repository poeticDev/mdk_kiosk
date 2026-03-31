# F4 Scope Fidelity Check — Timetable Data Source Management

기준: `.sisyphus/plans/timetable-data-source-management.md` (Must Have / Must NOT Have)

검토 방법:
- `git diff main...HEAD`로 구현 범위 확인
- 관련 파일 직접 점검 (`lib/timetable/**`, `lib/common/layout/default_layout.dart`, `lib/common/util/initializer.dart`, `lib/common/util/data/drift.dart`, `lib/common/util/route/router.dart`)
- grep 기반 가드레일 점검 (`WidgetRef`, `localServer`, source 노출, sync/import/export)

---

## 1) Must NOT Have 점검

### A. 시간표 표시 레이아웃 전면 개편 금지
**결과: 위반(Out-of-scope)**

증거 (`git diff main...HEAD -- lib/timetable/timetable_layout.dart lib/timetable/component/lecture_box.dart`):
- `TimetableLayout` 기본값 변경
  - `columnLength: 10 -> 14`
  - `weekendOption: none -> includingSaturday`
  - `WeekendOption.includingSaturday` 신규 추가
- `LectureBox` 표시 스타일 변경
  - 텍스트 패딩 `12.0 -> 6.0`
  - 제목/부제 폰트 비율 상향 (`0.22 -> 0.33`, `0.20 -> 0.30`)
  - `maxLines` 증가 (`2 -> 4`)

위 변경은 단순 데이터 소스 전환 범위를 넘어 UI 렌더링/표시 규칙 자체를 변경함.

### B. 사용자 가시 source 선택 UI/토글 금지
**결과: 준수**

증거:
- `activeTimetableSource`는 코드 상수 (`lib/timetable/config/timetable_source_config.dart:21`)
- source 관련 분기는 initializer에서만 처리 (`lib/common/util/initializer.dart:316-337`)
- 관리자 화면(`lib/timetable/admin/*.dart`)에 source 토글/선택 UI 없음 (grep 무매치)

### C. import/export 기능 금지
**결과: 준수**

증거:
- `lib/timetable/admin/timetable_admin_screen.dart` 기능은 `추가/수정/삭제/새로고침`만 존재
- import/export 액션/텍스트/라우트/서비스 구현 없음

### D. Google Sheets ↔ local DB sync 구현 금지
**결과: 준수**

증거:
- 소스 선택은 switch 분기 단일 선택 (`lib/common/util/initializer.dart:316-337`)
- Google/Drift 동시 동작 및 교차 동기화 코드 없음
- `GoogleSheets`와 `DriftTimetableRepository`는 각각 별도 구현체로 독립

### E. localServer 실제 구현 금지(Stub 유지)
**결과: 준수**

증거:
- `TimetableSourceType.localServer`는 enum에만 존재 (`lib/timetable/config/timetable_source_config.dart:16`)
- 선택 시 즉시 `UnsupportedError` throw (`lib/common/util/initializer.dart:332-336`)

### F. repository 인터페이스에 WidgetRef 금지
**결과: 준수**

증거:
- `lib/timetable/data/timetable_repository.dart`는 순수 Dart 시그니처만 사용
- `WidgetRef` 미사용
- 참고: `lib/timetable/util/google_sheets_dep.dart`에 `WidgetRef`가 주석으로만 남아 있음(실행 코드 아님)

### G. unsupported source 자동 fallback 금지
**결과: 준수**

증거:
- `localServer` 선택 시 fallback 없이 즉시 실패 (`UnsupportedError`) (`lib/common/util/initializer.dart:332-336`)

---

## 2) Scope boundary 점검

### A. localDb 첫 시작 시 빈 시간표(시드 없음)
**결과: 준수**

증거:
- `Timetables` 테이블 정의만 추가 (`lib/common/util/data/model/timetable.dart`)
- 초기화 경로에 timetable seed insert 없음
- `createTimetable` 호출은 CRUD 경로(`DriftTimetableRepository`)에서만 발생

### B. Admin UI는 localDb + editor mode에서만 표시
**결과: 준수(표시 조건 기준)**

증거:
- 표시 조건: `activeTimetableSource == localDb && appEditorManager.isEditorModeOn`
  (`lib/common/layout/default_layout.dart:193-195`)
- 조건 만족 시에만 `/admin/timetable` 진입 버튼 렌더링

### C. Google Sheets 모드 기존 동작 유지
**결과: 위반 가능성 높음(Out-of-scope)**

증거 (`git diff main...HEAD -- lib/timetable/util/google_sheets.dart`):
- Google Sheet ID 변경
  - 이전: `1cDSkWV4GQohzon0JH_Wf58OM9mWjSxsUnu2yIm9y2rY`
  - 현재: `1l71ItWpm7zQ5EYC1ib7wBn5uDJhLagO0GRysxBVsmjs`
- Credential 경로 변경
  - 이전: `asset/env/credentials.json`
  - 현재: `asset/env/credentials_tu_lld.json`

데이터 소스 추상화 범위를 넘어 Google 운영 타깃/설정값이 변경되어 "기존 모드 동작 유지" 경계를 침범할 가능성이 큼.

---

## 최종 판정

**VERDICT: OUT-OF-SCOPE ITEMS FOUND**

식별된 out-of-scope 항목:
1. 시간표 표시 UI 변경(레이아웃 기본값/표시 스타일 변경)
2. Google Sheets 모드 운영 설정(Spreadsheet ID/credentials path) 변경
