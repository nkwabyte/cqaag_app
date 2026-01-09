import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SnackbarType { success, error, warning, info }

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    IconData icon;
    Color iconColor;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green.shade600;
        icon = Icons.check_circle_outline;
        iconColor = Colors.white;
        break;
      case SnackbarType.error:
        backgroundColor = colorScheme.error;
        icon = Icons.error_outline;
        iconColor = Colors.white;
        break;
      case SnackbarType.warning:
        backgroundColor = Colors.orange.shade600;
        icon = Icons.warning_amber_outlined;
        iconColor = Colors.white;
        break;
      case SnackbarType.info:
        backgroundColor = colorScheme.primary;
        icon = Icons.info_outline;
        iconColor = Colors.white;
        break;
    }

    Flushbar(
      title: title,
      message: message,
      icon: Icon(
        icon,
        size: 28.r,
        color: iconColor,
      ),
      duration: duration,
      backgroundColor: backgroundColor,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      flushbarPosition: FlushbarPosition.TOP,
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      boxShadows: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ],
    ).show(context);
  }

  static void success(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.success,
      title: title ?? 'Success',
      duration: duration,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.error,
      title: title ?? 'Error',
      duration: duration,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.warning,
      title: title ?? 'Warning',
      duration: duration,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.info,
      title: title ?? 'Info',
      duration: duration,
    );
  }
}
