import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class ServicesScreen extends StatelessWidget {
  static const String id = 'services_screen';

  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkRed,
        title: const CustomText(
          'Our Services',
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
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              decoration: BoxDecoration(
                color: AppColors.darkRed,
              ),
              child: Column(
                children: [
                  const CustomText(
                    'Our Services',
                    variant: TextVariant.displayMedium,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(12.h),
                  CustomText(
                    'Explore the comprehensive services provided by C.Q.A.A.G in collaboration with our partners.',
                    variant: TextVariant.bodyMedium,
                    color: Colors.white.withValues(alpha: 0.9),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Services List
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  _buildServiceCard(
                    context,
                    title: 'Quality Inspection',
                    description:
                        'Our expert team, in close collaboration with the Tree Crops Development Authority (TCDA), conducts independent and rigorous quality inspections of raw cashew nuts (RCN) upon arrival, during dispatch, and prior to export. Inspections are performed at upcountry export warehouses and harbor facilities, covering key parameters including moisture content, kernel outturn ratio (KOR), defect identification, aflatoxin screening, and compliance with national/international standards.',
                    icon: Icons.youtube_searched_for,
                  ),
                  Gap(24.h),
                  _buildServiceCard(
                    context,
                    title: 'Arbitration Facilitation',
                    description:
                        'In partnership with TCDA and relevant stakeholders, we provide unbiased quality inspections and certifications to support dispute resolution. Our services help farmers, traders, exporters, and processors resolve quality-related conflicts through scientific evidence, facilitating fair mediation, arbitration, or litigation while promoting equitable practices in the cashew value chain.',
                    icon: Icons.gavel,
                  ),
                  Gap(24.h),
                  _buildServiceCard(
                    context,
                    title: 'Training Programs',
                    description:
                        'We deliver comprehensive, hands-on training programs in cashew quality analysis techniques, ethical practices, and sustainable handling. Participants receive practical instruction in cut testing, moisture analysis, aflatoxin detection, and more—followed by scoring and evaluation to prepare for professional licensing. Special priority is given to women and youth.',
                    icon: Icons.school,
                  ),
                  Gap(24.h),
                  _buildServiceCard(
                    context,
                    title: 'Get Licensed',
                    description:
                        'As the official professional association for cashew quality analysts in Ghana, we guide and facilitate the licensing process for our Full Members through the TCDA. Only licensed members (supported by CQAAG training and membership) are authorized to practice, ensuring the highest standards of professionalism and integrity.',
                    icon: Icons.card_membership,
                  ),
                  Gap(24.h),
                  _buildServiceCard(
                    context,
                    title: 'Certification',
                    description:
                        'We provide professional certification services for raw cashew nuts (RCN) and cashew kernels, based on thorough scientific testing and grading. Certifications verify compliance with Ghana Standards Authority, Codex Alimentarius, EU regulations, and other benchmarks—helping stakeholders access premium markets and achieve value addition.',
                    icon: Icons.workspace_premium,
                  ),
                  Gap(24.h),
                  _buildServiceCard(
                    context,
                    title: 'Consulting',
                    description:
                        'Our experienced analysts offer tailored consulting services on cashew quality management, sustainable practices, moisture control projects, value chain optimization, and regulatory compliance. We support farmers, processors, exporters, and organizations in improving quality standards, reducing arbitrations, and driving economic empowerment.',
                    icon: Icons.diversity_3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, {required String title, required String description, required IconData icon}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.lightOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: AppColors.darkRed,
              size: 32.r,
            ),
          ),
          Gap(16.h),
          CustomText(
            title,
            variant: TextVariant.headlineSmall,
            fontWeight: FontWeight.bold,
            color: AppColors.darkRed,
          ),
          Gap(12.h),
          CustomText(
            description,
            variant: TextVariant.bodyMedium,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
