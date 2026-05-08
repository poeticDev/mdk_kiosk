import 'package:carousel_slider/carousel_slider.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart' show BoxFit;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';
import 'package:mdk_kiosk/common/view/splash_screen.dart';
import 'package:mdk_kiosk/multimedia/multimedia_layout.dart';
import 'package:mdk_kiosk/multimedia/util/media_controller.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    GetIt.I.registerSingleton<AppDatabase>(db);
  });

  tearDown(() async {
    if (GetIt.I.isRegistered<AppDatabase>()) {
      await GetIt.I.reset();
    }
    await db.close();
  });

  Widget createTestWidget({List<Widget>? items}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: MultimediaLayout(items: items),
        ),
      ),
    );
  }

  group('MultimediaLayout', () {
    testWidgets('shows SplashScreen while media controller is loading',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // The AsyncNotifierProvider starts in loading state before build() resolves.
      // After pumpWidget (single frame), the widget tree should show SplashScreen.
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('shows empty placeholder for an empty media snapshot',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Empty DB → AsyncValue.data([]) → empty text placeholder
      expect(find.text('미디어 정보가 없습니다'), findsOneWidget);
    });

    testWidgets('renders carousel items from the current media snapshot',
        (tester) async {
      // Seed DB so the provider resolves with non-empty data
      await db.createMediaItems(MediaItemCompanion(
        key: const Value('test-img-1'),
        title: const Value('Test Image'),
        type: Value(MediaType.image),
        url: const Value('http://example.com/test.jpg'),
        fileName: const Value('test.jpg'),
        from: Value(MediaFrom.gDrive),
        fit: Value(BoxFit.cover),
        orderNum: const Value(0),
        lastUpdated: Value(DateTime(2024, 1, 1)),
      ));

      // Use items seam to inject safe test widgets, bypassing plugin-heavy
      // ItemImage/ItemVideo/ItemWebView
      final testItems = [
        Container(
          key: const Key('test-media-item-1'),
          child: const Text('Test Media Item 1'),
        ),
      ];

      await tester.pumpWidget(createTestWidget(items: testItems));
      await tester.pumpAndSettle();

      // CarouselSlider should be present
      expect(find.byType(CarouselSlider), findsOneWidget);
      // The injected test widget should be rendered inside the carousel
      expect(find.byKey(const Key('test-media-item-1')), findsOneWidget);
    });

    testWidgets('rebuilds when media controller emits a new snapshot',
        (tester) async {
      // Start with empty DB → empty placeholder
      await tester.pumpWidget(createTestWidget(
        items: [
          Container(
            key: const Key('test-media-item-1'),
            child: const Text('Test Media Item 1'),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Initially empty → shows empty placeholder text
      expect(find.text('미디어 정보가 없습니다'), findsOneWidget);
      // No carousel yet
      expect(find.byType(CarouselSlider), findsNothing);

      // Push new data through the provider via mediaDataHandler
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MultimediaLayout)),
      );
      final controller = container.read(mediaControllerProvider.notifier);
      await controller.mediaDataHandler(
        mediaDataList: [
          {
            'key': 'img1',
            'title': 'New Image',
            'type': 'image',
            'url': 'http://example.com/new.jpg',
            'from': 'gDrive',
            'orderNum': 0,
          },
        ],
      );

      await tester.pumpAndSettle();

      // After data arrives → empty placeholder gone, carousel visible
      expect(find.text('미디어 정보가 없습니다'), findsNothing);
      expect(find.byType(CarouselSlider), findsOneWidget);
    });
  });
}