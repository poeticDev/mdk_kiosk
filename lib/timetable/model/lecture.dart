import 'package:flutter/material.dart';

import '../data/mappers/gsheets_mapper.dart';

/// 요일 enum (월 ~ 일)
enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

/// 한국어 요일 문자열 리스트 (enum index와 매칭)
List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

/// 강의 정보 모델
///
/// 순수 도메인 모델로, 데이터 소스별 매핑 로직은 별도의 매퍼 클래스에서 처리합니다.
///
/// Google Sheets 매핑: [GsheetsMapper] (lib/timetable/data/mappers/gsheets_mapper.dart)
class Lecture {
  final int id;
  final String lectureName;
  final String instructorName;
  final Weekday weekday;
  final TimeOfDay startAt;
  final TimeOfDay endAt;
  final int colorIndex;

  const Lecture({
    required this.id,
    required this.lectureName,
    required this.instructorName,
    required this.weekday,
    required this.startAt,
    required this.endAt,
    this.colorIndex = 0,
  });

  /// Weekday → 한국어 요일(String) 변환
  String getWeekdayInKR() => weekdays[weekday.index];

  /// 객체 복사본 생성 (필드 변경 가능)
  Lecture copyWith({
    int? id,
    String? lectureName,
    String? instructorName,
    Weekday? weekday,
    TimeOfDay? startAt,
    TimeOfDay? endAt,
    int? colorIndex,
  }) {
    return Lecture(
      id: id ?? this.id,
      lectureName: lectureName ?? this.lectureName,
      instructorName: instructorName ?? this.instructorName,
      weekday: weekday ?? this.weekday,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  @override
  String toString() {
    return 'Lecture(id: $id, name: $lectureName, instructor: $instructorName, '
        'weekday: $weekday, startAt: ${startAt.hour}:${startAt.minute.toString().padLeft(2, '0')}, '
        'endAt: ${endAt.hour}:${endAt.minute.toString().padLeft(2, '0')}, colorIndex: $colorIndex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lecture &&
        other.id == id &&
        other.lectureName == lectureName &&
        other.instructorName == instructorName &&
        other.weekday == weekday &&
        other.startAt.hour == startAt.hour &&
        other.startAt.minute == startAt.minute &&
        other.endAt.hour == endAt.hour &&
        other.endAt.minute == endAt.minute &&
        other.colorIndex == colorIndex;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      lectureName,
      instructorName,
      weekday,
      startAt.hour,
      startAt.minute,
      endAt.hour,
      endAt.minute,
      colorIndex,
    );
  }
}

/// Google Sheets 매핑을 위한 Lecture 확장
extension LectureGsheetsExtension on Lecture {
  /// Google Sheets 행 데이터 → Lecture 객체 변환
  ///
  /// [GsheetsMapper.fromGsheets]를 사용하여 변환합니다.
  static Lecture fromGsheets(Map<String, String> row) {
    return GsheetsMapper.fromGsheets(row);
  }

  /// Lecture 객체 → Google Sheets 행 데이터 변환
  ///
  /// [GsheetsMapper.toGsheets]를 사용하여 변환합니다.
  Map<String, String> toGsheets() {
    return GsheetsMapper.toGsheets(this);
  }
}
