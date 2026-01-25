import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class ContactUsScreen extends StatelessWidget {
  static const String id = 'contact_us_screen';

  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkRed,
        title: const CustomText(
          'Contact Us',
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
            // Header
            const CustomText(
              'Get In Touch',
              variant: TextVariant.displaySmall,
              fontWeight: FontWeight.bold,
            ),
            Gap(8.h),
            CustomText(
              'We\'d love to hear from you. Reach out to us through any of the following channels.',
              variant: TextVariant.bodyMedium,
              color: colorScheme.secondary,
            ),

            Gap(32.h),

            // Contact Cards
            _buildContactCard(
              icon: Icons.email_outlined,
              title: 'Email',
              content: 'info@cqaag.org.gh',
              colorScheme: colorScheme,
            ),

            Gap(16.h),

            _buildContactCard(
              icon: Icons.phone_outlined,
              title: 'Phone',
              content: '+233 XX XXX XXXX',
              colorScheme: colorScheme,
            ),

            Gap(16.h),

            _buildContactCard(
              icon: Icons.location_on_outlined,
              title: 'Address',
              content: 'Accra, Ghana',
              colorScheme: colorScheme,
            ),

            Gap(32.h),

            // Office Hours
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
                        Icons.access_time,
                        color: colorScheme.primary,
                        size: 24.r,
                      ),
                      Gap(12.w),
                      const CustomText(
                        'Office Hours',
                        variant: TextVariant.headlineMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  Gap(16.h),
                  _buildOfficeHourRow('Monday - Friday', '8:00 AM - 5:00 PM'),
                  Gap(8.h),
                  _buildOfficeHourRow('Saturday', '9:00 AM - 2:00 PM'),
                  Gap(8.h),
                  _buildOfficeHourRow('Sunday', 'Closed'),
                ],
              ),
            ),

            Gap(32.h),

            // Social Media (placeholder)
            const CustomText(
              'Follow Us',
              variant: TextVariant.headlineMedium,
              fontWeight: FontWeight.bold,
            ),
            Gap(16.h),
            Row(
              children: [
                _buildSocialButton(Icons.facebook, colorScheme),
                Gap(12.w),
                _buildSocialButton(Icons.link, colorScheme),
                Gap(12.w),
                _buildSocialButton(Icons.email, colorScheme),
              ],
            ),

            Gap(40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 28.r,
            ),
          ),
          Gap(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  variant: TextVariant.bodySmall,
                  color: colorScheme.secondary,
                ),
                Gap(4.h),
                CustomText(
                  content,
                  variant: TextVariant.bodyLarge,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeHourRow(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          day,
          variant: TextVariant.bodyMedium,
          fontWeight: FontWeight.w500,
        ),
        CustomText(
          hours,
          variant: TextVariant.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        icon,
        color: colorScheme.primary,
        size: 24.r,
      ),
    );
  }
}
