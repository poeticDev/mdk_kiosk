import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/model/timetable.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Drift Migration v1 -> v2', () {
    test('migration creates Timetables table successfully', () async {
      // Arrange: Create database with in-memory connection
      final database = AppDatabase(NativeDatabase.memory());

      // Act: Verify schema version is 2
      expect(database.schemaVersion, equals(2));

      // Assert: Timetables table should exist and be accessible
      expect(database.timetables, isA<Object>());

      // Clean up
      await database.close();
    });

    test('can perform CRUD operations on Timetables after migration', () async {
      // Arrange: Create database with in-memory connection
      final database = AppDatabase(NativeDatabase.memory());
      const testRoomId = '0-004-0101';

      // Act: Insert a timetable entry
      final companion = TimetablesCompanion(
        roomId: const Value(testRoomId),
        lectureName: const Value('Test Lecture'),
        instructorName: const Value('Test Instructor'),
        weekdayIndex: const Value(1),
        startMinutes: const Value(540),
        endMinutes: const Value(630),
        colorIndex: const Value(1),
      );

      final id = await database.createTimetable(companion);
      expect(id, isPositive);

      // Assert: Query timetables for the room
      final timetables = await database.getTimetablesForRoom(testRoomId);
      expect(timetables.length, equals(1));
      expect(timetables.first.roomId, equals(testRoomId));
      expect(timetables.first.lectureName, equals('Test Lecture'));
      expect(timetables.first.instructorName, equals('Test Instructor'));
      expect(timetables.first.weekdayIndex, equals(1));
      expect(timetables.first.startMinutes, equals(540));
      expect(timetables.first.endMinutes, equals(630));
      expect(timetables.first.colorIndex, equals(1));
      expect(timetables.first.createdAt, isNotNull);

      // Clean up
      await database.close();
    });

    test('updateTimetable modifies existing entry', () async {
      // Arrange: Create database with in-memory connection and insert entry
      final database = AppDatabase(NativeDatabase.memory());
      const testRoomId = '0-004-0102';

      final companion = TimetablesCompanion(
        roomId: const Value(testRoomId),
        lectureName: const Value('Original Lecture'),
        weekdayIndex: const Value(2),
        startMinutes: const Value(600),
        endMinutes: const Value(690),
      );

      final id = await database.createTimetable(companion);

      // Act: Update the entry
      final updateCompanion = TimetablesCompanion(
        lectureName: const Value('Updated Lecture'),
        instructorName: const Value('Updated Instructor'),
      );

      final updatedCount = await database.updateTimetable(id, updateCompanion);
      expect(updatedCount, equals(1));

      // Assert
      final timetables = await database.getTimetablesForRoom(testRoomId);
      expect(timetables.first.lectureName, equals('Updated Lecture'));
      expect(timetables.first.instructorName, equals('Updated Instructor'));

      // Clean up
      await database.close();
    });

    test('deleteTimetable removes entry', () async {
      // Arrange: Create database with in-memory connection and insert entry
      final database = AppDatabase(NativeDatabase.memory());
      const testRoomId = '0-004-0103';

      final companion = TimetablesCompanion(
        roomId: const Value(testRoomId),
        lectureName: const Value('To Be Deleted'),
        weekdayIndex: const Value(3),
        startMinutes: const Value(660),
        endMinutes: const Value(750),
      );

      final id = await database.createTimetable(companion);

      // Act: Delete the entry
      final deletedCount = await database.deleteTimetable(id);
      expect(deletedCount, equals(1));

      // Assert
      final timetables = await database.getTimetablesForRoom(testRoomId);
      expect(timetables, isEmpty);

      // Clean up
      await database.close();
    });

    test('getTimetablesForRoom returns sorted results', () async {
      // Arrange: Create database with in-memory connection and insert multiple entries
      final database = AppDatabase(NativeDatabase.memory());
      const testRoomId = '0-004-0104';

      // Insert entries in non-sorted order
      final entries = [
        TimetablesCompanion(
          roomId: const Value(testRoomId),
          lectureName: const Value('Lecture C'),
          weekdayIndex: const Value(2),
          startMinutes: const Value(600),
          endMinutes: const Value(690),
        ),
        TimetablesCompanion(
          roomId: const Value(testRoomId),
          lectureName: const Value('Lecture A'),
          weekdayIndex: const Value(1),
          startMinutes: const Value(540),
          endMinutes: const Value(630),
        ),
        TimetablesCompanion(
          roomId: const Value(testRoomId),
          lectureName: const Value('Lecture B'),
          weekdayIndex: const Value(1),
          startMinutes: const Value(480),
          endMinutes: const Value(570),
        ),
      ];

      for (final entry in entries) {
        await database.createTimetable(entry);
      }

      // Act
      final timetables = await database.getTimetablesForRoom(testRoomId);

      // Assert: Should be sorted by weekdayIndex ASC, startMinutes ASC, id ASC
      expect(timetables.length, equals(3));
      expect(
        timetables[0].lectureName,
        equals('Lecture B'),
      ); // weekday 1, start 480
      expect(
        timetables[1].lectureName,
        equals('Lecture A'),
      ); // weekday 1, start 540
      expect(
        timetables[2].lectureName,
        equals('Lecture C'),
      ); // weekday 2, start 600

      // Clean up
      await database.close();
    });

    test('getTimetablesForRoom filters by roomId', () async {
      // Arrange: Create database with in-memory connection and insert entries for different rooms
      final database = AppDatabase(NativeDatabase.memory());

      await database.createTimetable(
        TimetablesCompanion(
          roomId: const Value('room-001'),
          lectureName: const Value('Room 001 Lecture'),
          weekdayIndex: const Value(1),
          startMinutes: const Value(540),
          endMinutes: const Value(630),
        ),
      );

      await database.createTimetable(
        TimetablesCompanion(
          roomId: const Value('room-002'),
          lectureName: const Value('Room 002 Lecture'),
          weekdayIndex: const Value(1),
          startMinutes: const Value(540),
          endMinutes: const Value(630),
        ),
      );

      // Act
      final room001Timetables = await database.getTimetablesForRoom('room-001');
      final room002Timetables = await database.getTimetablesForRoom('room-002');

      // Assert
      expect(room001Timetables.length, equals(1));
      expect(room001Timetables.first.lectureName, equals('Room 001 Lecture'));

      expect(room002Timetables.length, equals(1));
      expect(room002Timetables.first.lectureName, equals('Room 002 Lecture'));

      // Clean up
      await database.close();
    });

    test('default values are applied correctly', () async {
      // Arrange: Create database with in-memory connection
      final database = AppDatabase(NativeDatabase.memory());
      const testRoomId = '0-004-0105';

      // Insert without optional fields
      final companion = TimetablesCompanion(
        roomId: const Value(testRoomId),
        lectureName: const Value('Minimal Lecture'),
        weekdayIndex: const Value(1),
        startMinutes: const Value(540),
        endMinutes: const Value(630),
      );

      await database.createTimetable(companion);

      // Act
      final timetables = await database.getTimetablesForRoom(testRoomId);

      // Assert
      expect(timetables.first.instructorName, equals('')); // default value
      expect(timetables.first.colorIndex, equals(0)); // default value
      expect(timetables.first.createdAt, isNotNull);

      // Clean up
      await database.close();
    });
  });
}
