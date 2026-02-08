import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class ChaptersScreen extends StatelessWidget {
  static const String id = 'chapters_screen';

  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkRed,
        title: const CustomText(
          'Our Chapters',
          variant: TextVariant.bodyLarge,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              decoration: BoxDecoration(
                color: AppColors.darkRed,
              ),
              child: const Center(
                child: CustomText(
                  'Our Chapters',
                  variant: TextVariant.displayMedium,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Portal Intro
                  Center(
                    child: CustomText(
                      'Regional Chapters Portal',
                      variant: TextVariant.headlineMedium,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Gap(16.h),
                  const CustomText(
                    'The Chapters Portal is a dedicated section of the CQAAG website designed to highlight the association\'s regional structure, promote localized engagement, and provide easy access to Chapter-specific information. As per Article 3 of the Constitution, CQAAG operates through four semi-autonomous regional Chapters based on key cashew production zones and logistical hubs.',
                    variant: TextVariant.bodyMedium,
                    textAlign: TextAlign.justify,
                  ),
                  Gap(24.h),

                  // Map Placeholder
                  Container(
                    height: 250.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 60.r, color: Colors.grey.shade400),
                        Gap(8.h),
                        CustomText(
                          'Interactive Map Loading...',
                          variant: TextVariant.bodyMedium,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                  ),

                  Gap(32.h),

                  // Initiative Box
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), // Light green bg
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          'Current Initiative: Door-to-Door Campaign',
                          variant: TextVariant.headlineSmall,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                        Gap(8.h),
                        RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium,
                            children: [
                              const TextSpan(
                                text: 'Focus: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: 'Farmer and Aggregator Sensitization on Quality & Moisture Control'),
                            ],
                          ),
                        ),
                        Gap(12.h),
                        const CustomText(
                          'In line with Objective 3 and 7, C.Q.A.A.G is rolling out a nationwide door-to-door campaign targeting cashew farmers and aggregators. This initiative runs until the end of January 2026.',
                          variant: TextVariant.bodyMedium,
                        ),
                        Gap(12.h),
                        _buildBulletPoint('Goal: Educate on proper drying (≤10% moisture), Good Agricultural Practices (GAP), and aflatoxin risks.'),
                        _buildBulletPoint('Action: Chapter teams are visiting farms and warehouses to demonstrate quality testing.'),
                        _buildBulletPoint('Outcome: Data collection for the 2026 moisture control project and increased professional licensing.'),
                      ],
                    ),
                  ),

                  Gap(48.h),

                  // Welfare Section
                  _buildSectionHeader('Welfare and Benevolent Fund Guidelines'),
                  Gap(8.h),
                  const CustomText(
                    'In line with Article 5 of the Constitution and our core value of Community Empowerment.',
                    variant: TextVariant.bodySmall,
                    color: AppColors.darkBrown,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(24.h),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildBorderedCard(
                          title: 'Purpose & Beneficiaries',
                          content:
                              'To provide timely financial and moral support to members facing hardship. Priority is given to Full Members in good standing and vulnerable groups (women, youth).',
                        ),
                      ),
                      Gap(16.w),
                      Expanded(
                        child: _buildBorderedCard(
                          title: 'Sources of Fund',
                          bullets: [
                            'Percentage of annual dues (10-15%).',
                            'Voluntary contributions and levies.',
                            'Donations and fundraising events.',
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(24.h),

                  CustomText(
                    'Categories of Assistance',
                    variant: TextVariant.headlineSmall,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                  Gap(16.h),
                  _buildTwoColumnBullets([
                    'Bereavement: Member or immediate family.',
                    'Serious Illness: Hospitalization costs.',
                    'Accident/Disability: Loss of income support.',
                    'Natural Disasters: Floods/fire impacting livelihood.',
                    'Retirement: One-time support (min. 10 years service).',
                  ]),

                  Gap(24.h),
                  // Button
                  Center(
                    child: CustomButton(
                      text: 'Download Full Welfare Guide',
                      onPressed: () {}, // TODO: Implement download
                      backgroundColor: AppColors.darkBrown,
                      textColor: Colors.white,
                      width: 280.w,
                      trailingIcon: const Icon(Icons.file_download, color: Colors.white),
                    ),
                  ),

                  Gap(60.h),

                  // Regional Chapters
                  Center(
                    child: CustomText(
                      'Our Regional Chapters',
                      variant: TextVariant.headlineMedium,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  Gap(32.h),

                  // 1. Sampa
                  _buildChapter(
                    number: '1',
                    name: 'Sampa Chapter',
                    coverage: 'Jaman North, Banda, Tain, Berekum East/West, Sunyani Municipality.',
                    executiveOfficers: [
                      {'role': 'Chair', 'name': 'Mr. Kwame Asante', 'email': 'Email'},
                      {'role': 'Vice-Chair', 'name': '[Name]', 'email': 'Email'},
                      {'role': 'Organizer', 'name': '[Name]', 'email': 'Email'},
                      {'role': 'Secretary', 'name': '[Name]', 'email': 'Email'},
                      {'role': 'Treasurer', 'name': '[Name]', 'email': 'Email'},
                    ],
                    committees: [
                      {'item': 'Membership: [Name]'},
                      {'item': 'Programs & Events: [Name]'},
                      {'item': 'Welfare & Benevolent: [Name] (Email)'},
                      {'item': 'Data Research: [Name]'},
                    ],
                  ),
                  Gap(48.h),

                  // 2. Drobo-Dormaa
                  _buildChapter(
                    number: '2',
                    name: 'Drobo-Dormaa Chapter',
                    coverage: 'Jaman South, Dormaa (Central, East, West), Western North Region, Ahafo Region.',
                    executiveOfficers: [
                      {'role': 'Chair', 'name': 'Mr. Kwame Asante', 'email': 'Email'},
                      {'role': 'Vice-Chair', 'name': '[Name]', 'email': 'Email'},
                      {'role': 'Organizer', 'name': '[Name]', 'email': 'Email'},
                      {'role': 'Secretary', 'name': '[Name]', 'email': 'Email'},
                      {'role': 'Treasurer', 'name': '[Name]', 'email': 'Email'},
                    ],
                    committees: [
                      {'item': 'Membership: [Name]'},
                      {'item': 'Programs & Events: [Name]'},
                      {'item': 'Welfare & Benevolent: [Name] (Email)'},
                      {'item': 'Data Research: [Name]'},
                    ],
                  ),
                  Gap(48.h),

                  // 3. Techiman-Bole
                  _buildChapter(
                    number: '3',
                    name: 'Techiman-Bole Chapter (HQ)',
                    coverage: 'Wenchi, Bono East, Savanna Region, Northern Regions (North East, Upper East, Upper West).',
                    executiveOfficers: [
                      {'role': 'Chair', 'name': 'Mr. Kwame Asante', 'email': 'Email'},
                      {'role': 'Vice-Chair', 'name': '[Name]', 'email': 'Email'},
                      {'role': 'Organizer', 'name': '[Name]', 'email': 'Email'},
                      {'role': 'Secretary', 'name': '[Name]', 'email': 'Email'},
                      {'role': 'Treasurer', 'name': '[Name]', 'email': 'Email'},
                    ],
                    committees: [
                      {'item': 'Membership: [Name]'},
                      {'item': 'Programs & Events: [Name]'},
                      {'item': 'Welfare & Benevolent: [Name] (Email)'},
                      {'item': 'Data Research: [Name]'},
                    ],
                  ),

                  Gap(48.h),

                  // 4. Tema-Port
                  _buildChapter(
                    number: '4',
                    name: 'Tema-Port Chapter',
                    coverage: 'Volta to Eastern Region, Ashanti to Western Region, Greater Accra Region (Export Hubs).',
                    executiveOfficers: [
                      {'role': 'Chair', 'name': 'Mr. Kwame Asante', 'email': 'Email'},
                      {'role': 'Vice-Chair', 'name': '[Name]', 'email': 'Email'},
                      {'role': 'Organizer', 'name': '[Name]', 'email': 'Email'},
                      {'role': 'Secretary', 'name': '[Name]', 'email': 'Email'},
                      {'role': 'Treasurer', 'name': '[Name]', 'email': 'Email'},
                    ],
                    committees: [
                      {'item': 'Membership: [Name]'},
                      {'item': 'Programs & Events: [Name]'},
                      {'item': 'Welfare & Benevolent: [Name] (Email)'},
                      {'item': 'Data Research: [Name]'},
                    ],
                  ),

                  Gap(60.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return CustomText(
      title,
      variant: TextVariant.headlineSmall,
      fontWeight: FontWeight.bold,
      color: AppColors.darkBrown,
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText('• ', variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
          Expanded(child: CustomText(text, variant: TextVariant.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildBorderedCard({required String title, String? content, List<String>? bullets}) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        // borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            variant: TextVariant.bodyLarge,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
          ),
          Gap(12.h),
          if (content != null) CustomText(content, variant: TextVariant.bodySmall),
          if (bullets != null)
            ...bullets.map(
              (b) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText('• ', variant: TextVariant.bodySmall),
                    Expanded(child: CustomText(b, variant: TextVariant.bodySmall)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnBullets(List<String> items) {
    // Split items into two halves
    final mid = (items.length / 2).ceil();
    final leftItems = items.sublist(0, mid);
    final rightItems = items.sublist(mid);

    Widget buildColumn(List<String> list) {
      return Column(
        children: list.map((item) {
          final parts = item.split(':');
          final title = parts[0];
          final desc = parts.length > 1 ? parts.sublist(1).join(':') : '';

          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText('• ', variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 13.sp),
                      children: [
                        TextSpan(
                          text: '$title:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: desc),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: buildColumn(leftItems)),
        Gap(16.w),
        Expanded(child: buildColumn(rightItems)),
      ],
    );
  }

  Widget _buildChapter({
    required String number,
    required String name,
    required String coverage,
    required List<Map<String, String>> executiveOfficers,
    required List<Map<String, String>> committees,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          '$number. $name',
          variant: TextVariant.headlineSmall,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBrown,
        ),
        Gap(8.h),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp),
            children: [
              const TextSpan(
                text: 'Geographic Coverage: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: coverage),
            ],
          ),
        ),
        Gap(32.h),

        // Two columns for Officers and Committees
        // Mobile view: Stack them, or try Row if space permits?
        // Design shows two columns. On small phones, might cramp. Let's use Column for safety mobile-first, or wide Row.
        Wrap(
          spacing: 24.w,
          runSpacing: 24.h,
          children: [
            SizedBox(
              width: 1.sw > 600 ? (1.sw - 80.w) / 2 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    'Executive Officers',
                    variant: TextVariant.headlineSmall,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                  Gap(16.h),
                  ...executiveOfficers.map(
                    (e) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 13.sp),
                          children: [
                            TextSpan(
                              text: '${e['role']}: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                            ),
                            TextSpan(text: '${e['name']} '),
                            TextSpan(
                              text: '(${e['email']})',
                              style: const TextStyle(decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 1.sw > 600 ? (1.sw - 80.w) / 2 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    'Key Committees',
                    variant: TextVariant.headlineSmall,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                  Gap(16.h),
                  ...committees.map(
                    (c) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: CustomText(
                        c['item'] ?? '',
                        variant: TextVariant.bodyMedium,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
