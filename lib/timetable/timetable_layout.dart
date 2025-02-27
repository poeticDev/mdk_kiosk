import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';

List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

enum WeekendOption { none, included }

const weekendRowLengths = {
  WeekendOption.none: 5,
  WeekendOption.included: 7,
};

class TimetableLayout extends StatelessWidget {
  double? padding;
  int columnLength;
  WeekendOption weekendOption;

  TimetableLayout({
    this.columnLength = 12,
    this.padding,
    this.weekendOption = WeekendOption.none,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mWidth = constraints.maxWidth;
          final mHeight = constraints.maxHeight;

          const double headerHeight = 26;
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

            return SizedBox(
              height: boxHeight - 1,
              child: Center(
                child: Text(
                  '${index ~/ 2 + 9}',
                  style: TIME_TITLE_TEXT_STYLE.copyWith(
                    fontSize: (boxHeight - 1) * 0.3,
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
        child: Stack(
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
                    child: Container(),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    ];
  }
}
