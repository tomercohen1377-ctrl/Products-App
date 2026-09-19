import 'package:design_system/src/swipe_deck/swipe_decider.dart';
import 'package:design_system/src/swipe_deck/swipe_deck_config.dart';
import 'package:design_system/src/swipe_deck/swipe_direction.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = SwipeDeckConfig();
  const width = 400.0;
  // Threshold 0.35 * 400 = 140px; projection time 0.18s.

  const commitRight = SwipeCommit(SwipeDirection.right);
  const commitLeft = SwipeCommit(SwipeDirection.left);
  const snapBack = SwipeSnapBack();

  SwipeOutcome decide(
    Offset offset, [
    Offset velocity = Offset.zero,
    double w = width,
  ]) => SwipeDecider.decide(
    offset: offset,
    velocity: velocity,
    width: w,
    config: config,
  );

  final cases = <String, (Offset, Offset, SwipeOutcome)>{
    'a small drag snaps back': (const Offset(60, 0), Offset.zero, snapBack),
    'a drag just short of the threshold snaps back': (
      const Offset(139, 0),
      Offset.zero,
      snapBack,
    ),
    'a drag to the threshold is thrown right': (
      const Offset(140, 0),
      Offset.zero,
      commitRight,
    ),
    'a long drag left is thrown left': (
      const Offset(-220, 0),
      Offset.zero,
      commitLeft,
    ),
    'a short drag with a fast flick right is thrown': (
      const Offset(50, 0),
      const Offset(1500, 0),
      commitRight,
    ),
    'a short drag with a fast flick left is thrown': (
      const Offset(-40, 0),
      const Offset(-1800, 0),
      commitLeft,
    ),
    'a slow flick does not add enough': (
      const Offset(50, 0),
      const Offset(300, 0),
      snapBack,
    ),
    'a long drag right flicked back left snaps back': (
      const Offset(200, 0),
      const Offset(-1500, 0),
      snapBack,
    ),
    'a long drag right with a gentle pull back is still thrown': (
      const Offset(300, 0),
      const Offset(-200, 0),
      commitRight,
    ),
    'the vertical part of a drag is ignored': (
      const Offset(150, 400),
      Offset.zero,
      commitRight,
    ),
    'a mostly vertical flick does not throw a barely moved card': (
      const Offset(20, 0),
      const Offset(800, 3000),
      snapBack,
    ),
    'a mostly vertical flick does not throw a card dragged sideways a little': (
      const Offset(50, 100),
      const Offset(900, -2600),
      snapBack,
    ),
    'a diagonal fling that is mostly horizontal is thrown': (
      const Offset(60, 20),
      const Offset(1700, 900),
      commitRight,
    ),
    'a card at rest stays': (Offset.zero, Offset.zero, snapBack),
  };

  cases.forEach((name, testCase) {
    test(name, () {
      final (offset, velocity, expected) = testCase;
      expect(decide(offset, velocity), expected);
    });
  });

  test('a card with no width to measure against never throws', () {
    expect(decide(const Offset(500, 0), const Offset(5000, 0), 0), snapBack);
  });

  test('the threshold scales with the deck width', () {
    expect(decide(const Offset(140, 0), Offset.zero, 400), commitRight);
    expect(decide(const Offset(140, 0), Offset.zero, 800), snapBack);
  });

  test('the threshold and projection are configurable', () {
    const eager = SwipeDeckConfig(commitThreshold: 0.1);
    expect(
      SwipeDecider.decide(
        offset: const Offset(45, 0),
        velocity: Offset.zero,
        width: width,
        config: eager,
      ),
      commitRight,
    );
  });

  test('projectedX adds the velocity over the projection time', () {
    expect(
      SwipeDecider.projectedX(
        offset: const Offset(10, 0),
        velocity: const Offset(1000, 0),
        config: config,
      ),
      closeTo(10 + 1000 * config.projectionTime, 1e-9),
    );
  });

  test('direction sign helpers', () {
    expect(SwipeDirection.left.sign, -1);
    expect(SwipeDirection.right.sign, 1);
    expect(SwipeDirection.fromSign(-0.1), SwipeDirection.left);
    expect(SwipeDirection.fromSign(0.1), SwipeDirection.right);
  });

  test('snap-back overshoots the centre; the exit never overshoots', () {
    double extreme(SpringSimulation simulation, {required bool min}) {
      var result = simulation.x(0);
      for (var t = 0.0; t < 3; t += 0.005) {
        final x = simulation.x(t);
        result = min ? (x < result ? x : result) : (x > result ? x : result);
      }
      return result;
    }

    final snapBack = SpringSimulation(config.snapBackSpring, 120, 0, 0);
    expect(
      extreme(snapBack, min: true),
      lessThan(-1),
      reason: 'bounces past 0',
    );

    final exit = SpringSimulation(config.exitSpring, 0, 800, 1200);
    expect(extreme(exit, min: false), lessThanOrEqualTo(800.5));
  });
}
