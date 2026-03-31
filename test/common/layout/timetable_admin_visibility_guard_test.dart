import 'package:flutter_test/flutter_test.dart';
import 'package:mdk_kiosk/timetable/config/timetable_source_config.dart';

/// 시간표 관리자 UI 가시성 가드 테스트
///
/// 관리자 UI가 올바른 조건에서만 표시되는지 검증합니다.
void main() {
  group('Timetable Admin Visibility Guard', () {
    test('localDb 모드는 editable=true', () {
      // Given & Then
      expect(activeTimetableSource, TimetableSourceType.localDb);
      expect(activeTimetableSource.isEditable, isTrue);
    });

    test('googleSheets 모드는 editable=false', () {
      // Given & Then
      expect(TimetableSourceType.googleSheets.isEditable, isFalse);
    });

    test('localServer 모드는 editable=false', () {
      // Given & Then
      expect(TimetableSourceType.localServer.isEditable, isFalse);
    });

    test('오직 localDb만 editable', () {
      // Given: 모든 소스 타입
      final sources = TimetableSourceType.values;

      // Then: localDb만 editable=true
      for (final source in sources) {
        if (source == TimetableSourceType.localDb) {
          expect(source.isEditable, isTrue);
        } else {
          expect(source.isEditable, isFalse);
        }
      }
    });
  });
}
