

import 'package:mdk_kiosk/common/util/custom_permission_handler.dart';

class AppInitializer {

  static Future<void> initialize() async {
    /// . Permission
    await requestPermissions();

    /// . Network
    /// .1 OSC
    /// .2 MQTT

  }





  static Future<void> requestPermissions() async {
    final permissionHandler = CustomPermissionHandler();

    print('위치 권한 요청 중');
    await permissionHandler.requestLocationPermission();
    print('시스템 알람창 권한 요청 중');
    await permissionHandler.requestSystemAlertWindowPermission();
    print('미디어 접근 권한 요청 중');
    await permissionHandler.requestMediaPermissions();
  }

}