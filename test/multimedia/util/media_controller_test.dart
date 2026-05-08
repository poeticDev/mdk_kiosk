import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart' show BoxFit;
import 'package:flutter_test/flutter_test.dart' hide isNull;
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';
import 'package:mdk_kiosk/multimedia/util/media_controller.dart';
import 'package:riverpod/riverpod.dart';

/// Helper to create MediaItemCompanion for tests
MediaItemCompanion createMediaItem({
  required String key,
  required String title,
  required MediaType type,
  required String url,
  String? fileName,
  MediaFrom from = MediaFrom.gDrive,
  BoxFit? fit,
  int orderNum = 0,
  DateTime? lastUpdated,
}) {
  return MediaItemCompanion(
    key: Value(key),
    title: Value(title),
    type: Value(type),
    url: Value(url),
    fileName: fileName != null ? Value(fileName) : const Value.absent(),
    from: Value(from),
    fit: fit != null ? Value(fit) : const Value.absent(),
    orderNum: Value(orderNum),
    lastUpdated: lastUpdated != null
        ? Value(lastUpdated)
        : Value(DateTime(2024, 1, 1)),
  );
}

/// Helper to create JSON payload matching MQTT format
List<Map<String, dynamic>> createMediaJsonList({
  required String key,
  required String title,
  required String type,
  required String url,
  String? fileName,
  String from = 'gDrive',
  String? fit,
  int orderNum = 0,
}) {
  return [
    {
      'key': key,
      'title': title,
      'type': type,
      'url': url,
      'fileName': fileName,
      'from': from,
      'fit': fit,
      'orderNum': orderNum,
    }
  ];
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    // Create isolated in-memory database
    db = AppDatabase.forTesting(NativeDatabase.memory());

    // Register the test database in GetIt
    GetIt.I.registerSingleton<AppDatabase>(db);

    // Create provider container for testing
    container = ProviderContainer();
  });

  tearDown(() async {
    // Clean up provider container
    container.dispose();

    // Unregister test database from GetIt
    if (GetIt.I.isRegistered<AppDatabase>()) {
      await GetIt.I.reset();
    }

    // Close database
    await db.close();
  });

  group('mediaControllerProvider - async hydration', () {
    test('initial build() hydrates from seeded DB', () async {
      // Seed DB with initial data
      await db.createMediaItems(createMediaItem(
        key: 'img1',
        title: 'Initial Image',
        type: MediaType.image,
        url: 'http://example.com/initial.jpg',
        orderNum: 0,
      ));

      // Create a fresh container to trigger build()
      final testContainer = ProviderContainer();

      // Properly await the async provider resolution
      final mediaItems = await testContainer.read(mediaControllerProvider.future);

      // Verify initial hydration
      expect(mediaItems.length, 1);
      expect(mediaItems.first.key, 'img1');

      testContainer.dispose();
    });

    test('build() returns empty list when DB is empty', () async {
      // DB is empty - no seed data

      // Create a fresh container to trigger build()
      final testContainer = ProviderContainer();

      // Properly await the async provider resolution
      final mediaItems = await testContainer.read(mediaControllerProvider.future);

      // Verify empty state
      expect(mediaItems, isEmpty);

      testContainer.dispose();
    });

    test('loading state is observable before data resolves', () async {
      // Create a fresh container to trigger build()
      final testContainer = ProviderContainer();

      // Check loading state before awaiting
      final loadingState = testContainer.read(mediaControllerProvider);
      // Should be in loading state (has no value yet)
      expect(loadingState.isLoading, isTrue);
      expect(loadingState.hasValue, isFalse);

      // Now await the resolution
      final mediaItems = await testContainer.read(mediaControllerProvider.future);
      expect(mediaItems, isEmpty);

      testContainer.dispose();
    });
  });

  group('mediaDataHandler() - snapshot sync', () {
    test('media controller hydrates from db and refreshes after snapshot sync', () async {
      // Seed DB with initial data
      await db.createMediaItems(createMediaItem(
        key: 'img1',
        title: 'Initial Image',
        type: MediaType.image,
        url: 'http://example.com/initial.jpg',
        orderNum: 0,
      ));

      // Create container and await initial build
      final testContainer = ProviderContainer();
      final initialItems = await testContainer.read(mediaControllerProvider.future);

      // Verify initial state
      expect(initialItems.length, 1);
      expect(initialItems.first.title, 'Initial Image');

      // Call mediaDataHandler with new data
      final controller = testContainer.read(mediaControllerProvider.notifier);
      await controller.mediaDataHandler(
        mediaDataList: createMediaJsonList(
          key: 'img2',
          title: 'Synced Image',
          type: 'image',
          url: 'http://example.com/synced.jpg',
          orderNum: 0,
        ),
      );

      // Verify state was refreshed from DB
      final newItems = await testContainer.read(mediaControllerProvider.future);
      expect(newItems.length, 1);
      expect(newItems.first.key, 'img2');
      expect(newItems.first.title, 'Synced Image');

      testContainer.dispose();
    });

    test('media controller ignores malformed media rows without mutating persisted state', () async {
      // Seed DB with good data
      await db.createMediaItems(createMediaItem(
        key: 'img1',
        title: 'Good Image',
        type: MediaType.image,
        url: 'http://example.com/good.jpg',
        orderNum: 0,
      ));

      // Create container and await initial build
      final testContainer = ProviderContainer();
      final initialItems = await testContainer.read(mediaControllerProvider.future);

      // Verify initial good state
      expect(initialItems.length, 1);
      expect(initialItems.first.title, 'Good Image');

      final initialDbState = await db.getMediaItemDataList();

      // Call mediaDataHandler with malformed payload (missing required orderNum)
      final controller = testContainer.read(mediaControllerProvider.notifier);
      await controller.mediaDataHandler(
        mediaDataList: [
          {
            'key': 'mediaItem_bad',
            'title': 'Bad',
            'type': 'image',
            'url': 'http://example.com/bad.jpg',
            'from': 'gDrive',
          }
        ],
      );

      // Verify last good state is preserved (not destroyed)
      final preservedItems = await testContainer.read(mediaControllerProvider.future);
      expect(preservedItems.length, 1);
      expect(preservedItems.first.title, 'Good Image');

      final preservedDbState = await db.getMediaItemDataList();
      expect(preservedDbState.map((item) => item.key).toList(),
          initialDbState.map((item) => item.key).toList());
      expect(preservedDbState.first.title, 'Good Image');

      testContainer.dispose();
    });

    test('media controller is idempotent for repeated identical payloads', () async {
      // Create container and await initial build
      final testContainer = ProviderContainer();
      await testContainer.read(mediaControllerProvider.future);

      final controller = testContainer.read(mediaControllerProvider.notifier);

      // First sync
      await controller.mediaDataHandler(
        mediaDataList: createMediaJsonList(
          key: 'img1',
          title: 'Image 1',
          type: 'image',
          url: 'http://example.com/img1.jpg',
          orderNum: 0,
        ),
      );

      final firstItems = await testContainer.read(mediaControllerProvider.future);
      expect(firstItems.length, 1);

      // Second sync with identical payload
      await controller.mediaDataHandler(
        mediaDataList: createMediaJsonList(
          key: 'img1',
          title: 'Image 1',
          type: 'image',
          url: 'http://example.com/img1.jpg',
          orderNum: 0,
        ),
      );

      final secondItems = await testContainer.read(mediaControllerProvider.future);
      expect(secondItems.length, 1);
      expect(secondItems.first.key, 'img1');
      expect(secondItems.first.title, 'Image 1');

      // Third sync with identical payload
      await controller.mediaDataHandler(
        mediaDataList: createMediaJsonList(
          key: 'img1',
          title: 'Image 1',
          type: 'image',
          url: 'http://example.com/img1.jpg',
          orderNum: 0,
        ),
      );

      final thirdItems = await testContainer.read(mediaControllerProvider.future);
      expect(thirdItems.length, 1);
      expect(thirdItems.first.key, 'img1');

      testContainer.dispose();
    });

    test('media controller converges to the latest valid snapshot across rapid successive updates', () async {
      // Create container and await initial build
      final testContainer = ProviderContainer();
      await testContainer.read(mediaControllerProvider.future);

      final controller = testContainer.read(mediaControllerProvider.notifier);

      // Fire overlapping updates without awaiting between them to exercise the
      // real MQTT-style fire-and-forget path.
      final firstUpdate = controller.mediaDataHandler(
        mediaDataList: createMediaJsonList(
          key: 'img1',
          title: 'First',
          type: 'image',
          url: 'http://example.com/first.jpg',
          orderNum: 0,
        ),
      );

      final secondUpdate = controller.mediaDataHandler(
        mediaDataList: createMediaJsonList(
          key: 'img2',
          title: 'Second',
          type: 'image',
          url: 'http://example.com/second.jpg',
          orderNum: 0,
        ),
      );

      final thirdUpdate = controller.mediaDataHandler(
        mediaDataList: createMediaJsonList(
          key: 'img3',
          title: 'Third - Final',
          type: 'image',
          url: 'http://example.com/third.jpg',
          orderNum: 0,
        ),
      );

      await Future.wait([firstUpdate, secondUpdate, thirdUpdate]);

      // Verify convergence to latest snapshot
      final finalItems = await testContainer.read(mediaControllerProvider.future);
      expect(finalItems.length, 1);
      expect(finalItems.first.key, 'img3');
      expect(finalItems.first.title, 'Third - Final');
      // Should NOT have img1 or img2 - only latest snapshot

      testContainer.dispose();
    });

    test('rapid updates with multiple items converge correctly', () async {
      // Create container and await initial build
      final testContainer = ProviderContainer();
      await testContainer.read(mediaControllerProvider.future);

      final controller = testContainer.read(mediaControllerProvider.notifier);

      // First update: 2 items
      await controller.mediaDataHandler(
        mediaDataList: [
          ...createMediaJsonList(
            key: 'img1',
            title: 'First 1',
            type: 'image',
            url: 'http://example.com/first1.jpg',
            orderNum: 0,
          ),
          ...createMediaJsonList(
            key: 'img2',
            title: 'First 2',
            type: 'image',
            url: 'http://example.com/first2.jpg',
            orderNum: 1,
          ),
        ],
      );

      // Second update: 3 items (add one, update one)
      await controller.mediaDataHandler(
        mediaDataList: [
          ...createMediaJsonList(
            key: 'img1',
            title: 'Second 1 - Updated',
            type: 'image',
            url: 'http://example.com/first1.jpg', // Same URL = update
            orderNum: 0,
          ),
          ...createMediaJsonList(
            key: 'img2',
            title: 'Second 2',
            type: 'image',
            url: 'http://example.com/first2.jpg',
            orderNum: 1,
          ),
          ...createMediaJsonList(
            key: 'img3',
            title: 'Second 3 - New',
            type: 'image',
            url: 'http://example.com/second3.jpg',
            orderNum: 2,
          ),
        ],
      );

      // Verify final state has all 3 items with correct titles
      final finalItems = await testContainer.read(mediaControllerProvider.future);
      expect(finalItems.length, 3);

      // Find items by key
      final img1 = finalItems.firstWhere((i) => i.key == 'img1');
      final img2 = finalItems.firstWhere((i) => i.key == 'img2');
      final img3 = finalItems.firstWhere((i) => i.key == 'img3');

      expect(img1.title, 'Second 1 - Updated');
      expect(img2.title, 'Second 2');
      expect(img3.title, 'Second 3 - New');

      testContainer.dispose();
    });
  });

  group('mediaControllerProvider - AsyncValue states', () {
    test('provider starts in loading state then transitions to data', () async {
      // Seed DB
      await db.createMediaItems(createMediaItem(
        key: 'img1',
        title: 'Test Image',
        type: MediaType.image,
        url: 'http://example.com/test.jpg',
        orderNum: 0,
      ));

      // Create fresh container
      final testContainer = ProviderContainer();

      // Check loading state before awaiting
      final initialState = testContainer.read(mediaControllerProvider);
      expect(initialState.isLoading, isTrue);

      // Now await the resolution
      final resolvedItems = await testContainer.read(mediaControllerProvider.future);
      expect(resolvedItems.isNotEmpty, isTrue);

      testContainer.dispose();
    });

    test('empty DB build() returns empty list (not error)', () async {
      // Don't seed DB - build() should still work (returns empty list)
      final testContainer = ProviderContainer();

      // Await the build - should resolve to empty list, not error
      final mediaItems = await testContainer.read(mediaControllerProvider.future);

      // Should have value (empty list), not error
      expect(mediaItems, isEmpty);

      testContainer.dispose();
    });
  });
}
