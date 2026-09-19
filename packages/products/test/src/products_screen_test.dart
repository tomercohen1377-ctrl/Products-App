import 'package:core/core.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';
import 'package:products/src/presentation/list/products_bloc.dart';
import 'package:products/src/presentation/list/products_intent.dart';
import 'package:products/src/presentation/list/products_screen.dart';
import 'package:products/src/presentation/widgets/product_tile.dart';

import '../support/fake_products_repository.dart';

/// Drags the list down, waits for the refresh indicator to arm and fire, lets
/// the bloc finish, then lets the indicator retract.
Future<void> pullToRefresh(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, 400));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.settle();
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  late FakeProductsRepository repository;
  late ProductsBloc bloc;

  setUp(() {
    repository = FakeProductsRepository(makeProducts(5));
    bloc = ProductsBloc(repository, pageSize: 10);
  });

  tearDown(() {
    bloc.close();
    repository.dispose();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpApp(
      BlocProvider<ProductsBloc>.value(
        value: bloc,
        child: const ProductsScreen(actions: [Icon(Icons.star)]),
      ),
    );
  }

  testWidgets('loads and shows the products, with the app-provided actions', (
    tester,
  ) async {
    bloc.add(const ProductsStarted());
    await pumpScreen(tester);
    await tester.settle();
    await tester.pumpAndSettle();

    expect(find.text('Products'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byType(ProductTile), findsNWidgets(5));
  });

  testWidgets('a failed first load can be retried from the error view', (
    tester,
  ) async {
    repository.queued.add(const Failed(NetworkFailure()));
    bloc.add(const ProductsStarted());
    await pumpScreen(tester);
    await tester.settle();
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.settle();
    await tester.pumpAndSettle();

    expect(find.byType(ProductTile), findsNWidgets(5));
  });

  testWidgets('pull to refresh reloads the list', (tester) async {
    bloc.add(const ProductsStarted());
    await pumpScreen(tester);
    await tester.settle();
    await tester.pumpAndSettle();
    repository.server = makeProducts(2, start: 50);

    await pullToRefresh(tester);

    expect(find.byType(ProductTile), findsNWidgets(2));
    expect(find.text('Product 50'), findsOneWidget);
  });

  testWidgets('a failed refresh keeps the list and tells the user', (
    tester,
  ) async {
    bloc.add(const ProductsStarted());
    await pumpScreen(tester);
    await tester.settle();
    await tester.pumpAndSettle();
    repository.queued.add(const Failed(NetworkFailure()));

    await pullToRefresh(tester);

    expect(find.byType(ProductTile), findsNWidgets(5));
    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('a product created elsewhere shows up at the top', (
    tester,
  ) async {
    bloc.add(const ProductsStarted());
    await pumpScreen(tester);
    await tester.settle();
    await tester.pumpAndSettle();

    repository.publish(ProductCreated(makeProducts(1, start: 77).single));
    await tester.settle();
    await tester.pumpAndSettle();

    expect(find.text('Product 77'), findsOneWidget);
    expect(find.byType(ProductTile), findsNWidgets(6));
  });
}
