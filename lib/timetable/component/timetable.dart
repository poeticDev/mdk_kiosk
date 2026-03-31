import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/data/updaters.dart';
import 'package:mdk_kiosk/timetable/timetable_layout.dart';
import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';

class Timetable extends ConsumerStatefulWidget {
  const Timetable({super.key});

  @override
  ConsumerState<Timetable> createState() => _TimetableState();
}

class _TimetableState extends ConsumerState<Timetable> {
  final TimetableRepository repository = GetIt.I<TimetableRepository>();
  Timer? _timetableTimer;

  @override
  void initState() {
    super.initState();
    _startTimetableAutoUpdater();
  }

  @override
  void dispose() {
    _stopTimetableAutoUpdater();
    super.dispose();
  }

  void _startTimetableAutoUpdater() {
    // 백그라운드 새로고침을 지원하지 않는 경우 타이머를 시작하지 않음
    if (!repository.supportsBackgroundRefresh) {
      print(
        'ℹ️ Timetable: Background refresh not supported, skipping auto updater',
      );
      return;
    }

    const duration = Duration(minutes: 10); // 원하는 주기

    _timetableTimer?.cancel();

    _timetableTimer = Timer.periodic(duration, (_) async {
      final bool changed = await repository.refresh();
      if (changed) {
        ref.read(timetableUpdater.notifier).state = DateTime.now();
      }
    });

    print('✅ Timetable Auto Updater started (every ${duration.inMinutes} min)');
  }

  void _stopTimetableAutoUpdater() {
    _timetableTimer?.cancel();
    _timetableTimer = null;
    print('🛑 Timetable Auto Updater stopped');
  }

  @override
  Widget build(BuildContext context) {
    // ✅ timetableUpdater가 업데이트 되면 rebuild 발생
    final timetableWatcher = ref.watch(timetableUpdater);

    // ✅ repository에서 강의 목록 가져오기
    final lectures = repository.getLectures();

    // ✅ 정상 렌더링
    return TimetableLayout(
      key: Key(timetableWatcher.toString()),
      lectures: lectures,
    );
  }
}
