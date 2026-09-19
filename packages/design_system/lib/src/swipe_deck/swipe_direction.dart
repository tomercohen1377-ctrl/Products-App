/// Which way a card was thrown. Physical directions: right is always right,
/// also in right-to-left locales, so the gesture and its buttons agree.
enum SwipeDirection {
  left(-1),
  right(1);

  const SwipeDirection(this.sign);

  /// -1 for left, 1 for right; the direction along the x axis.
  final int sign;

  static SwipeDirection fromSign(double value) =>
      value < 0 ? SwipeDirection.left : SwipeDirection.right;
}
