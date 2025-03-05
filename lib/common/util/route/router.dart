import 'package:go_router/go_router.dart';
import 'package:mdk_kiosk/common/util/initializer.dart';
import 'package:mdk_kiosk/common/view/root_screen.dart';
import 'package:mdk_kiosk/common/view/splash_screen.dart';
import 'package:mdk_kiosk/multimedia/web_view_test.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(
        onSplashing: AppInitializer.initialize,
        nextPagePath: '/home',
      ),
      routes: [
        GoRoute(
          path: 'splash',
          builder: (context, state) => SplashScreen(),
        ),
        GoRoute(
          path: 'home',
          builder: (context, state) => RootScreen(),
        ),
        GoRoute(
          path: 'web_view_test',
          builder: (context, state) => WebViewTest(),
        ),
      ],
    ),
  ],
);
