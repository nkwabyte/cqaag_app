import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  static const String id = 'forgot_password_screen';
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _handleReset(BuildContext context) async {
    UIHelpers.dismissKeyboard(context);
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final email = _formKey.currentState?.value['email'] as String?;

      if (email == null || email.isEmpty) {
        CustomSnackBar.warning(
          context,
          message: "Please enter your email address",
        );
        return;
      }

      // Show loading dialog
      AppDialogs.showLoading(context);

      try {
        // Call auth service to send password reset email
        await ref.read(authServiceProvider).resetPassword(email);

        if (context.mounted) {
          AppDialogs.hide(context);

          // Show success dialog
          showDialog(
            context: context,
            builder: (context) => StatusDialog(
              type: DialogType.success,
              title: "Email Sent",
              message: "We've sent a password reset link to $email. Please check your inbox.",
              onConfirm: () {
                context.pop(); // Close dialog
                context.pop(); // Go back to login
              },
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppDialogs.hide(context);

          // Check if it's a connectivity error
          if (e is NoInternetException) {
            CustomSnackBar.info(
              context,
              message: e.message,
            );
          } else {
            // Use Firebase error mapper for user-friendly messages
            CustomSnackBar.error(
              context,
              message: FirebaseErrorMapper.getErrorMessage(e),
            );
          }
        }
      }
    } else {
      CustomSnackBar.warning(
        context,
        message: "Please fill in all required fields",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Reusing the Login Header Style
            Container(
              width: double.infinity,
              height: 280.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurface, // darkRed
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60.r),
                  bottomRight: Radius.circular(60.r),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Gap(40.h),
                  const CustomText(
                    "Forgot Password",
                    variant: TextVariant.displaySmall,
                    color: Colors.white,
                  ),
                  Gap(12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: CustomText(
                      "Enter your email address to receive a password reset link",
                      variant: TextVariant.bodyMedium,
                      textAlign: TextAlign.center,
                      color: colorScheme.secondary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.r),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Gap(20.h),
                    const CustomTextField(
                      name: 'email',
                      label: "Email Address",
                      hint: "Enter your registered email",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
                    Gap(40.h),
                    CustomButton(
                      text: "Send Reset Link",
                      onPressed: () => _handleReset(context),
                    ),
                    Gap(20.h),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: CustomText(
                        "Back to Login",
                        variant: TextVariant.bodyLarge,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
