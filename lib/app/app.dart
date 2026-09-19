import 'package:auth/auth.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:mylo_products/app/dev/dev_tools.dart';
import 'package:mylo_products/app/dev/dev_tools_overlay.dart';
import 'package:mylo_products/app/router/app_router.dart';

class MyloApp extends StatefulWidget {
  const MyloApp({
    required this.getIt,
    this.devTools = DevTools.enabled,
    super.key,
  });

  final GetIt getIt;
  final bool devTools;

  @override
  State<MyloApp> createState() => _MyloAppState();
}

class _MyloAppState extends State<MyloApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final SessionBloc _session = widget.getIt<SessionBloc>()
    ..add(const SessionStarted());
  late final GoRouter _router = createRouter(
    session: _session,
    getIt: widget.getIt,
    navigatorKey: _navigatorKey,
  );

  @override
  void dispose() {
    _router.dispose();
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<SessionBloc>.value(
    value: _session,
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => context.l10n.appTitle,
      builder: (context, child) => widget.devTools
          ? DevToolsOverlay(
              navigatorKey: _navigatorKey,
              tools: widget.getIt<AuthDebugTools>(),
              child: child!,
            )
          : child!,
    ),
  );
}
