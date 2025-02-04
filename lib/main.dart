import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdk_kiosk/common/util/route/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setOnlyPortrait(); // 디바이스 세로 모드로 고정
  runApp(
    ProviderScope(
      child: _KioskApp(),
    ),
  );
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
