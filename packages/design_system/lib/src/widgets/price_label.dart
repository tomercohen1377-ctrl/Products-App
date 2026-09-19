import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/theme/theme_context.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Formats [price] as dollars in the current locale, dropping ".00".
String formatPrice(BuildContext context, num price) {
  final locale = Localizations.localeOf(context).toString();
  final wholeNumber = price % 1 == 0;
  return NumberFormat.currency(
    locale: locale,
    symbol: r'$',
    decimalDigits: wholeNumber ? 0 : 2,
  ).format(price);
}

class PriceLabel extends StatelessWidget {
  const PriceLabel(this.price, {this.style, super.key});

  final num price;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text(
    formatPrice(context, price),
    style: style ?? context.dsTypography.h3(color: context.dsColors.brand),
  );
}

@AppPreviews('PriceLabel')
Widget priceLabelPreview() => const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [PriceLabel(10), PriceLabel(79.5), PriceLabel(1234.99)],
);
