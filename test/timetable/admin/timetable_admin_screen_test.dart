import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/timetable/admin/timetable_admin_screen.dart';
import 'package:mdk_kiosk/timetable/data/drift_timetable_repository.dart';
import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimetableAdminScreen', () {
    late AppDatabase database;
    late DriftTimetableRepository repository;
    const testRoomId = 'test-room-admin';

    setUp(() async {
      // GetIt 초기화
      GetIt.I.reset();

      // 인메모리 DB 생성
      database = AppDatabase(NativeDatabase.memory());
      repository = DriftTimetableRepository(db: database, roomId: testRoomId);
      await repository.initialize();

      // GetIt에 repository 등록
      GetIt.I.registerSingleton<EditableTimetableRepository>(repository);
    });

    tearDown(() async {
      await database.close();
      GetIt.I.reset();
    });

    testWidgets('초기 상태에서 로딩 인디케이터가 표시된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TimetableAdminScreen())),
      );

      // 로딩 인디케이터 확인
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('빈 상태에서 적절한 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TimetableAdminScreen())),
      );

      // 로딩 완료 대기
      await tester.pumpAndSettle();

      // 빈 상태 메시지 확인
      expect(find.text('등록된 강의가 없습니다'), findsOneWidget);
      expect(find.text('우측 하단 + 버튼을 눌러 강의를 추가하세요'), findsOneWidget);
    });

    testWidgets('AppBar에 올바른 타이틀이 표시된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TimetableAdminScreen())),
      );

      await tester.pumpAndSettle();

      expect(find.text('시간표 관리'), findsOneWidget);
    });

    testWidgets('FAB 버튼이 존재한다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TimetableAdminScreen())),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('새로고침 버튼이 존재한다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TimetableAdminScreen())),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('강의가 있을 때 목록에 표시된다', (tester) async {
      // 테스트 데이터 추가
      final lecture = Lecture(
        id: 0,
        lectureName: '테스트 강의',
        instructorName: '테스트 교수',
        weekday: Weekday.monday,
        startAt: const TimeOfDay(hour: 9, minute: 0),
        endAt: const TimeOfDay(hour: 10, minute: 30),
        colorIndex: 1,
      );
      await repository.createLecture(lecture);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TimetableAdminScreen())),
      );

      await tester.pumpAndSettle();

      // 강의명이 표시되는지 확인
      expect(find.text('테스트 강의'), findsOneWidget);
      expect(find.text('테스트 교수'), findsOneWidget);

      // 요일 헤더 확인
      expect(find.text('월요일'), findsOneWidget);

      // 수정/삭제 버튼 확인
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('여러 강의가 요일별로 그룹화되어 표시된다', (tester) async {
      // 여러 요일에 강의 추가
      await repository.createLecture(
        Lecture(
          id: 0,
          lectureName: '월요일 강의',
          instructorName: '교수1',
          weekday: Weekday.monday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 0),
        ),
      );
      await repository.createLecture(
        Lecture(
          id: 0,
          lectureName: '수요일 강의',
          instructorName: '교수2',
          weekday: Weekday.wednesday,
          startAt: const TimeOfDay(hour: 14, minute: 0),
          endAt: const TimeOfDay(hour: 15, minute: 0),
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TimetableAdminScreen())),
      );

      await tester.pumpAndSettle();

      // 각 요일 헤더 확인
      expect(find.text('월요일'), findsOneWidget);
      expect(find.text('수요일'), findsOneWidget);

      // 각 강의 확인
      expect(find.text('월요일 강의'), findsOneWidget);
      expect(find.text('수요일 강의'), findsOneWidget);
    });

    testWidgets('삭제 버튼 클릭 시 확인 다이얼로그가 표시된다', (tester) async {
      // 테스트 데이터 추가
      await repository.createLecture(
        Lecture(
          id: 0,
          lectureName: '삭제 테스트 강의',
          instructorName: '교수',
          weekday: Weekday.monday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 0),
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TimetableAdminScreen())),
      );

      await tester.pumpAndSettle();

      // 삭제 버튼 클릭
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // 확인 다이얼로그 확인
      expect(find.text('강의 삭제'), findsOneWidget);
      expect(find.text('정말 이 강의를 삭제하시겠습니까?'), findsOneWidget);
      expect(find.text('취소'), findsWidgets);
      expect(find.text('삭제'), findsOneWidget);
    });

    testWidgets('삭제 확인 후 강의가 삭제된다', (tester) async {
      // 테스트 데이터 추가
      await repository.createLecture(
        Lecture(
          id: 0,
          lectureName: '삭제될 강의',
          instructorName: '교수',
          weekday: Weekday.monday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 0),
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TimetableAdminScreen())),
      );

      await tester.pumpAndSettle();

      // 삭제 버튼 클릭
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // 삭제 확인
      await tester.tap(find.widgetWithText(TextButton, '삭제'));
      await tester.pumpAndSettle();

      // 강의가 삭제되어 빈 상태가 되어야 함
      expect(find.text('등록된 강의가 없습니다'), findsOneWidget);
    });

    testWidgets('삭제 취소 시 강의가 유지된다', (tester) async {
      // 테스트 데이터 추가
      await repository.createLecture(
        Lecture(
          id: 0,
          lectureName: '유지될 강의',
          instructorName: '교수',
          weekday: Weekday.monday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 0),
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TimetableAdminScreen())),
      );

      await tester.pumpAndSettle();

      // 삭제 버튼 클릭
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // 취소 버튼 클릭 (AlertDialog의 취소 버튼)
      final cancelButtons = find.widgetWithText(TextButton, '취소');
      await tester.tap(cancelButtons.first);
      await tester.pumpAndSettle();

      // 강의가 여전히 표시되어야 함
      expect(find.text('유지될 강의'), findsOneWidget);
    });

    testWidgets('새로고침 버튼이 동작한다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TimetableAdminScreen())),
      );

      await tester.pumpAndSettle();

      // 새로고침 버튼 클릭
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // 로딩 후 빈 상태 확인
      expect(find.text('등록된 강의가 없습니다'), findsOneWidget);
    });
  });
}
