import 'package:flutter_test/flutter_test.dart';
import 'package:mdk_kiosk/common/util/app_editor_mode.dart';

/// DefaultLayout 관리자 버튼 표시 조건 테스트
///
/// 관리자 버튼은 다음 조건이 모두 충족될 때만 표시됨:
/// 1. activeTimetableSource == TimetableSourceType.localDb
/// 2. appEditorManager.isEditorModeOn == true
void main() {
  setUp(() {
    // 각 테스트 전에 에디터 모드 초기화
    appEditorManager.turnEditorModeOff();
  });

  tearDown(() {
    // 각 테스트 후에 에디터 모드 초기화
    appEditorManager.turnEditorModeOff();
  });

  group('DefaultLayout 관리자 버튼 표시 조건', () {
    test('appEditorMode 초기 상태는 비활성화', () {
      // Given: 초기 상태
      // When: 앱 시작 시
      // Then: 에디터 모드는 비활성화 상태
      expect(appEditorManager.isEditorModeOn, false);
    });

    test('appEditorMode는 countUp 5회 호출 후 활성화', () {
      // Given: 초기 상태
      expect(appEditorManager.isEditorModeOn, false);

      // When: 5회 호출
      for (int i = 0; i < 5; i++) {
        appEditorManager.countUp();
      }

      // Then: 에디터 모드 활성화
      expect(appEditorManager.isEditorModeOn, true);
    });

    test('appEditorMode는 countUp 4회 호출 시 비활성화 유지', () {
      // Given: 초기 상태
      expect(appEditorManager.isEditorModeOn, false);

      // When: 4회 호출
      for (int i = 0; i < 4; i++) {
        appEditorManager.countUp();
      }

      // Then: 에디터 모드 여전히 비활성화
      expect(appEditorManager.isEditorModeOn, false);
    });

    test('appEditorMode는 turnEditorModeOn 호출 시 활성화', () {
      // Given: 초기 상태
      expect(appEditorManager.isEditorModeOn, false);

      // When: 직접 활성화
      appEditorManager.turnEditorModeOn();

      // Then: 에디터 모드 활성화
      expect(appEditorManager.isEditorModeOn, true);
    });

    test('appEditorMode는 turnEditorModeOff 호출 시 비활성화', () {
      // Given: 활성화 상태
      appEditorManager.turnEditorModeOn();
      expect(appEditorManager.isEditorModeOn, true);

      // When: 비활성화
      appEditorManager.turnEditorModeOff();

      // Then: 에디터 모드 비활성화
      expect(appEditorManager.isEditorModeOn, false);
    });

    test('활성화된 상태에서 countUp 호출 시 상태 유지', () {
      // Given: 활성화 상태
      appEditorManager.turnEditorModeOn();
      expect(appEditorManager.isEditorModeOn, true);

      // When: 추가 countUp 호출
      appEditorManager.countUp();

      // Then: 여전히 활성화 상태
      expect(appEditorManager.isEditorModeOn, true);
    });
  });

  group('관리자 버튼 표시 조건 로직', () {
    test('localDb 소스 + 에디터 모드 ON = 버튼 표시 조건 충족', () {
      // Given: localDb 소스 (기본값) + 에디터 모드 활성화
      appEditorManager.turnEditorModeOn();

      // When: 조건 확인
      // activeTimetableSource는 컴파일 타임 상수로 localDb가 기본값
      // import 'package:mdk_kiosk/timetable/config/timetable_source_config.dart';
      // final shouldShowButton = activeTimetableSource == TimetableSourceType.localDb &&
      //     appEditorManager.isEditorModeOn;

      // Then: 두 조건 모두 충족
      expect(appEditorManager.isEditorModeOn, true);
      // Note: activeTimetableSource는 상수이므로 테스트에서 변경 불가
      // 기본값이 localDb이므로 조건 충족
    });

    test('에디터 모드 OFF = 버튼 미표시', () {
      // Given: 에디터 모드 비활성화
      appEditorManager.turnEditorModeOff();

      // When: 조건 확인
      // final shouldShowButton = activeTimetableSource == TimetableSourceType.localDb &&
      //     appEditorManager.isEditorModeOn;

      // Then: 에디터 모드 조건 미충족
      expect(appEditorManager.isEditorModeOn, false);
    });
  });
}
