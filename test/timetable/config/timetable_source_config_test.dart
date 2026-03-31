import 'package:flutter_test/flutter_test.dart';
import 'package:mdk_kiosk/timetable/config/timetable_source_config.dart';

void main() {
  group('TimetableSourceType', () {
    test('enum has all three values', () {
      expect(TimetableSourceType.values.length, 3);
      expect(
        TimetableSourceType.values,
        contains(TimetableSourceType.googleSheets),
      );
      expect(TimetableSourceType.values, contains(TimetableSourceType.localDb));
      expect(
        TimetableSourceType.values,
        contains(TimetableSourceType.localServer),
      );
    });

    test('isEditable returns true only for localDb', () {
      expect(TimetableSourceType.googleSheets.isEditable, false);
      expect(TimetableSourceType.localDb.isEditable, true);
      expect(TimetableSourceType.localServer.isEditable, false);
    });
  });

  group('activeTimetableSource', () {
    test('is accessible', () {
      expect(activeTimetableSource, isNotNull);
      expect(activeTimetableSource, TimetableSourceType.localDb);
    });
  });
}
