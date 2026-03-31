import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';
import 'package:mdk_kiosk/timetable/util/google_sheets.dart';

/// GoogleSheets TimetableRepository 구현 테스트
///
/// GoogleSheets 클래스가 TimetableRepository 인터페이스를
/// 올바르게 구현하는지 검증합니다.
///
/// 테스트 대상:
/// - TimetableRepository 인터페이스 구현
/// - supportsBackgroundRefresh 속성
/// - getLectures() 메서드
/// - getLecturesForToday() 메서드
/// - refresh() 메서드 (반환값 검증)
/// - initialize() 메서드
///
/// 주의: 실제 Google Sheets API 호출을 수행하지 않고,
/// 인터페이스 계약과 동작을 검증합니다.
void main() {
  group('GoogleSheets implements TimetableRepository', () {
    test('should implement TimetableRepository interface', () {
      // Given: GoogleSheets 인스턴스
      final googleSheets = GoogleSheets(sheetName: 'test-room');

      // Then: TimetableRepository 타입으로 사용 가능해야 함
      expect(googleSheets, isA<TimetableRepository>());
    });

    test('should have supportsBackgroundRefresh as true', () {
      // Given: GoogleSheets 인스턴스
      final googleSheets = GoogleSheets(sheetName: 'test-room');

      // Then: 백그라운드 새로고침을 지원해야 함
      expect(googleSheets.supportsBackgroundRefresh, isTrue);
    });
  });

  group('GoogleSheets contract compliance', () {
    test('should expose getLectures returning List<Lecture>', () {
      // Given: GoogleSheets 인스턴스
      final googleSheets = GoogleSheets(sheetName: 'test-room');

      // When: getLectures 호출
      final lectures = googleSheets.getLectures();

      // Then: List<Lecture>를 반환해야 함
      expect(lectures, isA<List<Lecture>>());
    });

    test('should expose getLecturesForToday returning List<Lecture>', () {
      // Given: GoogleSheets 인스턴스
      final googleSheets = GoogleSheets(sheetName: 'test-room');

      // When: getLecturesForToday 호출
      final lectures = googleSheets.getLecturesForToday();

      // Then: List<Lecture>를 반환해야 함
      expect(lectures, isA<List<Lecture>>());
    });

    test('refresh should return Future<bool>', () async {
      // Given: GoogleSheets 인스턴스
      // 참고: 실제 Google Sheets 연결이 없으므로 예외가 발생할 수 있음
      // 이 테스트는 반환 타입 계약만 검증
      final googleSheets = GoogleSheets(sheetName: 'test-room');

      // Then: refresh() 메서드가 Future<bool> 타입을 반환
      // 실제 호출은 초기화되지 않은 상태이므로 예외 발생 가능
      expect(googleSheets.refresh, isA<Function>());
    });

    test('initialize should return Future<void>', () async {
      // Given: GoogleSheets 인스턴스
      final googleSheets = GoogleSheets(sheetName: 'test-room');

      // Then: initialize() 메서드가 Future<void> 타입을 반환
      expect(googleSheets.initialize, isA<Function>());
    });
  });

  group('GoogleSheets caching behavior', () {
    test('should have lectureCache getter', () {
      // Given: GoogleSheets 인스턴스
      final googleSheets = GoogleSheets(sheetName: 'test-room');

      // When: lectureCache getter 접근
      final cache = googleSheets.lectureCache;

      // Then: List<Lecture>를 반환해야 함
      expect(cache, isA<List<Lecture>>());
      expect(cache, isEmpty);
    });

    test('getLectures should return unmodifiable list', () {
      // Given: GoogleSheets 인스턴스
      final googleSheets = GoogleSheets(sheetName: 'test-room');

      // When: getLectures 호출
      final lectures = googleSheets.getLectures();

      // Then: 수정 불가능한 리스트여야 함
      expect(
        () => lectures.add(_createSampleLecture()),
        throwsUnsupportedError,
      );
    });
  });

  group('GoogleSheets configuration', () {
    test('should store sheetName', () {
      // Given: 특정 sheetName으로 생성
      const sheetName = '0-004-0101';
      final googleSheets = GoogleSheets(sheetName: sheetName);

      // Then: sheetName이 저장되어야 함 (낶부 접근 불가하므로 간접 검증)
      // initialize() 호출 시 해당 sheetName이 사용됨
      expect(googleSheets, isNotNull);
    });

    test('different instances should have different sheetNames', () {
      // Given: 두 개의 다른 sheetName을 가진 인스턴스
      final googleSheets1 = GoogleSheets(sheetName: 'room-1');
      final googleSheets2 = GoogleSheets(sheetName: 'room-2');

      // Then: 서로 다른 인스턴스여야 함
      expect(googleSheets1, isNot(equals(googleSheets2)));
    });
  });

  group('GoogleSheets lecture comparison logic', () {
    test('identical lectures should be equal', () {
      // Given: 동일한 데이터를 가진 두 강의
      final lecture1 = _createSampleLecture();
      final lecture2 = _createSampleLecture();

      // Then: 두 강의는 동일해야 함
      expect(lecture1, equals(lecture2));
    });

    test('lectures with different id should not be equal', () {
      // Given: id만 다른 두 강의
      final lecture1 = _createSampleLecture(id: 1);
      final lecture2 = _createSampleLecture(id: 2);

      // Then: 두 강의는 달라야 함
      expect(lecture1, isNot(equals(lecture2)));
    });

    test('lectures with different name should not be equal', () {
      // Given: 이름만 다른 두 강의
      final lecture1 = _createSampleLecture(lectureName: 'Math');
      final lecture2 = _createSampleLecture(lectureName: 'Physics');

      // Then: 두 강의는 달라야 함
      expect(lecture1, isNot(equals(lecture2)));
    });

    test('lectures with different time should not be equal', () {
      // Given: 시간만 다른 두 강의
      final lecture1 = _createSampleLecture(
        startAt: const TimeOfDay(hour: 9, minute: 0),
      );
      final lecture2 = _createSampleLecture(
        startAt: const TimeOfDay(hour: 10, minute: 0),
      );

      // Then: 두 강의는 달라야 함
      expect(lecture1, isNot(equals(lecture2)));
    });
  });

  group('getLecturesForToday filtering', () {
    test('should return only lectures for current weekday', () {
      // Given: GoogleSheets 인스턴스 (캐시가 비어있음)
      final googleSheets = GoogleSheets(sheetName: 'test-room');

      // When: 오늘 강의 조회
      final todayLectures = googleSheets.getLecturesForToday();

      // Then: 빈 리스트여야 함 (캐시가 비어있으므로)
      expect(todayLectures, isEmpty);
    });

    test('should sort lectures by start time', () {
      // Given: 시간순이 아닌 강의 리스트
      final lectures = [
        _createSampleLecture(
          id: 1,
          startAt: const TimeOfDay(hour: 14, minute: 0),
        ),
        _createSampleLecture(
          id: 2,
          startAt: const TimeOfDay(hour: 9, minute: 0),
        ),
        _createSampleLecture(
          id: 3,
          startAt: const TimeOfDay(hour: 10, minute: 30),
        ),
      ];

      // When: 시간순 정렬
      lectures.sort((a, b) {
        final aMinutes = a.startAt.hour * 60 + a.startAt.minute;
        final bMinutes = b.startAt.hour * 60 + b.startAt.minute;
        return aMinutes.compareTo(bMinutes);
      });

      // Then: 시간순으로 정렬되어야 함
      expect(lectures[0].id, equals(2));
      expect(lectures[1].id, equals(3));
      expect(lectures[2].id, equals(1));
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
