import 'package:flutter_test/flutter_test.dart';
import 'package:mdk_kiosk/timetable/config/timetable_source_config.dart';

void main() {
  group('Timetable Source Resolver', () {
    test('activeTimetableSource is set to localDb', () {
      expect(activeTimetableSource, equals(TimetableSourceType.localDb));
    });

    test('googleSheets source type is defined', () {
      expect(TimetableSourceType.googleSheets, isNotNull);
      expect(TimetableSourceType.googleSheets.name, equals('googleSheets'));
    });

    test('localDb source type is defined and is editable', () {
      expect(TimetableSourceType.localDb, isNotNull);
      expect(TimetableSourceType.localDb.name, equals('localDb'));
      expect(TimetableSourceType.localDb.isEditable, isTrue);
    });

    test('localServer source type is defined but not editable', () {
      expect(TimetableSourceType.localServer, isNotNull);
      expect(TimetableSourceType.localServer.name, equals('localServer'));
      expect(TimetableSourceType.localServer.isEditable, isFalse);
    });

    test('only localDb source is editable', () {
      expect(TimetableSourceType.googleSheets.isEditable, isFalse);
      expect(TimetableSourceType.localDb.isEditable, isTrue);
      expect(TimetableSourceType.localServer.isEditable, isFalse);
    });

    test('all source types are defined in enum', () {
      expect(TimetableSourceType.values.length, equals(3));
      expect(TimetableSourceType.values, contains(TimetableSourceType.googleSheets));
      expect(TimetableSourceType.values, contains(TimetableSourceType.localDb));
      expect(TimetableSourceType.values, contains(TimetableSourceType.localServer));
    });
  });

  group('TimetableSourceType extension', () {
    test('isEditable property works correctly for all types', () {
      for (final source in TimetableSourceType.values) {
        if (source == TimetableSourceType.localDb) {
          expect(source.isEditable, isTrue, reason: 'localDb should be editable');
        } else {
          expect(source.isEditable, isFalse, reason: '${source.name} should not be editable');
        }
      }
    });
  });
}
