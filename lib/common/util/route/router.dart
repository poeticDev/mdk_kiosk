import 'package:go_router/go_router.dart';
import 'package:mdk_kiosk/common/layout/default_layout.dart';
import 'package:mdk_kiosk/common/view/splash_screen.dart';
import 'package:mdk_kiosk/common/view/test_screen.dart';
import 'package:mdk_kiosk/timetable/component/timetable.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(
        nextPagePath: '/home',
        needInitializing: true,
      ),
      routes: [
        GoRoute(
          path: 'reinit',
          builder: (context, state) => SplashScreen(
            nextPagePath: '/home',
            needInitializing: true,
          ),
        ),
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
