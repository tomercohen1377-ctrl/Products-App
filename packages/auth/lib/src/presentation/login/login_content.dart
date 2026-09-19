import 'package:auth/src/presentation/login/login_intent.dart';
import 'package:auth/src/presentation/login/login_state.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

/// The login form. Pure: renders [state] and reports [onIntent].
class LoginContent extends StatelessWidget {
  const LoginContent({
    required this.state,
    required this.onIntent,
    this.sessionExpired = false,
    super.key,
  });

  final LoginState state;
  final void Function(LoginIntent intent) onIntent;

  /// Explain that the previous session ended unexpectedly.
  final bool sessionExpired;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typography = context.dsTypography;
    final failure = state.failure;

    return Center(
      child: SingleChildScrollView(
        padding: DSPadding.content,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DSSpacing.m,
            children: [
              Text(l10n.loginTitle, style: typography.h1()),
              Text(
                l10n.loginSubtitle,
                style: typography.body(color: context.dsColors.txtSecondary),
              ),
              const SizedBox.shrink(),
              if (sessionExpired && failure == null)
                AppBanner(message: l10n.errorUnauthorized),
              if (failure != null)
                AppBanner(
                  message: failure is UnauthorizedFailure
                      ? l10n.loginInvalidCredentials
                      : failure.localized(l10n),
                  tone: AppBannerTone.error,
                ),
              AppTextField(
                label: l10n.loginEmailLabel,
                initialValue: state.email,
                enabled: !state.isSubmitting,
                errorText: state.emailError?.localized(l10n),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                prefixIcon: Icons.mail_outline_rounded,
                onChanged: (value) => onIntent(LoginEmailChanged(value)),
              ),
              AppTextField(
                label: l10n.loginPasswordLabel,
                initialValue: state.password,
                enabled: !state.isSubmitting,
                errorText: state.passwordError?.localized(l10n),
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                prefixIcon: Icons.lock_outline_rounded,
                onChanged: (value) => onIntent(LoginPasswordChanged(value)),
                onSubmitted: (_) => onIntent(const LoginSubmitted()),
              ),
              AppButton(
                label: l10n.loginSubmit,
                isLoading: state.isSubmitting,
                onPressed: () => onIntent(const LoginSubmitted()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _filled = LoginState(email: 'john@mail.com', password: 'changeme');

@AppPreviews('LoginContent: empty')
Widget loginContentEmptyPreview() =>
    LoginContent(state: const LoginState(), onIntent: (_) {});

@AppPreviews('LoginContent: validation errors')
Widget loginContentErrorsPreview() => LoginContent(
  state: const LoginState(email: 'john', showErrors: true),
  onIntent: (_) {},
);

@AppPreviews('LoginContent: submitting')
Widget loginContentSubmittingPreview() => LoginContent(
  state: _filled.copyWith(status: const LoginSubmitting()),
  onIntent: (_) {},
);

@AppPreviews('LoginContent: wrong credentials')
Widget loginContentFailedPreview() => LoginContent(
  state: _filled.copyWith(status: const LoginFailed(UnauthorizedFailure())),
  onIntent: (_) {},
);

@AppPreviews('LoginContent: offline')
Widget loginContentOfflinePreview() => LoginContent(
  state: _filled.copyWith(status: const LoginFailed(NetworkFailure())),
  onIntent: (_) {},
);

@AppPreviews('LoginContent: session expired')
Widget loginContentExpiredPreview() => LoginContent(
  state: const LoginState(email: 'john@mail.com'),
  sessionExpired: true,
  onIntent: (_) {},
);
