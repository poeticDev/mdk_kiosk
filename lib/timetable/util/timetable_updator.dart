import 'package:riverpod/riverpod.dart';

final timetableUpdator = StateProvider<DateTime>((ref) {
  return DateTime.now(); // 초기값은 앱 시작 시각
});