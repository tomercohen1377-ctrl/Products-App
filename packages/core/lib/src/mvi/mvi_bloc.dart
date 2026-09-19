import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base class for every screen's bloc.
///
/// MVI on top of `flutter_bloc`: events are **intents**, [state] is the single
/// immutable snapshot the UI renders, and one-shot side effects (navigation,
/// snackbars, dialogs) leave through the separate [effects] stream so they are
/// never replayed by a rebuild.
abstract class MviBloc<
  I extends Equatable,
  S extends Equatable,
  E extends Equatable
>
    extends Bloc<I, S> {
  MviBloc(super.initialState);

  final StreamController<E> _effects = StreamController<E>.broadcast();

  /// One-shot effects. Broadcast: an effect emitted while nobody listens is
  /// dropped, which is what we want for transient UI events.
  Stream<E> get effects => _effects.stream;

  @protected
  void emitEffect(E effect) {
    if (!_effects.isClosed) {
      _effects.add(effect);
    }
  }

  @override
  Future<void> close() async {
    await _effects.close();
    return super.close();
  }
}
