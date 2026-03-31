import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/timetable/component/timetable.dart';
import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';
import 'package:mdk_kiosk/timetable/timetable_layout.dart';

/// Timetable 위젯 Repository 추상화 테스트
void main() {
  setUp(() {
    GetIt.I.reset();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('Timetable with Repository Abstraction', () {
    testWidgets('should use TimetableRepository from GetIt', (tester) async {
      final mockRepository = _MockTimetableRepository();
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      expect(GetIt.I.isRegistered<TimetableRepository>(), isTrue);
      expect(find.byType(Timetable), findsOneWidget);
      expect(find.byType(TimetableLayout), findsOneWidget);
    });

    testWidgets('should render with empty lectures from repository', (
      tester,
    ) async {
      final mockRepository = _MockTimetableRepository(lectures: []);
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      expect(find.byType(TimetableLayout), findsOneWidget);
      final timetableLayout = tester.widget<TimetableLayout>(
        find.byType(TimetableLayout),
      );
      expect(timetableLayout.lectures, isEmpty);
    });

    testWidgets('should render lectures from repository getLectures', (
      tester,
    ) async {
      final lectures = [
        _createSampleLecture(id: 1, lectureName: 'Math'),
        _createSampleLecture(id: 2, lectureName: 'Physics'),
        _createSampleLecture(id: 3, lectureName: 'Chemistry'),
      ];
      final mockRepository = _MockTimetableRepository(lectures: lectures);
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      final timetableLayout = tester.widget<TimetableLayout>(
        find.byType(TimetableLayout),
      );
      expect(timetableLayout.lectures.length, equals(3));
      expect(timetableLayout.lectures[0].lectureName, equals('Math'));
      expect(timetableLayout.lectures[1].lectureName, equals('Physics'));
      expect(timetableLayout.lectures[2].lectureName, equals('Chemistry'));
    });

    testWidgets('should not depend on GoogleSheets directly', (tester) async {
      final mockRepository = _MockTimetableRepository(
        lectures: [_createSampleLecture(id: 1, lectureName: 'Test')],
      );
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      expect(find.byType(TimetableLayout), findsOneWidget);
    });

    testWidgets(
      'should work with repository that supports background refresh',
      (tester) async {
        // Given: supportsBackgroundRefresh가 true인 Repository
        final repo = _MockTimetableRepository(
          lectures: [
            _createSampleLecture(id: 1, lectureName: 'Background Refreshable'),
          ],
          supportsBackgroundRefresh: true,
        );
        GetIt.I.registerSingleton<TimetableRepository>(repo);

        // When: Timetable 위젯 렌더링
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(home: Scaffold(body: Timetable())),
          ),
        );

        // Then: 정상적으로 렌더링되어야 함
        final timetableLayout = tester.widget<TimetableLayout>(
          find.byType(TimetableLayout),
        );
        expect(
          timetableLayout.lectures[0].lectureName,
          equals('Background Refreshable'),
        );
        expect(repo.supportsBackgroundRefresh, isTrue);
      },
    );

    testWidgets(
      'should work with repository that does not support background refresh',
      (tester) async {
        // Given: supportsBackgroundRefresh가 false인 Repository
        final repo = _MockTimetableRepository(
          lectures: [
            _createSampleLecture(id: 1, lectureName: 'No Background Refresh'),
          ],
          supportsBackgroundRefresh: false,
        );
        GetIt.I.registerSingleton<TimetableRepository>(repo);

        // When: Timetable 위젯 렌더링
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(home: Scaffold(body: Timetable())),
          ),
        );

        // Then: 정상적으로 렌더링되어야 함
        final timetableLayout = tester.widget<TimetableLayout>(
          find.byType(TimetableLayout),
        );
        expect(
          timetableLayout.lectures[0].lectureName,
          equals('No Background Refresh'),
        );
        expect(repo.supportsBackgroundRefresh, isFalse);
      },
    );

    testWidgets('should call repository getLectures in build', (tester) async {
      final trackingRepo = _TrackingTimetableRepository(
        lectures: [_createSampleLecture(id: 1)],
      );
      GetIt.I.registerSingleton<TimetableRepository>(trackingRepo);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      expect(trackingRepo.getLecturesCallCount, greaterThan(0));
    });

    testWidgets('should use unique key for TimetableLayout', (tester) async {
      final mockRepository = _MockTimetableRepository(
        lectures: [_createSampleLecture(id: 1)],
      );
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      final timetableLayout = tester.widget<TimetableLayout>(
        find.byType(TimetableLayout),
      );
      expect(timetableLayout.key, isNotNull);
    });
  });
}

Lecture _createSampleLecture({
  int id = 1,
  String lectureName = 'Test Lecture',
  String instructorName = 'Test Instructor',
  Weekday weekday = Weekday.monday,
  TimeOfDay startAt = const TimeOfDay(hour: 9, minute: 0),
  TimeOfDay endAt = const TimeOfDay(hour: 10, minute: 0),
  int colorIndex = 0,
}) {
  return Lecture(
    id: id,
    lectureName: lectureName,
    instructorName: instructorName,
    weekday: weekday,
    startAt: startAt,
    endAt: endAt,
    colorIndex: colorIndex,
  );
}

class _MockTimetableRepository implements TimetableRepository {
  List<Lecture> _lectures;
  final bool _supportsBackgroundRefresh;

  _MockTimetableRepository({
    List<Lecture>? lectures,
    bool supportsBackgroundRefresh = false,
  }) : _lectures = lectures ?? [],
       _supportsBackgroundRefresh = supportsBackgroundRefresh;

  @override
  List<Lecture> getLectures() => List.unmodifiable(_lectures);

  @override
  List<Lecture> getLecturesForToday() => _lectures;

  @override
  Future<bool> refresh() async => false;

  @override
  Future<void> initialize() async {}

  @override
  bool get supportsBackgroundRefresh => _supportsBackgroundRefresh;

  void updateLectures(List<Lecture> lectures) {
    _lectures = lectures;
  }
}

class _TrackingTimetableRepository extends _MockTimetableRepository {
  int getLecturesCallCount = 0;

  _TrackingTimetableRepository({required super.lectures});

  @override
  List<Lecture> getLectures() {
    getLecturesCallCount++;
    return super.getLectures();
  }
}
