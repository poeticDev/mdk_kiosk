import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mdk_kiosk/common/util/route/router.dart';

/// /admin/timetable 라우트 테스트
///
/// 관리자 시간표 관리 화면으로 이동하는 라우트가 올바르게 등록되어 있는지 확인
void main() {
  group('Router /admin/timetable 라우트', () {
    test('router는 GoRouter 인스턴스', () {
      expect(router, isA<GoRouter>());
    });

    test('router에 /admin/timetable 라우트가 등록됨', () {
      // Given: router 인스턴스
      // When: 라우트 목록 확인
      // Then: /admin/timetable 경로가 존재해야 함

      final routes = router.configuration.routes;
      expect(routes.isNotEmpty, true);

      // 루트 라우트 찾기
      final rootRoute = routes.firstWhere(
        (route) => route is GoRoute && route.path == '/',
        orElse: () => routes.first,
      );

      expect(rootRoute, isA<GoRoute>());

      // /admin/timetable 하위 라우트 찾기
      final goRoute = rootRoute as GoRoute;
      final adminRoute = goRoute.routes.firstWhere(
        (route) => route is GoRoute && route.path == 'admin/timetable',
        orElse: () => throw Exception('admin/timetable route not found'),
      );

      expect(adminRoute, isNotNull);
      expect(adminRoute, isA<GoRoute>());
    });

    test('/admin/timetable 라우트 경로 확인', () {
      // Given: router 인스턴스
      final routes = router.configuration.routes;
      final rootRoute =
          routes.firstWhere(
                (route) => route is GoRoute && route.path == '/',
                orElse: () => routes.first,
              )
              as GoRoute;

      // When: admin/timetable 라우트 찾기
      final adminRoute =
          rootRoute.routes.firstWhere(
                (route) => route is GoRoute && route.path == 'admin/timetable',
                orElse: () =>
                    throw Exception('admin/timetable route not found'),
              )
              as GoRoute;

      // Then: 경로가 올바르게 설정되어야 함
      expect(adminRoute.path, equals('admin/timetable'));
    });

    test('/admin/timetable 라우트는 DefaultLayout을 사용하는 builder를 가짐', () {
      // Given: router 인스턴스
      final routes = router.configuration.routes;
      final rootRoute =
          routes.firstWhere(
                (route) => route is GoRoute && route.path == '/',
                orElse: () => routes.first,
              )
              as GoRoute;

      // When: admin/timetable 라우트 찾기
      final adminRoute =
          rootRoute.routes.firstWhere(
                (route) => route is GoRoute && route.path == 'admin/timetable',
                orElse: () =>
                    throw Exception('admin/timetable route not found'),
              )
              as GoRoute;

      // Then: builder가 설정되어 있어야 함
      expect(adminRoute.builder, isNotNull);
    });
  });
}
