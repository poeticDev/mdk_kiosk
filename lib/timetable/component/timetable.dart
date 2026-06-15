import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/data/updaters.dart';
import 'package:mdk_kiosk/timetable/timetable_layout.dart';
import 'package:mdk_kiosk/timetable/util/google_sheets.dart';

class Timetable extends ConsumerStatefulWidget {
  const Timetable({super.key});

  @override
  ConsumerState<Timetable> createState() => _TimetableState();
}

class _TimetableState extends ConsumerState<Timetable> {
  final GoogleSheets gSheet = GetIt.I<GoogleSheets>();
  Timer? _timetableTimer;
  DateTime? _lastTimetableUpdate;
  bool _isRefreshingFromUpdate = false;

  @override
  void initState() {
    super.initState();
    _lastTimetableUpdate = ref.read(timetableUpdater);
    _startTimetableAutoUpdater();
  }

  @override
  void dispose() {
    _stopTimetableAutoUpdater();
    super.dispose();
  }

  void _startTimetableAutoUpdater() {
    const duration = Duration(minutes: 10);

    _timetableTimer?.cancel();
    _timetableTimer = Timer.periodic(duration, (_) async {
      await gSheet.compareNFetchLectureCache(ref);
    });

    print('✅ Timetable Auto Updater started (every ${duration.inMinutes} min)');
  }

  void _stopTimetableAutoUpdater() {
    _timetableTimer?.cancel();
    _timetableTimer = null;
    print('🛑 Timetable Auto Updater stopped');
  }

  void _refreshFromExternalUpdate(DateTime updateTime) {
    if (_lastTimetableUpdate == updateTime || _isRefreshingFromUpdate) {
      return;
    }

    _lastTimetableUpdate = updateTime;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      _isRefreshingFromUpdate = true;
      try {
        await gSheet.updateLectureCache();
        if (mounted) {
          setState(() {});
        }
      } catch (e, stackTrace) {
        print('[Timetable] external refresh failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      } finally {
        _isRefreshingFromUpdate = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timetableWatcher = ref.watch(timetableUpdater);
    _refreshFromExternalUpdate(timetableWatcher);

    final lectures = gSheet.lectureCache;

    return TimetableLayout(
      key: Key(timetableWatcher.toString()),
      lectures: lectures,
    );
  }
}
