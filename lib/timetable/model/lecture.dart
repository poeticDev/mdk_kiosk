import 'package:flutter/material.dart';

enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

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

  /// 📌 **스프레드시트 → Lecture 객체 변환**
  factory Lecture.fromGsheets(Map<String, String> json) {
    bool hasError = false;
    final errorFields = <String>[];

    final id = int.tryParse(json['id'] ?? '0') ?? 0;

    String lectureName = json['lectureName'] ?? '불러오기 실패';
    final instructorName = json['instructorName'] ?? '';

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

    TimeOfDay startAt;
    try {
      startAt = getTimeFromGsheets(json['startAt'] ?? '');
    } catch (_) {
      startAt = const TimeOfDay(hour: 9, minute: 0);
      hasError = true;
      errorFields.add('startAt');
    }

    TimeOfDay endAt;
    try {
      endAt = getTimeFromGsheets(json['endAt'] ?? '');
    } catch (_) {
      endAt = const TimeOfDay(hour: 18, minute: 0);
      hasError = true;
      errorFields.add('endAt');
    }

    int colorIndex;
    try {
      colorIndex = (int.tryParse(json['colorIndex'] ?? '0') ?? 0) % 6;
    } catch (_) {
      colorIndex = 0;
      hasError = true;
      errorFields.add('colorIndex');
    }

    if (hasError && !lectureName.startsWith('✔')) {
      lectureName = '✔ $lectureName';
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

  /// 📌 **Lecture 객체 → 스프레드시트 데이터 변환**
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

  /// 📌 **String → TimeOfDay 변환 (스프레드시트에서 읽을 때)**
  static TimeOfDay getTimeFromGsheets(String string) {
    final trimmedString = string.trim();

    if (trimmedString.contains(':')) {
      final splitedString = trimmedString.split(':');
      return TimeOfDay(
        hour: int.tryParse(splitedString[0]) ?? 0,
        minute: int.tryParse(
              splitedString.length > 1 ? splitedString[1] : '0',
            ) ??
            0,
      );
    }

    final serialTime = double.tryParse(trimmedString);
    if (serialTime == null) {
      throw FormatException('지원하지 않는 시간 형식입니다: $string');
    }
    if (serialTime < 0) {
      throw FormatException('음수 시간 시리얼은 지원하지 않습니다: $string');
    }

    final normalizedTime = serialTime >= 1
        ? serialTime - serialTime.floorToDouble()
        : serialTime;
    final totalMinutes = (normalizedTime * 24 * 60).round();
    final normalizedMinutes = totalMinutes % (24 * 60);

    return TimeOfDay(
      hour: normalizedMinutes ~/ 60,
      minute: normalizedMinutes % 60,
    );
  }

  /// 📌 **TimeOfDay → String 변환 (스프레드시트에 저장할 때)**
  static String getTimeToString(TimeOfDay timeOfDay) {
    final String time = timeOfDay.hour.toString().padLeft(2, '0');
    final String min = timeOfDay.minute.toString().padLeft(2, '0');

    return '$time:$min';
  }

  /// 📌 **한국어 요일(String) → Weekday 변환**
  // int getWeekdayNumber(Weekday day) => day.index + 1;
  static Weekday getWeekDayFromKr(String krName) {
    for (int i = 0; i < weekdays.length; i++) {
      if (krName.contains(weekdays[i])) {
        return Weekday.values[i];
      }
    }
    return Weekday.sunday;
  }

  String getWeekdayInKR() => weekdays[weekday.index];
}
