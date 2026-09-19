import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mylo_products/app/dev/dev_tools_sheet.dart';

/// A small floating button (only while signed in) that opens [DevToolsSheet].
/// Lives above the router so it is reachable from every screen.
///
/// It sits above the Navigator, so it brings its own [Overlay] (tooltips and
/// the FAB need one).
class DevToolsOverlay extends StatelessWidget {
  const DevToolsOverlay({
    required this.navigatorKey,
    required this.tools,
    required this.child,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final AuthDebugTools tools;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) =>
                _DevToolsButton(navigatorKey: navigatorKey, tools: tools),
          ),
        ],
      ),
    ],
  );
}

class _DevToolsButton extends StatelessWidget {
  const _DevToolsButton({required this.navigatorKey, required this.tools});

  final GlobalKey<NavigatorState> navigatorKey;
  final AuthDebugTools tools;

  @override
  Widget build(BuildContext context) {
    final signedIn = context.select<SessionBloc, bool>(
      (bloc) => bloc.state.isAuthenticated,
    );
    if (!signedIn) return const SizedBox.shrink();

    return PositionedDirectional(
      start: 8,
      bottom: 8,
      child: SafeArea(
        child: Opacity(
          opacity: 0.6,
          child: FloatingActionButton.small(
            heroTag: 'dev-tools',
            tooltip: 'Developer tools',
            onPressed: () {
              final navigatorContext = navigatorKey.currentContext;
              if (navigatorContext == null) return;
              showModalBottomSheet<void>(
                context: navigatorContext,
                showDragHandle: true,
                isScrollControlled: true,
                builder: (_) => DevToolsSheet(tools: tools),
              );
            },
            child: const Icon(Icons.bug_report_outlined),
          ),
        ),
      ),
    );
  }
}
