import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

class LectureBox extends StatelessWidget {
  final double width;
  final double height;
  final double headerHeight;
  final String lectureName;
  final String instructorName;
  final String weekday;
  final TimeOfDay startAt;
  final TimeOfDay endAt;
  final int colorIndex;

  const LectureBox({
    super.key,
    required this.width,
    required this.height,
    required this.headerHeight,
    required this.lectureName,
    required this.instructorName,
    required this.weekday,
    required this.startAt,
    required this.endAt,
    this.colorIndex = 0,
  });

  factory LectureBox.fromModel({
    required Lecture lecture,
    required width,
    required height,
    required headerHeight,
  }) {
    return LectureBox(
      width: width,
      height: height,
      headerHeight: headerHeight,
      lectureName: lecture.lectureName,
      instructorName: lecture.instructorName,
      startAt: lecture.startAt,
      endAt: lecture.endAt,
      weekday: lecture.getWeekdayInKR(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: height * (startAt.hour - 9 + startAt.minute / 60) +
          headerHeight +
          0.5,
      left: 1,
      child: Container(
        width: width,
        height: height *
            ((endAt.hour + endAt.minute / 60) -
                (startAt.hour + startAt.minute / 60)),
        color: LECTURE_BG_COLORS[colorIndex],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lectureName,
                style:
                    LECTURE_TITLE_TEXT_STYLE.copyWith(fontSize: height * 0.45),
              ),
              Text(
                instructorName,
                style: LECTURE_SUBTITLE_TEXT_STYLE.copyWith(
                    fontSize: height * 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
