import 'dart:async';

import 'package:core/src/mvi/mvi_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Renders a screen from an [MviBloc]'s state and reacts to its one-shot
/// effects, so screens don't each re-implement the subscription plumbing.
///
/// `builder` runs for state changes; `onEffect` runs once per effect.
class MviView<
  B extends MviBloc<Equatable, S, E>,
  S extends Equatable,
  E extends Equatable
>
    extends StatefulWidget {
  const MviView({
    required this.builder,
    this.onEffect,
    this.bloc,
    this.buildWhen,
    super.key,
  });

  final Widget Function(BuildContext context, S state) builder;
  final void Function(BuildContext context, E effect)? onEffect;

  /// Uses the nearest provided [B] when null.
  final B? bloc;
  final bool Function(S previous, S current)? buildWhen;

  @override
  State<MviView<B, S, E>> createState() => _MviViewState<B, S, E>();
}

class _MviViewState<
  B extends MviBloc<Equatable, S, E>,
  S extends Equatable,
  E extends Equatable
>
    extends State<MviView<B, S, E>> {
  B? _bloc;
  StreamSubscription<E>? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attach();
  }

  @override
  void didUpdateWidget(MviView<B, S, E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attach();
  }

  void _attach() {
    final bloc = widget.bloc ?? context.read<B>();
    if (identical(bloc, _bloc)) return;
    _bloc = bloc;
    unawaited(_subscription?.cancel());
    _subscription = bloc.effects.listen((effect) {
      if (mounted) {
        widget.onEffect?.call(context, effect);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<B, S>(
    bloc: _bloc,
    buildWhen: widget.buildWhen,
    builder: widget.builder,
  );
}
