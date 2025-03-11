import 'package:flutter/services.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

class KioskModeManager {
  static KioskMode _kioskMode = KioskMode.disabled;

  // 현재 키오스크 모드 상태 확인
  static Future<bool> isKioskMode() async {
    _kioskMode = await getKioskMode();
    print(_kioskMode);
    return _kioskMode == KioskMode.enabled;
  }

  // 키오스크 모드 활성화
  static Future<void> enableKioskMode() async {
    await startKioskMode();
    _kioskMode = KioskMode.enabled; // 활성화 시 상태 업데이트
  }

  // 키오스크 모드 비활성화
  static Future<void> disableKioskMode() async {
    await stopKioskMode();
    _kioskMode = KioskMode.disabled; // 비활성화 시 상태 업데이트
  }

  // 하단 네비게이션 바 숨김
  static void hideNavigationBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
}
