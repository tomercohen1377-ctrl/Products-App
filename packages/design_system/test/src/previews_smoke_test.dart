import 'package:design_system/src/widgets/app_button.dart';
import 'package:design_system/src/widgets/app_loader.dart';
import 'package:design_system/src/widgets/app_network_image.dart';
import 'package:design_system/src/widgets/app_text_field.dart';
import 'package:design_system/src/widgets/async_content.dart';
import 'package:design_system/src/widgets/empty_view.dart';
import 'package:design_system/src/widgets/error_view.dart';
import 'package:design_system/src/widgets/paginated_list.dart';
import 'package:design_system/src/widgets/price_label.dart';
import 'package:design_system/src/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

/// Guards the "every widget has a preview" rule: each preview function must
/// build and lay out without exceptions in a phone-width, unbounded-height
/// canvas, in both directions.
void main() {
  final previews = <String, Widget Function()>{
    'AppButton': appButtonPreview,
    'AppLoader': appLoaderPreview,
    'AppNetworkImage': appNetworkImagePreview,
    'AppTextField': appTextFieldPreview,
    'AsyncContent': asyncContentPreview,
    'EmptyView': emptyViewPreview,
    'ErrorView': errorViewPreview,
    'PaginatedList': paginatedListPreview,
    'PriceLabel': priceLabelPreview,
    'StatusMessage': statusMessagePreview,
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
