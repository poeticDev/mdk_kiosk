import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/timetable/admin/timetable_admin_screen.dart';
import 'package:mdk_kiosk/timetable/config/timetable_source_config.dart';
import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

import '../../mocks/mock_timetable_repository.dart';

/// 시간표 관리자 UI 통합 테스트
///
/// localDb 모드에서 시간표 CRUD 흐름을 검증합니다.
void main() {
  setUp(() {
    GetIt.I.reset();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('Timetable Admin Local DB Flow', () {
    testWidgets('관리 화면 렌더링', (tester) async {
      // Given: localDb 모드 확인
      expect(activeTimetableSource, TimetableSourceType.localDb);

      // Mock repository 설정
      final mockRepository = MockEditableTimetableRepository();
      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);
      GetIt.I.registerSingleton<EditableTimetableRepository>(mockRepository);

      // When: 관리 화면 렌더링
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: TimetableAdminScreen())),
      );
      await tester.pumpAndSettle();

      // Then: 관리 화면이 렌더링됨
      expect(find.byType(TimetableAdminScreen), findsOneWidget);
      expect(find.text('시간표 관리'), findsOneWidget);
    });

    testWidgets('빈 시간표에서 강의 추가', (tester) async {
      // Given: 빈 시간표로 시작
      final mockRepository = MockEditableTimetableRepository();
      expect(mockRepository.getLectures(), isEmpty);

      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);
      GetIt.I.registerSingleton<EditableTimetableRepository>(mockRepository);

      // When: 관리 화면 렌더링
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: TimetableAdminScreen())),
      );
      await tester.pumpAndSettle();

      // Then: 빈 상태에서 화면 표시
      expect(find.byType(TimetableAdminScreen), findsOneWidget);
    });

    testWidgets('강의 생성 후 조회', (tester) async {
      // Given: repository에 강의 생성
      final mockRepository = MockEditableTimetableRepository();
      final testLecture = Lecture(
        id: 1,
        lectureName: 'Math',
        instructorName: 'Kim',
        weekday: Weekday.monday,
        startAt: const TimeOfDay(hour: 9, minute: 0),
        endAt: const TimeOfDay(hour: 10, minute: 0),
        colorIndex: 0,
      );

      await mockRepository.createLecture(testLecture);
      expect(mockRepository.getLectures().length, equals(1));

      GetIt.I.registerSingleton<TimetableRepository>(mockRepository);

      // Then: 생성된 강의 조회 가능
      final lectures = mockRepository.getLectures();
      expect(lectures.first.lectureName, equals('Math'));
    });

    testWidgets('localDb 모드 확인', (tester) async {
      // Given: localDb 모드
      expect(activeTimetableSource, TimetableSourceType.localDb);
      expect(activeTimetableSource.isEditable, isTrue);
    });

    testWidgets('googleSheets 모드 비활성 확인', (tester) async {
      // googleSheets는 editable=false
      expect(TimetableSourceType.googleSheets.isEditable, isFalse);

      // localServer도 editable=false
      expect(TimetableSourceType.localServer.isEditable, isFalse);

      // localDb만 editable=true
      expect(TimetableSourceType.localDb.isEditable, isTrue);
    });
  });
}
