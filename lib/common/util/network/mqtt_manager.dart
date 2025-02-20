import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/v4.dart';

class MqttManager {
  final String broker;
  final String clientId;
  int port;
  late MqttServerClient _client;

  /// isSecure=true이고 port가 '1883 또는 미입력' 시 자동으로 port가 8883으로 설정됨
  final bool isSecure;
  final String userName;
  final String password;

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
    _client.logging(on: true);

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
  Future<bool> connect() async {
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(userName, password)
        .startClean() // 비연속 세션
        .withWillTopic('disconnect') // 비정상 연결 해제 시 토픽
        .withWillMessage(
            '$clientId disconnected unexpectedly') //비정상 연결 해제 시 메세지
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
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
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
}

final mqttManager =
    MqttManager(broker: '192.168.210.115', clientId: UuidV4().toString());