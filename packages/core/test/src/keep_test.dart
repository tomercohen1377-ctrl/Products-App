import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('omitting the argument keeps the current value', () {
    expect(valueOrKeep<String>(keep, 'now'), 'now');
    expect(valueOrKeep<String>(keep, null), isNull);
  });

  test('passing null clears the value', () {
    expect(valueOrKeep<String>(null, 'now'), isNull);
  });

  test('passing a value replaces it', () {
    expect(valueOrKeep<String>('new', 'now'), 'new');
  });
}
