import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// A two-button confirmation. [destructive] paints the confirm action in the
/// error color.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(cancelLabel),
      ),
      TextButton(
        style: destructive
            ? TextButton.styleFrom(foregroundColor: context.dsColors.error)
            : null,
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(confirmLabel),
      ),
    ],
  );
}

/// Shows a [ConfirmDialog]; true only if the user confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    ) ??
    false;

@AppPreviews('ConfirmDialog')
Widget confirmDialogPreview() => const ConfirmDialog(
  title: 'Delete this product?',
  message: '"Classic Red Pullover Hoodie" will be removed.',
  confirmLabel: 'Delete',
  cancelLabel: 'Cancel',
  destructive: true,
);
