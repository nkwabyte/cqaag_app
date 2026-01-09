import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static final String id = "register_screen";
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Header Section (Remains same)
              _buildHeader(colorScheme, context),

              // Form Section
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomTextField(
                      name: 'full_name',
                      label: "Full Name",
                      hint: "Enter your full name",
                      prefixIcon: Icons.person_outline,
                    ),
                    Gap(20.h),
                    const CustomTextField(
                      name: 'email',
                      label: "Email Address",
                      hint: "Enter your email",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
                    Gap(20.h),
                    const CustomTextField(
                      name: 'phone',
                      label: "Phone Number",
                      hint: "Enter your phone number",
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    Gap(20.h),

                    const CustomText("Role", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
                    Gap(8.h),
                    _buildRoleDropdown(colorScheme),

                    Gap(20.h),
                    const CustomTextField(
                      name: 'password',
                      label: "Password",
                      hint: "Create a password",
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    Gap(4.h),
                    CustomText(
                      "Must be at least 8 characters",
                      variant: TextVariant.bodySmall,
                      color: colorScheme.secondary.withValues(alpha: 0.8),
                    ),

                    Gap(20.h),
                    const CustomTextField(
                      name: 'confirm_password',
                      label: "Confirm Password",
                      hint: "Confirm your password",
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                    ),

                    Gap(30.h),
                    CustomButton(
                      text: "Continue to Verification",
                      onPressed: () async {
                        UIHelpers.dismissKeyboard(context);
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final values = _formKey.currentState?.value;
                          final email = values?['email'] as String?;
                          final password = values?['password'] as String?;
                          final confirmPassword = values?['confirm_password'] as String?;
                          final fullName = values?['full_name'] as String?;
                          final phone = values?['phone'] as String?;
                          // final role = values?['role'] as String?; // Capture role if needed

                          if (password != confirmPassword) {
                            CustomSnackbar.warning(
                              context,
                              message: "Passwords do not match. Please try again.",
                            );
                            return;
                          }

                          if (email != null && password != null && fullName != null && phone != null) {
                            // Simple split for first/last name
                            final names = fullName.trim().split(' ');
                            final firstName = names.isNotEmpty ? names.first : '';
                            final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

                            try {
                              final authService = ref.read(authServiceProvider);
                              await authService.signUpWithEmailAndPassword(
                                email: email,
                                password: password,
                                firstName: firstName,
                                lastName: lastName,
                                phoneNumber: phone,
                              );

                              if (context.mounted) {
                                CustomSnackbar.success(
                                  context,
                                  message: "Account created successfully!",
                                );
                                // Navigate to Terms and Conditions before dashboard
                                context.go('/${TermsAndConditionsScreen.id}');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                CustomSnackbar.error(
                                  context,
                                  message: e.toString(),
                                );
                              }
                            }
                          }
                        }
                      },
                    ),
                    Gap(30.h),
                    _buildFooter(colorScheme, context),
                    Gap(20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildRoleDropdown(ColorScheme colorScheme) {
    return FormBuilderDropdown<String>(
      name: 'role',
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.work_outline, color: colorScheme.secondary, size: 20.r),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.secondary),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      initialValue: null,
      hint: CustomText("Select your role", color: colorScheme.secondary.withValues(alpha: 0.6)),
      items: [
        "Analyst",
        "Manager",
        "Supervisor",
      ].map((val) => DropdownMenuItem(value: val, child: CustomText(val))).toList(),
    );
  }

  Widget _buildFooter(ColorScheme colorScheme, BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText("Already have an account? ", color: colorScheme.secondary),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CustomText("Sign In", fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, BuildContext context) {
    return // 1. Header Section
    Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: colorScheme.onSurface, // darkRed
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(60.r),
          bottomRight: Radius.circular(60.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Gap(60.h),
          // Back Button
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 20.r),
                Gap(8.w),
                const CustomText(
                  "Back to Login",
                  variant: TextVariant.bodyMedium,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Gap(30.h),
          const CustomText(
            "Create Account",
            variant: TextVariant.displaySmall,
            color: Colors.white,
          ),
          Gap(8.h),
          CustomText(
            "Join the CQAAG quality control team",
            variant: TextVariant.bodyMedium,
            // Using withValues as requested
            color: colorScheme.secondary.withValues(alpha: 0.9),
          ),
          Gap(40.h),
        ],
      ),
    );
  }
}
