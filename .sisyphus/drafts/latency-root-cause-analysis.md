# Draft: Latency Root Cause Analysis

## Requirements (confirmed)
- 현재까지 해결한 callback/build-time scheduling 외에, 예측 가능한 추가 지연 원인을 먼저 분석한다.
- 아직 구현/수정 계획은 세우지 않는다.
- 코드베이스 기준으로 남아 있을 만한 병목 후보를 우선순위 있게 보고한다.

## Technical Decisions
- callback 누적 문제와 겹치지 않는 원인군을 분리해서 조사한다.
- Flutter 앱 특성상 rebuild churn, sync I/O, timer/stream fanout, image/video work, layout overdraw, network/service blocking을 중심으로 본다.

## Research Findings
- pending

## Open Questions
- 없음 (우선 탐색으로 확인)

## Scope Boundaries
- INCLUDE: 코드 패턴 조사, 병목 가설, 근거 파일 경로
- EXCLUDE: 구현 계획, 소스 수정, 성능 계측 실행
