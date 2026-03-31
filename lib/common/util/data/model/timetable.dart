import 'package:drift/drift.dart';

class Timetables extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get roomId => text()();
  TextColumn get lectureName => text()();
  TextColumn get instructorName => text().withDefault(const Constant(''))();
  IntColumn get weekdayIndex => integer()();
  IntColumn get startMinutes => integer()();
  IntColumn get endMinutes => integer()();
  IntColumn get colorIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
}
