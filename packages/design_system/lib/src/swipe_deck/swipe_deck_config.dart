import 'package:flutter/physics.dart';

/// Every tunable of the swipe deck in one place, so its feel can be changed
/// with a one-line edit.
class SwipeDeckConfig {
  const SwipeDeckConfig({
    this.visibleCards = 3,
    this.commitThreshold = 0.35,
    this.projectionTime = 0.18,
    this.maxRotation = 0.35,
    this.stackScaleStep = 0.06,
    this.stackOffsetStep = 14,
    this.snapBackStiffness = 320,
    this.snapBackDampingRatio = 0.62,
    this.exitStiffness = 260,
    this.exitDampingRatio = 1,
    this.minExitVelocity = 1100,
    this.hapticFeedback = true,
  }) : assert(visibleCards >= 1, 'A deck shows at least one card');

  static const SwipeDeckConfig defaults = SwipeDeckConfig();

  /// How many cards are mounted: the one being dragged plus the pile behind.
  final int visibleCards;

  /// Fraction of the deck's width a card must travel to be thrown away.
  final double commitThreshold;

  /// How far ahead (seconds) the release velocity is projected when deciding:
  /// a quick flick can throw a card that was dragged only a short way.
  final double projectionTime;

  /// Rotation (radians) at a full deck-width of horizontal travel.
  final double maxRotation;

  /// How much each card deeper in the pile shrinks, as a fraction of its size.
  final double stackScaleStep;

  /// How far (logical pixels) each card deeper in the pile sits lower.
  final double stackOffsetStep;

  /// Spring for the snap-back. Under-damped (ratio below 1), so a card that
  /// was dragged and let go overshoots the centre and settles: the bounce.
  final double snapBackStiffness;
  final double snapBackDampingRatio;

  /// Spring for the exit. Critically damped (ratio 1): no bounce on the way
  /// out, just a smooth acceleration off-screen.
  final double exitStiffness;
  final double exitDampingRatio;

  /// A thrown card leaves at least this fast (px/s), so a slow release just
  /// past the threshold still flies out briskly.
  final double minExitVelocity;

  /// Tick when a card crosses the throw threshold; thump when it is thrown.
  final bool hapticFeedback;

  SpringDescription get snapBackSpring => SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: snapBackStiffness,
    ratio: snapBackDampingRatio,
  );

  SpringDescription get exitSpring => SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: exitStiffness,
    ratio: exitDampingRatio,
  );
}
