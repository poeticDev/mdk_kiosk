import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';
import 'package:mdk_kiosk/common/util/network/mqtt_manager.dart';
import 'package:mdk_kiosk/multimedia/util/media_controller.dart';

/// Captured dispatch calls for assertion
final capturedDispatches = <Map<String, dynamic>>[];

Future<void> waitForCondition(Future<bool> Function() condition) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    if (await condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  fail('Condition not reached within timeout');
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    GetIt.I.registerSingleton<AppDatabase>(db);
    capturedDispatches.clear();
    dispatchObserver = null;
  });

  tearDown(() async {
    dispatchObserver = null;
    capturedDispatches.clear();

    if (GetIt.I.isRegistered<AppDatabase>()) {
      await GetIt.I.reset();
    }

    await db.close();
  });

  group('mqttDataHandler() dispatch assertions', () {
    testWidgets('mqttDataHandler routes mediaItem payloads through a successful mediaControllerProvider notifier path', (tester) async {
      ProviderContainer? providerContainer;

      dispatchObserver = (notifierName, dataList) {
        capturedDispatches.add({'notifier': notifierName, 'dataList': dataList});
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Consumer(
                  builder: (context, ref, child) {
                    providerContainer ??= ProviderScope.containerOf(context);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final payload = jsonEncode([
                        {'key': 'mediaItem_001', 'title': 'Test Media', 'type': 'image', 'url': 'http://ex.com/m.jpg', 'from': 'gDrive', 'orderNum': 0},
                      ]);
                      mqttDataHandler(ref, payload);
                    });
                    return const SizedBox(key: Key('root'));
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await waitForCondition(() async {
        final items = await db.getMediaItemDataList();
        return items.length == 1 && items.first.key == 'mediaItem_001';
      });

      // Observer seam still proves routing.
      expect(capturedDispatches.length, 1);
      expect(capturedDispatches[0]['notifier'], 'mediaController');
      expect(capturedDispatches[0]['dataList'], isA<List>());
      expect((capturedDispatches[0]['dataList'] as List).length, 1);
      expect((capturedDispatches[0]['dataList'] as List).first['key'], 'mediaItem_001');

      // Real assertion: the provider-backed media path completed successfully.
      final persistedItems = await db.getMediaItemDataList();
      expect(persistedItems.length, 1);
      expect(persistedItems.first.title, 'Test Media');

      final mediaState = providerContainer!.read(mediaControllerProvider);
      expect(mediaState.valueOrNull, isNotNull);
      expect(mediaState.valueOrNull!.single.key, 'mediaItem_001');
    });

    testWidgets('message-only payload dispatches to messageController', (tester) async {
      dispatchObserver = (notifierName, dataList) {
        capturedDispatches.add({'notifier': notifierName, 'dataList': dataList});
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Consumer(
                  builder: (context, ref, child) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final payload = jsonEncode([
                        {'key': 'messageItem_001', 'content': 'Test', 'type': 'normal', 'until': '2025-01-01T00:00:00Z', 'lastUpdated': '2025-01-01T00:00:00Z'},
                      ]);
                      mqttDataHandler(ref, payload);
                    });
                    return const SizedBox(key: Key('root'));
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // REAL ASSERTION: verify messageController was dispatched exactly once
      expect(capturedDispatches.length, 1);
      expect(capturedDispatches[0]['notifier'], 'messageController');
      expect(capturedDispatches[0]['dataList'], isA<List>());
      expect((capturedDispatches[0]['dataList'] as List).length, 1);
      expect((capturedDispatches[0]['dataList'] as List).first['key'], 'messageItem_001');
    });

    testWidgets('mqttDataHandler dispatches mixed payload rows to the correct notifiers', (tester) async {
      ProviderContainer? providerContainer;

      dispatchObserver = (notifierName, dataList) {
        capturedDispatches.add({'notifier': notifierName, 'dataList': dataList});
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Consumer(
                  builder: (context, ref, child) {
                    providerContainer ??= ProviderScope.containerOf(context);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final payload = jsonEncode([
                        {'key': 'mediaItem_m1', 'title': 'Media', 'type': 'image', 'url': 'http://ex.com/m.jpg', 'from': 'gDrive', 'orderNum': 0},
                        {'key': 'messageItem_msg1', 'content': 'Test', 'type': 'normal', 'until': '2025-01-01T00:00:00Z', 'lastUpdated': '2025-01-01T00:00:00Z'},
                      ]);
                      mqttDataHandler(ref, payload);
                    });
                    return const SizedBox(key: Key('root'));
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await waitForCondition(() async {
        final items = await db.getMediaItemDataList();
        return items.length == 1 && items.first.key == 'mediaItem_m1';
      });

      // REAL ASSERTION: verify BOTH notifiers were called
      expect(capturedDispatches.length, 2);
      
      // Find media dispatch
      final mediaDispatch = capturedDispatches.firstWhere((d) => d['notifier'] == 'mediaController');
      expect(mediaDispatch['dataList'], isA<List>());
      expect((mediaDispatch['dataList'] as List).length, 1);
      expect((mediaDispatch['dataList'] as List).first['key'], 'mediaItem_m1');
      
      // Find message dispatch
      final messageDispatch = capturedDispatches.firstWhere((d) => d['notifier'] == 'messageController');
      expect(messageDispatch['dataList'], isA<List>());
      expect((messageDispatch['dataList'] as List).length, 1);
      expect((messageDispatch['dataList'] as List).first['key'], 'messageItem_msg1');

      final mediaState = providerContainer!.read(mediaControllerProvider);
      expect(mediaState.valueOrNull, isNotNull);
      expect(mediaState.valueOrNull!.single.title, 'Media');
    });

    testWidgets('malformed rows without key are ignored - not dispatched', (tester) async {
      ProviderContainer? providerContainer;

      dispatchObserver = (notifierName, dataList) {
        capturedDispatches.add({'notifier': notifierName, 'dataList': dataList});
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Consumer(
                  builder: (context, ref, child) {
                    providerContainer ??= ProviderScope.containerOf(context);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final payload = jsonEncode([
                        {'title': 'No key field'},  // malformed - no 'key'
                        {'key': 'mediaItem_001', 'title': 'Valid', 'type': 'image', 'url': 'http://ex.com/v.jpg', 'from': 'gDrive', 'orderNum': 0},
                      ]);
                      mqttDataHandler(ref, payload);
                    });
                    return const SizedBox(key: Key('root'));
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await waitForCondition(() async {
        final items = await db.getMediaItemDataList();
        return items.length == 1 && items.first.key == 'mediaItem_001';
      });

      // REAL ASSERTION: verify ONLY valid row dispatched, malformed ignored
      expect(capturedDispatches.length, 1);
      expect(capturedDispatches[0]['notifier'], 'mediaController');
      final dataList = capturedDispatches[0]['dataList'] as List;
      expect(dataList.length, 1);
      expect(dataList.first['key'], 'mediaItem_001');

      final mediaState = providerContainer!.read(mediaControllerProvider);
      expect(mediaState.valueOrNull, isNotNull);
      expect(mediaState.valueOrNull!.single.title, 'Valid');
    });

    testWidgets('mqttDataHandler ignores malformed rows without invoking either notifier', (tester) async {
      dispatchObserver = (notifierName, dataList) {
        capturedDispatches.add({'notifier': notifierName, 'dataList': dataList});
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Consumer(
                  builder: (context, ref, child) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final payload = jsonEncode([
                        {'title': 'Bad 1'},
                        {'title': 'Bad 2'},
                      ]);
                      mqttDataHandler(ref, payload);
                    });
                    return const SizedBox(key: Key('root'));
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // REAL ASSERTION: verify NO dispatch for all-malformed payload
      expect(capturedDispatches.length, 0);
    });

    testWidgets('empty payload dispatches to NEITHER notifier', (tester) async {
      dispatchObserver = (notifierName, dataList) {
        capturedDispatches.add({'notifier': notifierName, 'dataList': dataList});
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Consumer(
                  builder: (context, ref, child) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final payload = jsonEncode([]);
                      mqttDataHandler(ref, payload);
                    });
                    return const SizedBox(key: Key('root'));
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // REAL ASSERTION: verify NO dispatch for empty payload
      expect(capturedDispatches.length, 0);
    });

    testWidgets('invalid JSON throws FormatException', (tester) async {
      FormatException? thrown;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Consumer(
                  builder: (context, ref, child) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      try {
                        mqttDataHandler(ref, '{ invalid');
                      } catch (e) {
                        thrown = e as FormatException;
                      }
                    });
                    return const SizedBox(key: Key('root'));
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(thrown, isNotNull);
    });
  });
}
