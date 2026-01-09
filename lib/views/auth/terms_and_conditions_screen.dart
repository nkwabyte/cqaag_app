import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  static const String id = 'terms_conditions_screen';

  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // 1. Focused Header (No Back Button)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: colorScheme.onSurface, // AppColors.darkRed
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50.r),
                bottomRight: Radius.circular(50.r),
              ),
            ),
            child: Column(
              children: [
                Gap(80.h),
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

          // 2. Scrollable Terms Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "By using the CQAAG Platform, you agree to be bound by these Terms. If you do not agree, please do not use the service.",
                    variant: TextVariant.bodyLarge,
                    color: colorScheme.secondary,
                  ),
                  Gap(24.h),
                  _buildLegalSection(
                    "1. Acceptance of Terms",
                    "These Terms constitute a binding agreement between you and CQAAG. Continued use of the platform after changes constitutes acceptance of updated Terms.",
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
                    "All content, including text, logos, and report formats, is owned by CQAAG. Reproduction without written permission is prohibited.",
                  ),
                  _buildLegalSection(
                    "5. Membership Data",
                    "You are responsible for maintaining the confidentiality of your login credentials and providing accurate professional information.",
                  ),
                  _buildLegalSection(
                    "6. Limitation of Liability",
                    "CQAAG is not liable for indirect or incidental damages arising from platform use. Our liability is limited to fees paid in the last 12 months.",
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

          // 3. Acceptance Footer
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: CustomButton(
              text: "I Accept and Continue to Dashboard",
              onPressed: () {
                // Use context.goNamed to prevent back navigation to terms
                context.goNamed(DashboardScreen.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      children: [
        const CustomText(
          "Contact Us",
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        Gap(12.h),
        Row(
          children: [
            Icon(Icons.email_outlined, size: 18.r, color: colorScheme.primary),
            Gap(12.w),
            const CustomText("info@cqaag.org.gh", variant: TextVariant.bodyMedium),
          ],
        ),
      ],
    );
  }
}
