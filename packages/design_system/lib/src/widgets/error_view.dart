import 'package:core/core.dart';
import 'package:design_system/src/l10n_ext/failure_l10n.dart';
import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:design_system/src/widgets/app_button.dart';
import 'package:design_system/src/widgets/status_message.dart';
import 'package:flutter/widgets.dart';
import 'package:l10n/l10n.dart';

/// Shows a [Failure] with a retry action; [compact] fits list footers.
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.failure,
    this.onRetry,
    this.compact = false,
    super.key,
  });

  final Failure failure;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StatusMessage(
      icon: failure.icon,
      title: failure.localized(l10n),
      compact: compact,
      action: onRetry == null
          ? null
          : AppButton(
              label: l10n.retry,
              onPressed: onRetry,
              variant: compact
                  ? AppButtonVariant.text
                  : AppButtonVariant.secondary,
              expand: false,
            ),
    );
  }
}

@AppPreviews('ErrorView')
Widget errorViewPreview() => Column(
  spacing: DSSpacing.l,
  children: [
    ErrorView(failure: const NetworkFailure(), onRetry: () {}),
    ErrorView(
      failure: const ServerFailure(statusCode: 503),
      onRetry: () {},
      compact: true,
    ),
  ],
);
