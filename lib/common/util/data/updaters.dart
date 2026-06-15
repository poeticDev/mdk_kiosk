import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final timetableUpdater = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final mediaItemUpdater = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

void updateTimetable(WidgetRef ref) {
  print('시간표 업데이트!');
  Future.delayed(const Duration(seconds: 30), () {
    ref.read(timetableUpdater.notifier).state = DateTime.now();
  });
}

void updateMediaItems(WidgetRef ref) {
  print('미디어 아이템 업데이트!');
  ref.read(mediaItemUpdater.notifier).state = DateTime.now();
}
