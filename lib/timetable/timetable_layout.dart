import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/timetable/component/lecture_box.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

enum WeekendOption { none, included }

const weekendRowLengths = {
  WeekendOption.none: 5,
  WeekendOption.included: 7,
};

class TimetableLayout extends StatelessWidget {
  int columnLength;
  WeekendOption weekendOption;
  final List<Lecture> lectures;

  TimetableLayout({
    this.columnLength = 10,
    this.weekendOption = WeekendOption.none,
    super.key,
    required this.lectures,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mWidth = constraints.maxWidth;
          final mHeight = constraints.maxHeight;

          final double headerHeight = mHeight * 0.04;
          final double boxHeight = (mHeight - headerHeight) / columnLength;
          final rowLength = weekendRowLengths[weekendOption]!;

          return SizedBox(
            width: mWidth,
            height: mHeight,
            child: Row(
              children: [
                _buildTimeColumn(
                  headerHeight: headerHeight,
                  boxHeight: boxHeight,
                  timeLength: columnLength,
                ),
                // Column(
                //   children: [
                //     ElevatedButton(
                //       onPressed: () {
                //         final Lecture lecture = Lecture(
                //           id: 1,
                //           lectureName: '강의명',
                //           instructorName: '교수명',
                //           weekday: Weekday.monday,
                //           startAt: TimeOfDay(hour: 10, minute: 30),
                //           endAt: TimeOfDay(hour: 12, minute: 0),
                //         );
                //
                //         gSheet.insertLecture(lecture);
                //       },
                //       child: Text('1 업댓'),
                //     ),
                //     ElevatedButton(
                //       onPressed: () async {
                //         final lecture = await gSheet.fetchLecture(3);
                //
                //         print(lecture.id);
                //         print(lecture.lectureName);
                //         print(lecture.instructorName);
                //         print(lecture.startAt);
                //         print(lecture.endAt);
                //         print(lecture.weekday);
                //         print(lecture.colorIndex);
                //
                //         // print(await gSheet.getRow(3));
                //       },
                //       child: Text('프린트'),
                //     ),
                //   ],
                // ),
                ...List.generate(
                    rowLength,
                    (index) => _buildDayColumn(
                          weekdayIndex: index,
                          headerHeight: headerHeight,
                          boxHeight: boxHeight,
                          timeLength: columnLength,
                        )).expand((widgetList) => widgetList),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeColumn(
      {required double headerHeight,
      required double boxHeight,
      required int timeLength}) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: headerHeight,
          ),
          ...List.generate(timeLength * 2, (index) {
            if (index % 2 == 0) {
              return const Divider(
                color: DIVIDER_COLOR,
                height: 1,
              );
            }

            final String string = (index ~/ 2 + 9) < 13 ? (index ~/ 2 + 9).toString() : (index ~/ 2 - 3).toString()




            ;

            return SizedBox(
              height: boxHeight - 1,
              child: Center(
                child: Text(
                  string,
                  style: TIME_TITLE_TEXT_STYLE.copyWith(
                    fontSize: (boxHeight - 1) * 0.22,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildDayColumn(
      {required int weekdayIndex,
      required double headerHeight,
      required double boxHeight,
      required int timeLength}) {
    return [
      const VerticalDivider(
        color: DIVIDER_COLOR,
        width: 0,
      ),
      Expanded(
        flex: 3,
        child: LayoutBuilder(builder: (context, constraints) {
          final boxWidth = constraints.maxWidth - 2;

          List lectureBoxes = [];

          for (Lecture lecture in lectures) {
            if (lecture.weekday.index == weekdayIndex) {
              lectureBoxes = [
                ...lectureBoxes,
                LectureBox.fromModel(
                  lecture: lecture,
                  width: boxWidth,
                  height: boxHeight,
                  headerHeight: headerHeight,
                ),
              ];
            }
          }

          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    child: Text(
                      weekdays[weekdayIndex],
                      style: TIME_TITLE_TEXT_STYLE.copyWith(
                        fontSize: headerHeight * 0.65,
                      ),
                    ),
                  ),
                  ...List.generate(timeLength * 2, (index) {
                    if (index % 2 == 0) {
                      return DottedLine(
                        dashColor: DIVIDER_COLOR,
                        dashGapLength: index == 0 ? 0 : 4,
                        lineThickness: 1,
                      );
                    }

                    return SizedBox(
                      height: boxHeight - 1,
                    );
                  }),
                ],
              ),
              ...lectureBoxes
            ],
          );
        }),
      ),
    ];
  }
}
