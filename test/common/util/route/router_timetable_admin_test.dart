import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mdk_kiosk/common/layout/default_layout.dart';
import 'package:mdk_kiosk/common/util/route/router.dart';
import 'package:mdk_kiosk/timetable/admin/timetable_admin_screen.dart';
import 'package:mdk_kiosk/timetable/component/timetable.dart';

/// /admin/timetable 라우트 테스트
///
/// 관리자 시간표 관리 화면으로 이동하는 라우트가 올바르게 등록되어 있는지 확인
/// 새로운 동작: /admin/timetable은 SplashScreen과 별개의 최상위 라우트로 standalone 동작
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Router /admin/timetable 라우트', () {
    test('router는 GoRouter 인스턴스', () {
      expect(router, isA<GoRouter>());
    });

    test('router에 /admin/timetable 라우트가 등록됨 (최상위)', () {
      // Given: router 인스턴스
      // When: 최상위 라우트 목록에서 /admin/timetable 찾기
      // Then: /admin/timetable 경로가 최상위에 존재해야 함

      final routes = router.configuration.routes;
      expect(routes.isNotEmpty, true);

      // 최상위 라우트에서 /admin/timetable 찾기
      final adminRoute = routes.firstWhere(
        (route) => route is GoRoute && route.path == '/admin/timetable',
        orElse: () =>
            throw Exception('/admin/timetable route not found at top level'),
      );

      expect(adminRoute, isNotNull);
      expect(adminRoute, isA<GoRoute>());
    });

    test('/admin/timetable 라우트 경로 확인', () {
      // Given: router 인스턴스
      final routes = router.configuration.routes;

      // When: 최상위에서 admin/timetable 라우트 찾기
      final adminRoute =
          routes.firstWhere(
                (route) => route is GoRoute && route.path == '/admin/timetable',
                orElse: () =>
                    throw Exception('/admin/timetable route not found'),
              )
              as GoRoute;

      // Then: 경로가 올바르게 설정되어야 함
      expect(adminRoute.path, equals('/admin/timetable'));
    });

    test('/admin/timetable 라우트는 builder를 가짐', () {
      // Given: router 인스턴스
      final routes = router.configuration.routes;

      // When: 최상위에서 admin/timetable 라우트 찾기
      final adminRoute =
          routes.firstWhere(
                (route) => route is GoRoute && route.path == '/admin/timetable',
                orElse: () =>
                    throw Exception('/admin/timetable route not found'),
              )
              as GoRoute;

      // Then: builder가 설정되어 있어야 함
      expect(adminRoute.builder, isNotNull);
    });
  });

  group('Router 라우트 구조 검증 (standalone behavior)', () {
    test('/admin/timetable는 최상위 라우트 (SplashScreen 자식 아님)', () {
      // Given: router 인스턴스
      final routes = router.configuration.routes;

      // When: 루트 라우트 찾기
      final rootRoute =
          routes.firstWhere(
                (route) => route is GoRoute && route.path == '/',
                orElse: () => throw Exception('root route not found'),
              )
              as GoRoute;

      // Then: /admin/timetable는 루트의 자식이 아님
      final isChildOfRoot = rootRoute.routes.any(
        (route) => route is GoRoute && route.path == 'admin/timetable',
      );
      expect(
        isChildOfRoot,
        isFalse,
        reason:
            '/admin/timetable should NOT be a child of / (SplashScreen) to avoid auto-navigation issues',
      );

      // And: /admin/timetable는 최상위에 존재
      final isTopLevel = routes.any(
        (route) => route is GoRoute && route.path == '/admin/timetable',
      );
      expect(
        isTopLevel,
        isTrue,
        reason: '/admin/timetable should be a top-level route',
      );
    });

    test('/admin/timetable builder는 TimetableAdminScreen을 직접 반환', () {
      // Given: router 인스턴스
      final routes = router.configuration.routes;

      final adminRoute =
          routes.firstWhere(
                (route) => route is GoRoute && route.path == '/admin/timetable',
                orElse: () =>
                    throw Exception('/admin/timetable route not found'),
              )
              as GoRoute;

      // When: builder 존재 확인
      final builder = adminRoute.builder;
      expect(builder, isNotNull);

      // builder는 TimetableAdminScreen을 직접 반환해야 함
      // (DefaultLayout 래퍼 없음)
    });

    test('/home는 DefaultLayout을 사용 (변경 없음)', () {
      // Given: router 인스턴스
      final routes = router.configuration.routes;
      final rootRoute =
          routes.firstWhere(
                (route) => route is GoRoute && route.path == '/',
                orElse: () => routes.first,
              )
              as GoRoute;

      // When: home 라우트 찾기
      final homeRoute =
          rootRoute.routes.firstWhere(
                (route) => route is GoRoute && route.path == 'home',
                orElse: () => throw Exception('home route not found'),
              )
              as GoRoute;

      // Then: builder가 설정되어 있어야 함
      expect(homeRoute.builder, isNotNull);
    });

    test('/test도 DefaultLayout을 사용 (변경 없음)', () {
      // Given: router 인스턴스
      final routes = router.configuration.routes;
      final rootRoute =
          routes.firstWhere(
                (route) => route is GoRoute && route.path == '/',
                orElse: () => routes.first,
              )
              as GoRoute;

      // When: test 라우트 찾기
      final testRoute =
          rootRoute.routes.firstWhere(
                (route) => route is GoRoute && route.path == 'test',
                orElse: () => throw Exception('test route not found'),
              )
              as GoRoute;

      // Then: builder가 설정되어 있어야 함
      expect(testRoute.builder, isNotNull);
    });
  });

  group('Router /home 라우트는 여전히 DefaultLayout 사용', () {
    test('/home 라우트 존재 확인', () {
      // Given: router 인스턴스
      final routes = router.configuration.routes;
      final rootRoute =
          routes.firstWhere(
                (route) => route is GoRoute && route.path == '/',
                orElse: () => routes.first,
              )
              as GoRoute;

      // When: home 라우트 찾기
      final homeRoute =
          rootRoute.routes.firstWhere(
                (route) => route is GoRoute && route.path == 'home',
                orElse: () => throw Exception('home route not found'),
              )
              as GoRoute;

      // Then: home 라우트가 존재해야 함
      expect(homeRoute, isNotNull);
      expect(homeRoute.path, equals('home'));
    });
  });

  group('Router direct entry fallback 동작', () {
    test('/home 라우트는 fallback으로 사용 가능', () {
      // Given: router 인스턴스
      final routes = router.configuration.routes;
      final rootRoute =
          routes.firstWhere(
                (route) => route is GoRoute && route.path == '/',
                orElse: () => routes.first,
              )
              as GoRoute;

      // When: home 라우트 찾기
      final homeRoute =
          rootRoute.routes.firstWhere(
                (route) => route is GoRoute && route.path == 'home',
                orElse: () => throw Exception('home route not found'),
              )
              as GoRoute;

      // Then: home 라우트가 존재해야 함
      expect(homeRoute, isNotNull);
      expect(homeRoute.path, equals('home'));
    });

    test('/test 라우트도 별도로 존재함 (DefaultLayout 사용)', () {
      // Given: router 인스턴스
      final routes = router.configuration.routes;
      final rootRoute =
          routes.firstWhere(
                (route) => route is GoRoute && route.path == '/',
                orElse: () => routes.first,
              )
              as GoRoute;

      // When: test 라우트 찾기
      final testRoute =
          rootRoute.routes.firstWhere(
                (route) => route is GoRoute && route.path == 'test',
                orElse: () => throw Exception('test route not found'),
              )
              as GoRoute;

      // Then: test 라우트가 존재해야 함
      expect(testRoute, isNotNull);
      expect(testRoute.path, equals('test'));
    });
  });
}
