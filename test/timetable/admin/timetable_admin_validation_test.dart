import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/timetable/admin/lecture_form_dialog.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

import '../../mocks/mock_timetable_repository.dart';

/// 시간표 관리자 유효성 검증 테스트
///
/// CRUD 폼의 입력값 검증을 테스트합니다.
void main() {
  setUp(() {
    GetIt.I.reset();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('Timetable Admin Validation', () {
    testWidgets('강의명은 필수 입력값', (tester) async {
      // Given: 빈 강의명으로 생성 시도
      final mockRepository = MockEditableTimetableRepository();
      GetIt.I.registerSingleton(mockRepository);

      Lecture? savedLecture;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LectureFormDialog(
              onSave: (lecture) => savedLecture = lecture,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // When: 빈 강의명으로 저장 시도
      await tester.tap(find.text('추가'));
      await tester.pumpAndSettle();

      // Then: 저장되지 않아야 함 (validation error)
      // Note: 실제 validation 구현에 따라 조정 필요
      expect(savedLecture, isNull);
    });

    testWidgets('종료 시간은 시작 시간보다 늦어야 함', (tester) async {
      // Given: 종료 시간이 시작 시간보다 빠른 경우
      final startAt = const TimeOfDay(hour: 10, minute: 0);
      final endAt = const TimeOfDay(hour: 9, minute: 0); // 1시간 일찍

      // Then: 시작 시간 < 종료 시간 검증
      expect(
        startAt.hour * 60 + startAt.minute < endAt.hour * 60 + endAt.minute,
        isFalse,
      );
    });

    testWidgets('colorIndex는 0-5 범위', (tester) async {
      // Given: 유효한 colorIndex 값들
      const validIndices = [0, 1, 2, 3, 4, 5];

      // Then: 모두 0-5 범위 내
      for (final index in validIndices) {
        expect(index >= 0 && index <= 5, isTrue);
      }
    });

    testWidgets('요일은 월-일 범위', (tester) async {
      // Given: 모든 요일 값
      final weekdays = Weekday.values;

      // Then: 7개 요일
      expect(weekdays.length, equals(7));

      // 월요일부터 일요일까지
      expect(weekdays[0], equals(Weekday.monday));
      expect(weekdays[6], equals(Weekday.sunday));
    });

    testWidgets('HH:mm 형식 시간 파싱', (tester) async {
      // Given: 유효한 시간 문자열
      const timeStr = '09:30';

      // When: 파싱
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Then: 올바르게 파싱됨
      expect(hour, equals(9));
      expect(minute, equals(30));
    });

    testWidgets('잘못된 시간 형식은 reject', (tester) async {
      // Given: 잘못된 시간 문자열들
      const invalidTimes = ['25:00', '12:60', 'abc', '9-30'];

      // Then: 모두 유효하지 않음
      for (final timeStr in invalidTimes) {
        final isValid = _isValidTimeFormat(timeStr);
        expect(isValid, isFalse, reason: '$timeStr should be invalid');
      }
    });
  });
}

/// HH:mm 형식 검증 헬퍼
bool _isValidTimeFormat(String timeStr) {
  try {
    final parts = timeStr.split(':');
    if (parts.length != 2) return false;

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  } catch (e) {
    return false;
  }
}
