import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

sealed class CounterIntent extends Equatable {
  const CounterIntent();

  @override
  List<Object?> get props => const [];
}

final class Increment extends CounterIntent {
  const Increment();
}

final class CounterState extends Equatable {
  const CounterState(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}

sealed class CounterEffect extends Equatable {
  const CounterEffect();

  @override
  List<Object?> get props => const [];
}

final class LimitReached extends CounterEffect {
  const LimitReached();
}

class CounterBloc extends MviBloc<CounterIntent, CounterState, CounterEffect> {
  CounterBloc() : super(const CounterState(0)) {
    on<Increment>((intent, emit) {
      final next = state.count + 1;
      emit(CounterState(next));
      if (next == limit) emitEffect(const LimitReached());
    });
  }

  static const limit = 2;

  /// Lets a test emit an effect from outside the handlers.
  void emitLimitEffect() => emitEffect(const LimitReached());
}
