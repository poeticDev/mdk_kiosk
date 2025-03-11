import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class CustomPermissionHandler {
// ✅ Android SDK 버전 가져오기
  Future<int> getSdkVersion() async {
    if (Platform.isAndroid) {
      var sdkInt = 0;
      try {
        sdkInt = int.parse(
            await (Process.runSync('getprop', ['ro.build.version.sdk']))
                .stdout
                .toString()
                .trim());
      } catch (e) {
        print('SDK 버전 가져오는 중 오류 발생: $e');
      }
      return sdkInt;
    }
    return 0;
  }

  // ✅ 위치 권한 요청 메서드
  // ACCESS_FINE_LOCATION 권한이 필요한 경우 사용합니다.
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // ✅ 시스템 알림창 권한 요청 메서드
  // SYSTEM_ALERT_WINDOW 권한이 필요한 경우 사용합니다.
  Future<bool> requestSystemAlertWindowPermission() async {
    final status = await Permission.systemAlertWindow.request();
    return status.isGranted;
  }

  // ✅ 설정 변경 권한 요청 (WRITE_SETTINGS)
  Future<bool> requestWriteSettingsPermission() async {
    if (!await Permission.ignoreBatteryOptimizations.isGranted) {
      await openAppSettings(); // 설정 화면으로 이동
    }
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }

  // ✅ 미디어 접근 권한 요청 (Android 13 이상 & Android 12 이하 구분)
  Future<bool> requestMediaPermissions() async {
    int sdkVersion = await getSdkVersion();

    if (sdkVersion >= 33) {
      final audioStatus = await Permission.audio.request();
      final videoStatus = await Permission.videos.request();
      final imageStatus = await Permission.photos.request();
      return audioStatus.isGranted &&
          videoStatus.isGranted &&
          imageStatus.isGranted;
    } else {
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
  }

  // ✅ 여러 권한 한 번에 요청
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions() async {
    int sdkVersion = await getSdkVersion();

    final List<Permission> permissions = [
      Permission.location,
      Permission.systemAlertWindow,
      if (sdkVersion >= 33) ...[
        Permission.audio,
        Permission.videos,
        Permission.photos,
      ] else
        Permission.storage,
    ];

    return await permissions.request();
  }

  // ✅ 권한 상태 확인 메서드
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    // 특정 권한의 현재 상태를 반환합니다.
    return await permission.status;
  }

  // ✅ 권한 허용 여부를 확인하는 메서드
  Future<bool> isPermissionGranted(Permission permission) async {
    // 특정 권한이 허용되었는지 여부를 반환합니다.
    return await permission.isGranted;
  }
}
