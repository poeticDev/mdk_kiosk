import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MqttConnectionPhase { idle, connecting, connected, failed }

@immutable
class MqttInitResult {
  final bool isSuccess;
  final String message;
  final bool canRetry;
  final DateTime? nextRetryAt;

  const MqttInitResult._({
    required this.isSuccess,
    required this.message,
    required this.canRetry,
    this.nextRetryAt,
  });

  factory MqttInitResult.success({String message = 'MQTT 연결 성공'}) {
    return MqttInitResult._(
      isSuccess: true,
      message: message,
      canRetry: false,
    );
  }

  factory MqttInitResult.failure({
    required String message,
    bool canRetry = true,
    DateTime? nextRetryAt,
  }) {
    return MqttInitResult._(
      isSuccess: false,
      message: message,
      canRetry: canRetry,
      nextRetryAt: nextRetryAt,
    );
  }
}

@immutable
class MqttConnectionStatus {
  final MqttConnectionPhase phase;
  final MqttInitResult? lastResult;
  final DateTime? nextRetryAt;
  final int retryCount;

  const MqttConnectionStatus({
    this.phase = MqttConnectionPhase.idle,
    this.lastResult,
    this.nextRetryAt,
    this.retryCount = 0,
  });

  MqttConnectionStatus copyWith({
    MqttConnectionPhase? phase,
    MqttInitResult? lastResult,
    DateTime? nextRetryAt,
    int? retryCount,
  }) {
    return MqttConnectionStatus(
      phase: phase ?? this.phase,
      lastResult: lastResult ?? this.lastResult,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

class MqttConnectionStatusNotifier extends StateNotifier<MqttConnectionStatus> {
  MqttConnectionStatusNotifier() : super(const MqttConnectionStatus());

  void setConnecting() {
    state = state.copyWith(
      phase: MqttConnectionPhase.connecting,
      lastResult: null,
    );
  }

  void setResult(MqttInitResult result) {
    state = state.copyWith(
      phase: result.isSuccess
          ? MqttConnectionPhase.connected
          : MqttConnectionPhase.failed,
      lastResult: result,
      nextRetryAt: result.nextRetryAt,
      retryCount: result.isSuccess ? 0 : state.retryCount + 1,
    );
  }

  void reset() {
    state = const MqttConnectionStatus();
  }
}

final mqttConnectionStatusProvider =
    StateNotifierProvider<MqttConnectionStatusNotifier, MqttConnectionStatus>(
        (ref) {
  return MqttConnectionStatusNotifier();
});
