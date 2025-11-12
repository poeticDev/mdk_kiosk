import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdk_kiosk/common/util/data/global_data.dart';
import 'package:mdk_kiosk/common/util/data/updaters.dart';
import 'package:mdk_kiosk/header/message_controller.dart';
import 'package:mdk_kiosk/header/model/studio_state_model.dart';
import 'package:mdk_kiosk/header/util/state_manager.dart';
import 'package:mdk_kiosk/multimedia/util/media_controller.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

const KIOSK_NAME = 'wall_hub';

const List<String> SUBSCRIBING_TOPICS = [
  'node-mdk/+/$KIOSK_NAME',
  // 'node-mdk/+/ON_AIR_2',
  'node-mdk/states',
];

final mqttManagerProvider = Provider<MqttManager>((ref) {
  return MqttManager(
    broker: globalData.serverIp,
    port: globalData.serverMqttPort,
    userName: globalData.serverMqttId,
    password: globalData.serverMqttPassword,
    clientId: Uuid().v4(),
  );
});

/// Mqtt 수신시
void onMqttReceived(WidgetRef ref, String topic, String message) {
  final List<String> splitedTopicList = topic.split('/');

  // data : media data, message
  if (splitedTopicList.last == KIOSK_NAME) {
    mqttDataHandler(ref, message);
  }
  // states : 온습도
  else if (topic == 'node-mdk/states') {
    stateHandler(ref, message);
  }
  // else if (topic == 'node-mdk/command/ON_AIR_2') {
  //   /// 스테이트 변경 로직
  //   final parsedInt = int.tryParse(message) ?? 0;
  //   ref.read(studioStateProvider.notifier).state = STATE_LIST[parsedInt];
  // }
}

/// Kiosk Data 핸들링
void mqttDataHandler(WidgetRef ref, String dataJson) {
  final dynamic parsedData = jsonDecode(dataJson);

  print('✅parsedData: $parsedData');
  print('✅parsedData type: ${parsedData.runtimeType}');

  // if (parsedData is Map<String, dynamic>) {
  //   final DateTime? timeRecord = _parseTimeRecord(parsedData['timeRecord']);
  //
  //   // 발행시간이 없으면 무시
  //   if (timeRecord == null) {
  //     print('❌ MQTT data에 발행시간이 없습니다');
  //     return;
  //   }
  //   // 데이터 핸들링
  //   handleParsedData(parsedData, 'mediaData', (dataList) {
  //     print('✅ MQTT 미디어데이터 수신');
  //     MediaController().mediaDataHandler(
  //       mediaDataList: dataList,
  //       timeRecord: timeRecord,
  //     );
  //   });
  // } else

  if (parsedData is List) {
    final List<Map<String, dynamic>> messageMapList = [];
    final List<Map<String, dynamic>> mediaMapList = [];

    for (dynamic e in parsedData) {
      final dataMap = Map<String, dynamic>.from(e);
      print('dataMap: $dataMap');
      if (dataMap['key'].contains('message'))
        messageMapList.add(dataMap);
      else if (dataMap['key'].contains('mediaItem'))
        mediaMapList.add(dataMap);
      else if (dataMap['key'] == 'update') updateTimetable(ref);
    }

    if (messageMapList.isNotEmpty) {
      print('✅ 메세지 아이템 수신');
      ref.read(messageControllerProvider.notifier).messageDataHandler(
            messageDataList: messageMapList,
          );
    }

    if (mediaMapList.isNotEmpty) {
      print('✅ 미디어 아이템 수신');
      MediaController().mediaDataHandler(mediaDataList: mediaMapList, ref: ref
          // timeRecord: timeRecord,
          );
    }
  }
}

/// JSON에서 발행시간(timeRecord) 파싱
DateTime? _parseTimeRecord(dynamic timeRecord) {
  try {
    return DateTime.parse(timeRecord);
  } catch (e) {
    return null;
  }
}

/// 특정 key가 있는 경우, 해당 데이터를 리스트로 변환 후 핸들링
void handleParsedData(
  Map<String, dynamic> parsedData,
  String key,
  Function(List<Map<String, dynamic>>) handler,
) {
  if (parsedData.containsKey(key)) {
    final List<Map<String, dynamic>>? dataList =
        (parsedData[key] as List?)?.map((item) {
      return item as Map<String, dynamic>;
    }).toList();

    if (dataList != null) {
      handler(dataList);
    }
  }
}

void stateHandler(WidgetRef ref, String dataJson) {
  print('✅ MQTT State 수신');
  final Map<String, dynamic> parsedData = jsonDecode(dataJson);

  final sensor = parsedData['sensor2'];
  if (sensor is Map<String, dynamic>) {
    if (sensor.containsKey('temperature')) {
      final raw = double.tryParse(sensor['temperature'].toString());
      final double temperature = raw != null ? (raw * 10).round() / 10 : -999.0;
      ref.read(temperatureProvider.notifier).state = temperature;
    }

    if (sensor.containsKey('humidity')) {
      final raw = double.tryParse(sensor['humidity'].toString());
      final double humidity = raw != null ? (raw * 10).round() / 10 : -999.0;
      ref.read(humidityProvider.notifier).state = humidity;
    }
  } else {
    print('❌ sensor 필드가 없거나 형식이 잘못됨: $parsedData');
  }
}

class MqttManager {
  final String broker;
  final String clientId;
  int port;
  late MqttServerClient _client;

  /// isSecure=true이고 port가 '1883 또는 미입력' 시 자동으로 port가 8883으로 설정됨
  final bool isSecure;
  final String userName;
  final String password;
  WidgetRef? ref;

  MqttManager({
    required this.broker,
    required this.clientId,
    this.port = 1883, // 기본 MQTT 포트
    this.isSecure = false,
    this.userName = 'mdk',
    this.password = '12344321',
  }) {
    _client = MqttServerClient(broker, clientId);
    _configureClient();
  }

  /// MQTT 클라이언트 기본 설정
  void _configureClient() {
    if (isSecure && port == 1883) {
      port = 8883;
      _client.securityContext = SecurityContext.defaultContext;
    }
    _client.port = port;
    _client.keepAlivePeriod = 20;
    _client.connectTimeoutPeriod = 2000;
    _client.logging(on: false);

    // 콜백 설정
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onSubscribeFail = _onSubscribeFail;
    _client.pongCallback = _pongCallback;
    _client.pingCallback = _pingCallback;

    // MQTT 프로토콜 설정 (Mosquitto 등과 호환)
    _client.setProtocolV311();
  }

  /// MQTT 서버 연결
  Future<bool> connect(WidgetRef ref) async {
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(userName, password)
        .startClean() // 비연속 세션
        .withWillQos(MqttQos.atMostOnce);

    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
    } on NoConnectionException catch (e) {
      print('❌ 연결 실패: $e');
      _client.disconnect();
      return false;
    } on SocketException catch (e) {
      print('❌ 소켓 예외 발생: $e');
      _client.disconnect();
      return false;
    }

    return _client.connectionStatus?.state == MqttConnectionState.connected;
  }

  /// MQTT 서버 연결 해제
  void disconnect() {
    print('🔌 MQTT 연결 종료');
    _client.disconnect();
  }

  /// 토픽 구독
  void subscribe(String topic) {
    print('📡 구독 요청: $topic');
    _client.subscribe(topic, MqttQos.atMostOnce);
  }

  /// 메시지 발행
  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    print('📤 메시지 발행: $topic → "$message"');
    _client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// MQTT 메시지 수신 핸들러
  void listen(void Function(String topic, String message) onMessageReceived) {
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;

      final payload = utf8.decode(recMess.payload.message);

      // 한글이 깨지는 변환방식
      // final payload =
      //     MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('📩 수신된 메시지: ${c[0].topic} → "$payload"');
      onMessageReceived(c[0].topic, payload);
    });
  }

  /// 연결 성공 콜백
  void _onConnected() {
    print('✅ MQTT 서버 연결 성공');
  }

  /// 연결 해제 콜백
  void _onDisconnected() {
    print('❌ MQTT 서버 연결 해제됨');
    if (ref != null) retryConnect(ref!);
  }

  /// 구독 성공 콜백
  void _onSubscribed(String topic) {
    print('✅ 구독 성공: $topic');
  }

  /// 구독 실패 콜백
  void _onSubscribeFail(String topic) {
    print('❌ 구독 실패: $topic');
  }

  /// Pong 응답 콜백
  void _pongCallback() {
    print('🔄 Pong 응답 수신');
  }

  /// Ping 요청 콜백
  void _pingCallback() {
    print('🔄 Ping 요청 전송');
  }


  Timer? _retryTimer;

  Future<void> connectAndHandle(WidgetRef ref) async {
    this.ref = ref;

    final success = await connect(ref);
    if (success) {
      _retryTimer?.cancel();
      _retryTimer = null;

      // 연결 후 토픽 구독 + 수신 핸들러 등록
      for (var topic in SUBSCRIBING_TOPICS) {
        subscribe(topic);
      }

      listen((topic, message) {
        onMqttReceived(ref, topic, message);
      });
    } else {
      retryConnect(ref);
    }
  }

  void retryConnect(WidgetRef ref) {
    if (_retryTimer != null) return;

    _retryTimer = Timer(Duration(minutes: 5), () async {
      _retryTimer = null;
      print('🔁 MQTT 재연결 시도 중...');
      await connectAndHandle(ref);
    });
  }
}
