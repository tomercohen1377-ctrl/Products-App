import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/src/presentation/list/products_content.dart';
import 'package:products/src/presentation/widgets/product_tile.dart';

/// Guards the "every widget has a preview" rule: each preview function must
/// build and lay out without exceptions, in both directions.
void main() {
  final previews = <String, Widget Function()>{
    'ProductTile': productTilePreview,
    'ProductsContent loading': productsContentLoadingPreview,
    'ProductsContent loaded': productsContentLoadedPreview,
    'ProductsContent loading more': productsContentLoadingMorePreview,
    'ProductsContent next page failed': productsContentLoadMoreFailedPreview,
    'ProductsContent empty': productsContentEmptyPreview,
    'ProductsContent first load failed': productsContentFailedPreview,
  };

  for (final MapEntry(key: name, value: build) in previews.entries) {
    for (final locale in const [Locale('en'), Locale('he')]) {
      testWidgets('$name preview builds in ${locale.languageCode}', (
        tester,
      ) async {
        await tester.pumpApp(
          SingleChildScrollView(child: build()),
          locale: locale,
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
