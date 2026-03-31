import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/util/data/updaters.dart';
import 'package:mdk_kiosk/multimedia/studio/lecture_box_for_media_box.dart';
import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

/// DefaultMediaBox
/// 📌 오늘의 촬영 스케쥴 표시용 위젯 (MediaBox 화면)
/// 📌 매일 00:00 / 12:00 에 자동 refresh (타이머 기반)
class DefaultMediaBox extends ConsumerStatefulWidget {
  DefaultMediaBox({super.key});

  @override
  ConsumerState<DefaultMediaBox> createState() => _DefaultMediaBoxState();
}

class _DefaultMediaBoxState extends ConsumerState<DefaultMediaBox> {
  final TimetableRepository repository = GetIt.I<TimetableRepository>();

  /// 📌 refresh 타이머 (00:00 / 12:00 마다 자동 refresh 예약용)
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    /// 📌 위젯 초기화 시 → refresh 타이머 시작
    _scheduleNextRefresh();
  }

  @override
  void dispose() {
    /// 📌 위젯 dispose 시 → 타이머 정리
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// 📌 다음 refresh 시간 예약 (00:00 / 12:00 기준)
  void _scheduleNextRefresh() {
    _refreshTimer?.cancel();

    final now = DateTime.now();

    // 📌 다음 refresh 시간 계산 (00:00 또는 12:00)
    DateTime nextRefresh;
    if (now.hour < 12) {
      nextRefresh = DateTime(now.year, now.month, now.day, 12);
    } else {
      nextRefresh = DateTime(now.year, now.month, now.day + 1, 0);
    }

    final duration = nextRefresh.difference(now);
    print('🔄 DefaultMediaBox: 다음 refresh까지 ${duration.inMinutes}분 후');

    /// 📌 타이머 예약
    _refreshTimer = Timer(duration, () {
      print('🔄 DefaultMediaBox: refresh 트리거 실행');
      if (mounted) {
        /// 📌 setState → rebuild → getLecturesForToday() 재호출
        setState(() {});
      }

      /// 📌 다음 refresh 예약 (반복)
      _scheduleNextRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    /// 📌 timetableUpdater Provider → timetable 변경 시 자동 rebuild
    final timetableWatcher = ref.watch(timetableUpdater);

    /// 📌 오늘 요일 기준 강의 리스트 가져오기
    final List<Lecture> lectureList = repository.getLecturesForToday();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double mWidth = constraints.maxWidth;
        final double mHeight = constraints.maxHeight;

        final double lectureBoxWidth = mWidth * 0.9;
        final double lectureBoxHeight = 80;

        return Container(
          width: mWidth,
          height: mHeight,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(32.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /// 📌 헤더 텍스트
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '오늘의 강의실 스케쥴',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w600,
                    color: TEXT_COLOR,
                  ),
                ),
              ),

              /// 📌 강의 리스트 표시 (스크롤 가능)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 16.0,
                    children: lectureList
                        .map(
                          (lecture) => LectureBoxForMediaBox(
                            lecture: lecture,
                            width: lectureBoxWidth,
                            height: lectureBoxHeight,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
