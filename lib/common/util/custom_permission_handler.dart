import 'package:permission_handler/permission_handler.dart';

class CustomPermissionHandler {
  // 위치 권한 요청 메서드
  // ACCESS_FINE_LOCATION 권한이 필요한 경우 사용합니다.
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    // 권한 상태가 허용된 경우 true를 반환합니다.
    return status.isGranted;
  }

  // 시스템 알림창 권한 요청 메서드
  // SYSTEM_ALERT_WINDOW 권한이 필요한 경우 사용합니다.
  Future<bool> requestSystemAlertWindowPermission() async {
    final status = await Permission.systemAlertWindow.request();
    // 권한 상태가 허용된 경우 true를 반환합니다.
    return status.isGranted;
  }

  // 설정 변경 권한 요청 메서드
  // WRITE_SETTINGS 권한이 필요한 경우 사용합니다.
  Future<bool> requestWriteSettingsPermission() async {
    final status = await Permission.manageExternalStorage.request();
    // 권한 상태가 허용된 경우 true를 반환합니다.
    return status.isGranted;
  }

  // 미디어 접근 권한 요청 메서드
  // READ_MEDIA_AUDIO 및 READ_MEDIA_VIDEO 권한이 필요한 경우 사용합니다.
  Future<bool> requestMediaPermissions() async {
    final audioStatus = await Permission.audio.request();
    final videoStatus = await Permission.videos.request();
    final imageState = await Permission.photos.request();
    // 두 권한이 모두 허용된 경우 true를 반환합니다.
    return audioStatus.isGranted && videoStatus.isGranted && imageState.isGranted;
  }

  // 여러 권한을 한 번에 요청하는 메서드
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions() async {
    // 필요한 권한 목록을 정의합니다.
    final permissions = [
      Permission.location,
      Permission.systemAlertWindow,
      Permission.manageExternalStorage,
      Permission.audio,
      Permission.videos
    ];
    // 권한 요청 결과를 반환합니다.
    return await permissions.request();
  }

  // 권한 상태 확인 메서드
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    // 특정 권한의 현재 상태를 반환합니다.
    return await permission.status;
  }

  // 권한 허용 여부를 확인하는 메서드
  Future<bool> isPermissionGranted(Permission permission) async {
    // 특정 권한이 허용되었는지 여부를 반환합니다.
    return await permission.isGranted;
  }
}
