import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // TimeOfDay, Overlay 등을 위해
import 'package:mdk_kiosk/common/util/data/global_data.dart';
import 'package:screen_brightness/screen_brightness.dart';

import 'package:mdk_kiosk/common/component/black_overlay.dart';

/// Dim(어둡게) 모드를 총괄 관리:
/// - 오버레이(검은 화면) 표시/해제
/// - 앱/시스템 화면 밝기 조절
/// - 설정된 시각과 근무 요일에 맞춘 자동 진입/해제 스케줄링(주말 건너뜀)
class DimModeController {
  /// 사용자가 바꿀 수 있는 스케줄 설정(기본값: 18:00 진입, 09:00 해제, 월~금 근무)
  TimeOfDay? dimEnterTime; // 예: 18:00
  TimeOfDay? dimExitTime; // 예: 09:00
  Set<int> workingDays; // DateTime.monday ~ DateTime.friday

  DimModeController({TimeOfDay? enterTime, TimeOfDay? exitTime, Set<int>? days})
    : workingDays =
          days ??
          {
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
          };

  factory DimModeController.fromGlobalData() {
    TimeOfDay? wakeTime;
    TimeOfDay? sleepTime;

    if (globalData.wakeTime != null)
      wakeTime = TimeOfDay.fromDateTime(globalData.wakeTime!);
    if (globalData.sleepTime != null)
      sleepTime = TimeOfDay.fromDateTime(globalData.sleepTime!);

    return DimModeController(enterTime: sleepTime, exitTime: wakeTime);
  }

  OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;

  Timer? _enterTimer; // 다음 "진입" 예약
  Timer? _exitTimer; // 다음 "해제" 예약

  bool _isDim = false;

  /// 최초 1회 바인딩(앱 시작/최상위 화면에서 호출).
  /// 여기서 루트 오버레이를 잡고, 현재 시간/요일에 따라 “다음 동작”만 예약한다.
  void bind(BuildContext context) {
    _overlayState = Overlay.of(context, rootOverlay: true);
    scheduleNextByCurrentTime();
  }

  /// Dim 모드로 진입:
  /// - 검은 오버레이를 올리고
  /// - 밝기를 극저로 낮춘 뒤
  /// - “다음 근무일의 해제 시각(보통 아침)”에 exit를 예약
  ///   (금요일에 진입하면 자동으로 그 다음 주 월요일 아침으로 잡힘)
  Future<void> enterDim() async {
    if (dimEnterTime == null || dimExitTime == null) return;

    if (_isDim) {
      _scheduleExitAt(dimExitTime!); // 이미 Dim이면 해제 예약만 보장
      return;
    }

    try {
      // 1) 검은 오버레이 올리기 (터치 흡수는 BlackoutOverlay 내부 처리 가정)
      if (_overlayEntry == null) {
        _overlayEntry = OverlayEntry(builder: (_) => const BlackoutOverlay());
        _overlayState?.insert(_overlayEntry!);
      }

      // 2) 밝기 극저로 (앱/시스템 모두 — 시스템은 WRITE_SETTINGS 권한 필요)
      await setApplicationBrightness(0.01);
      await setSystemBrightness(0.01);

      // 3) 상태 변경
      _isDim = true;

      // 4) 다음 근무일 아침 해제 예약 (주말 자동 건너뜀)

      _scheduleExitAt(dimExitTime!);

      // 5) 반대편 타이머 정리
      _enterTimer?.cancel();
    } catch (e, st) {
      debugPrint('enterDim error: $e\n$st');
      rethrow;
    }
  }

  /// Dim 모드 해제:
  /// - 오버레이 제거
  /// - 밝기 복구
  /// - “다음 근무일의 진입 시각(보통 저녁)”에 enter를 예약
  Future<void> exitDim() async {
    if (dimEnterTime == null || dimExitTime == null) return;
    if (!_isDim) {
      _scheduleEnterAt(dimEnterTime!); // 이미 해제면 진입 예약만 보장
      return;
    }

    try {
      // 1) 오버레이 제거
      _overlayEntry?.remove();
      _overlayEntry = null;

      // 2) 밝기 복구 (운영 정책에 맞게 조정 가능)
      await setApplicationBrightness(1.0);
      await setSystemBrightness(1.0);

      // 3) 상태 변경
      _isDim = false;

      // 4) 다음 근무일 저녁 진입 예약 (주말 자동 건너뜀)
      _scheduleEnterAt(dimEnterTime!);

      // 5) 반대편 타이머 정리
      _exitTimer?.cancel();
    } catch (e, st) {
      debugPrint('exitDim error: $e\n$st');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 스케줄링
  // ---------------------------------------------------------------------------

  /// 지금 시각/요일 기준으로 “다음 동작만” 예약한다.
  /// - 오늘이 근무일이고, 해제~진입 사이(업무시간)이면: 오늘 저녁에 진입 예약
  /// - 그 외(야간/주말/업무 시작 전 등): 다음 근무일 아침에 해제 예약
  void scheduleNextByCurrentTime({DateTime? now}) {
    if (dimEnterTime == null || dimExitTime == null) return;
    final t = now ?? DateTime.now();
    final todayIsWorking = workingDays.contains(t.weekday);

    final todayExit = _combine(t, dimExitTime!);
    final todayEnter = _combine(t, dimEnterTime!);

    if (todayIsWorking && t.isAfter(todayExit) && t.isBefore(todayEnter)) {
      _scheduleEnterAt(dimEnterTime!); // 업무시간: 오늘 저녁에 진입
    } else {
      _scheduleExitAt(dimExitTime!); // 그 외: 다음 근무일 아침에 해제
    }
  }

  /// 지정된 “해제 시각”으로 다음 근무일(오늘 포함) 예약.
  /// - mustBeAfterNow=true 이므로, 이미 지난 시각이면 다음 근무일로 넘어간다.
  void _scheduleExitAt(TimeOfDay time) {
    _exitTimer?.cancel();
    final now = DateTime.now();
    final next = _nextOccurrenceOnWorkingDay(
      time,
      from: now,
      includeToday: true,
      mustBeAfterNow: true,
    );
    _exitTimer = Timer(next.difference(now), () => exitDim());
  }

  /// 지정된 “진입 시각”으로 다음 근무일(오늘 포함) 예약.
  /// - mustBeAfterNow=true 이므로, 이미 지난 시각이면 다음 근무일로 넘어간다.
  void _scheduleEnterAt(TimeOfDay time) {
    _enterTimer?.cancel();
    final now = DateTime.now();
    final next = _nextOccurrenceOnWorkingDay(
      time,
      from: now,
      includeToday: true,
      mustBeAfterNow: true,
    );
    _enterTimer = Timer(next.difference(now), () => enterDim());
  }

  /// 기준 시각[from]에서 시작해, workingDays에 해당하는 “다음 근무일의 [time]”을 찾는다.
  /// - includeToday: 오늘이 근무일이면 오늘도 후보에 포함
  /// - mustBeAfterNow: true면 “현재 시각 이후”인 후보만 유효
  ///   (예: 오늘이 근무일이라도 이미 진입 시각이 지났다면 내일/다음 근무일로 넘어감)
  DateTime _nextOccurrenceOnWorkingDay(
    TimeOfDay time, {
    required DateTime from,
    required bool includeToday,
    required bool mustBeAfterNow,
  }) {
    DateTime cursor = includeToday ? from : from.add(const Duration(days: 1));

    // 최대 8일만 탐색(안전장치). 정상이라면 1~3일 내에 반드시 반환됨.
    for (int i = 0; i < 8; i++) {
      final isWorking = workingDays.contains(cursor.weekday);
      final candidate = _combine(cursor, time);

      if (isWorking) {
        if (!mustBeAfterNow || candidate.isAfter(from)) {
          return candidate;
        }
      }
      // 자정 기준으로 +1일
      cursor = DateTime(
        cursor.year,
        cursor.month,
        cursor.day,
      ).add(const Duration(days: 1));
    }

    // 폴백: 그냥 다음날 같은 시각
    return _combine(from.add(const Duration(days: 1)), time);
  }

  /// DateTime(날짜) + TimeOfDay(시각)를 결합해 “해당 날짜의 특정 시각”을 만든다.
  DateTime _combine(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  // ---------------------------------------------------------------------------
  // 밝기 유틸
  // ---------------------------------------------------------------------------

  /// 시스템 전역 밝기(자동 밝기 OFF + WRITE_SETTINGS 권한 필요할 수 있음)
  Future<double> get systemBrightness async {
    try {
      return await ScreenBrightness.instance.system;
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to get system brightness';
    }
  }

  /// 시스템 전역 밝기 설정(0.0~1.0).
  /// - WRITE_SETTINGS 권한이 없으면 실패할 수 있음.
  Future<void> setSystemBrightness(double brightness) async {
    try {
      await ScreenBrightness.instance.setSystemScreenBrightness(brightness);
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to set system brightness';
    }
  }

  /// 현재 앱(윈도우) 밝기 설정(0.0~1.0).
  /// - Activity/Window가 살아있는 상태에서 호출해야 적용된다.
  Future<void> setApplicationBrightness(double brightness) async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(
        brightness,
      );
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to set application brightness';
    }
  }

  /// 컨트롤러 정리: 타이머/오버레이 해제
  void dispose() {
    _enterTimer?.cancel();
    _exitTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
