# Repository Guidelines

## 프로젝트 구조 및 모듈 구성
- 저장소 루트에는 Flutter 앱 코드와 배포 스크립트가 공존하며, 비즈니스 로직은 `lib/`에 집중된다.
- `lib/common`은 상수, 테마, 공용 유틸을 보관하고 `lib/timetable`, `lib/multimedia`, `lib/header`는 각각 시간표, 미디어 재생, 레이아웃 기능을 담당한다.
- 플랫폼별 런처는 `android/`, `linux/`, `web/`에, 정적 자산은 `asset/`에 위치하며, 문서는 `README.md`, `AGENTS.md`에서 유지한다.

## 빌드·테스트·개발 명령
- `flutter pub get` : 의존성을 동기화하고 코드 생성 훅을 준비한다.
- `flutter analyze --fatal-infos` : `analysis_options.yaml` 규칙을 강제해 경고 없는 상태를 확인한다.
- `dart format lib test` : 전체 Dart 파일을 일관 규칙으로 포맷한다.
- `flutter test --coverage` : 단위·위젯 테스트를 실행하고 `coverage/lcov.info`를 만든다.
- `flutter run -d chrome --web-renderer canvaskit` : 키오스크 UI를 브라우저에서 검증한다.

## 코딩 스타일 및 네이밍
- 타입을 모든 선언에 명시하고 2칸 들여쓰기를 유지하며, 클래스는 PascalCase, 나머지는 camelCase, 파일·폴더는 snake_case를 사용한다.
- Riverpod Controller는 입력 메서드만 노출하고, 상태는 `freezed` 데이터 모델로 정의한다.
- 상수는 `lib/common/constants.dart`로 모으고, getIt 싱글톤을 통해 서비스·리포지토리를 주입한다.

## 테스트 지침
- 공개 메서드마다 AAA 패턴의 단위 테스트를 `test/feature_name/feature_name_test.dart` 구조로 추가한다.
- 위젯 테스트는 Given-When-Then 주석을 붙이고 `pumpWidget` 전후로 기대 상태를 명확히 검증한다.
- MQTT나 스케줄 연동은 모킹해 결정적 실행을 보장하며, `integration_test/`에서는 주요 사용자 시나리오를 자동화한다.

## 커밋 및 PR 가이드
- 조직 전체에 설정된 글로벌 커밋/PR 컨벤션을 준수한다.

## 보안 및 설정 팁
- 현장별 기본 정보는 `lib/common/basic_info.dart`나 비공개 `.env`에서 관리하고, 자격 증명은 깃에 커밋하지 않는다.
- MQTT, 서버 포트, 룸 식별자는 단일 소스에서 정의해 빌드별 설정 틀어짐을 막는다.
- 배포 전에는 `BasicInfo`와 `roomId` 규칙을 재검증해 시간표 동기화 실패를 예방한다.

## 커뮤니케이션 원칙
- 모든 사용자 응답은 항상 한국어로 제공한다.
- 추가 정보가 필요하면 먼저 질문해 명확성을 확보한다.
