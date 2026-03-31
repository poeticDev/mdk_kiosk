import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mdk_kiosk/timetable/data/mappers/gsheets_mapper.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

/// GsheetsMapper 테스트
///
/// Google Sheets 행 데이터와 Lecture 도메인 모델 간의 양방향 매핑을 검증합니다.
void main() {
  group('GsheetsMapper.fromGsheets', () {
    test('should map valid Google Sheets row to Lecture', () {
      // Given: 유효한 Google Sheets 행 데이터
      final row = {
        'id': '1',
        'lectureName': 'Math',
        'instructorName': 'Kim',
        'weekday': '월',
        'startAt': '09:00',
        'endAt': '09:50',
        'colorIndex': '2',
      };

      // When: 매핑 수행
      final lecture = GsheetsMapper.fromGsheets(row);

      // Then: 모든 필드가 올바르게 매핑되어야 함
      expect(lecture.id, equals(1));
      expect(lecture.lectureName, equals('Math'));
      expect(lecture.instructorName, equals('Kim'));
      expect(lecture.weekday, equals(Weekday.monday));
      expect(lecture.startAt, equals(const TimeOfDay(hour: 9, minute: 0)));
      expect(lecture.endAt, equals(const TimeOfDay(hour: 9, minute: 50)));
      expect(lecture.colorIndex, equals(2));
    });

    test('should map all weekdays correctly', () {
      // 월요일
      final mondayLecture = GsheetsMapper.fromGsheets({'weekday': '월'});
      expect(mondayLecture.weekday, equals(Weekday.monday));

      // 화요일
      final tuesdayLecture = GsheetsMapper.fromGsheets({'weekday': '화'});
      expect(tuesdayLecture.weekday, equals(Weekday.tuesday));

      // 수요일
      final wednesdayLecture = GsheetsMapper.fromGsheets({'weekday': '수'});
      expect(wednesdayLecture.weekday, equals(Weekday.wednesday));

      // 목요일
      final thursdayLecture = GsheetsMapper.fromGsheets({'weekday': '목'});
      expect(thursdayLecture.weekday, equals(Weekday.thursday));

      // 금요일
      final fridayLecture = GsheetsMapper.fromGsheets({'weekday': '금'});
      expect(fridayLecture.weekday, equals(Weekday.friday));

      // 토요일
      final saturdayLecture = GsheetsMapper.fromGsheets({'weekday': '토'});
      expect(saturdayLecture.weekday, equals(Weekday.saturday));

      // 일요일
      final sundayLecture = GsheetsMapper.fromGsheets({'weekday': '일'});
      expect(sundayLecture.weekday, equals(Weekday.sunday));
    });

    test('should handle empty or missing fields with fallback values', () {
      // Given: 빈 행 데이터
      final row = <String, String>{};

      // When: 매핑 수행
      final lecture = GsheetsMapper.fromGsheets(row);

      // Then: fallback 값이 적용되어야 함 (weekday 파싱 실패로 인해 체크 표시가 추가됨)
      // 참고: startAt/endAt은 parseTime이 00:00을 반환하며, 이는 유효한 시간 범위이므로 fallback이 적용되지 않음
      expect(lecture.id, equals(0));
      expect(lecture.lectureName, equals('✔ 불러오기 실패'));
      expect(lecture.instructorName, equals(''));
      expect(lecture.weekday, equals(Weekday.monday));
      expect(lecture.startAt, equals(const TimeOfDay(hour: 0, minute: 0)));
      expect(lecture.endAt, equals(const TimeOfDay(hour: 0, minute: 0)));
      expect(lecture.colorIndex, equals(0));
    });

    test('should mark lecture with checkmark on parse error', () {
      // Given: 잘못된 시간 형식 (시간 범위 초과)
      final row = {
        'lectureName': 'Physics',
        'startAt': '25:00', // Invalid hour
      };

      // When: 매핑 수행
      final lecture = GsheetsMapper.fromGsheets(row);

      // Then: 오류 표시가 강의명에 추가되어야 함
      expect(lecture.lectureName, startsWith('✔'));
      expect(lecture.startAt, equals(const TimeOfDay(hour: 9, minute: 0)));
    });

    test('should handle invalid id gracefully', () {
      // Given: 유효하지 않은 id
      final row = {'id': 'invalid'};

      // When: 매핑 수행
      final lecture = GsheetsMapper.fromGsheets(row);

      // Then: 0으로 fallback
      expect(lecture.id, equals(0));
    });

    test('should handle invalid colorIndex with modulo', () {
      // Given: 범위를 벗어난 colorIndex
      final row = {'colorIndex': '10'};

      // When: 매핑 수행
      final lecture = GsheetsMapper.fromGsheets(row);

      // Then: 6으로 나눈 나머지가 적용됨
      expect(lecture.colorIndex, equals(4)); // 10 % 6 = 4
    });

    test('should not add duplicate checkmark', () {
      // Given: 이미 체크 표시가 있는 강의명
      final row = {'lectureName': '✔ Already Checked', 'startAt': 'invalid'};

      // When: 매핑 수행
      final lecture = GsheetsMapper.fromGsheets(row);

      // Then: 중복 체크 표시가 추가되지 않아야 함
      expect(lecture.lectureName, equals('✔ Already Checked'));
    });

    test('should handle weekday in compound strings', () {
      // Given: 복합 문자열에서 요일 추출
      final row = {'weekday': '월요일 수업'};

      // When: 매핑 수행
      final lecture = GsheetsMapper.fromGsheets(row);

      // Then: 첫 번째 매칭되는 요일이 선택됨
      expect(lecture.weekday, equals(Weekday.monday));
    });
  });

  group('GsheetsMapper.toGsheets', () {
    test('should map Lecture to Google Sheets row', () {
      // Given: Lecture 객체
      final lecture = Lecture(
        id: 1,
        lectureName: 'Math',
        instructorName: 'Kim',
        weekday: Weekday.monday,
        startAt: const TimeOfDay(hour: 9, minute: 0),
        endAt: const TimeOfDay(hour: 9, minute: 50),
        colorIndex: 2,
      );

      // When: 매핑 수행
      final row = GsheetsMapper.toGsheets(lecture);

      // Then: 모든 필드가 올바르게 매핑되어야 함
      expect(row['id'], equals('1'));
      expect(row['lectureName'], equals('Math'));
      expect(row['instructorName'], equals('Kim'));
      expect(row['weekday'], equals('월'));
      expect(row['startAt'], equals('09:00'));
      expect(row['endAt'], equals('09:50'));
      expect(row['colorIndex'], equals('2'));
    });

    test('should format time with leading zeros', () {
      // Given: 한 자리 시간과 분을 가진 Lecture
      final lecture = Lecture(
        id: 1,
        lectureName: 'Test',
        instructorName: 'Instructor',
        weekday: Weekday.monday,
        startAt: const TimeOfDay(hour: 1, minute: 5),
        endAt: const TimeOfDay(hour: 2, minute: 30),
        colorIndex: 0,
      );

      // When: 매핑 수행
      final row = GsheetsMapper.toGsheets(lecture);

      // Then: 시간이 두 자리로 포맷되어야 함
      expect(row['startAt'], equals('01:05'));
      expect(row['endAt'], equals('02:30'));
    });

    test('should map all weekdays to Korean strings', () {
      final weekdays = [
        (Weekday.monday, '월'),
        (Weekday.tuesday, '화'),
        (Weekday.wednesday, '수'),
        (Weekday.thursday, '목'),
        (Weekday.friday, '금'),
        (Weekday.saturday, '토'),
        (Weekday.sunday, '일'),
      ];

      for (final (weekday, expectedKorean) in weekdays) {
        final lecture = Lecture(
          id: 1,
          lectureName: 'Test',
          instructorName: 'Instructor',
          weekday: weekday,
          startAt: const TimeOfDay(hour: 9, minute: 0),
          endAt: const TimeOfDay(hour: 10, minute: 0),
          colorIndex: 0,
        );

        final row = GsheetsMapper.toGsheets(lecture);
        expect(row['weekday'], equals(expectedKorean));
      }
    });
  });

  group('GsheetsMapper.parseTime', () {
    test('should parse valid time strings', () {
      expect(
        GsheetsMapper.parseTime('09:00'),
        equals(const TimeOfDay(hour: 9, minute: 0)),
      );
      expect(
        GsheetsMapper.parseTime('14:30'),
        equals(const TimeOfDay(hour: 14, minute: 30)),
      );
      expect(
        GsheetsMapper.parseTime('23:59'),
        equals(const TimeOfDay(hour: 23, minute: 59)),
      );
    });

    test('should handle empty string', () {
      expect(
        GsheetsMapper.parseTime(''),
        equals(const TimeOfDay(hour: 0, minute: 0)),
      );
    });

    test('should handle hour only format', () {
      expect(
        GsheetsMapper.parseTime('09'),
        equals(const TimeOfDay(hour: 9, minute: 0)),
      );
    });

    test('should handle invalid time strings gracefully', () {
      expect(
        GsheetsMapper.parseTime('invalid'),
        equals(const TimeOfDay(hour: 0, minute: 0)),
      );
      expect(
        GsheetsMapper.parseTime('::'),
        equals(const TimeOfDay(hour: 0, minute: 0)),
      );
    });
  });

  group('GsheetsMapper.formatTime', () {
    test('should format TimeOfDay to HH:mm string', () {
      expect(
        GsheetsMapper.formatTime(const TimeOfDay(hour: 9, minute: 0)),
        equals('09:00'),
      );
      expect(
        GsheetsMapper.formatTime(const TimeOfDay(hour: 14, minute: 30)),
        equals('14:30'),
      );
      expect(
        GsheetsMapper.formatTime(const TimeOfDay(hour: 23, minute: 59)),
        equals('23:59'),
      );
    });

    test('should pad single digits with zeros', () {
      expect(
        GsheetsMapper.formatTime(const TimeOfDay(hour: 1, minute: 5)),
        equals('01:05'),
      );
      expect(
        GsheetsMapper.formatTime(const TimeOfDay(hour: 0, minute: 0)),
        equals('00:00'),
      );
    });
  });

  group('GsheetsMapper.parseWeekday', () {
    test('should parse Korean weekday characters', () {
      expect(GsheetsMapper.parseWeekday('월'), equals(Weekday.monday));
      expect(GsheetsMapper.parseWeekday('화'), equals(Weekday.tuesday));
      expect(GsheetsMapper.parseWeekday('수'), equals(Weekday.wednesday));
      expect(GsheetsMapper.parseWeekday('목'), equals(Weekday.thursday));
      expect(GsheetsMapper.parseWeekday('금'), equals(Weekday.friday));
      expect(GsheetsMapper.parseWeekday('토'), equals(Weekday.saturday));
      expect(GsheetsMapper.parseWeekday('일'), equals(Weekday.sunday));
    });

    test('should return sunday for unknown weekday', () {
      expect(GsheetsMapper.parseWeekday(''), equals(Weekday.sunday));
      expect(GsheetsMapper.parseWeekday('X'), equals(Weekday.sunday));
      expect(GsheetsMapper.parseWeekday('Unknown'), equals(Weekday.sunday));
    });

    test('should find first matching weekday in compound string', () {
      expect(GsheetsMapper.parseWeekday('월요일'), equals(Weekday.monday));
      expect(GsheetsMapper.parseWeekday('화요일'), equals(Weekday.tuesday));
      expect(GsheetsMapper.parseWeekday('매주 월요일 수업'), equals(Weekday.monday));
    });
  });

  group('GsheetsMapper.formatWeekday', () {
    test('should format Weekday to Korean string', () {
      expect(GsheetsMapper.formatWeekday(Weekday.monday), equals('월'));
      expect(GsheetsMapper.formatWeekday(Weekday.tuesday), equals('화'));
      expect(GsheetsMapper.formatWeekday(Weekday.wednesday), equals('수'));
      expect(GsheetsMapper.formatWeekday(Weekday.thursday), equals('목'));
      expect(GsheetsMapper.formatWeekday(Weekday.friday), equals('금'));
      expect(GsheetsMapper.formatWeekday(Weekday.saturday), equals('토'));
      expect(GsheetsMapper.formatWeekday(Weekday.sunday), equals('일'));
    });
  });

  group('GsheetsMapper round-trip conversion', () {
    test('should preserve lecture data through round-trip conversion', () {
      // Given: 원본 Lecture 객체
      final originalLecture = Lecture(
        id: 42,
        lectureName: 'Advanced Physics',
        instructorName: 'Dr. Smith',
        weekday: Weekday.wednesday,
        startAt: const TimeOfDay(hour: 13, minute: 30),
        endAt: const TimeOfDay(hour: 15, minute: 0),
        colorIndex: 3,
      );

      // When: Lecture -> Google Sheets row -> Lecture 변환
      final row = GsheetsMapper.toGsheets(originalLecture);
      final reconstructedLecture = GsheetsMapper.fromGsheets(row);

      // Then: 데이터가 보존되어야 함
      expect(reconstructedLecture.id, equals(originalLecture.id));
      expect(
        reconstructedLecture.lectureName,
        equals(originalLecture.lectureName),
      );
      expect(
        reconstructedLecture.instructorName,
        equals(originalLecture.instructorName),
      );
      expect(reconstructedLecture.weekday, equals(originalLecture.weekday));
      expect(reconstructedLecture.startAt, equals(originalLecture.startAt));
      expect(reconstructedLecture.endAt, equals(originalLecture.endAt));
      expect(
        reconstructedLecture.colorIndex,
        equals(originalLecture.colorIndex),
      );
    });

    test('round-trip should preserve time formatting', () {
      final original = Lecture(
        id: 1,
        lectureName: 'Test',
        instructorName: 'Instructor',
        weekday: Weekday.monday,
        startAt: const TimeOfDay(hour: 9, minute: 5),
        endAt: const TimeOfDay(hour: 10, minute: 55),
        colorIndex: 0,
      );

      final row = GsheetsMapper.toGsheets(original);
      expect(row['startAt'], equals('09:05'));
      expect(row['endAt'], equals('10:55'));

      final reconstructed = GsheetsMapper.fromGsheets(row);
      expect(
        reconstructed.startAt,
        equals(const TimeOfDay(hour: 9, minute: 5)),
      );
      expect(
        reconstructed.endAt,
        equals(const TimeOfDay(hour: 10, minute: 55)),
      );
    });
  });
}
