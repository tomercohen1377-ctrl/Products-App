import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void table(
    String name,
    FieldValidator validator,
    Map<String?, FieldError?> cases,
  ) {
    group(name, () {
      cases.forEach((input, expected) {
        test('${input == null ? 'null' : "'$input'"} -> $expected', () {
          expect(validator(input), expected);
        });
      });
    });
  }

  table('required', Validators.required, {
    null: FieldError.required,
    '': FieldError.required,
    '   ': FieldError.required,
    'x': null,
  });

  table('email', Validators.email, {
    null: FieldError.required,
    'john': FieldError.invalidEmail,
    'john@': FieldError.invalidEmail,
    'john@mail': FieldError.invalidEmail,
    'jo hn@mail.com': FieldError.invalidEmail,
    'john@mail.com': null,
    '  john@mail.com  ': null,
  });

  table('price', Validators.price, {
    null: FieldError.required,
    'abc': FieldError.invalidNumber,
    'NaN': FieldError.invalidNumber,
    'Infinity': FieldError.invalidNumber,
    '0': FieldError.notPositive,
    '-4': FieldError.notPositive,
    '12': null,
    '12.5': null,
  });

  table('httpUrl', Validators.httpUrl, {
    null: FieldError.required,
    'not a url': FieldError.invalidUrl,
    'ftp://a.com/x.png': FieldError.invalidUrl,
    'https://': FieldError.invalidUrl,
    'https://i.imgur.com/a.jpeg': null,
    'http://a.com/b': null,
  });

  test('compose returns the first error only', () {
    final validator = Validators.compose([
      Validators.required,
      (v) => FieldError.invalidEmail,
    ]);
    expect(validator(''), FieldError.required);
    expect(validator('x'), FieldError.invalidEmail);
  });
}
