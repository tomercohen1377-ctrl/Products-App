import 'package:flutter_test/flutter_test.dart';
import 'package:mylo_products/main.dart';

void main() {
  testWidgets('app shell boots', (tester) async {
    await tester.pumpWidget(const MyloApp());
    expect(find.text('Mylo'), findsOneWidget);
  });
}
