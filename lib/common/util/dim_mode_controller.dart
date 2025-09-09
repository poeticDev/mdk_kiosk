import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:screen_brightness/screen_brightness.dart';

import 'package:mdk_kiosk/common/component/black_overlay.dart';

class DimModeController {
  DimModeController();

  OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;

  Timer? _enterTimer; // 20:00 진입 예약
  Timer? _exitTimer; // 08:00 해제 예약

  bool _isDim = false;

  // 최초 바인딩. 앱 시작 또는 최상위 화면에서 호출
  void bind(BuildContext context) {
    _overlayState = Overlay.of(context, rootOverlay: true);

    // 앱 부팅 시 현재 시간에 따라 다음 Dim 스케쥴 예약
    scheduleNextByCurrentTime();
  }

  Future<void> enterDim() async {
    if (_isDim) {
      _scheduleExitAt8AM(); // 이미 Dim이면 스케줄만 보장
      return;
    }

    try {
      // 1) 검은 오버레이 최상단에 삽입
      if (_overlayEntry == null) {
        _overlayEntry = OverlayEntry(builder: (_) => const BlackoutOverlay());
        _overlayState?.insert(_overlayEntry!);
      }

      // 2) 밝기 최소화 (앱 레벨 권장)
      await setApplicationBrightness(0.01);

      // 3) 상태 마킹
      _isDim = true;

      // 4) 08:00에 exitDim() 예약
      _scheduleExitAt8AM();

      // 5) 반대편 타이머 정리
      _enterTimer?.cancel();
    } catch (e, st) {
      debugPrint('enterDim error: $e\n$st');
      rethrow;
    }
  }

  /// DIM 해제
  Future<void> exitDim() async {
    if (!_isDim) {
      _scheduleEnterAt8PM(); // 이미 해제 상태면 스케줄만 보장
      return;
    }

    try {
      // 1) 오버레이 제거
      _overlayEntry?.remove();
      _overlayEntry = null;

      // 2) 밝기 복구(요구사항대로 시스템 밝기를 1.0으로)
      await setSystemBrightness(1.0);

      // 3) 상태 마킹
      _isDim = false;

      // 4) 20:00에 enterDim() 예약
      _scheduleEnterAt8PM();

      // 5) 반대편 타이머 정리
      _exitTimer?.cancel();
    } catch (e, st) {
      debugPrint('exitDim error: $e\n$st');
      rethrow;
    }
  }

  // ====== 스케줄링 유틸 ======

  void _scheduleExitAt8AM() {
    _exitTimer?.cancel();
    final now = DateTime.now();
    final next = _nextAt(hour: 8, minute: 0, from: now);
    final diff = next.difference(now);
    _exitTimer = Timer(diff, () {
      // 타이머 콜백에서 예외 터지지 않도록 안전 호출
      exitDim();
    });
  }

  void _scheduleEnterAt8PM() {
    _enterTimer?.cancel();
    final now = DateTime.now();
    final next = _nextAt(hour: 20, minute: 0, from: now);
    final diff = next.difference(now);
    _enterTimer = Timer(diff, () {
      enterDim();
    });
  }

  DateTime _nextAt(
      {required int hour, required int minute, required DateTime from}) {
    final candidate = DateTime(from.year, from.month, from.day, hour, minute);
    if (candidate.isAfter(from)) return candidate;
    return candidate.add(const Duration(days: 1));
    // 필요하면 요일 제한 등 추가 가능
  }

  /// 현재 시간을 판단해 다음 예약만 건다.
  /// - 08:00 ~ 20:00: 밤 8시에 enterDim 예약
  /// - 20:00 ~ 08:00: 아침 8시에 exitDim 예약
  void scheduleNextByCurrentTime({DateTime? now}) {
    final t = now ?? DateTime.now();
    if (t.hour >= 8 && t.hour < 20) {
      _scheduleEnterAt8PM();
    } else {
      _scheduleExitAt8AM();
    }
  }

  // ====== 밝기 유틸 ======
  Future<double> get systemBrightness async {
    try {
      return await ScreenBrightness.instance.system;
    } catch (e) {
      print(e);
      throw 'Failed to get system brightness';
    }
  }

  Future<void> setSystemBrightness(double brightness) async {
    try {
      await ScreenBrightness.instance.setSystemScreenBrightness(brightness);
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to set system brightness';
    }
  }

  Future<void> setApplicationBrightness(double brightness) async {
    try {
      await ScreenBrightness.instance
          .setApplicationScreenBrightness(brightness);
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to set application brightness';
    }
  }

  void dispose() {
    _enterTimer?.cancel();
    _exitTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
