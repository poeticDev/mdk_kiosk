import 'package:go_router/go_router.dart';
import 'package:mdk_kiosk/common/layout/default_layout.dart';
import 'package:mdk_kiosk/common/util/initializer.dart';
import 'package:mdk_kiosk/common/view/root_screen.dart';
import 'package:mdk_kiosk/common/view/splash_screen.dart';
import 'package:mdk_kiosk/common/view/test_screen.dart';
import 'package:mdk_kiosk/timetable/component/timetable.dart';

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
          builder: (context, state) => DefaultLayout(
            midChild: Timetable(),
          ),
        ),
        GoRoute(
          path: 'test',
          builder: (context, state) => DefaultLayout(
            midChild: TestScreen(),
          ),
        ),
      ],
    ),
  ],
);
