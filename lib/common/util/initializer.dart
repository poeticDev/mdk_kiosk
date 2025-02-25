import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/custom_permission_handler.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/initial/initial_basic_info.dart';
import 'package:mdk_kiosk/common/util/kiosk.dart';
import 'package:mdk_kiosk/common/util/network/mqtt_manager.dart';

class AppInitializer {
  static Future<void> initialize() async {
    /// 1. 하드웨어 세팅
    /// 1.1 필수권한 요청
    await _requestPermissions();

    /// 1.2 세로모드 고정
    await _setOnlyPortrait();

    /// 1.3 하단 네비게이션 바 숨김
    KioskModeManager.hideNavigationBar();

    /// 1.4 키오스크 모드
    KioskModeManager.enableKioskMode();

    /// 2. Data
    /// 2.1. GetIt 세팅
    GetIt.I.allowReassignment = true;

    /// 2.2 Database 열기
    AppDatabase.openDB();

    /// 2.3 첫 실행 시 초기 Data 등록
    await _initializeDB();

    /// 2.4 Database 데이터 로딩

    /// 3. Network
    /// 3.1 OSC
    /// 3.2 MQTT
  }

  /// 1. 하드웨어 세팅
  /// 1.1 필수 권한 요청
  static Future<void> _requestPermissions() async {
    final permissionHandler = CustomPermissionHandler();

    print('위치 권한 요청 중');
    await permissionHandler.requestLocationPermission();
    print('시스템 알람창 권한 요청 중');
    await permissionHandler.requestSystemAlertWindowPermission();
    print('미디어 접근 권한 요청 중');
    await permissionHandler.requestMediaPermissions();
  }

  /// 1.2 세로 모드 고정
  static Future<void> _setOnlyPortrait() async {
    await SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ],
    );
  }

  /// 2. Data
  /// 2.3 첫 실행 시 초기 Data 등록
  /// 앱 첫 실행 시 기본 데이터를 데이터베이스에 초기화하는 메서드
  /// 기본 버튼, 페이지, 장비 등의 정보를 데이터베이스에 입력
  static Future<void> _initializeDB() async {
    final db = GetIt.I<AppDatabase>();

    final BasicInfoData? basicInfo = await db.getLatestBasicInfo();

    if (basicInfo == null) {
      // 로고 이미지 파일을 로드하여 DB에 저장
      final ByteData bytes = await rootBundle.load(initialImagePath);
      final Uint8List imageList = bytes.buffer.asUint8List();

      // 기본 정보 생성
      await db.createBasicInfo(
        BasicInfoCompanion(
          roomId: const Value(initialRoomId),
          roomName: const Value(initialRoomName),
          wifiName: const Value(initialWifiName),
          logoImage: Value(imageList),
          serverIp: const Value(initialServerIp),
        ),
      );
    }
  }

  /// . Network

  void _mqttConnect() async {
    await mqttManager.connect();
    mqttManager.subscribe('msg/#');
    mqttManager.listen((String topic, String payload) {});
  }
}
