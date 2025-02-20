import 'package:drift/drift.dart';

// 요일 종류
enum Weekday {
  Mon,
  Tues,
  Wednes,
  Thurs,
  Fri,
  Satur,
  Sun,
}

class Timetable extends Table {
  /// 1) 식별 아이디
  IntColumn get id => integer().autoIncrement()();

  /// 2) 강의자
  TextColumn get educator => text().nullable()();

  /// 3) 강의명
  TextColumn get courseName => text()();

  /// 4) 시작 시간
  DateTimeColumn get startAt => dateTime()();

  /// 5) 종료 시간
  DateTimeColumn get endAt => dateTime()();

  /// 6) 강의 요일
  TextColumn get weekDay => textEnum<Weekday>()();

}