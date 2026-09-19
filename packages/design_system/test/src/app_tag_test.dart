import 'package:design_system/design_system.dart';
import 'package:design_system/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows its label', (tester) async {
    await tester.pumpApp(const AppTag('Clothes'));

    expect(find.text('Clothes'), findsOneWidget);
  });
}
