import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/counter_bloc.dart';

typedef _View = MviView<CounterBloc, CounterState, CounterEffect>;

void main() {
  Widget host(CounterBloc bloc, void Function(CounterEffect) onEffect) =>
      MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: _View(
            builder: (context, state) => Text('count ${state.count}'),
            onEffect: (context, effect) => onEffect(effect),
          ),
        ),
      );

  testWidgets('rebuilds on state and delivers each effect once', (
    tester,
  ) async {
    final bloc = CounterBloc();
    addTearDown(bloc.close);
    final effects = <CounterEffect>[];

    await tester.pumpWidget(host(bloc, effects.add));
    expect(find.text('count 0'), findsOneWidget);

    bloc
      ..add(const Increment())
      ..add(const Increment());
    await tester.pump();

    expect(find.text('count 2'), findsOneWidget);
    expect(effects, [const LimitReached()]);
  });

  testWidgets('stops listening when removed from the tree', (tester) async {
    final bloc = CounterBloc();
    addTearDown(bloc.close);
    final effects = <CounterEffect>[];

    await tester.pumpWidget(host(bloc, effects.add));
    await tester.pumpWidget(const SizedBox());
    bloc.emitLimitEffect();
    await tester.pump();

    expect(effects, isEmpty);
  });
}
