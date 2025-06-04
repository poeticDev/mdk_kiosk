import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/util/data/updaters.dart';
import 'package:mdk_kiosk/multimedia/studio/lecture_box_for_media_box.dart';
import 'package:mdk_kiosk/multimedia/studio/state_indicator_for_mediabox.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';
import 'package:mdk_kiosk/timetable/util/google_sheets.dart';

class DefaultMediaBox extends ConsumerWidget {
  DefaultMediaBox({super.key});

  final GoogleSheets gSheet = GetIt.I<GoogleSheets>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetableWatcher = ref.watch(timetableUpdater);
    final List<Lecture> lectureList = gSheet.getLecturesForToday();


    return LayoutBuilder(builder: (context, constraints) {
      final double mWidth = constraints.maxWidth;
      final double mHeight = constraints.maxHeight;

      return Container(
        width: mWidth,
        height: mHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              '오늘의 촬영 스케쥴',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.w600,
                color: TEXT_COLOR,
              ),
            ),
            LectureBoxForMediaBox(lecture: lectureList.first),
            StateIndicatorForMediaBox(
              fontSize: 80,
              width: mWidth * 0.9,
              height: mHeight / 3,
            ),
          ],
        ),
      );
    });
  }
}
