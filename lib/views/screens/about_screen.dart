import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class AboutScreen extends StatelessWidget {
  static const String id = 'about_screen';

  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkRed,
        title: const CustomText(
          'About C.Q.A.A.G',
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
            // Logo/Icon Section
            Center(
              child: Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.agriculture,
                  size: 80.r,
                  color: colorScheme.primary,
                ),
              ),
            ),

            Gap(32.h),

            // Mission Section
            _buildSection(
              title: 'Our Mission',
              content: 'To promote professional development, ethical practices, and sustainability in Ghana\'s cashew industry through skilled analysis and quality assurance.',
              colorScheme: colorScheme,
            ),

            Gap(24.h),

            // Vision Section
            _buildSection(
              title: 'Our Vision',
              content: 'A Ghana where every cashew nut meets global excellence standards through skilled, ethical, and innovative practices.',
              colorScheme: colorScheme,
            ),

            Gap(24.h),

            // Motto Section
            _buildSection(
              title: 'Our Motto',
              content: 'Guardians of Ghana\'s Cashew Quality',
              colorScheme: colorScheme,
            ),

            Gap(24.h),

            // Core Values Section
            const CustomText(
              'Core Values',
              variant: TextVariant.headlineMedium,
              fontWeight: FontWeight.bold,
            ),
            Gap(12.h),
            _buildValueItem('Integrity', Icons.verified_user),
            _buildValueItem('Excellence', Icons.star),
            _buildValueItem('Sustainability', Icons.eco),
            _buildValueItem('Professionalism', Icons.business_center),
            _buildValueItem('Collaboration', Icons.handshake),
            _buildValueItem('Community Empowerment', Icons.groups),

            Gap(32.h),

            // Contact Info
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
                  const CustomText(
                    'Get In Touch',
                    variant: TextVariant.headlineMedium,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(16.h),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 20.r, color: colorScheme.primary),
                      Gap(12.w),
                      const CustomText(
                        'info@cqaag.org.gh',
                        variant: TextVariant.bodyMedium,
                      ),
                    ],
                  ),
                  Gap(12.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 20.r, color: colorScheme.primary),
                      Gap(12.w),
                      const Expanded(
                        child: CustomText(
                          'Ghana',
                          variant: TextVariant.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Gap(40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
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
          content,
          variant: TextVariant.bodyMedium,
          color: colorScheme.secondary,
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildValueItem(String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: AppColors.darkRed),
          Gap(12.w),
          CustomText(
            value,
            variant: TextVariant.bodyMedium,
          ),
        ],
      ),
    );
  }
}
