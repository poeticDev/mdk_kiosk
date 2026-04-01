import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdk_kiosk/header/component/message_container.dart';
import 'package:mdk_kiosk/header/model/message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MessageContainer auto-scroll behavior', () {
    // Helper to create a Message
    Message createMessage(String content) {
      return Message(
        key: 'test-key',
        until: DateTime.now().add(const Duration(hours: 1)),
        type: MessageType.normal,
        content: content,
      );
    }

    // Helper to pump MessageContainer with fixed constraints
    // Note: MessageContainer has internal structure:
    // - SizedBox(width: height * 0.9) for icon space
    // - Expanded for text
    // - Padding: 16.0 horizontal
    // So we need width > (height * 0.9 + padding * 2 + text_width)
    Future<void> pumpMessageContainer(
      WidgetTester tester, {
      required Message message,
      required double width,
      required double height,
      bool isFading = false,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              height: height,
              child: MessageContainer(
                height: height,
                padding: 16.0,
                fontSize: 24.0,
                messageData: message,
                isFading: isFading,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('(a) short message does not scroll', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a short message that fits within container
      final shortMessage = createMessage('Hi');

      // Act: Pump widget with enough width to fit the message
      // Using larger width to accommodate internal structure
      await pumpMessageContainer(
        tester,
        message: shortMessage,
        width: 400.0,
        height: 80.0,
      );

      // Wait for post-frame callback
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));

      // Assert: Find ScrollController and verify no scroll happened
      final scrollableView = find.byType(SingleChildScrollView);
      expect(scrollableView, findsOneWidget);

      final scrollController = tester
          .widget<SingleChildScrollView>(scrollableView)
          .controller;
      expect(scrollController, isNotNull);
      expect(scrollController!.offset, equals(0.0));
      expect(scrollController.position.maxScrollExtent, equals(0.0));
    });

    testWidgets('(b) long message starts at 0.0 and scrolls after delay', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a long message that exceeds container width
      final longMessage = createMessage(
        'This is a very long message that will definitely overflow the container width and require scrolling to see the full content',
      );

      // Act: Pump widget with narrow width to force overflow
      // Using width that allows text area to be small enough for overflow
      // height * 0.9 = 72 for icon, remaining ~28 for text area
      // With padding 16*2=32, we need width that makes text overflow
      await pumpMessageContainer(
        tester,
        message: longMessage,
        width: 200.0,
        height: 80.0,
      );

      // Wait for post-frame callback
      await tester.pump();

      // Find ScrollController
      final scrollableView = find.byType(SingleChildScrollView);
      final scrollController = tester
          .widget<SingleChildScrollView>(scrollableView)
          .controller;
      expect(scrollController, isNotNull);

      // Assert: Initially at 0.0
      expect(scrollController!.offset, equals(0.0));

      // Assert: maxScrollExtent > 0 (overflow exists)
      final maxScroll = scrollController.position.maxScrollExtent;
      expect(maxScroll, greaterThan(0.0));

      // Wait for 3-second delay (but not full scroll duration)
      await tester.pump(const Duration(seconds: 3));

      // Assert: Still at 0.0 after delay (scroll hasn't started yet)
      expect(scrollController.offset, equals(0.0));

      // Pump for scroll animation to progress
      await tester.pump(const Duration(seconds: 2));

      // Assert: Scroll has started (offset > 0)
      expect(scrollController.offset, greaterThan(0.0));
    });

    testWidgets(
      '(c) switching from long message A to long message B resets scroll to 0.0 and restarts',
      (WidgetTester tester) async {
        // Arrange: Create two different long messages
        final longMessageA = createMessage(
          'Long message A: This is the first long message that will overflow the container',
        );
        final longMessageB = createMessage(
          'Long message B: This is the second long message that will also overflow',
        );

        // Act: Pump with first message
        await pumpMessageContainer(
          tester,
          message: longMessageA,
          width: 200.0,
          height: 80.0,
        );

        await tester.pump();

        // Find ScrollController
        final scrollableView = find.byType(SingleChildScrollView);
        final scrollController = tester
            .widget<SingleChildScrollView>(scrollableView)
            .controller;
        expect(scrollController, isNotNull);

        // Wait for 3-second delay + some scroll progress
        await tester.pump(const Duration(seconds: 3));
        await tester.pump(const Duration(seconds: 2));

        // Assert: Scroll has started for message A
        final offsetAfterScroll = scrollController!.offset;
        expect(offsetAfterScroll, greaterThan(0.0));

        // Act: Switch to message B
        await pumpMessageContainer(
          tester,
          message: longMessageB,
          width: 200.0,
          height: 80.0,
        );

        await tester.pump();

        // Assert: Scroll position reset to 0.0
        expect(scrollController.offset, equals(0.0));

        // Wait for 3-second delay again
        await tester.pump(const Duration(seconds: 3));

        // Assert: Still at 0.0 after delay
        expect(scrollController.offset, equals(0.0));

        // Pump for scroll animation to progress
        await tester.pump(const Duration(seconds: 2));

        // Assert: Scroll has started for message B
        expect(scrollController.offset, greaterThan(0.0));
      },
    );

    testWidgets('(d) no exception after widget dispose', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a long message
      final longMessage = createMessage(
        'Long message for dispose test: This message will overflow the container',
      );

      // Act: Pump widget
      await pumpMessageContainer(
        tester,
        message: longMessage,
        width: 200.0,
        height: 80.0,
      );

      await tester.pump();

      // Find ScrollController
      final scrollableView = find.byType(SingleChildScrollView);
      final scrollController = tester
          .widget<SingleChildScrollView>(scrollableView)
          .controller;
      expect(scrollController, isNotNull);

      // Start scroll process
      await tester.pump(const Duration(seconds: 3));

      // Act: Dispose widget by pumping a different widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      // Assert: No exception thrown during dispose
      // The test will fail if any exception is thrown
      expect(scrollController!.hasClients, isFalse);

      // Wait additional time to ensure no pending callbacks cause issues
      await tester.pump(const Duration(seconds: 5));

      // If we reach here without exceptions, the test passes
      expect(true, isTrue);
    });

    // Constraint-only regression tests: verify behavior recalculation
    // when ONLY width constraint changes (same message content)
    group('constraint-only regression tests', () {
      // A short message that fits in wide width (1200px) but overflows in narrow (200px)
      // Available text width at 1200px: 1200 - 72 (icon) - 32 (padding) = 1096px
      // Available text width at 200px: 200 - 72 - 32 = 96px
      final constraintTestMessage = createMessage('Hello World');

      testWidgets('(e) wide→narrow: non-overflow becomes overflow, scroll required', (
        WidgetTester tester,
      ) async {
        // Act: Start with wide container - message should fit (no overflow)
        await pumpMessageContainer(
          tester,
          message: constraintTestMessage, // SAME content throughout
          width: 1200.0, // Wide constraint - message fits
          height: 80.0,
        );

        await tester.pump();

        // Find ScrollController
        final scrollableView = find.byType(SingleChildScrollView);
        final scrollController = tester
            .widget<SingleChildScrollView>(scrollableView)
            .controller;
        expect(scrollController, isNotNull);

        // Assert: In wide container, no overflow (maxScrollExtent = 0)
        expect(scrollController!.position.maxScrollExtent, equals(0.0));
        expect(scrollController.offset, equals(0.0));

        // Act: Constraint-only change - narrow the width (SAME message, only width changes!)
        await pumpMessageContainer(
          tester,
          message:
              constraintTestMessage, // SAME content, only width constraint changes
          width: 200.0, // Narrow constraint - message now overflows
          height: 80.0,
        );

        await tester.pump();

        // Assert: Overflow is now detected (maxScrollExtent > 0)
        // This proves: constraint change ALONE triggers overflow behavior recalculation
        expect(scrollController.position.maxScrollExtent, greaterThan(0.0));
        expect(scrollController.offset, equals(0.0));

        // Wait for scroll delay and verify scroll starts
        await tester.pump(const Duration(seconds: 3));
        await tester.pump(const Duration(seconds: 1));

        // Assert: Auto-scroll started due to newly detected overflow
        expect(scrollController.offset, greaterThan(0.0));
      });

      testWidgets('(f) narrow→wide: overflow resolved, scroll stops', (
        WidgetTester tester,
      ) async {
        // Act: Start with narrow container - message overflows
        await pumpMessageContainer(
          tester,
          message: constraintTestMessage, // SAME content throughout
          width: 200.0, // Narrow constraint - message overflows
          height: 80.0,
        );

        await tester.pump();

        // Find ScrollController
        final scrollableView = find.byType(SingleChildScrollView);
        final scrollController = tester
            .widget<SingleChildScrollView>(scrollableView)
            .controller;
        expect(scrollController, isNotNull);

        // Assert: In narrow container, overflow exists
        expect(scrollController!.position.maxScrollExtent, greaterThan(0.0));

        // Wait for scroll to start and progress
        await tester.pump(const Duration(seconds: 3));
        await tester.pump(const Duration(seconds: 2));

        // Assert: Scroll has progressed
        final offsetDuringScroll = scrollController.offset;
        expect(offsetDuringScroll, greaterThan(0.0));

        // Act: Constraint-only change - widen the container (SAME message, only width changes!)
        await pumpMessageContainer(
          tester,
          message:
              constraintTestMessage, // SAME content, only width constraint changes
          width: 1200.0, // Wide constraint - overflow now resolved
          height: 80.0,
        );

        await tester.pump();

        // Assert: Overflow is now resolved (maxScrollExtent = 0)
        // This proves: constraint change ALONE triggers overflow behavior recalculation
        expect(scrollController.position.maxScrollExtent, equals(0.0));

        // Assert: Scroll position reset to 0 when overflow resolved
        expect(scrollController.offset, equals(0.0));
      });
    });
  });
}
