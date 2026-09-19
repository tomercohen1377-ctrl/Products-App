import 'package:design_system/src/swipe_deck/swipe_direction.dart';

/// Lets outside widgets (the Like and Skip buttons) throw the top card with
/// the same physics as a finger.
class SwipeDeckController {
  void Function(SwipeDirection direction)? _swipe;
  bool Function()? _isBusy;

  /// Throws the top card. Does nothing when there is no card or one is
  /// already moving.
  void swipe(SwipeDirection direction) => _swipe?.call(direction);

  /// Whether a card is currently being dragged or is animating.
  bool get isBusy => _isBusy?.call() ?? false;

  // Called by the deck's state.
  void attach({
    required void Function(SwipeDirection direction) swipe,
    required bool Function() isBusy,
  }) {
    _swipe = swipe;
    _isBusy = isBusy;
  }

  void detach() {
    _swipe = null;
    _isBusy = null;
  }
}
