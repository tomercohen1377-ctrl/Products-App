import 'package:auth/auth.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:l10n/l10n.dart';

/// Temporary landing screen until the products feature exists.
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionBloc, User?>((bloc) => bloc.state.user);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.productsTitle),
        actions: const [AccountButton()],
      ),
      body: Center(
        child: Text(user?.name ?? '', style: context.dsTypography.h2()),
      ),
    );
  }
}
