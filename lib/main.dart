import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdk_kiosk/common/util/route/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
        fontFamily: 'Paperlogy',
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
