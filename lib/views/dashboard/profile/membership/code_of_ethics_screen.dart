import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class CodeOfEthicsScreen extends StatefulWidget {
  static const String id = 'code_ethics_screen';

  const CodeOfEthicsScreen({super.key});

  @override
  State<CodeOfEthicsScreen> createState() => _CodeOfEthicsScreenState();
}

class _CodeOfEthicsScreenState extends State<CodeOfEthicsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // 1. Curved Header with Back Button
          _buildHeader(colorScheme, context),

          // 2. Ethics Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preamble
                  _buildSectionTitle("Preamble"),
                  CustomText(
                    "Members of the Cashew Quality Analysts’ Association, Ghana (C.Q.A.A.G) proudly serve as Guardians of Ghana’s Cashew Quality. This Code establishes the highest standards of professional conduct.",
                    variant: TextVariant.bodyLarge,
                    color: colorScheme.secondary,
                  ),
                  Gap(24.h),

                  // Articles
                  _buildArticle(
                    "Article 1: Integrity and Impartiality",
                    "1.1 Members shall perform analysis with unwavering honesty, accuracy, and freedom from bias.\n"
                        "1.2 Members shall avoid conflicts of interest.\n"
                        "1.3 Members shall reject bribes, gifts, or inducements.",
                  ),
                  _buildArticle(
                    "Article 2: Professional Excellence",
                    "2.1 Members shall maintain technical competence through ongoing education.\n"
                        "2.2 Members shall conduct analyses using approved national and international methods (e.g., KOR assessment).",
                  ),
                  _buildArticle(
                    "Article 3: Sustainability",
                    "3.1 Members shall support environmentally responsible practices in cashew farming.\n"
                        "3.2 Members shall advocate for reduced waste and good agricultural practices.",
                  ),
                  _buildArticle(
                    "Article 4: Fairness and Equity",
                    "4.1 Members shall treat all stakeholders—farmers, traders, and processors—with respect and without discrimination.",
                  ),
                  _buildArticle(
                    "Article 5: Collaboration",
                    "5.1 Members shall collaborate constructively with regulators (TCDA) and international partners.",
                  ),
                  _buildArticle(
                    "Article 6: Compliance",
                    "6.1 Members shall comply with this Code, the Association’s Constitution, and the laws of Ghana.",
                  ),

                  Gap(12.h),
                  const Divider(),
                  Gap(24.h),

                  // Final Declaration Box
                  _buildDeclarationCard(colorScheme),
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
            "Code of Ethics",
            variant: TextVariant.displaySmall,
            color: Colors.white,
          ),
          Gap(8.h),
          CustomText(
            "Guardians of Ghana’s Cashew Quality",
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

  Widget _buildArticle(String title, String content) {
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

  Widget _buildDeclarationCard(ColorScheme colorScheme) {
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
            "Declaration",
            variant: TextVariant.headlineMedium,
            fontWeight: FontWeight.bold,
          ),
          Gap(12.h),
          const CustomText(
            "I have read, understood, and fully accept the Code of Ethics. I commit to abide by all provisions to uphold the Association’s core values of Integrity, Excellence, and Professionalism.",
            variant: TextVariant.bodyMedium,
          ),
        ],
      ),
    );
  }
}
