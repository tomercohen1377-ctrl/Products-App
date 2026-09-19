import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:design_system/src/widgets/app_loader.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, text }

/// The app's only button. Null [onPressed] disables it; [isLoading] shows a
/// spinner and blocks taps so a submit can't be fired twice.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  /// Fill the available width (default) or size to the content.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final onPressed = isLoading ? null : this.onPressed;
    final child = Builder(
      builder: (context) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: DSSpacing.xs,
        children: [
          if (isLoading)
            AppLoader.small(color: IconTheme.of(context).color)
          else if (icon != null)
            Icon(icon, size: 20),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onPressed,
        child: child,
      ),
      AppButtonVariant.text => TextButton(onPressed: onPressed, child: child),
    };
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

@AppPreviews('AppButton')
Widget appButtonPreview() => Column(
  spacing: DSSpacing.s,
  children: [
    AppButton(label: 'Primary', onPressed: () {}),
    AppButton(label: 'With icon', icon: Icons.add, onPressed: () {}),
    AppButton(
      label: 'Secondary',
      variant: AppButtonVariant.secondary,
      onPressed: () {},
    ),
    AppButton(label: 'Text', variant: AppButtonVariant.text, onPressed: () {}),
    const AppButton(label: 'Disabled', onPressed: null),
    AppButton(label: 'Saving', isLoading: true, onPressed: () {}),
    AppButton(label: 'Hug content', expand: false, onPressed: () {}),
  ],
);
