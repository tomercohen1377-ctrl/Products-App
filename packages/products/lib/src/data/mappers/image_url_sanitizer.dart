import 'dart:convert';

/// Turns the `images` field of a product into valid http(s) URLs.
///
/// The public API is user-generated and historically returns junk here: a
/// JSON array serialized into a single string (`["[\"https://...\"]"]`),
/// stray quotes and brackets, blanks, non-URLs and duplicates.
abstract final class ImageUrlSanitizer {
  static List<String> clean(Iterable<String> raw) {
    final seen = <String>{};
    final result = <String>[];
    for (final candidate in raw.expand(_expand)) {
      final url = _normalize(candidate);
      if (url != null && seen.add(url)) result.add(url);
    }
    return result;
  }

  static Iterable<String> _expand(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) return decoded.whereType<String>();
      } on FormatException {
        // Not valid JSON; fall through to stripping brackets below.
      }
    }
    return [trimmed];
  }

  static String? _normalize(String value) {
    final stripped = value.trim().replaceAll(
      RegExp(r'''^[\["'\s]+|[\]"'\s]+$'''),
      '',
    );
    final uri = Uri.tryParse(stripped);
    final valid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return valid ? stripped : null;
  }
}
