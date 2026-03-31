import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/timetable/component/timetable.dart';
import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';
import 'package:mdk_kiosk/timetable/timetable_layout.dart';

import '../../mocks/mock_timetable_repository.dart';

/// 빈 로컬 DB 상태 테스트
///
/// 시간표가 비어있을 때의 UI 동작을 검증합니다.
void main() {
  setUp(() {
    GetIt.I.reset();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('Timetable Local Empty State', () {
    testWidgets('빈 시간표에서 Timetable 위젯 렌더링', (tester) async {
      // Given: 빈 repository
      final mockRepository = MockEditableTimetableRepository();
      expect(mockRepository.getLectures(), isEmpty);

      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      // When: Timetable 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );
      await tester.pumpAndSettle();

      // Then: 에러 없이 렌더링됨
      expect(find.byType(Timetable), findsOneWidget);
      expect(find.byType(TimetableLayout), findsOneWidget);
    });

    testWidgets('빈 시간표에서 TimetableLayout은 빈 리스트 전달', (tester) async {
      // Given: 빈 repository
      final mockRepository = MockEditableTimetableRepository();
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      // When: 위젯 렌더링
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: Timetable())),
        ),
      );
      await tester.pumpAndSettle();

      // Then: TimetableLayout에 빈 리스트 전달
      final timetableLayout = tester.widget<TimetableLayout>(
        find.byType(TimetableLayout),
      );
      expect(timetableLayout.lectures, isEmpty);
    });

    testWidgets('getLecturesForToday는 빈 리스트 반환', (tester) async {
      // Given: 빈 repository
      final mockRepository = MockEditableTimetableRepository();

      // When: 오늘 강의 조회
      final todayLectures = mockRepository.getLecturesForToday();

      // Then: 빈 리스트
      expect(todayLectures, isEmpty);
    });

    testWidgets('빈 상태에서도 refresh 가능', (tester) async {
      // Given: 빈 repository
      final mockRepository = MockEditableTimetableRepository();
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      // When: refresh 호출
      final changed = await mockRepository.refresh();

      // Then: 에러 없이 실행됨 (변경 없음)
      expect(changed, isFalse);
    });

    testWidgets('빈 상태에서 강의 추가 후 조회', (tester) async {
      // Given: 빈 repository
      final mockRepository = MockEditableTimetableRepository();
      expect(mockRepository.getLectures(), isEmpty);

      // When: 강의 추가
      await mockRepository.createLecture(
        Lecture(
          id: 0, // ID는 자동 할당
          lectureName: 'New Lecture',
          instructorName: 'Instructor',
          weekday: Weekday.monday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 0),
          colorIndex: 0,
        ),
      );

      // Then: 강의가 추가됨
      expect(mockRepository.getLectures().length, equals(1));
      expect(
        mockRepository.getLectures().first.lectureName,
        equals('New Lecture'),
      );
    });
  });
}
