import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/timetable/admin/lecture_form_dialog.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LectureFormDialog', () {
    group('생성 모드', () {
      testWidgets('다이얼로그가 올바르게 렌더링된다', (tester) async {
        // 큰 뷰포트 설정
        await tester.binding.setSurfaceSize(const Size(1200, 1200));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => LectureFormDialog(onSave: (_) {}),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        // 다이얼로그 열기
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // 타이틀 확인
        expect(find.text('강의 추가'), findsOneWidget);

        // 입력 필드 확인
        expect(find.text('강의명 *'), findsOneWidget);
        expect(find.text('교수명'), findsOneWidget);
        expect(find.text('요일'), findsOneWidget);
        expect(find.text('시작 시간'), findsOneWidget);
        expect(find.text('종료 시간'), findsOneWidget);
        expect(find.text('색상'), findsOneWidget);

        // 버튼 확인
        expect(find.text('취소'), findsOneWidget);
        expect(find.text('추가'), findsOneWidget);
      });

      testWidgets('필수 필드 검증이 동작한다', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 1200));
        Lecture? savedLecture;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => LectureFormDialog(
                        onSave: (lecture) => savedLecture = lecture,
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        // 다이얼로그 열기
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // 강의명 없이 저장 시도 - 버튼이 보일 때까지 스크롤
        await tester.ensureVisible(find.text('추가'));
        await tester.tap(find.text('추가'), warnIfMissed: false);
        await tester.pumpAndSettle();

        // 다이얼로그가 닫히지 않아야 함
        expect(find.text('강의 추가'), findsOneWidget);
        expect(savedLecture, isNull);
      });

      testWidgets('올바른 데이터로 강의를 생성한다', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 1200));
        Lecture? savedLecture;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => LectureFormDialog(
                        onSave: (lecture) => savedLecture = lecture,
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        // 다이얼로그 열기
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // 강의명 입력 - CustomTextFormField 내부의 TextFormField 찾기
        // CustomTextFormField는 내부적으로 TextEditingController를 사용하므로
        // hintText로 필드를 식별하여 입력
        final lectureNameInput = find.widgetWithText(
          TextFormField,
          '강의명을 입력하세요',
        );
        if (lectureNameInput.evaluate().isNotEmpty) {
          await tester.enterText(lectureNameInput.first, '테스트 강의');
        } else {
          // 대안: 모든 TextFormField 중 첫 번째 사용
          final allTextFields = find.byType(TextFormField);
          await tester.enterText(allTextFields.first, '테스트 강의');
        }
        await tester.pumpAndSettle();

        // 저장 - 버튼이 보일 때까지 스크롤
        await tester.ensureVisible(find.text('추가'));
        await tester.tap(find.text('추가'), warnIfMissed: false);
        await tester.pumpAndSettle();

        // 저장된 강의 확인 - 강의명이 입력되었으므로 저장되어야 함
        expect(savedLecture, isNotNull);
        expect(savedLecture!.lectureName, equals('테스트 강의'));
        // 교수명은 입력하지 않았으므로 빈 문자열
        expect(savedLecture!.instructorName, equals(''));
        expect(savedLecture!.weekday, equals(Weekday.monday));
        expect(savedLecture!.colorIndex, equals(0));
      });

      testWidgets('취소 버튼이 동작한다', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 1200));
        Lecture? savedLecture;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => LectureFormDialog(
                        onSave: (lecture) => savedLecture = lecture,
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        // 다이얼로그 열기
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // 취소 버튼 클릭 - 버튼이 보일 때까지 스크롤
        await tester.ensureVisible(find.text('취소'));
        await tester.tap(find.text('취소'), warnIfMissed: false);
        await tester.pumpAndSettle();

        // 다이얼로그가 닫혀야 함
        expect(find.text('강의 추가'), findsNothing);
        expect(savedLecture, isNull);
      });

      testWidgets('색상 선택이 동작한다', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 1200));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => LectureFormDialog(onSave: (_) {}),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        // 다이얼로그 열기
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // 색상 선택기 확인
        expect(find.text('색상'), findsOneWidget);

        // 색상 옵션들이 표시되는지 확인
        for (int i = 0; i < LECTURE_BG_COLORS.length; i++) {
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration as BoxDecoration).color ==
                      LECTURE_BG_COLORS[i],
            ),
            findsWidgets,
          );
        }
      });
    });

    group('수정 모드', () {
      testWidgets('기존 강의 데이터로 폼이 초기화된다', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 1200));

        final existingLecture = Lecture(
          id: 1,
          lectureName: '기존 강의',
          instructorName: '기존 교수',
          weekday: Weekday.wednesday,
          startAt: const TimeOfDay(hour: 14, minute: 0),
          endAt: const TimeOfDay(hour: 16, minute: 0),
          colorIndex: 2,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => LectureFormDialog(
                        lecture: existingLecture,
                        onSave: (_) {},
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        // 다이얼로그 열기
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // 수정 모드 타이틀 확인
        expect(find.text('강의 수정'), findsOneWidget);

        // 기존 데이터가 표시되는지 확인
        expect(find.text('기존 강의'), findsWidgets);
        expect(find.text('기존 교수'), findsWidgets);
      });

      testWidgets('수정 버튼이 표시된다', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 1200));

        final existingLecture = Lecture(
          id: 1,
          lectureName: '기존 강의',
          instructorName: '기존 교수',
          weekday: Weekday.monday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 0),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => LectureFormDialog(
                        lecture: existingLecture,
                        onSave: (_) {},
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        // 다이얼로그 열기
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // 수정 버튼 확인
        expect(find.text('수정'), findsOneWidget);
      });
    });
  });
}
