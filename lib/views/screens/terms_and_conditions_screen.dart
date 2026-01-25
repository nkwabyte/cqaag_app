import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cqaag_app/index.dart';

class TermsAndConditionsScreen extends HookConsumerWidget {
  static const String id = 'terms_conditions_screen';

  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(currentUserProfileProvider).value;
    final isAuthenticated = user != null;

    final isLoading = useState(false);

    Future<void> handleAcceptance() async {
      if (isAuthenticated) {
        try {
          isLoading.value = true;
          await ref.read(userServiceProvider).updateUserData(user.id, {'has_accepted_terms': true});
          if (context.mounted) {
            context.goNamed(DashboardScreen.id);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating profile: $e')),
            );
          }
        } finally {
          isLoading.value = false;
        }
      } else {
        context.goNamed(DashboardScreen.id);
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Column(
        children: <Widget>[
          // 1. Focused Header (No Back Button)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: AppColors.darkRed,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50.r),
                bottomRight: Radius.circular(50.r),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Gap(40.h),
                  Row(
                    children: [
                      if (isAuthenticated)
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back, color: Colors.white, size: 20.r),
                              Gap(8.w),
                              const CustomText("Back", color: Colors.white),
                            ],
                          ),
                        ),
                      Gap(24.h),
                    ],
                  ),
                  Gap(12.h),
                  const CustomText(
                    "Terms of Service",
                    variant: TextVariant.displaySmall,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                  ),
                  Gap(12.h),
                  CustomText(
                    "Effective Date: January 05, 2026",
                    variant: TextVariant.bodySmall,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  Gap(40.h),
                ],
              ),
            ),
          ),

          // 2. Scrollable Terms Content
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomText(
                      "By using the C.Q.A.A.G Platform, you agree to be bound by these Terms. If you do not agree, please do not use the service.",
                      variant: TextVariant.bodyLarge,
                      color: colorScheme.secondary,
                    ),
                    Gap(24.h),
                    _buildLegalSection(
                      "1. Acceptance of Terms",
                      "These Terms constitute a binding agreement between you and C.Q.A.A.G. Continued use of the platform after changes constitutes acceptance of updated Terms.",
                    ),
                    _buildLegalSection(
                      "2. Authorized Use",
                      "You may use this platform for lawful, professional purposes including quality inspections, reporting, and accessing association resources.",
                    ),
                    _buildLegalSection(
                      "3. User Conduct",
                      "You agree not to violate Ghanaian law, disrupt servers, or upload malicious code. Unauthorized access to data is strictly prohibited.",
                    ),
                    _buildLegalSection(
                      "4. Intellectual Property",
                      "All content, including text, logos, and report formats, is owned by C.Q.A.A.G. Reproduction without written permission is prohibited.",
                    ),
                    _buildLegalSection(
                      "5. Membership Data",
                      "You are responsible for maintaining the confidentiality of your login credentials and providing accurate professional information.",
                    ),
                    _buildLegalSection(
                      "6. Limitation of Liability",
                      "C.Q.A.A.G is not liable for indirect or incidental damages arising from platform use. Our liability is limited to fees paid in the last 12 months.",
                    ),
                    _buildLegalSection(
                      "7. Governing Law",
                      "These Terms are governed by the laws of the Republic of Ghana. Any disputes shall be resolved in Ghanaian courts.",
                    ),
                    Gap(20.h),
                    const Divider(),
                    Gap(20.h),
                    _buildContactSection(colorScheme),
                    Gap(40.h),
                  ],
                ),
              ),
            ),
          ),

          // 3. Acceptance Footer - Only show if not accepted yet
          if (isAuthenticated && !user.hasAcceptedTerms || !isAuthenticated)
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: CustomButton(
                text: "I Accept and Continue to Dashboard",
                isLoading: isLoading.value,
                onPressed: handleAcceptance,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomText(
          title,
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        Gap(8.h),
        CustomText(
          content,
          variant: TextVariant.bodyMedium,
          textAlign: TextAlign.justify,
        ),
        Gap(24.h),
      ],
    );
  }

  Widget _buildContactSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const CustomText(
          "Contact Us",
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        Gap(12.h),
        Row(
          children: <Widget>[
            Icon(Icons.email_outlined, size: 18.r, color: colorScheme.primary),
            Gap(12.w),
            const CustomText("info@cqaag.org", variant: TextVariant.bodyMedium),
          ],
        ),
      ],
    );
  }
}
