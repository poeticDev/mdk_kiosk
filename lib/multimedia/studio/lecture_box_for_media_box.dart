import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

class LectureBoxForMediaBox extends StatelessWidget {
  final Lecture lecture;
  final double width;
  final double height;

  const LectureBoxForMediaBox({
    super.key,
    required this.lecture,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      width: width,
      // height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: LECTURE_BG_COLORS[lecture.colorIndex],
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.center,
        runSpacing: 4.0,
        children: [
          Text(
            '${lecture.startAt.hour.toString().padLeft(2, '0')}:${lecture.startAt.minute.toString().padLeft(2, '0')} ~ ${lecture.endAt.hour}:${lecture.endAt.minute.toString().padLeft(2, '0')}',
            style: TITLE_TEXT_STYLE.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              '${lecture.instructorName}    ${lecture.lectureName}',
              style: TITLE_TEXT_STYLE.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Text(
          //   lecture.lectureName,
          //   style: TITLE_TEXT_STYLE,
          // )
        ],
      ),
    );
  }
}
