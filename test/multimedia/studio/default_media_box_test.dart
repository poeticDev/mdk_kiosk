import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/multimedia/studio/default_media_box.dart';
import 'package:mdk_kiosk/multimedia/studio/lecture_box_for_media_box.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';
import 'package:mdk_kiosk/timetable/util/google_sheets.dart';

/// DefaultMediaBox characterization test
///
/// DefaultMediaBox의 현재 동작을 잠그는 테스트입니다.
/// GoogleSheets 기반 현재 구현의 동작을 검증합니다.
/// Task 2 이후 TimetableRepository 기반으로 업데이트 예정.
void main() {
  setUp(() {
    GetIt.I.reset();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('DefaultMediaBox Characterization', () {
    testWidgets('renders header "오늘의 강의실 스케쥴"', (tester) async {
      // Given: Mock GoogleSheets with sample lectures
      final mockGoogleSheets = _MockGoogleSheets(
        lectures: [
          Lecture(
            id: 1,
            lectureName: 'Math',
            instructorName: 'Kim',
            weekday: Weekday.monday,
            startAt: const TimeOfDay(hour: 9, minute: 0),
            endAt: const TimeOfDay(hour: 10, minute: 0),
            colorIndex: 0,
          ),
        ],
      );
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

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

    testWidgets('renders lecture list', (tester) async {
      // Given: Mock GoogleSheets with multiple lectures for TODAY
      // getLecturesForToday() returns only today's lectures
      final today = DateTime.now();
      final todayWeekday = Weekday.values[(today.weekday - 1) % 7];

      final mockGoogleSheets = _MockGoogleSheets(
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
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

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
      // Given: Empty Mock GoogleSheets
      final mockGoogleSheets = _MockGoogleSheets();
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

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

/// 테스트용 Mock GoogleSheets
class _MockGoogleSheets implements GoogleSheets {
  @override
  final String sheetName = 'test-room';

  final List<Lecture> _lectures;

  _MockGoogleSheets({List<Lecture>? lectures}) : _lectures = lectures ?? [];

  @override
  List<Lecture> get lectureCache => List.unmodifiable(_lectures);

  @override
  List<Lecture> getLectures() => List.unmodifiable(_lectures);

  @override
  List<Lecture> getLecturesForToday() {
    final today = DateTime.now();
    final weekdayIndex = today.weekday;
    final todayWeekday = Weekday.values[(weekdayIndex - 1) % 7];

    return _lectures
        .where((lecture) => lecture.weekday == todayWeekday)
        .toList();
  }

  @override
  Future<bool> refresh() async => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> reInitialize() async {}

  @override
  bool get supportsBackgroundRefresh => true;

  @override
  Future<List<Lecture>> fetchAllLectures() async => _lectures;

  @override
  Future<Lecture> fetchLecture(int row) async => _lectures.first;

  @override
  Future<List<String>> getRow(int row) async => [];

  @override
  Future<void> insertLecture(Lecture lecture) async {}

  @override
  Future<void> append() async {}
}
