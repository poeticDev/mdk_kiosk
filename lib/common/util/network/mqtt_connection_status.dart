import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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
      nextRetryAt: null,
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
class MqttConnectionState {
  final MqttConnectionPhase phase;
  final MqttInitResult? lastResult;
  final DateTime? nextRetryAt;
  final int retryCount;

  const MqttConnectionState({
    this.phase = MqttConnectionPhase.idle,
    this.lastResult,
    this.nextRetryAt,
    this.retryCount = 0,
  });

  MqttConnectionState copyWith({
    MqttConnectionPhase? phase,
    MqttInitResult? lastResult,
    DateTime? nextRetryAt,
    int? retryCount,
  }) {
    return MqttConnectionState(
      phase: phase ?? this.phase,
      lastResult: lastResult ?? this.lastResult,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

class MqttConnectionStateNotifier extends StateNotifier<MqttConnectionState> {
  MqttConnectionStateNotifier() : super(const MqttConnectionState());

  void setConnecting() {
    state = state.copyWith(
      phase: MqttConnectionPhase.connecting,
      lastResult: null,
    );
  }

  void setResult(MqttInitResult result) {
    final MqttConnectionPhase phase = result.isSuccess
        ? MqttConnectionPhase.connected
        : MqttConnectionPhase.failed;
    state = state.copyWith(
      phase: phase,
      lastResult: result,
      nextRetryAt: result.nextRetryAt,
      retryCount: result.isSuccess ? 0 : state.retryCount + 1,
    );
  }

  void reset() {
    state = const MqttConnectionState();
  }
}

final StateNotifierProvider<MqttConnectionStateNotifier, MqttConnectionState>
mqttConnectionStateProvider =
    StateNotifierProvider<MqttConnectionStateNotifier, MqttConnectionState>((
      Ref ref,
    ) {
      return MqttConnectionStateNotifier();
    });
