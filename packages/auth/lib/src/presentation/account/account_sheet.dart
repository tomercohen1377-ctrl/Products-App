import 'package:auth/src/domain/entities/user.dart';
import 'package:auth/src/presentation/session/session_bloc.dart';
import 'package:auth/src/presentation/session/session_intent.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:l10n/l10n.dart';

/// App-bar button that opens the account sheet (who is signed in, sign out).
/// Needs a [SessionBloc] above it.
class AccountButton extends StatelessWidget {
  const AccountButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.accountTooltip,
    icon: const Icon(Icons.account_circle_outlined),
    onPressed: () {
      final session = context.read<SessionBloc>();
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => AccountSheetContent(
          user: session.state.user,
          onSignOut: () {
            Navigator.of(sheetContext).pop();
            session.add(const SessionSignOutRequested());
          },
        ),
      );
    },
  );
}

/// The sheet body. Pure: takes the user (unknown while offline) and a
/// sign-out callback.
class AccountSheetContent extends StatelessWidget {
  const AccountSheetContent({
    required this.user,
    required this.onSignOut,
    super.key,
  });

  final User? user;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final user = this.user;

    return SafeArea(
      child: Padding(
        padding: DSPadding.content,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DSSpacing.m,
          children: [
            if (user != null)
              Row(
                spacing: DSSpacing.m,
                children: [
                  SizedBox.square(
                    dimension: DSDimensions.iconXl,
                    child: ClipOval(
                      child: AppNetworkImage(url: user.avatarUrl),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.accountSignedInAs,
                          style: typography.caption(color: colors.txtSecondary),
                        ),
                        Text(user.name, style: typography.bodyStrong()),
                        Text(
                          user.email,
                          style: typography.small(color: colors.txtSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            AppButton(
              label: l10n.accountSignOut,
              icon: Icons.logout_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: onSignOut,
            ),
          ],
        ),
      ),
    );
  }
}

@AppPreviews('AccountSheetContent')
Widget accountSheetContentPreview() => AccountSheetContent(
  user: const User(
    id: 1,
    email: 'john@mail.com',
    name: 'John',
    avatarUrl: 'https://i.imgur.com/LDOO4Qs.jpg',
  ),
  onSignOut: () {},
);

@AppPreviews('AccountSheetContent: offline (no profile)')
Widget accountSheetContentOfflinePreview() =>
    AccountSheetContent(user: null, onSignOut: () {});
