import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

class Lecture {
  final int id;
  final String lectureName;
  final String instructorName;
  final Weekday dayOn;
  final TimeOfDay startAt;
  final TimeOfDay endAt;

  Lecture({
    required this.id,
    required this.lectureName,
    required this.instructorName,
    required this.dayOn,
    required this.startAt,
    required this.endAt,
  });

  factory Lecture.absence({
    required Weekday dayOn,
    required TimeOfDay startAt,
    required TimeOfDay endAt,
  }) {
    return Lecture(
        id: 9999,
        lectureName: '공강',
        instructorName: '',
        dayOn: dayOn,
        startAt: startAt,
        endAt: endAt);
  }

  int getWeekdayNumber(Weekday day) => day.index + 1;
  String getWeekdayInKR(Weekday day) => weekdays[day.index];
}


class TimetableSource extends DataGridSource {
  List<DataGridRow> _lectures = [];

  TimetableSource({required List<Lecture> lectures}) {
    _lectures = lectures.map<DataGridRow>((lecture) => DataGridRow(
      cells: [
        DataGridCell(columnName: '시간', value: value)
        
      ],
      
    ),).toList();

}

  @override
  List<DataGridRow> get rows =>  _lectures;

}