import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

enum ButtonVariant { filled, outlined }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.filled,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on variant and user input
    final bool isOutlined = variant == ButtonVariant.outlined;

    final Color effectiveBgColor = backgroundColor ?? (isOutlined ? Colors.transparent : colorScheme.primary);

    final Color effectiveTextColor = textColor ?? (isOutlined ? colorScheme.primary : colorScheme.onPrimary);

    final Color effectiveBorderColor = borderColor ?? (isOutlined ? colorScheme.primary : Colors.transparent);

    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width ?? double.infinity,
        height: height ?? 56.h,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          border: Border.all(
            color: effectiveBorderColor,
            width: isOutlined ? 1.5.w : 0,
          ),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 24.h,
                  width: 24.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leadingIcon != null) ...[
                      leadingIcon!,
                      Gap(10.w),
                    ],
                    Flexible(
                      child: CustomText(
                        text,
                        variant: TextVariant.labelLarge,
                        color: effectiveTextColor,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      Gap(10.w),
                      trailingIcon!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
