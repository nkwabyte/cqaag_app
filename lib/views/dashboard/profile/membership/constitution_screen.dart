import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class ConstitutionScreen extends StatefulWidget {
  static const String id = 'constitution_screen';

  const ConstitutionScreen({super.key});

  @override
  State<ConstitutionScreen> createState() => _ConstitutionScreenState();
}

class _ConstitutionScreenState extends State<ConstitutionScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: <Widget>[
          // 1. Curved Header with Back Button
          _buildHeader(colorScheme, context),

          // 2. Constitution Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preamble Section
                  _buildSectionTitle("Preamble"),
                  CustomText(
                    "WE, the Cashew Quality Analysts’ Association, Ghana, recognizing the cashew industry as a vital pillar of our nation's economy... do hereby establish this Association to promote professional development, ethical practices, and sustainability.",
                    variant: TextVariant.bodyMedium,
                    textAlign: TextAlign.justify,
                    color: colorScheme.secondary,
                  ), //
                  Gap(24.h),

                  // Article 1: Identity & Vision
                  _buildArticleHeader("Article 1: Name, Vision & Missions"),
                  _buildSubSection("Motto", "Guardians of Ghana’s Cashew Quality"), // [cite: 272]
                  _buildSubSection(
                    "Vision",
                    "A Ghana where every cashew nut meets global excellence standards through skilled, ethical, and innovative practices.",
                  ), // [cite: 258]
                  _buildSubSection(
                    "Core Values",
                    "Integrity, Excellence, Sustainability, Professionalism, Collaboration, and Community Empowerment.",
                  ), // [cite: 273-281]
                  Gap(24.h),

                  // Article 2: Membership
                  _buildArticleHeader("Article 2: Membership"),
                  _buildSubSection(
                    "Categories",
                    "• Full Members (Licensed Professionals with voting rights)\n"
                        "• Associate Members (Trainees/Affiliates)\n"
                        "• Corporate Members (Labs/Processors)\n"
                        "• Honorary Members (Distinguished Nominations)",
                  ), //
                  _buildSubSection(
                    "Eligibility",
                    "Open to individuals and entities demonstrating genuine interest in Association objectives and agreeing to abide by the Constitution.",
                  ), // [cite: 320-323]
                  Gap(24.h),

                  // Article 3: Governance
                  _buildArticleHeader("Article 3: Governance Structure"),
                  _buildSubSection(
                    "General Assembly",
                    "The supreme body comprising all members; responsible for policy approval, Board elections, and report reviews.",
                  ), // [cite: 385-387]
                  _buildSubSection(
                    "Board of Directors",
                    "Serves as the primary oversight and strategic body, acting as trustees for the Association's assets and missions.",
                  ), // [cite: 433-435]
                  _buildSubSection(
                    "Chapters",
                    "Regional units (Sampa, Drobo-Dormaa, Techiman-Bole, Tema-Port) facilitating localized member engagement.",
                  ), // [cite: 547-548]
                  Gap(24.h),

                  // Article 4: Meetings
                  _buildArticleHeader("Article 4: Meetings"),
                  _buildSubSection(
                    "AGM & ADM",
                    "Annual General or Delegates Meetings held once every calendar year to review performance and discuss strategic matters.",
                  ), // [cite: 580, 606]
                  Gap(24.h),

                  // Article 5: Financial Provisions
                  _buildArticleHeader("Article 5: Funding"),
                  _buildSubSection(
                    "Sources",
                    "Derived from membership registration fees, annual dues, special levies, training proceeds, and approved grants.",
                  ), // [cite: 692-698]
                  _buildSubSection(
                    "Transparency",
                    "All external funding is subject to Board review to ensure independence and integrity are not compromised.",
                  ), //
                  Gap(24.h),

                  // Article 7: Supremacy
                  _buildArticleHeader("Article 7: Supremacy"),
                  _buildSubSection(
                    "Legal Standing",
                    "This Constitution is the supreme governing document. Any bylaws or actions inconsistent with it shall be null and void.",
                  ), //

                  Gap(12.h),
                  const Divider(),
                  Gap(24.h),

                  // Status Indicator
                  _buildLegalNotice(colorScheme),
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
                const CustomText("Back to Profile", color: Colors.white),
              ],
            ),
          ),
          Gap(24.h),
          const CustomText(
            "Association Constitution",
            variant: TextVariant.displaySmall,
            color: Colors.white,
          ),
          Gap(8.h),
          CustomText(
            "Established 2025 • Republic of Ghana",
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

  Widget _buildArticleHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: CustomText(
        title,
        variant: TextVariant.headlineMedium,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF591a04), // darkBrown
      ),
    );
  }

  Widget _buildSubSection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          variant: TextVariant.bodyLarge,
          fontWeight: FontWeight.bold,
        ),
        Gap(4.h),
        CustomText(
          content,
          variant: TextVariant.bodyMedium,
          textAlign: TextAlign.justify,
        ),
        Gap(20.h),
      ],
    );
  }

  Widget _buildLegalNotice(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            "Legal Notice",
            variant: TextVariant.headlineMedium,
            fontWeight: FontWeight.bold,
          ),
          Gap(12.h),
          const CustomText(
            "Every member of the Board, Executive, or Committee is indemnified by the Association against costs incurred in the good-faith discharge of their duties.",
            variant: TextVariant.bodySmall,
          ), //
        ],
      ),
    );
  }
}
