import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

/// The "nothing to show" state. Title defaults to the shared empty string.
class EmptyView extends StatelessWidget {
  const EmptyView({
    this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    super.key,
  });

  final String? title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => StatusMessage(
    icon: icon,
    title: title ?? context.l10n.emptyTitle,
    message: message,
    action: action,
  );
}

@AppPreviews('EmptyView')
Widget emptyViewPreview() => const EmptyView(message: 'Pull down to refresh.');
