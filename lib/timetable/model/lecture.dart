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
    return Lecture(
      id: int.tryParse(json['id'] ?? '0') ?? 0,
      lectureName: json['lectureName'] ?? '불러오기 실패',
      instructorName: json['instructorName'] ?? '',
      weekday: getWeekDayFromKr(json['weekday'] ?? ''),
      startAt: getTimeFromGsheets(json['startAt'] ?? '00:00'),
      endAt: getTimeFromGsheets(json['endAt'] ?? '00:00'),
      colorIndex: int.tryParse(json['colorIndex'] ?? '0') ?? 0,
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
    final splitedString = string.split(':');
    final timeOfDay = TimeOfDay(
        hour: int.tryParse(splitedString[0]) ?? 0,
        minute: int.tryParse(splitedString[1]) ?? 0);

    return timeOfDay;
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
