import 'package:auth/auth.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Developer-only strings are intentionally not localized.
class DevToolsSheet extends StatefulWidget {
  const DevToolsSheet({required this.tools, super.key});

  final AuthDebugTools tools;

  @override
  State<DevToolsSheet> createState() => _DevToolsSheetState();
}

class _DevToolsSheetState extends State<DevToolsSheet> {
  String? _status;
  bool _busy = false;

  Future<void> _run(Future<String> Function() action) async {
    setState(() => _busy = true);
    final status = await action();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) => DevToolsSheetContent(
    status: _status,
    busy: _busy,
    onExpireAccessToken: () => _run(() async {
      await widget.tools.expireAccessToken();
      return 'Access token corrupted. The next protected call gets a real 401, '
          'refreshes and replays. Tap "Call profile now" to see it.';
    }),
    onKillSession: () => _run(() async {
      await widget.tools.killSession();
      return 'Both tokens corrupted. The next protected call gets a 401, the '
          'refresh is rejected and you are logged out. Tap "Call profile now".';
    }),
    onPingProfile: () => _run(() async {
      final ping = await widget.tools.pingProfile();
      if (!ping.succeeded) return 'Profile call failed: ${ping.failure}';
      return ping.tokenRotated
          ? 'OK. A 401 was recovered transparently: token refreshed and call replayed.'
          : 'OK. Token was still valid, no refresh needed.';
    }),
  );
}

class DevToolsSheetContent extends StatelessWidget {
  const DevToolsSheetContent({
    required this.status,
    required this.busy,
    required this.onExpireAccessToken,
    required this.onKillSession,
    required this.onPingProfile,
    super.key,
  });

  final String? status;
  final bool busy;
  final VoidCallback onExpireAccessToken;
  final VoidCallback onKillSession;
  final VoidCallback onPingProfile;

  @override
  Widget build(BuildContext context) {
    final typography = context.dsTypography;
    return SafeArea(
      child: Padding(
        padding: DSPadding.content,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DSSpacing.s,
          children: [
            Text('Developer tools', style: typography.h3()),
            AppButton(
              label: 'Expire access token (force a 401)',
              variant: AppButtonVariant.secondary,
              onPressed: busy ? null : onExpireAccessToken,
            ),
            AppButton(
              label: 'Kill session (refresh will fail)',
              variant: AppButtonVariant.secondary,
              onPressed: busy ? null : onKillSession,
            ),
            AppButton(
              label: 'Call profile now',
              isLoading: busy,
              onPressed: busy ? null : onPingProfile,
            ),
            if (status != null) AppBanner(message: status!),
          ],
        ),
      ),
    );
  }
}

@AppPreviews('DevToolsSheetContent')
Widget devToolsSheetContentPreview() => DevToolsSheetContent(
  status: 'OK. A 401 was recovered transparently: token refreshed and call replayed.',
  busy: false,
  onExpireAccessToken: () {},
  onKillSession: () {},
  onPingProfile: () {},
);
