import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  static const String id = 'privacy_policy_screen';

  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // 1. Header with Back Button
          _buildHeader(colorScheme, context),

          // 2. Policy Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preamble
                  _buildSectionTitle("Privacy Commitment"),
                  CustomText(
                    "The Cashew Quality Analysts’ Association, Ghana (C.Q.A.A.G) is committed to safeguarding the privacy and security of our members, partners, and app users in accordance with Ghana's Data Protection Act, 2012 (Act 843).",
                    variant: TextVariant.bodyLarge,
                    color: colorScheme.secondary,
                  ),
                  Gap(24.h),

                  // Sections
                  _buildSection(
                    "1. Information We Collect",
                    "• Personal Identification: Name, phone number, email address, Ghana Card/ID number, and regional location.\n"
                    "• Professional Information: Quality analyst accreditation status, membership tier, and organization affiliation.\n"
                    "• Operational & Inspection Data: Cashew quality analysis records, Outturn Ratio (KOR) test reports, batch logs, and inspection location coordinates.\n"
                    "• Device & Technical Data: Device IP address, app usage statistics, operating system details, and system crash logs.",
                  ),

                  _buildSection(
                    "2. How We Use Your Information",
                    "• Account & Membership Management: To verify credentials, maintain association registries, and grant access to analyst tools.\n"
                    "• Quality Assurance & Traceability: To generate verifiable cashew inspection certificates and maintain national quality benchmarks.\n"
                    "• Communication: To issue official notices, policy updates, event invitations, and verification alerts.\n"
                    "• Regulatory Reporting: To provide aggregated quality statistics to regulatory bodies including the Tree Crop Development Authority (TCDA).",
                  ),

                  _buildSection(
                    "3. Data Sharing & Disclosure",
                    "• Regulators & Authorities: We may share inspection and quality compliance data with official agricultural regulators as required by law.\n"
                    "• Public Verification: Verification badges and official certificate numbers may be publicly verifiable via QR codes.\n"
                    "• No Commercial Sale: C.Q.A.A.G does not sell, rent, or trade your personal data to third-party advertisers.",
                  ),

                  _buildSection(
                    "4. Data Security & Storage",
                    "• Encryption: All data transmitted between your device and our servers is protected using TLS/HTTPS encryption.\n"
                    "• Access Controls: Access to personal data is restricted to authorized C.Q.A.A.G administrators and compliance officers.\n"
                    "• Retention: We retain your information for as long as your account is active or as needed to meet legal and audit obligations.",
                  ),

                  _buildSection(
                    "5. Your Data Protection Rights",
                    "• Access & Export: You have the right to request a copy of your personal data stored in the application.\n"
                    "• Correction: You can request updates or corrections to any inaccurate profile details.\n"
                    "• Deletion: You may request account deletion, subject to regulatory retention mandates for quality audit logs.",
                  ),

                  _buildSection(
                    "6. Contact & Data Protection Officer",
                    "For inquiries, data access requests, or privacy concerns, please contact the C.Q.A.A.G Data Protection Office:\n\n"
                    "• Email: privacy@cqaag.org / info@cqaag.org\n"
                    "• Phone: +233 (0) 302 000 000\n"
                    "• Address: C.Q.A.A.G Secretariat, Accra, Ghana",
                  ),

                  Gap(12.h),
                  const Divider(),
                  Gap(24.h),

                  // Security Summary Box
                  _buildSecurityCard(colorScheme),
                  Gap(40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 40.h),
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50.r),
          bottomRight: Radius.circular(50.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const CustomText(
            "Privacy Policy",
            variant: TextVariant.displaySmall,
            color: Colors.white,
          ),
          Gap(8.h),
          CustomText(
            "Data Protection & Privacy Policy • Act 843",
            variant: TextVariant.bodySmall,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: CustomText(
        title,
        variant: TextVariant.headlineMedium,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSection(String title, String content) {
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
          textAlign: TextAlign.left,
        ),
        Gap(24.h),
      ],
    );
  }

  Widget _buildSecurityCard(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: colorScheme.primary,
            size: 32.r,
          ),
          Gap(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  "Data Protection Assurance",
                  variant: TextVariant.headlineMedium,
                  fontWeight: FontWeight.bold,
                ),
                Gap(8.h),
                const CustomText(
                  "Your data is securely stored and processed in full compliance with Ghana's Data Protection Act (Act 843). Last updated: August 2026.",
                  variant: TextVariant.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
