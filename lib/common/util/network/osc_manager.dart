import 'package:mdk_kiosk/common/util/data/global_data.dart';
import 'package:osc/osc.dart';

late OscManager oscManager;

// OscManager oscManager = OscManager(
//   address: '192.168.219.122',
//   listenPort: 12321,
//   sendPort: 12321,
// );

Future<void> openOscManager() async {
  // oscManager가 열려있으면 일단 닫음
  if (isOscManagerInitialized) oscManager.disconnect();

  oscManager = OscManager(
    address: globalData.serverIp,
    listenPort: globalData.myOscPort,
    sendPort: globalData.serverOscPort,
  );

  await oscManager.connect();
}

// oscManager 초기화 여부 확인
bool get isOscManagerInitialized {
  try {
    oscManager.hashCode;
    return true;
  } catch (_) {
    return false;
  }
}
