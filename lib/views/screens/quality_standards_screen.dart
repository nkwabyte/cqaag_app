import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class QualityStandardsScreen extends StatelessWidget {
  static const String id = 'quality_standards_screen';

  const QualityStandardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkRed,
        title: const CustomText(
          'Quality Standards',
          variant: TextVariant.bodyLarge,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            const CustomText(
              'Cashew Quality Standards',
              variant: TextVariant.displaySmall,
              fontWeight: FontWeight.bold,
            ),
            Gap(12.h),
            CustomText(
              'C.Q.A.A.G adheres to international and national quality standards to ensure Ghana\'s cashew nuts meet global excellence.',
              variant: TextVariant.bodyMedium,
              color: colorScheme.secondary,
              textAlign: TextAlign.justify,
            ),

            Gap(32.h),

            // KOR Assessment
            _buildStandardSection(
              title: 'KOR Assessment',
              description: 'Kernel Outturn Ratio (KOR) is the primary metric for cashew quality, measuring the weight of kernels obtained from raw cashew nuts.',
              colorScheme: colorScheme,
            ),

            Gap(24.h),

            // Quality Parameters
            const CustomText(
              'Key Quality Parameters',
              variant: TextVariant.headlineMedium,
              fontWeight: FontWeight.bold,
            ),
            Gap(16.h),

            _buildQualityParameter(
              icon: Icons.scale,
              title: 'Kernel Weight',
              description: 'Measured in pounds per 80kg bag',
              colorScheme: colorScheme,
            ),

            Gap(12.h),

            _buildQualityParameter(
              icon: Icons.water_drop_outlined,
              title: 'Moisture Content',
              description: 'Must not exceed 5% for optimal storage',
              colorScheme: colorScheme,
            ),

            Gap(12.h),

            _buildQualityParameter(
              icon: Icons.bug_report_outlined,
              title: 'Defect Analysis',
              description: 'Assessment of broken, spotted, or damaged kernels',
              colorScheme: colorScheme,
            ),

            Gap(12.h),

            _buildQualityParameter(
              icon: Icons.color_lens_outlined,
              title: 'Color Grading',
              description: 'Classification based on kernel color uniformity',
              colorScheme: colorScheme,
            ),

            Gap(32.h),

            // International Standards
            _buildStandardSection(
              title: 'International Standards',
              description: 'Our quality assessments align with standards set by the African Cashew Alliance (ACA) and international trade requirements.',
              colorScheme: colorScheme,
            ),

            Gap(24.h),

            // Best Practices
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: colorScheme.primary,
                        size: 24.r,
                      ),
                      Gap(12.w),
                      const CustomText(
                        'Best Practices',
                        variant: TextVariant.headlineMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  Gap(16.h),
                  _buildBestPracticeItem('Regular quality inspections at all stages'),
                  _buildBestPracticeItem('Proper storage and handling procedures'),
                  _buildBestPracticeItem('Continuous training for quality analysts'),
                  _buildBestPracticeItem('Documentation and traceability'),
                  _buildBestPracticeItem('Adherence to environmental standards'),
                ],
              ),
            ),

            Gap(40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardSection({
    required String title,
    required String description,
    required ColorScheme colorScheme,
  }) {
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
          description,
          variant: TextVariant.bodyMedium,
          color: colorScheme.secondary,
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildQualityParameter({
    required IconData icon,
    required String title,
    required String description,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 24.r,
            ),
          ),
          Gap(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  variant: TextVariant.bodyLarge,
                  fontWeight: FontWeight.bold,
                ),
                Gap(4.h),
                CustomText(
                  description,
                  variant: TextVariant.bodySmall,
                  color: colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestPracticeItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20.r,
            color: AppColors.darkRed,
          ),
          Gap(12.w),
          Expanded(
            child: CustomText(
              text,
              variant: TextVariant.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
