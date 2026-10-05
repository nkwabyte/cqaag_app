import 'package:flutter/services.dart';

/// Validation and formatting for the Ghana Card (National Identification Card)
/// personal ID number.
///
/// Ghanaian law now allows the Association to record the card *number* only —
/// no images of the card are captured or stored. The number is therefore the
/// single piece of identity evidence an admin verifies against, so it has to be
/// structurally correct before it is ever written.
///
/// Structure: `GHA-#########-#`
///   - the fixed `GHA` country prefix
///   - nine digits
///   - a single check digit
class GhanaCard {
  GhanaCard._();

  /// Prefix every Ghana Card personal ID number carries.
  static const String prefix = 'GHA-';

  /// Total length of a complete, formatted number.
  static const int formattedLength = 15;

  /// Placeholder shown in inputs.
  static const String placeholder = 'GHA-000000000-0';

  static final RegExp _strict = RegExp(r'^GHA-\d{9}-\d$');

  /// Whether [value] is a structurally valid Ghana Card number.
  static bool isValid(String? value) {
    if (value == null) return false;
    return _strict.hasMatch(value.trim().toUpperCase());
  }

  /// Normalises loose input — lower case, missing hyphens, stray spaces — into
  /// the canonical `GHA-#########-#` form, or returns null when the input does
  /// not hold exactly ten digits.
  ///
  /// Used before writing and before comparing two numbers, so the same card
  /// entered two different ways is still recognised as the same card.
  static String? normalise(String? value) {
    if (value == null) return null;
    final digits = value.toUpperCase().replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 10) return null;
    return '$prefix${digits.substring(0, 9)}-${digits.substring(9)}';
  }

  /// Error message for [value], or null when it is acceptable.
  ///
  /// [required] is false where the number is optional, e.g. a Corporate
  /// member registering an organization rather than a person.
  static String? validationError(String? value, {bool required = true}) {
    final trimmed = value?.trim() ?? '';
    final isBlank = trimmed.isEmpty || trimmed.toUpperCase() == prefix;

    if (isBlank) {
      return required ? 'Enter your Ghana Card number.' : null;
    }
    if (!isValid(trimmed)) {
      return 'Enter a valid Ghana Card number in the form $placeholder.';
    }
    return null;
  }

  /// Masks all but the last four characters, for display where the full number
  /// is not needed.
  static String mask(String? value) {
    final normalised = normalise(value);
    if (normalised == null) return value?.trim() ?? '';
    return '$prefix•••••••-${normalised.substring(normalised.length - 1)}'
        .replaceFirst('•••••••', '•' * 9);
  }
}

/// Keeps a Ghana Card field in `GHA-#########-#` shape as the user types.
///
/// The `GHA-` prefix is held in place and hyphens are inserted for the user, so
/// the only thing they actually type is the ten digits.
class GhanaCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Anything that is not a digit is discarded; the prefix and hyphens are
    // re-applied below, so pasting a number in any format still works.
    final digits = newValue.text.toUpperCase().replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: GhanaCard.prefix,
        selection: TextSelection.collapsed(offset: GhanaCard.prefix.length),
      );
    }

    final capped = digits.length > 10 ? digits.substring(0, 10) : digits;

    final buffer = StringBuffer(GhanaCard.prefix);
    if (capped.length > 9) {
      buffer.write('${capped.substring(0, 9)}-${capped.substring(9)}');
    } else {
      buffer.write(capped);
      // Offer the second hyphen as soon as the nine digits are in, but only
      // while typing forwards — otherwise backspace could never get past it.
      if (capped.length == 9 && newValue.text.length > oldValue.text.length) {
        buffer.write('-');
      }
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
