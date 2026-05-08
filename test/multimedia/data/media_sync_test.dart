import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart' show BoxFit;
import 'package:flutter/widgets.dart' hide Table;
import 'package:flutter_test/flutter_test.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/data/model/media_item.dart';

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

void main() {
  late AppDatabase db;

  setUp(() async {
    // Use the real AppDatabase with an in-memory database for isolation
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('getMediaItemDataList', () {
    test('returns media items ordered by orderNum ascending, then key ascending', () async {
      // Insert items in non-sorted order
      await db.createMediaItems(createMediaItem(
        key: 'b',
        title: 'Item B',
        type: MediaType.image,
        url: 'http://example.com/b.jpg',
        orderNum: 2,
      ));
      await db.createMediaItems(createMediaItem(
        key: 'a',
        title: 'Item A',
        type: MediaType.image,
        url: 'http://example.com/a.jpg',
        orderNum: 1,
      ));
      await db.createMediaItems(createMediaItem(
        key: 'c',
        title: 'Item C',
        type: MediaType.image,
        url: 'http://example.com/c.jpg',
        orderNum: 1,
      ));

      final result = await db.getMediaItemDataList();

      expect(result.length, 3);
      // orderNum 1 comes first, then orderNum 2
      // Within orderNum 1, keys are sorted: 'a' before 'c'
      expect(result[0].key, 'a');
      expect(result[1].key, 'c');
      expect(result[2].key, 'b');
    });

    test('returns empty list when no media items exist', () async {
      final result = await db.getMediaItemDataList();
      expect(result, isEmpty);
    });
  });

  group('syncMediaItems - full snapshot inserts and updates', () {
    test('inserts new media items from snapshot', () async {
      final snapshot = [
        createMediaItem(
          key: 'img1',
          title: 'Image 1',
          type: MediaType.image,
          url: 'http://example.com/img1.jpg',
          orderNum: 0,
        ),
        createMediaItem(
          key: 'vid1',
          title: 'Video 1',
          type: MediaType.video,
          url: 'http://example.com/vid1.mp4',
          orderNum: 1,
        ),
      ];

      await db.syncMediaItems(snapshot);

      final result = await db.getMediaItemDataList();
      expect(result.length, 2);
      expect(result[0].key, 'img1');
      expect(result[1].key, 'vid1');
    });

    test('updates existing media when URL matches', () async {
      // Insert initial data
      await db.createMediaItems(createMediaItem(
        key: 'img1',
        title: 'Original Title',
        type: MediaType.image,
        url: 'http://example.com/img1.jpg',
        orderNum: 0,
      ));

      // Sync with updated title but same URL
      final snapshot = [
        createMediaItem(
          key: 'img1',
          title: 'Updated Title',
          type: MediaType.image,
          url: 'http://example.com/img1.jpg',
          orderNum: 5,
        ),
      ];

      await db.syncMediaItems(snapshot);

      final result = await db.getMediaItemDataList();
      expect(result.length, 1);
      expect(result[0].title, 'Updated Title');
      expect(result[0].orderNum, 5);
    });

    test('preserves ordered reads after sync', () async {
      final snapshot = [
        createMediaItem(
          key: 'z',
          title: 'Z Item',
          type: MediaType.image,
          url: 'http://example.com/z.jpg',
          orderNum: 3,
        ),
        createMediaItem(
          key: 'a',
          title: 'A Item',
          type: MediaType.image,
          url: 'http://example.com/a.jpg',
          orderNum: 1,
        ),
        createMediaItem(
          key: 'm',
          title: 'M Item',
          type: MediaType.image,
          url: 'http://example.com/m.jpg',
          orderNum: 2,
        ),
      ];

      await db.syncMediaItems(snapshot);

      final result = await db.getMediaItemDataList();
      expect(result[0].key, 'a');
      expect(result[1].key, 'm');
      expect(result[2].key, 'z');
    });
  });

  group('syncMediaItems - delete semantics', () {
    test('removes media items not present in next snapshot', () async {
      // Insert initial data
      await db.createMediaItems(createMediaItem(
        key: 'img1',
        title: 'Image 1',
        type: MediaType.image,
        url: 'http://example.com/img1.jpg',
        orderNum: 0,
      ));
      await db.createMediaItems(createMediaItem(
        key: 'img2',
        title: 'Image 2',
        type: MediaType.image,
        url: 'http://example.com/img2.jpg',
        orderNum: 1,
      ));

      // Sync with only one item
      final snapshot = [
        createMediaItem(
          key: 'img1',
          title: 'Image 1',
          type: MediaType.image,
          url: 'http://example.com/img1.jpg',
          orderNum: 0,
        ),
      ];

      await db.syncMediaItems(snapshot);

      final result = await db.getMediaItemDataList();
      expect(result.length, 1);
      expect(result[0].key, 'img1');
    });

    test('syncMediaItems clears all media on empty snapshot', () async {
      // Insert initial data
      await db.createMediaItems(createMediaItem(
        key: 'img1',
        title: 'Image 1',
        type: MediaType.image,
        url: 'http://example.com/img1.jpg',
        orderNum: 0,
      ));
      await db.createMediaItems(createMediaItem(
        key: 'vid1',
        title: 'Video 1',
        type: MediaType.video,
        url: 'http://example.com/vid1.mp4',
        orderNum: 1,
      ));

      // Sync with empty snapshot
      await db.syncMediaItems([]);

      final result = await db.getMediaItemDataList();
      expect(result, isEmpty);
    });
  });

  group('syncMediaItems - idempotency', () {
    test('syncMediaItems is idempotent for repeated identical payloads', () async {
      final snapshot = [
        createMediaItem(
          key: 'img1',
          title: 'Image 1',
          type: MediaType.image,
          url: 'http://example.com/img1.jpg',
          orderNum: 0,
        ),
        createMediaItem(
          key: 'img2',
          title: 'Image 2',
          type: MediaType.image,
          url: 'http://example.com/img2.jpg',
          orderNum: 1,
        ),
      ];

      // First sync
      await db.syncMediaItems(snapshot);
      var result = await db.getMediaItemDataList();
      expect(result.length, 2);

      // Second sync with identical payload
      await db.syncMediaItems(snapshot);
      result = await db.getMediaItemDataList();
      expect(result.length, 2);
      expect(result[0].key, 'img1');
      expect(result[1].key, 'img2');
    });

    test('idempotent with mixed insert, update, and unchanged items', () async {
      // Initial state
      await db.createMediaItems(createMediaItem(
        key: 'img1',
        title: 'Original',
        type: MediaType.image,
        url: 'http://example.com/img1.jpg',
        orderNum: 0,
      ));

      // First sync: update img1, add img2
      final snapshot1 = [
        createMediaItem(
          key: 'img1',
          title: 'Updated',
          type: MediaType.image,
          url: 'http://example.com/img1.jpg',
          orderNum: 0,
        ),
        createMediaItem(
          key: 'img2',
          title: 'New Image',
          type: MediaType.image,
          url: 'http://example.com/img2.jpg',
          orderNum: 1,
        ),
      ];
      await db.syncMediaItems(snapshot1);

      // Second sync: identical payload
      await db.syncMediaItems(snapshot1);

      final result = await db.getMediaItemDataList();
      expect(result.length, 2);
      expect(result[0].title, 'Updated');
      expect(result[1].key, 'img2');
    });
  });

  group('syncMediaItems - URL as sync anchor', () {
    test('URL change triggers delete + insert semantics', () async {
      // Insert initial data
      await db.createMediaItems(createMediaItem(
        key: 'img1',
        title: 'Image 1',
        type: MediaType.image,
        url: 'http://example.com/old.jpg',
        orderNum: 0,
      ));

      // Sync with changed URL (same key but different URL)
      final snapshot = [
        createMediaItem(
          key: 'img1',
          title: 'Image 1',
          type: MediaType.image,
          url: 'http://example.com/new.jpg',
          orderNum: 0,
        ),
      ];

      await db.syncMediaItems(snapshot);

      final result = await db.getMediaItemDataList();
      // Old URL is deleted, new URL is inserted (treated as new item)
      expect(result.length, 1);
      expect(result[0].url, 'http://example.com/new.jpg');
    });
  });

  test('syncMediaItems inserts updates deletes and preserves ordered reads', () async {
    await db.createMediaItems(createMediaItem(
      key: 'stale',
      title: 'Stale Item',
      type: MediaType.image,
      url: 'http://example.com/stale.jpg',
      orderNum: 9,
    ));

    await db.createMediaItems(createMediaItem(
      key: 'update-me',
      title: 'Original Title',
      type: MediaType.image,
      url: 'http://example.com/shared.jpg',
      orderNum: 4,
    ));

    await db.syncMediaItems([
      createMediaItem(
        key: 'img-b',
        title: 'Second Ordered Item',
        type: MediaType.video,
        url: 'http://example.com/ordered-b.mp4',
        orderNum: 2,
      ),
      createMediaItem(
        key: 'img-a',
        title: 'Updated Title',
        type: MediaType.image,
        url: 'http://example.com/shared.jpg',
        orderNum: 1,
      ),
    ]);

    final result = await db.getMediaItemDataList();

    expect(result.map((item) => item.key).toList(), ['img-a', 'img-b']);
    expect(result[0].title, 'Updated Title');
    expect(result[0].url, 'http://example.com/shared.jpg');
    expect(result[1].url, 'http://example.com/ordered-b.mp4');
  });
}
