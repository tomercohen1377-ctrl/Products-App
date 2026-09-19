import 'package:design_system/design_system.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hosts a deck whose parent removes swiped items, like a real screen.
class _Host extends StatefulWidget {
  const _Host({
    required this.controller,
    required this.log,
    this.count = 8,
    this.removeSwiped = true,
    this.onEndReached,
    this.onTap,
    this.withOverlays = false,
    this.onBuild,
  });

  final SwipeDeckController controller;
  final List<String> log;
  final int count;
  final bool removeSwiped;
  final VoidCallback? onEndReached;
  final void Function(int item)? onTap;
  final bool withOverlays;
  final VoidCallback? onBuild;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late List<int> items = List<int>.generate(widget.count, (i) => i + 1);

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 300,
      height: 400,
      child: SwipeDeck<int>(
        items: items,
        keyOf: (item) => item,
        controller: widget.controller,
        config: const SwipeDeckConfig(hapticFeedback: false),
        onEndReached: widget.onEndReached,
        onTap: widget.onTap,
        leftActionLabel: 'Skip',
        rightActionLabel: 'Like',
        leftOverlay: widget.withOverlays ? const Text('SKIP') : null,
        rightOverlay: widget.withOverlays ? const Text('LIKE') : null,
        itemBuilder: (context, item) {
          widget.onBuild?.call();
          return ColoredBox(
            key: ValueKey('card-$item'),
            color: Colors.primaries[item % Colors.primaries.length],
            child: Center(child: Text('Card $item')),
          );
        },
        onSwiped: (item, direction) {
          widget.log.add('$item:${direction.name}');
          if (widget.removeSwiped) {
            setState(() => items = items.where((i) => i != item).toList());
          }
        },
      ),
    ),
  );
}

void main() {
  late SwipeDeckController controller;
  late List<String> log;

  setUp(() {
    controller = SwipeDeckController();
    log = [];
  });

  Future<void> pumpDeck(WidgetTester tester, _Host host) async {
    await tester.pumpApp(host);
    await tester.pump();
  }

  Finder card(int item) => find.byKey(ValueKey('card-$item'));

  test('config asserts a deck shows at least one card', () {
    expect(() => SwipeDeckConfig(visibleCards: 0), throwsAssertionError);
  });

  testWidgets('mounts only the top visibleCards cards', (tester) async {
    await pumpDeck(tester, _Host(controller: controller, log: log));

    expect(card(1), findsOneWidget);
    expect(card(2), findsOneWidget);
    expect(card(3), findsOneWidget);
    expect(card(4), findsNothing);
  });

  testWidgets('an empty deck renders nothing', (tester) async {
    await pumpDeck(tester, _Host(controller: controller, log: log, count: 0));

    expect(find.byType(RepaintBoundary), findsWidgets);
    expect(card(1), findsNothing);
  });

  group('drag', () {
    testWidgets('the top card follows the finger and tilts', (tester) async {
      await pumpDeck(tester, _Host(controller: controller, log: log));
      final rest = tester.getCenter(card(1));

      final gesture = await tester.startGesture(rest);
      await gesture.moveBy(const Offset(60, 30));
      await tester.pump();

      final moved = tester.getCenter(card(1));
      expect(moved.dx - rest.dx, closeTo(60, 1));
      expect(moved.dy - rest.dy, closeTo(30, 1));

      final transform = tester.widget<Transform>(
        find.ancestor(of: card(1), matching: find.byType(Transform)).first,
      );
      expect(
        transform.transform.getRotation().entry(0, 1),
        isNot(0),
        reason: 'the card is tilted',
      );
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('grabbing the card below its middle tilts it the other way', (
      tester,
    ) async {
      await pumpDeck(tester, _Host(controller: controller, log: log));
      final rest = tester.getCenter(card(1));

      final top = await tester.startGesture(rest - const Offset(0, 100));
      await top.moveBy(const Offset(80, 0));
      await tester.pump();
      final tiltTop = tester
          .widget<Transform>(
            find.ancestor(of: card(1), matching: find.byType(Transform)).first,
          )
          .transform
          .getRotation()
          .entry(1, 0);
      await top.cancel();
      await tester.pumpAndSettle();

      final bottom = await tester.startGesture(rest + const Offset(0, 100));
      await bottom.moveBy(const Offset(80, 0));
      await tester.pump();
      final tiltBottom = tester
          .widget<Transform>(
            find.ancestor(of: card(1), matching: find.byType(Transform)).first,
          )
          .transform
          .getRotation()
          .entry(1, 0);
      await bottom.cancel();
      await tester.pumpAndSettle();

      expect(tiltTop.sign, isNot(tiltBottom.sign));
    });

    testWidgets('the pile behind advances with the drag', (tester) async {
      await pumpDeck(tester, _Host(controller: controller, log: log));
      final frontSlot = tester.getTopLeft(card(1)).dx;
      final restInset = tester.getTopLeft(card(2)).dx;
      expect(
        restInset,
        greaterThan(frontSlot + 1),
        reason: 'the second card is smaller, so inset',
      );

      final gesture = await tester.startGesture(tester.getCenter(card(1)));
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump();
      final partway = tester.getTopLeft(card(2)).dx;
      await gesture.moveBy(const Offset(150, 0));
      await tester.pump();
      final full = tester.getTopLeft(card(2)).dx;

      expect(partway, lessThan(restInset));
      expect(full, lessThan(partway));
      expect(
        full,
        closeTo(frontSlot, 1.5),
        reason: 'in the front slot at the threshold',
      );
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('dragging does not rebuild the cards', (tester) async {
      var builds = 0;
      await pumpDeck(
        tester,
        _Host(controller: controller, log: log, onBuild: () => builds++),
      );
      final built = builds;

      final gesture = await tester.startGesture(tester.getCenter(card(1)));
      for (var i = 0; i < 30; i++) {
        await gesture.moveBy(const Offset(4, 1));
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(
        builds,
        built,
        reason: 'per frame only the transform changes, not the card content',
      );
      await gesture.cancel();
      await tester.pumpAndSettle();
    });

    testWidgets('a stamp fades in toward the side being dragged', (
      tester,
    ) async {
      await pumpDeck(
        tester,
        _Host(controller: controller, log: log, withOverlays: true),
      );
      expect(find.text('LIKE'), findsNothing);

      final gesture = await tester.startGesture(tester.getCenter(card(1)));
      await gesture.moveBy(const Offset(70, 0));
      await tester.pump();
      expect(find.text('LIKE'), findsOneWidget);
      expect(find.text('SKIP'), findsNothing);

      await gesture.moveBy(const Offset(-200, 0));
      await tester.pump();
      expect(find.text('SKIP'), findsOneWidget);
      expect(find.text('LIKE'), findsNothing);
      await gesture.cancel();
      await tester.pumpAndSettle();
    });
  });

  group('release', () {
    testWidgets(
      'past the threshold the card is thrown and the next one is on top',
      (tester) async {
        await pumpDeck(tester, _Host(controller: controller, log: log));
        final restCenter = tester.getCenter(card(2));

        final gesture = await tester.startGesture(tester.getCenter(card(1)));
        await gesture.moveBy(const Offset(200, 0));
        await gesture.up();
        await tester.pumpAndSettle();

        expect(log, ['1:right']);
        expect(card(1), findsNothing);
        expect(tester.getCenter(card(2)).dx, closeTo(restCenter.dx, 0.5));
        expect(
          tester.getTopLeft(card(2)).dx,
          closeTo(tester.getTopLeft(card(2)).dx, 0.5),
        );
        final transform = tester.widget<Transform>(
          find.ancestor(of: card(2), matching: find.byType(Transform)).first,
        );
        expect(
          transform.transform.getTranslation().x,
          closeTo(0, 0.5),
          reason: 'the new top card starts at rest',
        );
      },
    );

    testWidgets('left is left', (tester) async {
      await pumpDeck(tester, _Host(controller: controller, log: log));

      final gesture = await tester.startGesture(tester.getCenter(card(1)));
      await gesture.moveBy(const Offset(-200, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(log, ['1:left']);
    });

    testWidgets('a quick fling throws a card dragged only a little', (
      tester,
    ) async {
      await pumpDeck(tester, _Host(controller: controller, log: log));

      await tester.fling(card(1), const Offset(-70, 0), 2200);
      await tester.pumpAndSettle();

      expect(log, ['1:left']);
    });

    testWidgets('a short slow drag snaps back and throws nothing', (
      tester,
    ) async {
      await pumpDeck(tester, _Host(controller: controller, log: log));
      final rest = tester.getCenter(card(1));

      final gesture = await tester.startGesture(rest);
      await gesture.moveBy(const Offset(40, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(log, isEmpty);
      expect(tester.getCenter(card(1)).dx, closeTo(rest.dx, 0.5));
      expect(card(1), findsOneWidget);
    });

    testWidgets('snap-back overshoots the centre before settling', (
      tester,
    ) async {
      await pumpDeck(tester, _Host(controller: controller, log: log));
      final rest = tester.getCenter(card(1)).dx;

      final gesture = await tester.startGesture(tester.getCenter(card(1)));
      await gesture.moveBy(const Offset(70, 0));
      await tester.pump();
      await gesture.up();

      var lowest = tester.getCenter(card(1)).dx - rest;
      for (var frame = 0; frame < 150; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        lowest = lowest < tester.getCenter(card(1)).dx - rest
            ? lowest
            : tester.getCenter(card(1)).dx - rest;
      }

      expect(lowest, lessThan(-0.5), reason: 'bounces past the centre');
      expect(
        tester.getCenter(card(1)).dx,
        closeTo(rest, 0.5),
        reason: 'then settles',
      );
    });

    testWidgets(
      'a card can be grabbed again while it is still springing back',
      (tester) async {
        await pumpDeck(tester, _Host(controller: controller, log: log));
        final gesture = await tester.startGesture(tester.getCenter(card(1)));
        await gesture.moveBy(const Offset(60, 0));
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 60));

        final again = await tester.startGesture(tester.getCenter(card(1)));
        await again.moveBy(const Offset(200, 0));
        await again.up();
        await tester.pumpAndSettle();

        expect(log, ['1:right']);
      },
    );
  });

  group('controller', () {
    testWidgets('swipe throws the top card the same way a finger does', (
      tester,
    ) async {
      await pumpDeck(tester, _Host(controller: controller, log: log));

      controller.swipe(SwipeDirection.right);
      await tester.pumpAndSettle();
      controller.swipe(SwipeDirection.left);
      await tester.pumpAndSettle();

      expect(log, ['1:right', '2:left']);
    });

    testWidgets('is busy while a card moves, and ignores a second swipe', (
      tester,
    ) async {
      await pumpDeck(tester, _Host(controller: controller, log: log));
      expect(controller.isBusy, isFalse);

      controller.swipe(SwipeDirection.right);
      controller.swipe(SwipeDirection.right);
      await tester.pump(const Duration(milliseconds: 30));
      expect(controller.isBusy, isTrue);
      await tester.pumpAndSettle();

      expect(log, ['1:right']);
      expect(controller.isBusy, isFalse);
    });

    testWidgets('does nothing on an empty deck', (tester) async {
      await pumpDeck(tester, _Host(controller: controller, log: log, count: 0));

      controller.swipe(SwipeDirection.right);
      await tester.pumpAndSettle();

      expect(log, isEmpty);
    });
  });

  group('parent interaction', () {
    testWidgets('a card the parent does not remove comes back', (tester) async {
      await pumpDeck(
        tester,
        _Host(controller: controller, log: log, removeSwiped: false),
      );
      final rest = tester.getCenter(card(1));

      controller.swipe(SwipeDirection.right);
      await tester.pumpAndSettle();
      await tester.pump();
      await tester.pump();

      expect(log, ['1:right']);
      expect(tester.getCenter(card(1)).dx, closeTo(rest.dx, 0.5));
    });

    testWidgets('tapping the top card reports it', (tester) async {
      final tapped = <int>[];
      await pumpDeck(
        tester,
        _Host(controller: controller, log: log, onTap: tapped.add),
      );

      await tester.tap(card(1));

      expect(tapped, [1]);
    });

    testWidgets(
      'a card tracks the finger exactly even when it can also be tapped',
      (tester) async {
        await pumpDeck(
          tester,
          _Host(controller: controller, log: log, onTap: (_) {}),
        );
        final rest = tester.getCenter(card(1));

        final gesture = await tester.startGesture(rest);
        await gesture.moveBy(const Offset(90, 0));
        await tester.pump();

        expect(
          tester.getCenter(card(1)).dx - rest.dx,
          closeTo(90, 1),
          reason: 'no touch-slop lag at the start of the drag',
        );
        await gesture.cancel();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('a drag is not a tap', (tester) async {
      final tapped = <int>[];
      await pumpDeck(
        tester,
        _Host(controller: controller, log: log, onTap: tapped.add),
      );

      final gesture = await tester.startGesture(tester.getCenter(card(1)));
      await gesture.moveBy(const Offset(30, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tapped, isEmpty);
    });

    testWidgets('asks for more when few cards remain, once per count', (
      tester,
    ) async {
      var calls = 0;
      await pumpDeck(
        tester,
        _Host(
          controller: controller,
          log: log,
          count: 7,
          onEndReached: () => calls++,
        ),
      );
      expect(calls, 0, reason: '7 cards left is above the threshold of 5');

      controller.swipe(SwipeDirection.right);
      await tester.pumpAndSettle();
      controller.swipe(SwipeDirection.right);
      await tester.pumpAndSettle();
      expect(calls, 1, reason: '5 cards left');

      await tester.pump();
      await tester.pump();
      expect(calls, 1, reason: 'not repeated while the count is unchanged');

      controller.swipe(SwipeDirection.right);
      await tester.pumpAndSettle();
      expect(calls, 2, reason: '4 cards left');
    });

    testWidgets('asks for more immediately when it starts short', (
      tester,
    ) async {
      var calls = 0;
      await pumpDeck(
        tester,
        _Host(
          controller: controller,
          log: log,
          count: 3,
          onEndReached: () => calls++,
        ),
      );

      expect(calls, 1);
    });
  });

  group('accessibility and platform', () {
    testWidgets('exposes throw-left and throw-right as screen-reader actions', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpDeck(tester, _Host(controller: controller, log: log));

      final data = tester.getSemantics(card(1)).getSemanticsData();
      expect(data.customSemanticsActionIds, hasLength(2));
      handle.dispose();
    });

    testWidgets('with reduced motion a swipe completes at once, without tilt', (
      tester,
    ) async {
      await tester.pumpApp(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _Host(controller: controller, log: log),
        ),
      );
      await tester.pump();

      controller.swipe(SwipeDirection.right);
      await tester.pump();

      expect(log, ['1:right']);
    });

    testWidgets('works in a right-to-left locale, right still means right', (
      tester,
    ) async {
      await tester.pumpApp(
        _Host(controller: controller, log: log),
        locale: const Locale('he'),
      );
      await tester.pump();

      final gesture = await tester.startGesture(tester.getCenter(card(1)));
      await gesture.moveBy(const Offset(200, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(log, ['1:right']);
    });

    testWidgets('the demo preview builds', (tester) async {
      await tester.pumpApp(SingleChildScrollView(child: swipeDeckPreview()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
