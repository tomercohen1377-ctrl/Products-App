import 'package:flutter_test/flutter_test.dart';
import 'package:products/src/data/mappers/image_url_sanitizer.dart';

void main() {
  const a = 'https://i.imgur.com/a.jpeg';
  const b = 'https://i.imgur.com/b.jpeg';

  final cases = <String, (List<String>, List<String>)>{
    'keeps valid urls in order': ([a, b], [a, b]),
    'drops duplicates': ([a, a, b], [a, b]),
    'trims whitespace': (['  $a  '], [a]),
    'unwraps a JSON array serialized into a string': (['["$a","$b"]'], [a, b]),
    'unwraps a JSON array with surrounding spaces': (['  ["$a"]  '], [a]),
    'strips stray quotes': (['"$a"', "'$b'"], [a, b]),
    'strips brackets that are not valid JSON': (['[$a]'], [a]),
    'drops blanks': (['', '   '], []),
    'drops non-urls': (
      ['not a url', 'imgur.com/a.jpeg', '/relative/a.png'],
      [],
    ),
    'drops other schemes': (
      ['ftp://x.com/a.png', 'data:image/png;base64,AAA'],
      [],
    ),
    'drops urls without a host': (['https://', 'http:///a.png'], []),
    'keeps urls with long query strings': (
      ['https://www.google.com/aclk?sa=L&ai=abc&adurl='],
      ['https://www.google.com/aclk?sa=L&ai=abc&adurl='],
    ),
    'an empty list stays empty': (<String>[], <String>[]),
    'mixes good and bad': (['nope', a, '[]', b], [a, b]),
  };

  cases.forEach((name, testCase) {
    test(name, () {
      final (input, expected) = testCase;
      expect(ImageUrlSanitizer.clean(input), expected);
    });
  });
}
