import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class CustomTextField extends StatefulWidget {
  final String name; // Required for FormBuilder
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;

  const CustomTextField({
    super.key,
    required this.name,
    required this.label,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          widget.label,
          variant: TextVariant.bodyLarge,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        Gap(8.h),
        FormBuilderTextField(
          name: widget.name,
          controller: widget.controller,
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          validator: widget.validator,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.secondary.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: colorScheme.secondary, size: 20.r)
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: colorScheme.secondary,
                      size: 20.r,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: colorScheme.secondary.withValues(alpha: 0.3),
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.secondary, width: 1.5.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.redAccent, width: 1.w),
            ),
          ),
        ),
      ],
    );
  }
}
