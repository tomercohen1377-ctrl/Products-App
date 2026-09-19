/// Why a form field is invalid. Presentation maps each value to localized
/// text once; validators themselves carry no strings.
enum FieldError {
  required,
  invalidEmail,
  invalidNumber,
  notPositive,
  invalidUrl,
}

typedef FieldValidator = FieldError? Function(String? value);

/// Small, composable form validators shared by every form in the app.
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static FieldError? required(String? value) =>
      value == null || value.trim().isEmpty ? FieldError.required : null;

  static FieldError? email(String? value) =>
      compose([required, _emailFormat])(value);

  static FieldError? price(String? value) =>
      compose([required, _positiveNumber])(value);

  static FieldError? httpUrl(String? value) =>
      compose([required, _absoluteHttpUrl])(value);

  /// Runs [validators] in order and returns the first error, or null.
  static FieldValidator compose(List<FieldValidator> validators) => (value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  };

  static FieldError? _emailFormat(String? value) =>
      _email.hasMatch(value!.trim()) ? null : FieldError.invalidEmail;

  static FieldError? _positiveNumber(String? value) {
    final number = num.tryParse(value!.trim());
    if (number == null || number.isNaN || number.isInfinite) {
      return FieldError.invalidNumber;
    }
    return number > 0 ? null : FieldError.notPositive;
  }

  static FieldError? _absoluteHttpUrl(String? value) {
    final uri = Uri.tryParse(value!.trim());
    final valid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return valid ? null : FieldError.invalidUrl;
  }
}
