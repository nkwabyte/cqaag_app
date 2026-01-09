import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class AppDialogs {
  static void showLoading(
    BuildContext context, {
    String message = "Please wait...",
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
                Gap(20.h),
                CustomText(message, variant: TextVariant.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) => context.pop();
}

enum DialogType { success, error, info }

class StatusDialog extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onConfirm;

  const StatusDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.buttonText = "Done",
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData getIcon() {
      switch (type) {
        case DialogType.success:
          return Icons.check_circle_outline;
        case DialogType.error:
          return Icons.error_outline;
        case DialogType.info:
          return Icons.info_outline;
      }
    }

    Color getColor() {
      switch (type) {
        case DialogType.success:
          return Colors.green;
        case DialogType.error:
          return colorScheme.error;
        case DialogType.info:
          return colorScheme.primary;
      }
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Gap(10.h),
          Icon(getIcon(), size: 60.r, color: getColor()),
          Gap(20.h),
          CustomText(title, variant: TextVariant.headlineMedium, textAlign: TextAlign.center),
          Gap(10.h),
          CustomText(
            message,
            variant: TextVariant.bodyMedium,
            textAlign: TextAlign.center,
            color: colorScheme.secondary,
          ),
          Gap(30.h),
          CustomButton(
            text: buttonText,
            onPressed: onConfirm ?? () => context.pop(),
          ),
        ],
      ),
    );
  }
}
