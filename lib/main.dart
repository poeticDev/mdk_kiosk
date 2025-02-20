import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdk_kiosk/common/util/route/router.dart';
import 'common/util/network/mqtt_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setOnlyPortrait(); // 디바이스 세로 모드로 고정
  // 하단 네비게이션 바 숨김 -> 이니셜라이저로 나중에 이동
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  mqttConnect();

  runApp(
    ProviderScope(
      child: _KioskApp(),
    ),
  );
}

void mqttConnect() async {
  await mqttManager.connect();
  mqttManager.subscribe('msg/#');
  mqttManager.listen((String topic, String payload) {
  });
}

class _KioskApp extends StatelessWidget {
  const _KioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        fontFamily: 'Pretendard',
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> setOnlyPortrait() async {
  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ],
  );
}
