import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/multimedia/studio/default_media_box.dart';
import 'package:mdk_kiosk/multimedia/studio/lecture_box_for_media_box.dart';
import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

import '../../mocks/mock_timetable_repository.dart';

/// DefaultMediaBox test
///
/// TimetableRepository 기반으로 동작하는 DefaultMediaBox를 테스트합니다.
void main() {
  setUp(() {
    GetIt.I.reset();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('DefaultMediaBox with TimetableRepository', () {
    testWidgets('renders header "오늘의 강의실 스케쥴"', (tester) async {
      // Given: Mock TimetableRepository with sample lectures
      final today = DateTime.now();
      final todayWeekday = Weekday.values[(today.weekday - 1) % 7];

      final mockRepository = MockEditableTimetableRepository(
        lectures: [
          Lecture(
            id: 1,
            lectureName: 'Math',
            instructorName: 'Kim',
            weekday: todayWeekday,
            startAt: const TimeOfDay(hour: 9, minute: 0),
            endAt: const TimeOfDay(hour: 10, minute: 0),
            colorIndex: 0,
          ),
        ],
      );
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      // When: Render DefaultMediaBox
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: DefaultMediaBox())),
        ),
      );
      await tester.pumpAndSettle();

      // Then: Header is rendered
      expect(find.text('오늘의 강의실 스케쥴'), findsOneWidget);
    });

    testWidgets('renders lecture list from repository', (tester) async {
      // Given: Mock TimetableRepository with multiple lectures
      final today = DateTime.now();
      final todayWeekday = Weekday.values[(today.weekday - 1) % 7];

      final mockRepository = MockEditableTimetableRepository(
        lectures: [
          Lecture(
            id: 1,
            lectureName: 'Math',
            instructorName: 'Kim',
            weekday: todayWeekday,
            startAt: const TimeOfDay(hour: 9, minute: 0),
            endAt: const TimeOfDay(hour: 10, minute: 0),
            colorIndex: 0,
          ),
          Lecture(
            id: 2,
            lectureName: 'Physics',
            instructorName: 'Lee',
            weekday: todayWeekday,
            startAt: const TimeOfDay(hour: 10, minute: 0),
            endAt: const TimeOfDay(hour: 11, minute: 0),
            colorIndex: 1,
          ),
        ],
      );
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      // When: Render DefaultMediaBox
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: DefaultMediaBox())),
        ),
      );
      await tester.pumpAndSettle();

      // Then: Lecture boxes are rendered
      expect(find.byType(LectureBoxForMediaBox), findsNWidgets(2));
    });

    testWidgets('renders empty list when no lectures', (tester) async {
      // Given: Empty Mock TimetableRepository
      final mockRepository = MockEditableTimetableRepository();
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      // When: Render DefaultMediaBox
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: DefaultMediaBox())),
        ),
      );
      await tester.pumpAndSettle();

      // Then: Header is rendered but no lecture boxes
      expect(find.text('오늘의 강의실 스케쥴'), findsOneWidget);
      expect(find.byType(LectureBoxForMediaBox), findsNothing);
    });
  });
}
