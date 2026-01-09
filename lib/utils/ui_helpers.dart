import 'package:flutter/material.dart';

/// Utility class for common UI helper functions
class UIHelpers {
  /// Dismisses the keyboard by removing focus from any text field
  static void dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
  }

  /// Alternative method using FocusManager
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
