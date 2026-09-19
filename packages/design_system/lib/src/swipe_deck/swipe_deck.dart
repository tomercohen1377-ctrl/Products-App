import 'dart:async';
import 'dart:math' as math;

import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/swipe_deck/swipe_decider.dart';
import 'package:design_system/src/swipe_deck/swipe_deck_config.dart';
import 'package:design_system/src/swipe_deck/swipe_deck_controller.dart';
import 'package:design_system/src/swipe_deck/swipe_direction.dart';
import 'package:design_system/src/theme/theme_context.dart';
import 'package:design_system/src/tokens/ds_corner_radius.dart';
import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// A physics-driven deck of swipeable cards, built by hand (no package).
///
/// * **Drag**: the top card follows the finger and tilts with it, pivoting
///   the way it was grabbed.
/// * **Release**: [SwipeDecider] projects where the card is heading. A card
///   heading past the threshold is thrown off on a critically damped spring
///   carrying the release velocity; otherwise it snaps back on an
///   under-damped spring seeded with that velocity, so it overshoots and
///   settles.
/// * **Pile**: the cards behind advance continuously with the drag (scale
///   and offset interpolate toward the slot in front), so the pile reacts to
///   the finger rather than jumping when a card leaves.
///
/// The deck is controlled: it shows the first [SwipeDeckConfig.visibleCards]
/// of [items] and calls [onSwiped]; the parent removes the item. All feel is
/// in [SwipeDeckConfig].
///
/// **Performance**: cards are built once and cached; while a card moves, only
/// a `Transform` matrix changes (no rebuild, layout or repaint of the card),
/// and each card sits in a `RepaintBoundary`.
class SwipeDeck<T> extends StatefulWidget {
  const SwipeDeck({
    required this.items,
    required this.keyOf,
    required this.itemBuilder,
    required this.onSwiped,
    this.controller,
    this.config = SwipeDeckConfig.defaults,
    this.leftOverlay,
    this.rightOverlay,
    this.onTap,
    this.onEndReached,
    this.endReachedThreshold = 5,
    this.leftActionLabel,
    this.rightActionLabel,
    super.key,
  });

  final List<T> items;

  /// A stable identity per item, so cards keep their state as the pile shifts.
  final Object Function(T item) keyOf;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final void Function(T item, SwipeDirection direction) onSwiped;
  final SwipeDeckController? controller;
  final SwipeDeckConfig config;

  /// Faded in over the top card as it is dragged that way (e.g. "SKIP").
  final Widget? leftOverlay;
  final Widget? rightOverlay;

  /// The top card was tapped (not dragged).
  final void Function(T item)? onTap;

  /// Called when [endReachedThreshold] or fewer items remain, to load more.
  final VoidCallback? onEndReached;
  final int endReachedThreshold;

  /// Screen-reader names for throwing the top card left / right.
  final String? leftActionLabel;
  final String? rightActionLabel;

  @override
  State<SwipeDeck<T>> createState() => _SwipeDeckState<T>();
}

class _SwipeDeckState<T> extends State<SwipeDeck<T>>
    with SingleTickerProviderStateMixin {
  /// The top card's offset from its resting place. The only thing that
  /// changes per frame; listeners rebuild just their `Transform`.
  final ValueNotifier<Offset> _drag = ValueNotifier<Offset>(Offset.zero);
  late final Ticker _ticker = createTicker(_onTick);

  _Motion? _motion;
  Size _size = Size.zero;
  bool _dragging = false;
  bool _pastThreshold = false;

  /// +1 when the card was grabbed above its middle, -1 below: it tilts the
  /// way a real card would pivot around the finger.
  double _grabSign = 1;
  Object? _topKey;
  int? _endReachedAtCount;

  SwipeDeckConfig get _config => widget.config;
  bool get _busy => _dragging || _motion != null;

  @override
  void initState() {
    super.initState();
    _topKey = _currentTopKey;
    _attach(widget.controller);
    _checkEndReached();
  }

  @override
  void didUpdateWidget(SwipeDeck<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      _attach(widget.controller);
    }
    final topKey = _currentTopKey;
    if (topKey != _topKey) {
      // A new top card: it starts at rest, whatever the old one was doing.
      _stopMotion();
      _dragging = false;
      _pastThreshold = false;
      _drag.value = Offset.zero;
      _topKey = topKey;
    }
    _checkEndReached();
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _ticker.dispose();
    _drag.dispose();
    super.dispose();
  }

  Object? get _currentTopKey =>
      widget.items.isEmpty ? null : widget.keyOf(widget.items.first);

  void _attach(SwipeDeckController? controller) =>
      controller?.attach(swipe: _swipeProgrammatically, isBusy: () => _busy);

  void _checkEndReached() {
    final onEndReached = widget.onEndReached;
    if (onEndReached == null) return;
    final count = widget.items.length;
    if (count > widget.endReachedThreshold) {
      _endReachedAtCount = null;
      return;
    }
    if (_endReachedAtCount == count) return;
    _endReachedAtCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) onEndReached();
    });
  }

  // ---- gestures ----

  void _onPanStart(DragStartDetails details) {
    if (_motion?.isExit ?? false) return;
    _stopMotion();
    _dragging = true;
    _grabSign = details.localPosition.dy < _cardHeight / 2 ? 1 : -1;
    _pastThreshold = _isPastThreshold(_drag.value);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_dragging) return;
    _drag.value += details.delta;
    final past = _isPastThreshold(_drag.value);
    if (past != _pastThreshold) {
      _pastThreshold = past;
      if (_config.hapticFeedback) unawaited(HapticFeedback.selectionClick());
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;
    final velocity = details.velocity.pixelsPerSecond;
    final outcome = SwipeDecider.decide(
      offset: _drag.value,
      velocity: velocity,
      width: _size.width,
      config: _config,
    );
    switch (outcome) {
      case SwipeCommit(:final direction):
        _throw(direction, velocity);
      case SwipeSnapBack():
        _snapBack(velocity);
    }
  }

  void _onPanCancel() {
    if (!_dragging) return;
    _dragging = false;
    _snapBack(Offset.zero);
  }

  bool _isPastThreshold(Offset offset) =>
      offset.dx.abs() >= SwipeDecider.thresholdFor(_size.width, _config);

  // ---- motion ----

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _swipeProgrammatically(SwipeDirection direction) {
    if (widget.items.isEmpty || _busy || _size.width <= 0) return;
    _grabSign = 1;
    // A gentle toss: sideways with a little lift.
    _throw(direction, Offset(direction.sign * 1400, -260));
  }

  void _snapBack(Offset velocity) {
    if (_reduceMotion) {
      _drag.value = Offset.zero;
      return;
    }
    final start = _drag.value;
    const tolerance = Tolerance(distance: 0.4, velocity: 8);
    final spring = _config.snapBackSpring;
    _run(
      _Motion(
        x: SpringSimulation(
          spring,
          start.dx,
          0,
          velocity.dx,
          tolerance: tolerance,
        ),
        y: SpringSimulation(
          spring,
          start.dy,
          0,
          velocity.dy,
          tolerance: tolerance,
        ),
        onDone: () => _drag.value = Offset.zero,
      ),
    );
  }

  void _throw(SwipeDirection direction, Offset velocity) {
    final item = widget.items.first;
    if (_config.hapticFeedback) unawaited(HapticFeedback.mediumImpact());
    if (_reduceMotion) {
      _complete(item, direction);
      return;
    }

    final start = _drag.value;
    final spring = _config.exitSpring;
    final along = math.max(
      velocity.dx * direction.sign,
      _config.minExitVelocity,
    );
    // Aim well past the edge; the motion is finished as soon as the card is
    // fully off-screen, well before the spring settles.
    final targetX = direction.sign * _size.width * 2;
    final targetY = start.dy + velocity.dy * 0.12;
    final offscreen = _size.width * 1.2;

    _run(
      _Motion(
        x: SpringSimulation(spring, start.dx, targetX, along * direction.sign),
        y: SpringSimulation(spring, start.dy, targetY, velocity.dy),
        isExit: true,
        isFinished: (offset) => offset.dx.abs() >= offscreen,
        onDone: () => _complete(item, direction),
      ),
    );
  }

  void _complete(T item, SwipeDirection direction) {
    final key = widget.keyOf(item);
    _motion = null;
    _pastThreshold = false;
    widget.onSwiped(item, direction);

    // The parent is expected to remove the item. If it did not, put the card
    // back rather than leave it off-screen. Two frames of grace cover a
    // parent that updates asynchronously (e.g. through a bloc).
    // Post-frame callbacks only run when a frame happens, so ask for one.
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {
      binding.addPostFrameCallback((_) {
        if (mounted && _currentTopKey == key && !_busy) {
          _drag.value = Offset.zero;
        }
      });
      binding.scheduleFrame();
    });
    binding.scheduleFrame();
  }

  void _run(_Motion motion) {
    _motion = motion;
    _ticker
      ..stop()
      ..start();
  }

  void _stopMotion() {
    _motion = null;
    if (_ticker.isActive) _ticker.stop();
  }

  void _onTick(Duration elapsed) {
    final motion = _motion;
    if (motion == null) return;
    final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final offset = Offset(motion.x.x(t), motion.y.x(t));
    _drag.value = offset;
    if (motion.isDone(t, offset)) {
      _ticker.stop();
      _motion = null;
      motion.onDone();
    }
  }

  // ---- layout ----

  double get _peek => _config.stackOffsetStep * (_config.visibleCards - 1);
  double get _cardHeight => math.max(0, _size.height - _peek);

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.expand();

    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        final visible = items.take(_config.visibleCards).toList();
        final cardSize = Size(_size.width, _cardHeight);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Back to front, keyed so each card keeps its state as the pile
            // shifts forward.
            for (var depth = visible.length - 1; depth >= 0; depth--)
              KeyedSubtree(
                key: ValueKey<Object>(widget.keyOf(visible[depth])),
                child: _buildCard(context, visible[depth], depth, cardSize),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, T item, int depth, Size cardSize) {
    final content = RepaintBoundary(
      child: SizedBox(
        width: cardSize.width,
        height: cardSize.height,
        child: widget.itemBuilder(context, item),
      ),
    );

    if (depth > 0) {
      return IgnorePointer(
        child: ValueListenableBuilder<Offset>(
          valueListenable: _drag,
          child: content,
          builder: (context, drag, child) =>
              _pileTransform(depth: depth, drag: drag, child: child!),
        ),
      );
    }

    final topCard = Stack(
      fit: StackFit.expand,
      children: [
        content,
        if (widget.leftOverlay != null || widget.rightOverlay != null)
          _Overlays(
            drag: _drag,
            threshold: SwipeDecider.thresholdFor(cardSize.width, _config),
            left: widget.leftOverlay,
            right: widget.rightOverlay,
          ),
      ],
    );

    return SizedBox(
      width: cardSize.width,
      height: cardSize.height,
      child: Semantics(
        customSemanticsActions: {
          if (widget.leftActionLabel != null)
            CustomSemanticsAction(label: widget.leftActionLabel!): () =>
                _swipeProgrammatically(SwipeDirection.left),
          if (widget.rightActionLabel != null)
            CustomSemanticsAction(label: widget.rightActionLabel!): () =>
                _swipeProgrammatically(SwipeDirection.right),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap == null || _motion != null
              ? null
              : () => widget.onTap!(item),
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onPanCancel: _onPanCancel,
          child: ValueListenableBuilder<Offset>(
            valueListenable: _drag,
            child: topCard,
            builder: (context, drag, child) =>
                _topTransform(drag: drag, child: child!),
          ),
        ),
      ),
    );
  }

  Widget _topTransform({required Offset drag, required Widget child}) {
    final tilt = _size.width == 0 || _reduceMotion
        ? 0.0
        : _config.maxRotation *
              (drag.dx / _size.width).clamp(-1.0, 1.0) *
              _grabSign;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.translationValues(
        drag.dx,
        drag.dy,
        0,
      ).multiplied(Matrix4.rotationZ(tilt)),
      child: child,
    );
  }

  /// A card [depth] places back in the pile. As the top card is dragged, the
  /// pile advances toward the slot in front of it.
  Widget _pileTransform({
    required int depth,
    required Offset drag,
    required Widget child,
  }) {
    final threshold = SwipeDecider.thresholdFor(_size.width, _config);
    final progress = threshold <= 0
        ? 0.0
        : (drag.dx.abs() / threshold).clamp(0.0, 1.0);
    final behind = _slot(depth);
    final ahead = _slot(depth - 1);
    final scale = _lerp(behind.scale, ahead.scale, progress);
    final dy = _lerp(behind.dy, ahead.dy, progress);
    return Transform(
      // Scaled about the bottom edge so cards behind peek out below.
      alignment: Alignment.bottomCenter,
      transform: Matrix4.translationValues(
        0,
        dy,
        0,
      ).multiplied(Matrix4.diagonal3Values(scale, scale, 1)),
      child: child,
    );
  }

  ({double scale, double dy}) _slot(int depth) => (
    scale: 1 - _config.stackScaleStep * depth,
    dy: _config.stackOffsetStep * depth,
  );

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

/// Stamps that fade in as the top card is dragged toward either side.
class _Overlays extends StatelessWidget {
  const _Overlays({
    required this.drag,
    required this.threshold,
    required this.left,
    required this.right,
  });

  final ValueListenable<Offset> drag;
  final double threshold;
  final Widget? left;
  final Widget? right;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ValueListenableBuilder<Offset>(
      valueListenable: drag,
      builder: (context, offset, _) {
        final progress = threshold <= 0
            ? 0.0
            : (offset.dx.abs() / threshold).clamp(0.0, 1.0);
        final towardRight = offset.dx > 0;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Physical placement on purpose: the stamp for a right swipe sits
            // on the left, where the card is leaving from, in any locale.
            if (right != null && towardRight && progress > 0)
              Positioned(
                top: DSSpacing.l,
                left: DSSpacing.l,
                child: Opacity(opacity: progress, child: right),
              ),
            if (left != null && !towardRight && progress > 0)
              Positioned(
                top: DSSpacing.l,
                right: DSSpacing.l,
                child: Opacity(opacity: progress, child: left),
              ),
          ],
        );
      },
    ),
  );
}

class _Motion {
  const _Motion({
    required this.x,
    required this.y,
    required this.onDone,
    this.isExit = false,
    this.isFinished,
  });

  final Simulation x;
  final Simulation y;
  final VoidCallback onDone;
  final bool isExit;

  /// Ends the motion early (e.g. once the card has left the screen).
  final bool Function(Offset offset)? isFinished;

  bool isDone(double t, Offset offset) =>
      (isFinished?.call(offset) ?? false) || (x.isDone(t) && y.isDone(t));
}

/// An interactive demo: drag, fling and release the cards in the previewer.
class _DemoDeck extends StatefulWidget {
  const _DemoDeck();

  @override
  State<_DemoDeck> createState() => _DemoDeckState();
}

class _DemoDeckState extends State<_DemoDeck> {
  final SwipeDeckController _controller = SwipeDeckController();
  List<int> _items = List<int>.generate(8, (i) => i + 1);
  String _last = 'Drag or fling a card';

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    return Column(
      children: [
        SizedBox(
          height: 360,
          child: SwipeDeck<int>(
            items: _items,
            keyOf: (item) => item,
            controller: _controller,
            leftOverlay: Text(
              'SKIP',
              style: TextStyle(
                color: colors.error,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            rightOverlay: Text(
              'LIKE',
              style: TextStyle(
                color: colors.success,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            itemBuilder: (context, item) => DecoratedBox(
              decoration: BoxDecoration(
                color: HSLColor.fromAHSL(
                  1,
                  (item * 47) % 360,
                  0.55,
                  0.62,
                ).toColor(),
                borderRadius: DSCornerRadius.xlAll,
              ),
              child: Center(
                child: Text(
                  'Card $item',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            onSwiped: (item, direction) => setState(() {
              _last = 'Card $item swiped ${direction.name}';
              _items = _items.where((i) => i != item).toList();
            }),
          ),
        ),
        const SizedBox(height: DSSpacing.m),
        Text(_last),
        const SizedBox(height: DSSpacing.s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: DSSpacing.m,
          children: [
            OutlinedButton(
              onPressed: () => _controller.swipe(SwipeDirection.left),
              child: const Text('Skip'),
            ),
            OutlinedButton(
              onPressed: () =>
                  setState(() => _items = List<int>.generate(8, (i) => i + 1)),
              child: const Text('Reset'),
            ),
            FilledButton(
              onPressed: () => _controller.swipe(SwipeDirection.right),
              child: const Text('Like'),
            ),
          ],
        ),
      ],
    );
  }
}

@AppPreviews('SwipeDeck (interactive)')
Widget swipeDeckPreview() => const _DemoDeck();
