import 'package:mdk_mqtt_manager/mqtt_manager.dart';
import 'package:uuid/uuid.dart';

final mqttManager =
    MqttManager(broker: '192.168.219.122', clientId: Uuid().v4());
