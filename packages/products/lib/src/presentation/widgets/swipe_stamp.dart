import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// The bordered, tilted label that fades in over a deck card as it is dragged
/// toward a side ("LIKE", "SKIP").
class SwipeStamp extends StatelessWidget {
  const SwipeStamp({
    required this.label,
    required this.color,
    this.tilt = -0.2,
    super.key,
  });

  final String label;
  final Color color;

  /// Rotation in radians.
  final double tilt;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: tilt,
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 4),
        borderRadius: DSCornerRadius.mAll,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: DSSpacing.m,
          vertical: DSSpacing.xs,
        ),
        child: Text(
          label.toUpperCase(),
          style: context.dsTypography
              .h2(color: color)
              .copyWith(fontWeight: FontWeight.w800, letterSpacing: 2),
        ),
      ),
    ),
  );
}

@AppPreviews('SwipeStamp')
Widget swipeStampPreview() => Builder(
  builder: (context) => Row(
    spacing: DSSpacing.l,
    children: [
      SwipeStamp(label: 'Like', color: context.dsColors.success),
      SwipeStamp(label: 'Skip', color: context.dsColors.error, tilt: 0.2),
    ],
  ),
);
