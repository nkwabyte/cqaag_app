import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:cqaag_app/index.dart';

class GuestHomeScreen extends StatelessWidget {
  static const String id = 'guest_home_screen';

  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Hero Section with Background
              _buildHeroSection(context),

              Gap(40.h),

              // Live Quality Statistics Section
              _buildStatisticsSection(context),

              Gap(40.h),

              // Vision, Mission, Core Values, Impact Goals
              _buildVisionMissionSection(context),

              Gap(40.h),

              // Updates & Events Section
              _buildUpdatesEventsSection(context),

              Gap(40.h),

              // Features Section
              _buildFeaturesSection(context),

              Gap(40.h),

              // Call to Action Section
              _buildCallToActionSection(context),

              Gap(10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 400.h),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(Assets.imagesCashewBg),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.darkRed.withValues(alpha: 0.9),
            BlendMode.darken,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CustomText(
              'Cashew Quality Analysts\' Association, Ghana\n(CQAAG)',
              variant: TextVariant.displaySmall,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
            Gap(16.h),
            CustomText(
              'Guardians of Ghana\'s Cashew Quality',
              variant: TextVariant.headlineMedium,
              color: const Color(0xFFD4A574),
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            Gap(12.h),
            const CustomText(
              'A non-profit association dedicated to ethical, world-class cashew quality standards and sustainable prosperity',
              variant: TextVariant.bodyLarge,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
            Gap(8.h),
            const CustomText(
              'We are a non-profit association dedicated to elevating Ghanaian cashews to global excellence through skilled, ethical, and innovative quality practices – driving sustainable prosperity for farmers, processors, and the nation.',
              variant: TextVariant.bodyMedium,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
            Gap(32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomButton(
                  text: 'Learn More',
                  fullWidth: false,
                  onPressed: () {
                    context.pushNamed(AboutScreen.id);
                  },
                ),
                Gap(12.w),
                CustomButton(
                  text: 'Become a Member',
                  variant: ButtonVariant.outlined,
                  borderColor: Colors.white,
                  textColor: Colors.white,
                  fullWidth: false,
                  onPressed: () {
                    context.pushNamed(RegisterScreen.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: <Widget>[
          const CustomText(
            'Live Quality Statistics',
            variant: TextVariant.displaySmall,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          Gap(8.h),
          CustomText(
            'Real-time data from our quality assurance operations',
            variant: TextVariant.bodyMedium,
            color: Theme.of(context).colorScheme.secondary,
            textAlign: TextAlign.center,
          ),
          Gap(24.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 1.0,
            children: <Widget>[
              _buildStatCard(context, '1,247,890', 'Total Inspected', '+12%', Colors.green),
              _buildStatCard(context, '1,142,503', 'Export Ready', '8%', Colors.green),
              _buildStatCard(context, '91.5%', 'Pass Rate', '+2.3%', Colors.green),
              _buildStatCard(context, '156', 'Active Analysts', '+5', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, String change, Color changeColor) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.trending_up, size: 16.r, color: AppColors.darkRed),
              Gap(4.w),
              CustomText(
                change,
                variant: TextVariant.bodySmall,
                color: changeColor,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          Gap(8.h),
          CustomText(
            value,
            variant: TextVariant.bodyLarge,
            fontWeight: FontWeight.w900,
          ),
          Gap(4.h),
          CustomText(
            label,
            variant: TextVariant.bodySmall,
            color: AppColors.darkRed,
          ),
        ],
      ),
    );
  }

  Widget _buildVisionMissionSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.shield_outlined,
                  title: 'Our Vision',
                  content:
                      'To be the leading authority in cashew quality assurance in West Africa, setting the gold standard for excellence, innovation, and integrity in agricultural quality inspection.',
                ),
              ),
              Gap(12.w),
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.emoji_events_outlined,
                  title: 'Our Mission',
                  content:
                      'To safeguard Ghana\'s cashew industry through rigorous quality standards, professional certification, and continuous innovation, ensuring every nut meets international excellence benchmarks.',
                ),
              ),
            ],
          ),
          Gap(12.h),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.favorite_outline,
                  title: 'Core Values',
                  content: '• Integrity\n• Excellence\n• Sustainability\n• Professionalism\n• Collaboration\n• Community Empowerment',
                ),
              ),
              Gap(12.w),
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.track_changes,
                  title: 'Impact Goals',
                  content: '1. Train & license 500 controllers by 2028\n2. Achieve 100% standardised protocols by 2027\n3. Promote local value addition',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 32.r, color: AppColors.darkRed),
          Gap(12.h),
          CustomText(
            title,
            variant: TextVariant.headlineMedium,
            fontWeight: FontWeight.bold,
          ),
          Gap(8.h),
          CustomText(
            content,
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: <Widget>[
          _buildFeatureCard(
            context,
            icon: Icons.verified_outlined,
            title: 'Rigorous Standards',
            description: 'Comprehensive quality metrics for every inspection',
          ),
          Gap(16.h),
          _buildFeatureCard(
            context,
            icon: Icons.description_outlined,
            title: 'Certified Excellence',
            description: 'ISO-compliant certification processes',
          ),
          Gap(16.h),
          _buildFeatureCard(
            context,
            icon: Icons.groups_outlined,
            title: 'Expert Team',
            description: '156 professional analysts nationwide',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.darkRed,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28.r),
          ),
          Gap(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomText(
                  title,
                  variant: TextVariant.headlineMedium,
                  fontWeight: FontWeight.bold,
                ),
                Gap(4.h),
                CustomText(
                  description,
                  variant: TextVariant.bodyMedium,
                  color: AppColors.darkRed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToActionSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2D5F2E),
            const Color(0xFF3A7A3C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: <Widget>[
          const CustomText(
            'Join us in safeguarding Ghana\'s cashew quality. Whether you\'re an analyst, processor, or supporter – your expertise matters',
            variant: TextVariant.bodyLarge,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          Gap(24.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.w,
            runSpacing: 12.h,
            children: <Widget>[
              CustomButton(
                text: 'Apply for Membership',
                backgroundColor: const Color(0xFF90C695),
                fullWidth: false,
                onPressed: () {
                  context.pushNamed(RegisterScreen.id);
                },
              ),
              CustomButton(
                text: 'Nominate Honorary Member',
                variant: ButtonVariant.outlined,
                borderColor: Colors.white,
                textColor: Colors.white,
                fullWidth: false,
                onPressed: () {
                  context.pushNamed(ContactUsScreen.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesEventsSection(BuildContext context) {
    final events = Event.getMockEvents().take(2).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: <Widget>[
          const CustomText(
            'Updates & Events',
            variant: TextVariant.displaySmall,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          Gap(8.h),
          CustomText(
            'Latest news and insights from the cashew industry',
            variant: TextVariant.bodyMedium,
            color: Theme.of(context).colorScheme.secondary,
            textAlign: TextAlign.center,
          ),
          Gap(24.h),
          ...events.map(
            (event) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildEventPreviewCard(context, event),
            ),
          ),
          Gap(16.h),
          CustomButton(
            text: 'View All Updates',
            backgroundColor: AppColors.darkBrown,
            onPressed: () {
              context.pushNamed(GuestEventsScreen.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventPreviewCard(BuildContext context, Event event) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        context.pushNamed(
          GuestEventDetailsScreen.id,
          extra: event,
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(event.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Gap(16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.lightOrange,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: CustomText(
                      event.category.label,
                      variant: TextVariant.bodySmall,
                      color: AppColors.darkBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(8.h),
                  CustomText(
                    event.title,
                    variant: TextVariant.bodyLarge,
                    fontWeight: FontWeight.bold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(4.h),
                  CustomText(
                    event.description,
                    variant: TextVariant.bodySmall,
                    color: colorScheme.secondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Gap(8.w),
            Icon(Icons.arrow_forward_ios, size: 16.r, color: AppColors.darkBrown),
          ],
        ),
      ),
    );
  }
}
