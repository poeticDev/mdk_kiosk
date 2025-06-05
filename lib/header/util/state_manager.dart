import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdk_kiosk/header/model/studio_state_model.dart';

/// 초기 상태 정의
final studioStateProvider = StateProvider<StudioState>((ref) {
  return STATE_READY;
});

final temperatureProvider = StateProvider<double>((ref) {
  return 0.0;
});

final humidityProvider = StateProvider<double>((ref) {
  return 0.0;
});