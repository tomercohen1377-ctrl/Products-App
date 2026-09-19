import 'dart:ui';

import 'package:design_system/src/swipe_deck/swipe_deck_config.dart';
import 'package:design_system/src/swipe_deck/swipe_direction.dart';

sealed class SwipeOutcome {
  const SwipeOutcome();
}

/// Throw the card off in [direction].
final class SwipeCommit extends SwipeOutcome {
  const SwipeCommit(this.direction);

  final SwipeDirection direction;

  @override
  bool operator ==(Object other) =>
      other is SwipeCommit && other.direction == direction;

  @override
  int get hashCode => direction.hashCode;

  @override
  String toString() => 'SwipeCommit($direction)';
}

/// Spring the card back to the centre.
final class SwipeSnapBack extends SwipeOutcome {
  const SwipeSnapBack();

  @override
  bool operator ==(Object other) => other is SwipeSnapBack;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'SwipeSnapBack()';
}

/// Decides, when the finger lifts, whether a card is thrown or springs back.
///
/// Pure and side-effect free, so the rule can be tested as a table.
abstract final class SwipeDecider {
  /// Where a card released at [offset] with [velocity] (px/s) is heading: its
  /// position plus a short projection along its velocity. Using the
  /// projection, not the position, is what lets a quick flick throw a card.
  static double projectedX({
    required Offset offset,
    required Offset velocity,
    required SwipeDeckConfig config,
  }) => offset.dx + velocity.dx * config.projectionTime;

  /// The horizontal distance (px) a card has to be heading for to be thrown.
  static double thresholdFor(double width, SwipeDeckConfig config) =>
      width * config.commitThreshold;

  static SwipeOutcome decide({
    required Offset offset,
    required Offset velocity,
    required double width,
    required SwipeDeckConfig config,
  }) {
    if (width <= 0) return const SwipeSnapBack();

    final projected = projectedX(
      offset: offset,
      velocity: velocity,
      config: config,
    );
    if (projected.abs() < thresholdFor(width, config)) {
      return const SwipeSnapBack();
    }

    // A mostly vertical flick is not a horizontal throw, even if a little
    // sideways speed pushes the projection over the line.
    final mostlyVertical = velocity.dy.abs() > velocity.dx.abs() * 2;
    if (mostlyVertical && offset.dx.abs() < thresholdFor(width, config) * 0.5) {
      return const SwipeSnapBack();
    }

    return SwipeCommit(SwipeDirection.fromSign(projected));
  }
}
