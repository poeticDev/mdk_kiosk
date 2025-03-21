import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/custom_permission_handler.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/global_data.dart';
import 'package:mdk_kiosk/common/util/data/initial/default_buttons.dart';
import 'package:mdk_kiosk/common/util/data/initial/default_pages.dart';
import 'package:mdk_kiosk/common/util/data/initial/initial_basic_info.dart';
import 'package:mdk_kiosk/common/util/data/initial/initial_media_item.dart';
import 'package:mdk_kiosk/common/util/kiosk.dart';
import 'package:mdk_kiosk/common/util/network/mqtt_manager.dart';
import 'package:mdk_kiosk/common/util/network/osc_manager.dart';
import 'package:mdk_kiosk/timetable/util/google_sheets.dart';

class AppInitializer {
  static bool _isInitialized = false;

  /// 싱글턴 패턴
  static final AppInitializer _instance = AppInitializer._internal();

  factory AppInitializer() => _instance;

  AppInitializer._internal();

  static bool getInitializedStatus() {
    return _isInitialized;
  }

  static String state = '';

  static Stream<String> initialize(WidgetRef ref) async* {
    if (_isInitialized) {
      yield 'done';
      return;
    }

    /// 1. 하드웨어 세팅
    /// 1.1 필수권한 요청
    yield '필수 권한 요청 중...';
    await _requestPermissions();

    /// 1.2 세로모드 고정
    yield '세로 모드 고정 중...';
    await _setOnlyPortrait();

    /// 1.3 하단 네비게이션 바 숨김
    KioskModeManager.hideNavigationBar();

    /// 1.4 키오스크 모드
    KioskModeManager.enableKioskMode();

    /// 2. Data
    /// 2.1. GetIt 세팅
    GetIt.I.allowReassignment = true;

    /// 2.2 Database 열기
    yield 'Database 여는 중...';
    AppDatabase.openDB();

    /// 2.3 첫 실행 시 초기 Data 등록
    yield 'Database 초기화 중...';
    final basicInfoData = await _initializeBasicInfo();
    await _initializePages();
    await _initializeButtons();
    await _initializeMediaItems();

    /// 2.4 Database 데이터 로딩
    yield 'Database 데이터 로딩 중...';
    if (basicInfoData != null)
      globalData.updateFromBasicInfoData(basicInfoData: basicInfoData);

    /// 3. Network
    /// 3.1 OSC
    yield 'OSC 매니저 초기화 중...';
    openOscManager();

    /// 3.2 MQTT
    yield 'MQTT 매니저 초기화 중...';
    await openMqttManager(ref);
    subscribeTopics(ref);

    /// 4. 시간표 연결
    yield '시간표 불러오는 중...';
    final gSheet = GoogleSheets(sheetName: globalData.roomId);
    await gSheet.initialize();
    GetIt.I.registerSingleton<GoogleSheets>(gSheet);

    _isInitialized = true;

    yield ' ';
  }

  static Stream<String> reinitAfterEditorMode(WidgetRef ref) async* {
    _isInitialized = false;

    /// 2.4 Database 데이터 로딩
    yield 'Database 데이터 로딩 중...';
    final basicInfoData = await _initializeBasicInfo();
    if (basicInfoData != null)
      globalData.updateFromBasicInfoData(basicInfoData: basicInfoData);

    /// 3. Network
    /// 3.1 OSC
    yield 'OSC 매니저 초기화 중...';
    openOscManager();

    /// 3.2 MQTT
    yield 'MQTT 매니저 초기화 중...';
    try {
      await openMqttManager(ref).then((_) {
        subscribeTopics(ref);
      }).timeout(
        Duration(seconds: 10),
      );
    } catch (e) {
      print(' ❌ Mqtt 매니저 초기화 실패! : $e');
    }

    /// 4. 시간표 연결
    yield '시간표 불러오는 중...';
    final gSheet = GoogleSheets(sheetName: globalData.roomId);
    await gSheet.reInitialize();
    GetIt.I.registerSingleton<GoogleSheets>(gSheet);

    _isInitialized = true;

    yield ' ';
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
    // print('설정 변경 권한 요청 중');
    // await permissionHandler.requestWriteSettingsPermission();
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
  /// 2.3.1 기본정보 초기화 메서드(globalData 등록)
  static Future<BasicInfoData?> _initializeBasicInfo() async {
    final db = GetIt.I<AppDatabase>();

    // 최신 BasicInfo 불러오기
    print('BasicInfo 불러오는 중');
    BasicInfoData? basicInfoData = await db.getLatestBasicInfo();

    // 앱 첫 실행 시, 초기값을 가져와 기본 정보에 저장
    if (basicInfoData == null) {
      print('BasicInfo 초기화 중');
      // 로고 이미지 파일을 로드하여 DB에 저장
      final ByteData bytes = await rootBundle.load(initialImagePath);
      final Uint8List imageList = bytes.buffer.asUint8List();

      // 기본 정보 생성
      try {
        await db.createBasicInfo(
          BasicInfoCompanion(
            roomId: const Value(initialRoomId),
            roomName: const Value(initialRoomName),
            wifiName: const Value(initialWifiName),
            logoImage: Value(imageList),
            titleText: const Value(initialTitleText),
            serverIp: const Value(initialServerIp),
          ),
        );
        basicInfoData = await db.getLatestBasicInfo();
      } catch (e) {
        print('❌ BasicInfo 초기화 실패 : $e');
        return null;
      }
    }
    return basicInfoData;
  }

  /// 2.3.2 페이지 정보 초기화 메서드(globalData 미등록)
  static Future<void> _initializePages() async {
    final db = GetIt.I<AppDatabase>();

    // 최신 pageData 불러오기
    List<PageData>? pageDataList = await db.getPages();

    // 앱 첫 실행 시, 초기값을 가져와 기본 정보에 저장
    if (pageDataList.isEmpty) {
      Map<String, int> resultCreatingPages = {};

      // 기본 정보 생성
      for (PageCompanion pageCompanion in DEFAULT_PAGES) {
        try {
          final result = await db.createPage(pageCompanion);

          resultCreatingPages = {
            ...resultCreatingPages,
            pageCompanion.pageName.value: result,
          };
        } catch (e) {
          print('❌ page 초기화 실패 : $e');
          return;
        }
      }

      print('✅ 페이지 데이터 초기화 결과');
      print(resultCreatingPages);
    }
  }

  /// 2.3.3 버튼정보 초기화 메서드(globalData 미등록)
  static Future<void> _initializeButtons() async {
    final db = GetIt.I<AppDatabase>();

    // 최신 buttonData 불러오기
    List<ButtonData>? buttonDataList = await db.getButtons();

    // 앱 첫 실행 시, 초기값을 가져와 기본 정보에 저장
    if (buttonDataList.isEmpty) {
      Map<String, int> resultCreatingButtons = {};

      // 기본 정보 생성
      for (ButtonCompanion buttonCompanion in DEFAULT_BUTTONS) {
        try {
          final result = await db.createButton(buttonCompanion);

          resultCreatingButtons = {
            ...resultCreatingButtons,
            buttonCompanion.buttonName.value: result,
          };
        } catch (e) {
          print('❌ button 초기화 실패 : $e');
          return;
        }
      }

      print('✅ 버튼 데이터 초기화 결과');
      print(resultCreatingButtons);
    }
  }

  /// 2.3.4 미디어 아이템 초기화 메서드(globalData 미등록)
  static Future<void> _initializeMediaItems() async {
    final db = GetIt.I<AppDatabase>();

    // 최신 buttonData 불러오기
    List<MediaItemData>? mediaItemDataList = await db.getMediaItemDataList();

    // 앱 첫 실행 시, 초기값을 가져와 기본 정보에 저장
    if (mediaItemDataList.isEmpty) {
      Map<String, int> resultCreatingMediaItems = {};

      // 기본 정보 생성
      for (MediaItemCompanion mediaItemCompanion in DEFAULT_MEDIA_ITEM) {
        try {
          final result = await db.createMediaItems(mediaItemCompanion);

          resultCreatingMediaItems = {
            ...resultCreatingMediaItems,
            mediaItemCompanion.title.value: result,
          };
        } catch (e) {
          print('❌ mediaItem 초기화 실패 : $e');
          return;
        }
      }

      print('✅ 미디어 아이템 데이터 초기화 결과');
      print(resultCreatingMediaItems);
    }
  }

  /// 3.2. Network
  /// 3.2.1 MqttManager 오픈
  static Future<void> openMqttManager(WidgetRef ref) async {
    print('MqttManager를 오픈 중입니다...');
    try {
      final mqttManager = ref.read(mqttManagerProvider);
      await mqttManager.connect();
    } catch (e) {
      print('❌ MQTT 연결 실패: $e');
    }
  }

  /// 3.2.2 토픽 구독
  static void subscribeTopics(WidgetRef ref) {
    final mqttManager = ref.read(mqttManagerProvider);
    for (var topic in SUBSCRIBING_TOPICS) {
      mqttManager.subscribe(topic);
    }
    mqttManager.listen((topic, message) {
      onMqttReceived(ref, topic, message);
    });
  }
}
