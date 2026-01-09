import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum TextVariant {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineMedium,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
}

class CustomText extends StatelessWidget {
  final String text;
  final TextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final int? maxLines;
  final FontStyle? fontStyle;

  const CustomText(
    this.text, {
    super.key,
    this.variant = TextVariant.bodyMedium,
    this.color,
    this.textAlign,
    this.fontWeight,
    this.maxLines,
    this.fontStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    TextStyle? getStyle() {
      switch (variant) {
        case TextVariant.displayLarge:
          return theme.displayLarge;
        case TextVariant.displayMedium:
          return theme.displayMedium;
        case TextVariant.displaySmall:
          return theme.displaySmall;
        case TextVariant.headlineMedium:
          return theme.headlineMedium;
        case TextVariant.bodyLarge:
          return theme.bodyLarge;
        case TextVariant.bodyMedium:
          return theme.bodyMedium;
        case TextVariant.bodySmall:
          return theme.bodySmall;
        case TextVariant.labelLarge:
          return theme.labelLarge;
      }
    }

    return AutoSizeText(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      style: getStyle()?.copyWith(
        // Pulls color from theme if not explicitly provided
        color: color ?? colorScheme.onSurface,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        fontSize: getStyle()?.fontSize?.sp,
      ),
    );
  }
}
