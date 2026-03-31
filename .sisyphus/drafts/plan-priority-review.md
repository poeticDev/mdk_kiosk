# Draft: Plan Priority Review

## Requirements (confirmed)
- 기존 플랜에서 완료되지 않은 지점을 파악한다
- 새 플랜과의 우선순위를 검토한다
- 어떤 순서로 진행하는 게 좋은지 알려준다

## Technical Decisions
- active plan은 `timetable-data-source-management`로 유지 중이며, `boulder.json` 기준 세션이 누적된 상태
- 새 플랜은 `multimedia-gsheets-dependency-removal`로 별도 분리되어 있음
- 기존 플랜 문서 체크박스와 실제 저장소 완료 상태가 불일치함
- 새 플랜은 기존 플랜의 핵심 인프라(`TimetableRepository`, source resolver)에 의존하지만, 추가 구현 대기 상태는 아님
- 우선순위 결정: 새 플랜으로 전환하지 않고 기존 플랜의 미완료 항목을 먼저 마무리

## Research Findings
- `.sisyphus/boulder.json`: active plan은 기존 시간표 플랜
- 기존 플랜 체크박스는 Task 1-9, F1-F4가 모두 체크된 상태
- 새 플랜은 아직 모든 task가 미체크 상태
- 실제 저장소 기준 기존 플랜은 Task 1,2,4,5,7 완료 / Task 3,6,8 부분 완료 / Task 9 및 Final Verification 미완료로 재평가됨
- 기존 플랜 DoD에 포함된 `integration_test/timetable_admin_local_db_flow_test.dart` 및 Task 9 테스트 3종이 없음
- 전체 테스트 상태는 `+121 -12`로 실패가 남아 있어 기존 플랜을 완료로 보기 어려움
- 새 플랜의 핵심 변경 파일은 `lib/multimedia/studio/default_media_box.dart`, `lib/timetable/model/lecture.dart`로, 기존 플랜과 일부 파일 겹침은 있으나 선행 미완료 작업에 막히지는 않음

## Open Questions
- 없음 — 우선순위 판단에 필요한 정보는 확보됨

## Execution Order
1. 기존 플랜의 실패 테스트 원인 정리 및 복구 (특히 Google source preservation 계열)
2. 누락된 integration test 추가 (`integration_test/timetable_admin_local_db_flow_test.dart`)
3. 누락된 Task 9 테스트 3종 추가
4. Final Verification(F1-F4)를 실제 evidence 기반으로 다시 실행
5. 이후 `multimedia-gsheets-dependency-removal` 플랜 착수

## Scope Boundaries
- INCLUDE: 플랜 완료도/우선순위/전환 권고
- EXCLUDE: 실제 구현 시작, 코드 수정
