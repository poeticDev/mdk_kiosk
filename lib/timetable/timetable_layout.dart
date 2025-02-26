import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';

List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

class TimetableLayout extends StatelessWidget {
  double? padding;

  TimetableLayout({
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mWidth = constraints.maxWidth;
          final mHeight = constraints.maxHeight;

          final int timeLength = 10;
          final double headerHeight = 20;
          final double boxHeight = (mHeight - headerHeight) / timeLength;

          return SizedBox(
            width: mWidth,
            height: mHeight,
            child: Row(
              children: [
                _buildTimeColumn(
                  headerHeight: headerHeight,
                  boxHeight: boxHeight,
                  timeLength: timeLength,
                ),
                Column(),
              ],
            ),
          );
        },
      ),
    );
  }

  _buildTimeColumn(
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
                color: Color(0xFF485157),
                height: 0,
              );
            }

            return SizedBox(
              height: boxHeight,
              child: Center(
                child: Text('${index ~/ 2 + 9}'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
