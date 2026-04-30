import 'package:go_router/go_router.dart';
import 'package:mdk_kiosk/common/layout/default_layout.dart';
import 'package:mdk_kiosk/common/view/splash_screen.dart';
import 'package:mdk_kiosk/common/view/test_screen.dart';
import 'package:mdk_kiosk/timetable/admin/timetable_admin_screen.dart';
import 'package:mdk_kiosk/timetable/component/timetable.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          SplashScreen(nextPagePath: '/home', needInitializing: true),
      routes: [
        GoRoute(
          path: 'reinit',
          builder: (context, state) =>
              SplashScreen(nextPagePath: '/home', needInitializing: true),
        ),
        GoRoute(path: 'splash', builder: (context, state) => SplashScreen()),
        GoRoute(
          path: 'home',
          builder: (context, state) => DefaultLayout(midChild: Timetable()),
        ),
        GoRoute(
          path: 'test',
          builder: (context, state) => DefaultLayout(midChild: TestScreen()),
        ),
      ],
    ),
    // 관리자 화면은 SplashScreen의 자식이 아닌 최상위 라우트로 분리
    // SplashScreen의 자동 네비게이션 영향을 받지 않도록 함
    GoRoute(
      path: '/admin/timetable',
      builder: (context, state) => const TimetableAdminScreen(),
    ),
  ],
);
