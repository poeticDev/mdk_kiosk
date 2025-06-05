import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

class LectureBoxForMediaBox extends StatelessWidget {
  final Lecture lecture;
  final double width;
  final double height;

  const LectureBoxForMediaBox(
      {super.key,
      required this.lecture,
      required this.width,
      required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.0),
        color: LECTURE_BG_COLORS[lecture.colorIndex],
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.center,
        spacing: 20.0,
        runSpacing: 16.0,
        children: [
          SizedBox(width: 8.0),
          Text(
            '${lecture.startAt.hour}:${lecture.startAt.minute.toString().padLeft(2, '0')}~${lecture.endAt.hour}:${lecture.endAt.minute.toString().padLeft(2, '0')}',
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
      ),
    );
  }
}
