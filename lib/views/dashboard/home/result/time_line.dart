import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class JourneyNode extends StatelessWidget {
  final IconData icon;
  final bool isCompleted;
  final bool isLast;

  const JourneyNode({
    super.key,
    required this.icon,
    this.isCompleted = true,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color nodeColor = isCompleted ? const Color(0xFF591a04) : colorScheme.secondary.withValues(alpha: 0.3);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: nodeColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.w),
          ),
          child: Icon(icon, color: Colors.white, size: 18.r),
        ),
        if (!isLast)
          Container(
            width: 2.w,
            height: 220.h, // Adjusted to match the card heights
            color: const Color(0xFF591a04),
          ),
      ],
    );
  }
}

class JourneyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String location;
  final String person;
  final String role;
  final String dateTime;
  final bool isCompleted;

  const JourneyCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.person,
    required this.role,
    required this.dateTime,
    this.isCompleted = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 280.w,
      padding: EdgeInsets.all(16.r),
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCompleted
              ? colorScheme.secondary.withValues(alpha: 0.1)
              : colorScheme.primary.withValues(alpha: 0.4),
          width: isCompleted ? 1.w : 1.5.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(title, variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
              Icon(
                isCompleted ? Icons.check_circle : Icons.access_time,
                color: isCompleted ? Colors.green : colorScheme.primary,
                size: 20.r,
              ),
            ],
          ),
          CustomText(subtitle, variant: TextVariant.bodySmall, color: colorScheme.secondary),
          Gap(12.h),
          const Divider(),
          Gap(12.h),
          _buildInfoRow(Icons.location_on_outlined, location, colorScheme),
          Gap(8.h),
          _buildInfoRow(Icons.person_outline, "$person • $role", colorScheme),
          Gap(8.h),
          _buildInfoRow(Icons.calendar_today_outlined, dateTime, colorScheme),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: AppColors.deepGrayOrange),
        Gap(8.w),
        Expanded(child: CustomText(text, variant: TextVariant.bodySmall)),
      ],
    );
  }
}
