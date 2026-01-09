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
  bool _isRegisteringAsAdmin = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Header Section (Remains same)
              _buildHeader(colorScheme, context),

              // Form Section
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: const CustomTextField(
                              name: 'first_name',
                              label: "First Name",
                              hint: "First Name",
                              prefixIcon: Icons.person_outline,
                            ),
                          ),
                          Gap(16.w),
                          Expanded(
                            child: const CustomTextField(
                              name: 'last_name',
                              label: "Last Name",
                              hint: "Last Name",
                              prefixIcon: Icons.person_outline,
                            ),
                          ),
                        ],
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

                      _buildAdminCheckbox(colorScheme),

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

                      // Optional Location Section
                      const CustomText(
                        "Location Information (Optional)",
                        variant: TextVariant.headlineMedium,
                        fontWeight: FontWeight.bold,
                      ),
                      Gap(16.h),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: const CustomTextField(
                              name: 'region',
                              label: "Region",
                              hint: "Region",
                              prefixIcon: Icons.map_outlined,
                            ),
                          ),
                          Gap(16.w),
                          Expanded(
                            child: const CustomTextField(
                              name: 'district',
                              label: "District",
                              hint: "District",
                              prefixIcon: Icons.location_city_outlined,
                            ),
                          ),
                        ],
                      ),
                      Gap(20.h),
                      const CustomTextField(
                        name: 'address',
                        label: "Address",
                        hint: "Residential Address",
                        prefixIcon: Icons.home_outlined,
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
                            final firstName = values?['first_name'] as String?;
                            final lastName = values?['last_name'] as String?;
                            final phone = values?['phone'] as String?;

                            // Optional fields
                            final region = values?['region'] as String?;
                            final district = values?['district'] as String?;
                            final address = values?['address'] as String?;

                            // Get admin status from state since it's outside the form builder

                            if (password != confirmPassword) {
                              CustomSnackbar.warning(
                                context,
                                message: "Passwords do not match. Please try again.",
                              );
                              return;
                            }

                            if (email != null && password != null && firstName != null && lastName != null && phone != null) {
                              try {
                                final authService = ref.read(authServiceProvider);
                                await authService.signUpWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                  firstName: firstName,
                                  lastName: lastName,
                                  phoneNumber: phone,
                                  address: address,
                                  district: district,
                                  region: region,
                                  isAdmin: _isRegisteringAsAdmin,
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
                                  // Check if it's a connectivity error
                                  if (e is NoInternetException) {
                                    CustomSnackbar.info(
                                      context,
                                      message: e.message,
                                    );
                                  } else {
                                    // Use Firebase error mapper for user-friendly messages
                                    CustomSnackbar.error(
                                      context,
                                      message: FirebaseErrorMapper.getErrorMessage(e),
                                    );
                                  }
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildAdminCheckbox(ColorScheme colorScheme) {
    return Row(
      children: <Widget>[
        SizedBox(
          height: 24.h,
          width: 24.w,
          child: Checkbox(
            value: _isRegisteringAsAdmin,
            onChanged: (value) {
              setState(() {
                _isRegisteringAsAdmin = value ?? false;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            side: BorderSide(
              color: colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
        Gap(8.w),
        CustomText(
          "Register as Admin",
          variant: TextVariant.bodyMedium,
          color: colorScheme.onSurface,
        ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme colorScheme, BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomText(
            "Already have an account? ",
            color: colorScheme.secondary,
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CustomText(
              "Sign In",
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: colorScheme.onSurface, // darkRed
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(60.r),
          bottomRight: Radius.circular(60.r),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Gap(60.h),
            // Back Button
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20.r,
                  ),
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
              "Join the C.Q.A.A.G quality control team",
              variant: TextVariant.bodyMedium,
              // Using withValues as requested
              color: colorScheme.secondary.withValues(alpha: 0.9),
            ),
            Gap(40.h),
          ],
        ),
      ),
    );
  }
}
