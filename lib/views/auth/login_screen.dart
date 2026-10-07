import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const String id = 'login';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    // Listen for auth errors
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          // Check if it's a connectivity error
          if (error is NoInternetException) {
            CustomSnackBar.info(
              context,
              message: error.message,
            );
          } else {
            // Use Firebase error mapper for user-friendly messages
            CustomSnackBar.error(
              context,
              message: FirebaseErrorMapper.getErrorMessage(error),
            );
          }
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 1. Curved Header Section
            Container(
              width: double.infinity,
              height: 300.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurface, // Using darkRed from theme
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60.r),
                  bottomRight: Radius.circular(60.r),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    colorScheme.onSurface,
                    colorScheme.onSurface.withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Gap(20.h),
                    SvgPicture.asset(
                      Assets.svgLogoWhite,
                      width: 100.w,
                    ),
                    Gap(6.h),
                    CustomText(
                      "Guardians of Ghana's Cashew Quality",
                      variant: TextVariant.bodySmall,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontStyle: FontStyle.italic,
                    ),
                    Gap(10.h),
                    const CustomText(
                      "Welcome Back",
                      variant: TextVariant.displaySmall,
                      color: Colors.white,
                    ),
                    Gap(8.h),
                    CustomText(
                      "Sign in to your C.Q.A.A.G account",
                      variant: TextVariant.bodyMedium,
                      color: colorScheme.secondary,
                    ),
                    Gap(10.0.h),
                  ],
                ),
              ),
            ),

            // 2. Form Section
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      CustomTextField(
                        label: "Email or Phone Number",
                        hint: "Enter your email or phone",
                        prefixIcon: Icons.email_outlined,
                        name: 'email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      Gap(20.h),
                      CustomTextField(
                        name: 'password',
                        label: "Password",
                        hint: "Enter your password",
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                      ),
                      Gap(12.h),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            context.pushNamed(ForgotPasswordScreen.id);
                          },
                          child: CustomText(
                            "Forgot Password?",
                            variant: TextVariant.bodyMedium,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),

                      Gap(30.h),

                      // Sign In Button
                      CustomButton(
                        text: "Sign In",
                        isLoading: isLoading,
                        onPressed: () {
                          UIHelpers.dismissKeyboard(context);
                          if (isLoading) return;
                          if (_formKey.currentState?.saveAndValidate() ?? false) {
                            final values = _formKey.currentState?.value;
                            final email = values?['email'] as String?;
                            final password = values?['password'] as String?;

                            if (email != null && password != null) {
                              ref.read(authControllerProvider.notifier).signIn(email, password).then((_) {
                                // Check if sign in was successful
                                if (context.mounted && !ref.read(authControllerProvider).hasError) {
                                  ref.invalidate(currentUserProfileProvider);
                                  CustomSnackBar.success(
                                    context,
                                    message: "Welcome back!",
                                    duration: const Duration(seconds: 2),
                                  );
                                  // Use context.go to prevent back navigation
                                  context.go('/${DashboardScreen.id}');
                                }
                              });
                            }
                          }
                        },
                      ),

                      Gap(30.h),

                      // 3. The "OR" Divider
                      Row(
                        children: <Widget>[
                          Expanded(child: Divider(color: colorScheme.secondary.withValues(alpha: 0.3))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: CustomText(
                              "OR",
                              variant: TextVariant.bodySmall,
                              color: colorScheme.secondary,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: colorScheme.secondary.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),

                      // Gap(30.h),

                      // // 4. Biometric Login Button
                      // CustomButton(
                      //   text: "Use Biometric Login",
                      //   variant: ButtonVariant.outlined,
                      //   borderColor: colorScheme.primary,
                      //   leadingIcon: Icon(Icons.fingerprint, color: colorScheme.primary),
                      //   onPressed: () {
                      //     /* Handle Biometric */
                      //   },
                      // ),
                      Gap(40.h),

                      // 5. Footer: Create Account
                      Center(
                        child: Column(
                          children: <Widget>[
                            CustomText(
                              "Don't have an account?",
                              variant: TextVariant.bodyMedium,
                              color: colorScheme.secondary,
                            ),
                            GestureDetector(
                              onTap: () {
                                context.pushNamed(RegisterScreen.id);
                              },
                              child: CustomText(
                                "Create Account",
                                variant: TextVariant.bodyLarge,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),

                            Gap(16.h),

                            // Apply for Membership Button
                            CustomButton(
                              text: "Apply for Membership",
                              backgroundColor: Colors.green.shade800,
                              onPressed: () => _explainApplying(context),
                            ),

                            Gap(16.h),

                            // Guest Mode opens the website in the device default browser
                            CustomButton(
                              text: "Guest Mode",
                              variant: ButtonVariant.outlined,
                              borderColor: colorScheme.secondary,
                              trailingIcon: Icon(Icons.open_in_new, size: 18.r, color: colorScheme.secondary),
                              onPressed: () async {
                                final opened = await WebsiteLauncher.open();
                                if (!opened && context.mounted) {
                                  CustomSnackBar.error(
                                    context,
                                    message: 'Could not open the C.Q.A.A.G website.',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Applying is done from an account, so the application, the signed
  /// agreements and the payment stay together, as on the website.
  void _explainApplying(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Gap(16.h),
              Icon(Icons.card_membership_outlined, color: Colors.green.shade800, size: 40.r),
              Gap(8.h),
              const CustomText(
                "Apply for Membership",
                variant: TextVariant.headlineMedium,
                fontWeight: FontWeight.bold,
              ),
              Gap(14.h),
              _buildStepRow(1, 'Create an account with your email, or sign in.'),
              Gap(8.h),
              _buildStepRow(2, 'Open Profile → Membership Application, fill it in and sign the agreements.'),
              Gap(8.h),
              _buildStepRow(3, 'Once approved by the Secretariat, pay online to activate — your credentials will be confirmed via email.'),
              Gap(20.h),
              CustomButton(
                text: "Create Account",
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  context.pushNamed(RegisterScreen.id);
                },
              ),
              Gap(10.h),
              CustomButton(
                text: "Apply on Website",
                variant: ButtonVariant.outlined,
                trailingIcon: Icon(Icons.open_in_new, size: 16.r),
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  WebsiteLauncher.open('${WebsiteLauncher.baseUrl}/membership/');
                },
              ),
              Gap(6.h),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: CustomText(
                  "I already have an account",
                  variant: TextVariant.bodyMedium,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22.r,
          height: 22.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.shade800.withValues(alpha: 0.3)),
          ),
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ),
        Gap(10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
