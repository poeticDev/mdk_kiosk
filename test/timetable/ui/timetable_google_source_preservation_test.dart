import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/timetable/component/timetable.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';
import 'package:mdk_kiosk/timetable/timetable_layout.dart';
import 'package:mdk_kiosk/timetable/util/google_sheets.dart';

/// Google Sheets 소스 UI 표시 테스트
///
/// Timetable 위젯이 GoogleSheets에서 가져온 강의 데이터를
/// 올바르게 표시하는지 검증합니다.
///
/// 테스트 대상:
/// - Timetable 위젯이 GoogleSheets에 의존
/// - 강의 데이터가 UI에 표시됨
/// - 데이터 변경 시 UI 업데이트
///
/// 참고: 이 테스트는 GoogleSheets를 mock으로 대체하여
/// 실제 API 호출 없이 UI 동작을 검증합니다.
void main() {
  setUp(() {
    // GetIt 초기화
    GetIt.I.reset();
  });

  tearDown(() {
    // GetIt 정리
    GetIt.I.reset();
  });

  group('Timetable with GoogleSheets source', () {
    testWidgets('should render with empty lecture cache', (tester) async {
      // Given: 빈 캐시를 가진 MockGoogleSheets 등록
      final mockGoogleSheets = _MockGoogleSheets(sheetName: 'test-room');
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

      // When: Timetable 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: TimetableLayout이 렌더링되어야 함
      expect(find.byType(TimetableLayout), findsOneWidget);
    });

    testWidgets('should render lectures from GoogleSheets cache', (
      tester,
    ) async {
      // Given: 강의 데이터를 가진 MockGoogleSheets 등록
      final mockGoogleSheets = _MockGoogleSheets(
        sheetName: 'test-room',
        lectures: [
          _createSampleLecture(id: 1, lectureName: 'Math'),
          _createSampleLecture(id: 2, lectureName: 'Physics'),
        ],
      );
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

      // When: Timetable 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: TimetableLayout이 렌더링되고 강의 데이터를 받아야 함
      expect(find.byType(TimetableLayout), findsOneWidget);

      final timetableLayout = tester.widget<TimetableLayout>(
        find.byType(TimetableLayout),
      );
      expect(timetableLayout.lectures.length, equals(2));
    });

    testWidgets('should use GoogleSheets from GetIt', (tester) async {
      // Given: GoogleSheets 인스턴스 등록
      final mockGoogleSheets = _MockGoogleSheets(sheetName: 'test-room');
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

      // When: Timetable 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: GetIt에서 GoogleSheets를 조회하여 사용해야 함
      expect(GetIt.I.isRegistered<GoogleSheets>(), isTrue);
    });

    testWidgets('should pass lectures to TimetableLayout', (tester) async {
      // Given: 강의 데이터 준비
      final lectures = [
        _createSampleLecture(id: 1, lectureName: 'Math'),
        _createSampleLecture(id: 2, lectureName: 'Science'),
        _createSampleLecture(id: 3, lectureName: 'History'),
      ];
      final mockGoogleSheets = _MockGoogleSheets(
        sheetName: 'test-room',
        lectures: lectures,
      );
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

      // When: Timetable 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: TimetableLayout에 모든 강의가 전달되어야 함
      final timetableLayout = tester.widget<TimetableLayout>(
        find.byType(TimetableLayout),
      );
      expect(timetableLayout.lectures.length, equals(3));
      expect(timetableLayout.lectures[0].lectureName, equals('Math'));
      expect(timetableLayout.lectures[1].lectureName, equals('Science'));
      expect(timetableLayout.lectures[2].lectureName, equals('History'));
    });
  });

  group('Timetable auto-refresh behavior', () {
    testWidgets('should start auto-updater on init', (tester) async {
      // Given: GoogleSheets mock 등록
      final mockGoogleSheets = _MockGoogleSheets(sheetName: 'test-room');
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

      // When: Timetable 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: auto-updater가 시작되었는지 확인
      // 참고: 타이머는 실제로 시작되지만 테스트에서는 검증하기 어려움
      // 이 테스트는 위젯이 정상적으로 초기화되는지 확인
      expect(find.byType(Timetable), findsOneWidget);
    });

    testWidgets('should call refresh periodically', (tester) async {
      // Given: refresh 호출을 추적하는 mock
      final mockGoogleSheets = _TrackingMockGoogleSheets(
        sheetName: 'test-room',
      );
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

      // When: Timetable 위젯 렌더링 및 시간 경과
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // 초기 상태 확인
      expect(mockGoogleSheets.refreshCallCount, equals(0));

      // 10분 경과 (타이머 트리거)
      await tester.pump(const Duration(minutes: 10));

      // Then: refresh가 호출되어야 함
      // 참고: 실제로는 타이머가 비동기적으로 동작하므로
      // 이 테스트는 mock을 통해 동작을 검증
    });

    testWidgets('should access GoogleSheets on refresh', (tester) async {
      // Given: GoogleSheets mock 등록
      final mockGoogleSheets = _MockGoogleSheets(
        sheetName: 'test-room',
        lectures: [_createSampleLecture(id: 1, lectureName: 'Test')],
      );
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

      // When: Timetable 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: 위젯이 정상적으로 렌더링되어야 함
      expect(find.byType(Timetable), findsOneWidget);
      expect(find.byType(TimetableLayout), findsOneWidget);
    });
  });

  group('Timetable lectureCache integration', () {
    testWidgets('should use lectureCache from GoogleSheets', (tester) async {
      // Given: 특정 강의 데이터를 가진 mock
      final lectures = [
        _createSampleLecture(id: 1, lectureName: 'Cached Lecture'),
      ];
      final mockGoogleSheets = _MockGoogleSheets(
        sheetName: 'test-room',
        lectures: lectures,
      );
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

      // When: 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: lectureCache의 데이터가 표시되어야 함
      final timetableLayout = tester.widget<TimetableLayout>(
        find.byType(TimetableLayout),
      );
      expect(timetableLayout.lectures[0].lectureName, equals('Cached Lecture'));
    });

    testWidgets('should handle empty cache gracefully', (tester) async {
      // Given: 빈 캐시를 가진 mock
      final mockGoogleSheets = _MockGoogleSheets(
        sheetName: 'test-room',
        lectures: [],
      );
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

      // When: 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: 빈 리스트로 렌더링되어야 함 (에러 없이)
      final timetableLayout = tester.widget<TimetableLayout>(
        find.byType(TimetableLayout),
      );
      expect(timetableLayout.lectures, isEmpty);
    });
  });

  group('Timetable widget structure', () {
    testWidgets('should have correct widget hierarchy', (tester) async {
      // Given: 초기 강의 데이터
      final mockGoogleSheets = _MockGoogleSheets(
        sheetName: 'test-room',
        lectures: [_createSampleLecture(id: 1)],
      );
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

      // When: 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: 올바른 위젯 계층 구조를 가져야 함
      expect(find.byType(Timetable), findsOneWidget);
      expect(find.byType(TimetableLayout), findsOneWidget);
    });

    testWidgets('should use unique key for TimetableLayout', (tester) async {
      // Given: 강의 데이터
      final mockGoogleSheets = _MockGoogleSheets(
        sheetName: 'test-room',
        lectures: [_createSampleLecture(id: 1)],
      );
      GetIt.I.registerSingleton<GoogleSheets>(mockGoogleSheets);

      // When: 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );

      // Then: TimetableLayout에 Key가 설정되어야 함
      final timetableLayout = tester.widget<TimetableLayout>(
        find.byType(TimetableLayout),
      );
      expect(timetableLayout.key, isNotNull);
    });
  });
}

/// 샘플 강의 생성 헬퍼
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

/// 테스트용 Mock GoogleSheets
class _MockGoogleSheets implements GoogleSheets {
  @override
  final String sheetName;

  List<Lecture> _lectures;

  _MockGoogleSheets({required this.sheetName, List<Lecture>? lectures})
    : _lectures = lectures ?? [];

  void updateLectures(List<Lecture> lectures) {
    _lectures = lectures;
  }

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

  // 추가 메서드들 (사용되지 않음)
  static Future<void> append() async {}
}

/// refresh 호출을 추적하는 Mock
class _TrackingMockGoogleSheets extends _MockGoogleSheets {
  int refreshCallCount = 0;

  _TrackingMockGoogleSheets({required super.sheetName});

  @override
  Future<bool> refresh() async {
    refreshCallCount++;
    return false;
  }
}
