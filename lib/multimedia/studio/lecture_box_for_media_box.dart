import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

class LectureBoxForMediaBox extends StatelessWidget {
  final Lecture lecture;

  const LectureBoxForMediaBox({super.key, required this.lecture});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 20.0,
      runSpacing: 16.0,
      children: [
        Text(
          '${lecture.startAt.hour}:${lecture.startAt.minute}',
          style: TITLE_TEXT_STYLE,
        ),
        Text(
          lecture.instructorName,
          style: TITLE_TEXT_STYLE,
        ),
        Text(
          lecture.lectureName,
          style: TITLE_TEXT_STYLE,
        )
      ],
    );
  }
}
