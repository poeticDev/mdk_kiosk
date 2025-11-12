import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timetableUpdater = StateProvider<DateTime>((ref) {
  return DateTime.now(); // 초기값은 앱 시작 시각
});

final mediaItemUpdater = StateProvider<DateTime>((ref) {
  return DateTime.now(); // 초기값은 앱 시작 시각
});

/// 시간표 상태 업데이트
void updateTimetable(WidgetRef ref) {
  print('시간표 업데이트!');
  Future.delayed(Duration(seconds: 30), () {
    ref.read(timetableUpdater.notifier).state = DateTime.now();
  });
}

/// 미디어 아이템 상태 업데이트
void updateMediaItems(WidgetRef ref) {
  print('미디어 아이템 업데이트!');
  ref.read(mediaItemUpdater.notifier).state = DateTime.now();
}
