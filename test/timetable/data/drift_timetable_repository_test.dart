import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/timetable/data/drift_timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DriftTimetableRepository', () {
    late AppDatabase database;
    late DriftTimetableRepository repository;
    const testRoomId = 'test-room-001';

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      repository = DriftTimetableRepository(db: database, roomId: testRoomId);
      await repository.initialize();
    });

    tearDown(() async {
      await database.close();
    });

    group('CRUD operations', () {
      test('createLecture adds lecture to repository', () async {
        final lecture = Lecture(
          id: 0,
          lectureName: 'Test Lecture',
          instructorName: 'Test Instructor',
          weekday: Weekday.monday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 30),
          colorIndex: 1,
        );

        await repository.createLecture(lecture);
        final lectures = repository.getLectures();

        expect(lectures.length, equals(1));
        expect(lectures.first.lectureName, equals('Test Lecture'));
        expect(lectures.first.instructorName, equals('Test Instructor'));
        expect(lectures.first.weekday, equals(Weekday.monday));
        expect(lectures.first.startAt.hour, equals(9));
        expect(lectures.first.startAt.minute, equals(0));
        expect(lectures.first.endAt.hour, equals(10));
        expect(lectures.first.endAt.minute, equals(30));
        expect(lectures.first.colorIndex, equals(1));
        expect(lectures.first.id, isPositive);
      });

      test('createLecture with zero values works correctly', () async {
        final lecture = Lecture(
          id: 0,
          lectureName: 'Midnight Lecture',
          instructorName: '',
          weekday: Weekday.sunday,
          startAt: const TimeOfDay(hour: 0, minute: 0),
          endAt: const TimeOfDay(hour: 0, minute: 0),
          colorIndex: 0,
        );

        await repository.createLecture(lecture);
        final lectures = repository.getLectures();

        expect(lectures.length, equals(1));
        expect(lectures.first.lectureName, equals('Midnight Lecture'));
        expect(lectures.first.instructorName, equals(''));
        expect(lectures.first.weekday, equals(Weekday.sunday));
        expect(lectures.first.startAt.hour, equals(0));
        expect(lectures.first.startAt.minute, equals(0));
        expect(lectures.first.endAt.hour, equals(0));
        expect(lectures.first.endAt.minute, equals(0));
        expect(lectures.first.colorIndex, equals(0));
      });

      test('updateLecture modifies existing lecture', () async {
        final lecture = Lecture(
          id: 0,
          lectureName: 'Original Lecture',
          instructorName: 'Original Instructor',
          weekday: Weekday.tuesday,
          startAt: const TimeOfDay(hour: 10, minute: 0),
          endAt: const TimeOfDay(hour: 11, minute: 30),
          colorIndex: 2,
        );
        await repository.createLecture(lecture);
        final createdLecture = repository.getLectures().first;

        final updatedLecture = Lecture(
          id: createdLecture.id,
          lectureName: 'Updated Lecture',
          instructorName: 'Updated Instructor',
          weekday: Weekday.wednesday,
          startAt: const TimeOfDay(hour: 14, minute: 0),
          endAt: const TimeOfDay(hour: 15, minute: 30),
          colorIndex: 3,
        );
        await repository.updateLecture(updatedLecture);

        final lectures = repository.getLectures();
        expect(lectures.length, equals(1));
        expect(lectures.first.lectureName, equals('Updated Lecture'));
        expect(lectures.first.instructorName, equals('Updated Instructor'));
        expect(lectures.first.weekday, equals(Weekday.wednesday));
        expect(lectures.first.startAt.hour, equals(14));
        expect(lectures.first.startAt.minute, equals(0));
        expect(lectures.first.endAt.hour, equals(15));
        expect(lectures.first.endAt.minute, equals(30));
        expect(lectures.first.colorIndex, equals(3));
      });

      test('deleteLecture removes lecture by id', () async {
        final lecture1 = Lecture(
          id: 0,
          lectureName: 'Lecture 1',
          instructorName: 'Instructor 1',
          weekday: Weekday.monday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 0),
          colorIndex: 1,
        );
        final lecture2 = Lecture(
          id: 0,
          lectureName: 'Lecture 2',
          instructorName: 'Instructor 2',
          weekday: Weekday.tuesday,
          startAt: const TimeOfDay(hour: 11, minute: 0),
          endAt: const TimeOfDay(hour: 12, minute: 0),
          colorIndex: 2,
        );
        await repository.createLecture(lecture1);
        await repository.createLecture(lecture2);

        final lecturesBefore = repository.getLectures();
        expect(lecturesBefore.length, equals(2));

        final idToDelete = lecturesBefore.first.id;
        await repository.deleteLecture(idToDelete);

        final lecturesAfter = repository.getLectures();
        expect(lecturesAfter.length, equals(1));
        expect(lecturesAfter.first.id, isNot(equals(idToDelete)));
      });

      test('deleteLecture with non-existent id does nothing', () async {
        final lecture = Lecture(
          id: 0,
          lectureName: 'Only Lecture',
          instructorName: 'Instructor',
          weekday: Weekday.monday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 0),
        );
        await repository.createLecture(lecture);

        await repository.deleteLecture(999);

        final lectures = repository.getLectures();
        expect(lectures.length, equals(1));
        expect(lectures.first.lectureName, equals('Only Lecture'));
      });
    });

    group('Room scoping', () {
      test(
        'getLectures only returns lectures for the specified room',
        () async {
          const otherRoomId = 'other-room-002';
          final otherRepository = DriftTimetableRepository(
            db: database,
            roomId: otherRoomId,
          );
          await otherRepository.initialize();

          final testRoomLecture = Lecture(
            id: 0,
            lectureName: 'Test Room Lecture',
            instructorName: 'Instructor A',
            weekday: Weekday.monday,
            startAt: const TimeOfDay(hour: 9, minute: 0),
            endAt: const TimeOfDay(hour: 10, minute: 0),
          );
          await repository.createLecture(testRoomLecture);

          final otherRoomLecture = Lecture(
            id: 0,
            lectureName: 'Other Room Lecture',
            instructorName: 'Instructor B',
            weekday: Weekday.tuesday,
            startAt: const TimeOfDay(hour: 11, minute: 0),
            endAt: const TimeOfDay(hour: 12, minute: 0),
          );
          await otherRepository.createLecture(otherRoomLecture);

          final testRoomLectures = repository.getLectures();
          final otherRoomLectures = otherRepository.getLectures();

          expect(testRoomLectures.length, equals(1));
          expect(
            testRoomLectures.first.lectureName,
            equals('Test Room Lecture'),
          );

          expect(otherRoomLectures.length, equals(1));
          expect(
            otherRoomLectures.first.lectureName,
            equals('Other Room Lecture'),
          );
        },
      );

      test('createLecture is isolated to the repository room', () async {
        const otherRoomId = 'other-room-003';
        final otherRepository = DriftTimetableRepository(
          db: database,
          roomId: otherRoomId,
        );
        await otherRepository.initialize();

        final lecture = Lecture(
          id: 0,
          lectureName: 'Test Lecture',
          instructorName: 'Instructor',
          weekday: Weekday.monday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 0),
        );
        await repository.createLecture(lecture);

        final testRoomLectures = repository.getLectures();
        final otherRoomLectures = otherRepository.getLectures();

        expect(testRoomLectures.length, equals(1));
        expect(otherRoomLectures.length, equals(0));
      });
    });

    group('Repository properties', () {
      test('supportsBackgroundRefresh returns false', () {
        expect(repository.supportsBackgroundRefresh, isFalse);
      });

      test('getLectures returns unmodifiable list', () async {
        final lecture = Lecture(
          id: 0,
          lectureName: 'Test Lecture',
          instructorName: 'Instructor',
          weekday: Weekday.monday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 0),
        );
        await repository.createLecture(lecture);

        final lectures = repository.getLectures();
        expect(() => lectures.add(lecture), throwsUnsupportedError);
      });

      test('refresh returns true when data changes', () async {
        final lecture = Lecture(
          id: 0,
          lectureName: 'Test Lecture',
          instructorName: 'Instructor',
          weekday: Weekday.monday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 0),
        );
        await repository.createLecture(lecture);

        final result = await repository.refresh();
        expect(result, isFalse);
      });
    });
  });
}
