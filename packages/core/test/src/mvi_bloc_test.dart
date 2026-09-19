import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/counter_bloc.dart';

void main() {
  blocTest<CounterBloc, CounterState>(
    'intents update state',
    build: CounterBloc.new,
    act: (bloc) => bloc.add(const Increment()),
    expect: () => [const CounterState(1)],
  );

  test('effects are emitted once, separately from state', () async {
    final bloc = CounterBloc();
    final effects = <CounterEffect>[];
    final subscription = bloc.effects.listen(effects.add);

    bloc
      ..add(const Increment())
      ..add(const Increment());
    await pumpEventQueue();

    expect(bloc.state, const CounterState(2));
    expect(effects, [const LimitReached()]);

    await subscription.cancel();
    await bloc.close();
  });

  test('an effect emitted with no listener is dropped, not replayed', () async {
    final bloc = CounterBloc()..emitLimitEffect();
    final effects = <CounterEffect>[];
    final subscription = bloc.effects.listen(effects.add);
    await pumpEventQueue();

    expect(effects, isEmpty);

    await subscription.cancel();
    await bloc.close();
  });

  test(
    'emitting after close is a safe no-op and the stream completes',
    () async {
      final bloc = CounterBloc();
      final done = expectLater(bloc.effects, emitsDone);
      await bloc.close();
      await done;

      expect(bloc.emitLimitEffect, returnsNormally);
    },
  );
}
