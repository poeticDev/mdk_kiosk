import 'package:flutter/material.dart';

/// 요일 enum (월 ~ 일)
enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

/// 한국어 요일 문자열 리스트 (enum index와 매칭)
List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

/// 강의 정보 모델
class Lecture {
  final int id;
  final String lectureName;
  final String instructorName;
  final Weekday weekday;
  final TimeOfDay startAt;
  final TimeOfDay endAt;
  final int colorIndex;

  Lecture({
    required this.id,
    required this.lectureName,
    required this.instructorName,
    required this.weekday,
    required this.startAt,
    required this.endAt,
    this.colorIndex = 0,
  });

  /// 스프레드시트 → Lecture 객체 변환
  /// 필드 파싱 오류 시 fallback 적용 + 오류 로그 출력 + lectureName에 체크 추가
  factory Lecture.fromGsheets(Map<String, String> json) {
    bool hasError = false;
    List<String> errorFields = [];

    // id
    final id = int.tryParse(json['id'] ?? '0') ?? 0;

    // lectureName
    String lectureName = json['lectureName'] ?? '불러오기 실패';

    // instructorName
    final instructorName = json['instructorName'] ?? '';

    // weekday
    Weekday weekday;
    try {
      weekday = getWeekDayFromKr(json['weekday'] ?? '');
      if (weekday == Weekday.sunday && !(json['weekday'] ?? '').contains('일')) {
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
      startAt = getTimeFromGsheets(json['startAt'] ?? '');
      if (startAt.hour < 0 || startAt.hour > 23 || startAt.minute < 0 || startAt.minute > 59) {
        throw Exception();
      }
    } catch (_) {
      startAt = TimeOfDay(hour: 9, minute: 0);
      hasError = true;
      errorFields.add('startAt');
    }

    // endAt
    TimeOfDay endAt;
    try {
      endAt = getTimeFromGsheets(json['endAt'] ?? '');
      if (endAt.hour < 0 || endAt.hour > 23 || endAt.minute < 0 || endAt.minute > 59) {
        throw Exception();
      }
    } catch (_) {
      endAt = TimeOfDay(hour: 18, minute: 0);
      hasError = true;
      errorFields.add('endAt');
    }

    // colorIndex
    int colorIndex;
    try {
      final rawIndex = int.tryParse(json['colorIndex'] ?? '') ?? 0;
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
      print('⚠️ Lecture 파싱 오류 발생 (id: $id, name: "$lectureName") → 오류 필드: $errorFields');
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

  /// Lecture 객체 → 스프레드시트 데이터 변환
  Map<String, String> toGsheets() {
    return {
      'id': id.toString(),
      'lectureName': lectureName,
      'instructorName': instructorName,
      'weekday': getWeekdayInKR(),
      'startAt': getTimeToString(startAt),
      'endAt': getTimeToString(endAt),
      'colorIndex': colorIndex.toString(),
    };
  }

  /// String → TimeOfDay 변환 (스프레드시트 시간 문자열 파싱)
  static TimeOfDay getTimeFromGsheets(String string) {
    final splitedString = string.split(':');
    final timeOfDay = TimeOfDay(
      hour: int.tryParse(splitedString[0]) ?? 0,
      minute: int.tryParse(splitedString.length > 1 ? splitedString[1] : '0') ?? 0,
    );

    return timeOfDay;
  }

  /// TimeOfDay → String 변환 (스프레드시트 저장용)
  static String getTimeToString(TimeOfDay timeOfDay) {
    final String time = timeOfDay.hour.toString().padLeft(2, '0');
    final String min = timeOfDay.minute.toString().padLeft(2, '0');

    return '$time:$min';
  }

  /// 한국어 요일(String) → Weekday 변환
  static Weekday getWeekDayFromKr(String krName) {
    for (int i = 0; i < weekdays.length; i++) {
      if (krName.contains(weekdays[i])) {
        return Weekday.values[i];
      }
    }
    return Weekday.sunday;
  }

  /// Weekday → 한국어 요일(String) 변환
  String getWeekdayInKR() => weekdays[weekday.index];
}
