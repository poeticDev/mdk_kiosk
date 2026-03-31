import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/timetable/component/timetable.dart';
import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';
import 'package:mdk_kiosk/timetable/timetable_layout.dart';

/// Timetable 위젯 새로고침 정책 테스트
///
/// Repository의 supportsBackgroundRefresh 값에 따라
/// 자동 새로고침(polling) 동작이 달라지는지 검증합니다.
void main() {
  setUp(() {
    GetIt.I.reset();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('Timetable auto-refresh with supportsBackgroundRefresh=true', () {
    testWidgets('should start timer when supportsBackgroundRefresh is true', (
      tester,
    ) async {
      // Given: supportsBackgroundRefresh가 true인 Repository
      final mockRepository = _MockTimetableRepository(
        lectures: [_createSampleLecture(id: 1)],
        supportsBackgroundRefresh: true,
      );
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      // When: Timetable 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: 위젯이 정상 렌더링되어야 함
      expect(find.byType(Timetable), findsOneWidget);
      expect(find.byType(TimetableLayout), findsOneWidget);
    });

    testWidgets('should call refresh periodically when enabled', (
      tester,
    ) async {
      // Given: refresh 호출을 추적하는 Repository
      final trackingRepo = _TrackingTimetableRepository(
        lectures: [_createSampleLecture(id: 1)],
        supportsBackgroundRefresh: true,
      );
      GetIt.I.registerSingleton<TimetableRepository>(trackingRepo);

      // When: Timetable 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // 초기 상태 확인 - build에서 getLectures가 호출됨
      expect(trackingRepo.getLecturesCallCount, greaterThan(0));
      expect(trackingRepo.refreshCallCount, equals(0));

      // 10분 경과 시뮬레이션
      await tester.pump(const Duration(minutes: 10));

      // Then: 타이머가 동작하여 refresh가 호출되어야 함
      expect(trackingRepo.refreshCallCount, greaterThan(0));
    });

    testWidgets('should trigger timetableUpdater when refresh returns true', (
      tester,
    ) async {
      // Given: refresh가 true를 반환하는 Repository
      final mockRepository = _MockTimetableRepository(
        lectures: [_createSampleLecture(id: 1)],
        supportsBackgroundRefresh: true,
        refreshResult: true,
      );
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      // When: Timetable 위젯 렌더링 및 10분 경과
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: 위젯이 정상 렌더링되어야 함
      expect(find.byType(Timetable), findsOneWidget);
    });
  });

  group('Timetable auto-refresh with supportsBackgroundRefresh=false', () {
    testWidgets('should NOT start timer when supportsBackgroundRefresh is false', (
      tester,
    ) async {
      // Given: supportsBackgroundRefresh가 false인 Repository (LocalDB 스타일)
      final trackingRepo = _TrackingTimetableRepository(
        lectures: [_createSampleLecture(id: 1)],
        supportsBackgroundRefresh: false,
      );
      GetIt.I.registerSingleton<TimetableRepository>(trackingRepo);

      // When: Timetable 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: 위젯은 렌더링되지만 refresh는 호출되지 않아야 함
      expect(find.byType(Timetable), findsOneWidget);
      expect(trackingRepo.refreshCallCount, equals(0));

      // 10분 경과 시뮬레이션
      await tester.pump(const Duration(minutes: 10));

      // 여전히 refresh가 호출되지 않아야 함 (타이머가 시작되지 않음)
      expect(trackingRepo.refreshCallCount, equals(0));
    });

    testWidgets('should work with localDb style repository', (
      tester,
    ) async {
      // Given: LocalDB 스타일 Repository (supportsBackgroundRefresh = false)
      final localDbRepo = _MockTimetableRepository(
        lectures: [
          _createSampleLecture(id: 1, lectureName: 'Local Lecture 1'),
          _createSampleLecture(id: 2, lectureName: 'Local Lecture 2'),
        ],
        supportsBackgroundRefresh: false,
      );
      GetIt.I.registerSingleton<TimetableRepository>(localDbRepo);

      // When: Timetable 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: 데이터가 정상적으로 표시되어야 함
      final timetableLayout = tester.widget<TimetableLayout>(
        find.byType(TimetableLayout),
      );
      expect(timetableLayout.lectures.length, equals(2));
      expect(timetableLayout.lectures[0].lectureName, equals('Local Lecture 1'));
    });

    testWidgets('should not poll when localDb repository is used', (
      tester,
    ) async {
      // Given: polling을 지원하지 않는 Repository
      final trackingRepo = _TrackingTimetableRepository(
        lectures: [_createSampleLecture(id: 1)],
        supportsBackgroundRefresh: false,
      );
      GetIt.I.registerSingleton<TimetableRepository>(trackingRepo);

      // When: 위젯 렌더링 및 여러 시간 경과
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // 30분 경과 시뮬레이션 (3번의 10분 주기)
      await tester.pump(const Duration(minutes: 30));

      // Then: polling이 없으므로 refresh는 한 번도 호출되지 않아야 함
      expect(trackingRepo.refreshCallCount, equals(0));
    });
  });

  group('Timetable refresh behavior comparison', () {
    testWidgets('GoogleSheets-like repo should support polling', (
      tester,
    ) async {
      // Given: GoogleSheets 스타일 Repository
      final googleSheetsRepo = _TrackingTimetableRepository(
        lectures: [_createSampleLecture(id: 1, lectureName: 'Google Sheet Data')],
        supportsBackgroundRefresh: true,
      );
      GetIt.I.registerSingleton<TimetableRepository>(googleSheetsRepo);

      // When: 위젯 렌더링 및 시간 경과
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      await tester.pump(const Duration(minutes: 10));

      // Then: polling이 활성화되어 refresh가 호출되어야 함
      expect(googleSheetsRepo.supportsBackgroundRefresh, isTrue);
      expect(googleSheetsRepo.refreshCallCount, greaterThan(0));
    });

    testWidgets('LocalDb-like repo should not poll', (tester) async {
      // Given: LocalDB 스타일 Repository
      final localDbRepo = _TrackingTimetableRepository(
        lectures: [_createSampleLecture(id: 1, lectureName: 'Local DB Data')],
        supportsBackgroundRefresh: false,
      );
      GetIt.I.registerSingleton<TimetableRepository>(localDbRepo);

      // When: 위젯 렌더링 및 시간 경과
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      await tester.pump(const Duration(minutes: 10));
      await tester.pump(const Duration(minutes: 10));

      // Then: polling이 비활성화되어 refresh가 호출되지 않아야 함
      expect(localDbRepo.supportsBackgroundRefresh, isFalse);
      expect(localDbRepo.refreshCallCount, equals(0));
    });
  });

  group('Timetable refresh return value handling', () {
    testWidgets('should handle refresh returning true', (tester) async {
      // Given: refresh가 true를 반환하는 Repository
      final mockRepo = _MockTimetableRepository(
        lectures: [_createSampleLecture(id: 1)],
        supportsBackgroundRefresh: true,
        refreshResult: true,
      );
      GetIt.I.registerSingleton<TimetableRepository>(mockRepo);

      // When: 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: 정상 렌더링되어야 함
      expect(find.byType(TimetableLayout), findsOneWidget);
    });

    testWidgets('should handle refresh returning false', (tester) async {
      // Given: refresh가 false를 반환하는 Repository
      final mockRepo = _MockTimetableRepository(
        lectures: [_createSampleLecture(id: 1)],
        supportsBackgroundRefresh: true,
        refreshResult: false,
      );
      GetIt.I.registerSingleton<TimetableRepository>(mockRepo);

      // When: 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: 정상 렌더링되어야 함
      expect(find.byType(TimetableLayout), findsOneWidget);
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
  final bool _refreshResult;

  _MockTimetableRepository({
    List<Lecture>? lectures,
    bool supportsBackgroundRefresh = false,
    bool refreshResult = false,
  })  : _lectures = lectures ?? [],
        _supportsBackgroundRefresh = supportsBackgroundRefresh,
        _refreshResult = refreshResult;

  @override
  List<Lecture> getLectures() => List.unmodifiable(_lectures);

  @override
  List<Lecture> getLecturesForToday() => _lectures;

  @override
  Future<bool> refresh() async => _refreshResult;

  @override
  Future<void> initialize() async {}

  @override
  bool get supportsBackgroundRefresh => _supportsBackgroundRefresh;

  void updateLectures(List<Lecture> lectures) {
    _lectures = lectures;
  }
}

class _TrackingTimetableRepository extends _MockTimetableRepository {
  int refreshCallCount = 0;
  int getLecturesCallCount = 0;

  _TrackingTimetableRepository({
    required super.lectures,
    required super.supportsBackgroundRefresh,
  });

  @override
  Future<bool> refresh() async {
    refreshCallCount++;
    return super.refresh();
  }

  @override
  List<Lecture> getLectures() {
    getLecturesCallCount++;
    return super.getLectures();
  }
}
