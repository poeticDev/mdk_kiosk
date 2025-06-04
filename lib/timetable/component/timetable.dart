import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/data/global_data.dart';
import 'package:mdk_kiosk/common/util/data/updaters.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';
import 'package:mdk_kiosk/timetable/timetable_layout.dart';
import 'package:mdk_kiosk/timetable/util/google_sheets.dart';

class Timetable extends ConsumerStatefulWidget {
  const Timetable({super.key});

  @override
  ConsumerState<Timetable> createState() => _TimetableState();
}

class _TimetableState extends ConsumerState<Timetable> {
  // Future<List<Lecture>> lectures;
  final GoogleSheets gSheet = GetIt.I<GoogleSheets>();
  Timer? _timetableTimer;

  @override
  void initState() {
    _startTimetableAutoUpdater();
    super.initState();
  }

  @override
  void dispose() {
    _stopTimetableAutoUpdater();
    super.dispose();
  }

  void _startTimetableAutoUpdater() {
    const duration = Duration(minutes: 10); // 원하는 주기

    // 기존 타이머 정지
    _timetableTimer?.cancel();

    // 새 타이머 시작
    _timetableTimer = Timer.periodic(duration, (_) async {
      await gSheet.compareNFetchWorksheet(ref);
    });
  }

  void _stopTimetableAutoUpdater() {
    _timetableTimer?.cancel();
    _timetableTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final timetableWatcher = ref.watch(timetableUpdater);
    Future<List<Lecture>> lectures = gSheet.fetchAllLectures();

    return FutureBuilder(
        future: lectures,
        builder: (context, snapshot) {
          // 에러체크
          if (snapshot.hasError) {
            return Center(
                child: Text(
                    '에러가 발생했습니다. 관리자에게 문의하세요.\nError: ${snapshot.error.toString()}'));
          }

          // 데이터 로딩 중
          if (snapshot.data == null ||
              snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }

          return TimetableLayout(
            lectures: snapshot.data!,
          );
        });
  }
}
