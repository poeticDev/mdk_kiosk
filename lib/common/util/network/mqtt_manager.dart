import 'package:mdk_kiosk/common/util/data/global_data.dart';
import 'package:mdk_mqtt_manager/mqtt_manager.dart';
import 'package:uuid/uuid.dart';

late MqttManager mqttManager;

// final mqttManager =
//     MqttManager(broker: '192.168.219.122', clientId: Uuid().v4());

Future<void> openMqttManager() async {
  // oscManager가 열려있으면 일단 닫음
  if (isMqttManagerInitialized) mqttManager.disconnect();

  mqttManager = MqttManager(
    broker: globalData.serverIp,
    clientId: Uuid().v4(),
  );

  await mqttManager.connect();
}

// oscManager 초기화 여부 확인
bool get isMqttManagerInitialized {
  try {
    mqttManager.hashCode;
    return true;
  } catch (_) {
    return false;
  }
}
