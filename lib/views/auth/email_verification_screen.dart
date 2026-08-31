import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  static const String id = 'email_verification_screen';
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _resendCooldown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkVerificationStatus() async {
    setState(() => _isChecking = true);
    try {
      final isVerified = await ref.read(authServiceProvider).reloadAndCheckEmailVerified();
      if (!mounted) return;

      if (isVerified) {
        CustomSnackBar.success(
          context,
          message: "Email successfully verified! Welcome to CQAAG.",
        );
        context.go('/${DashboardScreen.id}');
      } else {
        CustomSnackBar.info(
          context,
          message: "Your email is not verified yet. Please check your inbox and click the verification link.",
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(
          context,
          message: "Failed to check verification status: ${e.toString()}",
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0) return;

    setState(() => _isResending = true);
    try {
      await ref.read(authServiceProvider).sendEmailVerification();
      if (mounted) {
        CustomSnackBar.success(
          context,
          message: "Verification email sent. Please check your inbox and spam folder.",
        );
        _startCooldown();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(
          context,
          message: "Unable to resend email. Please try again in a few moments.",
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _signOut() async {
    AppDialogs.showLoading(context);
    try {
      await ref.read(authServiceProvider).signOut();
      if (mounted) {
        AppDialogs.hide(context);
        context.go('/${LoginScreen.id}');
      }
    } catch (_) {
      if (mounted) {
        AppDialogs.hide(context);
        context.go('/${LoginScreen.id}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = ref.watch(authServiceProvider).currentUser;
    final userEmail = currentUser?.email ?? "your email address";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              decoration: BoxDecoration(
                color: colorScheme.onSurface,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.r),
                  bottomRight: Radius.circular(50.r),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Gap(20.h),
                  Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.tcdaVibrantGreen, width: 2),
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      color: AppColors.mintLight,
                      size: 40.r,
                    ),
                  ),
                  Gap(16.h),
                  const CustomText(
                    "Verify Your Email",
                    variant: TextVariant.displaySmall,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(8.h),
                  CustomText(
                    "Action Required for Security",
                    variant: TextVariant.bodySmall,
                    color: AppColors.mintLight.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),

            // Content Body
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Gap(10.h),
                  CustomText(
                    "We have sent a verification link to:",
                    variant: TextVariant.bodyMedium,
                    textAlign: TextAlign.center,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  Gap(8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.passGreen.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.tcdaAccentGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.email_outlined, size: 18.r, color: AppColors.primaryGreen),
                        Gap(8.w),
                        Flexible(
                          child: CustomText(
                            userEmail,
                            variant: TextVariant.bodyLarge,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(20.h),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 20.r),
                            Gap(10.w),
                            Expanded(
                              child: CustomText(
                                "Please open your email inbox (or spam folder) and tap the link to confirm this email belongs to you.",
                                variant: TextVariant.bodySmall,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        Gap(10.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lock_reset_outlined, color: AppColors.primaryGreen, size: 20.r),
                            Gap(10.w),
                            Expanded(
                              child: CustomText(
                                "This ensures you can always recover your account, receive password reset codes, and receive official notifications.",
                                variant: TextVariant.bodySmall,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Gap(30.h),

                  // I Have Verified Button
                  CustomButton(
                    text: _isChecking ? "Checking Status..." : "I've Verified My Email",
                    isLoading: _isChecking,
                    onPressed: () => _checkVerificationStatus(),
                  ),
                  Gap(16.h),

                  // Resend Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: (_isResending || _resendCooldown > 0) ? null : _resendVerificationEmail,
                      child: _isResending
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            )
                          : CustomText(
                              _resendCooldown > 0
                                  ? "Resend Email in (${_resendCooldown}s)"
                                  : "Resend Verification Link",
                              variant: TextVariant.bodyMedium,
                              fontWeight: FontWeight.w600,
                              color: _resendCooldown > 0 ? Colors.grey : AppColors.primaryGreen,
                            ),
                    ),
                  ),
                  Gap(20.h),

                  // Wrong Email / Sign Out
                  TextButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
                    label: const CustomText(
                      "Wrong Email? Sign Out & Re-register",
                      variant: TextVariant.bodySmall,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
