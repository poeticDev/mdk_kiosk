import 'package:flutter/material.dart';

import '../../model/lecture.dart';

/// Google Sheets 행 데이터와 Lecture 도메인 모델 간의 매핑을 담당합니다.
///
/// 이 클래스는 Lecture 모델에서 분리된 Google Sheets 전용 매핑 로직을 포함합니다.
class GsheetsMapper {
  /// 한국어 요일 문자열 리스트 (enum index와 매칭)
  static const List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  /// Google Sheets 행 데이터 → Lecture 객체 변환
  ///
  /// [row]는 Google Sheets API에서 반환한 행 데이터입니다.
  /// 각 컬럼은 다음 키를 사용합니다:
  /// - id: 강의 ID (정수)
  /// - lectureName: 강의명
  /// - instructorName: 교수명
  /// - weekday: 요일 (한국어: 월, 화, 수, 목, 금, 토, 일)
  /// - startAt: 시작 시간 (HH:mm 형식)
  /// - endAt: 종료 시간 (HH:mm 형식)
  /// - colorIndex: 색상 인덱스 (0-5)
  ///
  /// 파싱 오류 시 fallback 값을 적용하고 오류가 있는 강의명 앞에 체크 표시를 추가합니다.
  static Lecture fromGsheets(Map<String, String> row) {
    bool hasError = false;
    List<String> errorFields = [];

    // id
    final id = int.tryParse(row['id'] ?? '0') ?? 0;

    // lectureName
    String lectureName = row['lectureName'] ?? '불러오기 실패';

    // instructorName
    final instructorName = row['instructorName'] ?? '';

    // weekday
    Weekday weekday;
    try {
      weekday = parseWeekday(row['weekday'] ?? '');
      if (weekday == Weekday.sunday && !(row['weekday'] ?? '').contains('일')) {
        weekday = Weekday.monday;
        hasError = true;
        errorFields.add('weekday');
      }
    } catch (_) {
      weekday = Weekday.monday;
      hasError = true;
      errorFields.add('weekday');
    }

    // startAt
    TimeOfDay startAt;
    try {
      startAt = parseTime(row['startAt'] ?? '');
      if (startAt.hour < 0 ||
          startAt.hour > 23 ||
          startAt.minute < 0 ||
          startAt.minute > 59) {
        throw Exception('Invalid time range');
      }
    } catch (_) {
      startAt = const TimeOfDay(hour: 9, minute: 0);
      hasError = true;
      errorFields.add('startAt');
    }

    // endAt
    TimeOfDay endAt;
    try {
      endAt = parseTime(row['endAt'] ?? '');
      if (endAt.hour < 0 ||
          endAt.hour > 23 ||
          endAt.minute < 0 ||
          endAt.minute > 59) {
        throw Exception('Invalid time range');
      }
    } catch (_) {
      endAt = const TimeOfDay(hour: 18, minute: 0);
      hasError = true;
      errorFields.add('endAt');
    }

    // colorIndex
    int colorIndex;
    try {
      final rawIndex = int.tryParse(row['colorIndex'] ?? '') ?? 0;
      colorIndex = rawIndex % 6;
    } catch (_) {
      colorIndex = 0;
      hasError = true;
      errorFields.add('colorIndex');
    }

    // 오류 발생 시 lectureName 앞에 체크 추가
    if (hasError && !lectureName.startsWith('✔')) {
      lectureName = '✔ $lectureName';
    }

    // 디버그 로그 출력
    if (hasError) {
      // ignore: avoid_print
      print(
        '⚠️ Lecture 파싱 오류 발생 (id: $id, name: "$lectureName") → 오류 필드: $errorFields',
      );
    }

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

  /// Lecture 객체 → Google Sheets 행 데이터 변환
  ///
  /// [lecture] 객체를 Google Sheets API에 저장할 수 있는 행 데이터로 변환합니다.
  static Map<String, String> toGsheets(Lecture lecture) {
    return {
      'id': lecture.id.toString(),
      'lectureName': lecture.lectureName,
      'instructorName': lecture.instructorName,
      'weekday': formatWeekday(lecture.weekday),
      'startAt': formatTime(lecture.startAt),
      'endAt': formatTime(lecture.endAt),
      'colorIndex': lecture.colorIndex.toString(),
    };
  }

  /// 시간 문자열 → TimeOfDay 변환
  ///
  /// [timeStr]은 HH:mm 형식의 시간 문자열입니다.
  /// 파싱 실패 시 00:00을 반환합니다.
  static TimeOfDay parseTime(String timeStr) {
    if (timeStr.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }

    final splitedString = timeStr.split(':');
    if (splitedString.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }

    final hour = int.tryParse(splitedString[0]) ?? 0;
    final minute = splitedString.length > 1
        ? int.tryParse(splitedString[1]) ?? 0
        : 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  /// TimeOfDay → 시간 문자열 변환
  ///
  /// [time]을 HH:mm 형식의 문자열로 변환합니다.
  static String formatTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 한국어 요일 문자열 → Weekday 변환
  ///
  /// [krName]에서 첫 번째로 매칭되는 한국어 요일을 찾아 반환합니다.
  /// 매칭되는 요일이 없으면 [Weekday.sunday]를 반환합니다.
  static Weekday parseWeekday(String krName) {
    for (int i = 0; i < _weekdays.length; i++) {
      if (krName.contains(_weekdays[i])) {
        return Weekday.values[i];
      }
    }
    return Weekday.sunday;
  }

  /// Weekday → 한국어 요일 문자열 변환
  ///
  /// [weekday]를 해당하는 한국어 요일 문자열로 변환합니다.
  static String formatWeekday(Weekday weekday) {
    return _weekdays[weekday.index];
  }
}
