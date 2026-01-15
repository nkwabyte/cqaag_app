import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final String count;

  const SummaryCard({
    super.key,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      // height: 90.h,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CustomText(
            label,
            variant: TextVariant.bodySmall,
            color: Colors.white70,
          ),
          Gap(10.0.h),
          CustomText(
            count,
            variant: TextVariant.displayMedium,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

// Individual Schedule Item
class InspectionCard extends StatelessWidget {
  final String name;
  final String batchId;
  final String location;
  final String time;
  final String weight;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;

  const InspectionCard({
    super.key,
    required this.name,
    required this.batchId,
    required this.location,
    required this.time,
    required this.weight,
    required this.status,
    required this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _buildStatusBadge(status, statusColor),
                    Gap(10.w),
                    CustomText(batchId, variant: TextVariant.bodySmall, color: colorScheme.secondary),
                  ],
                ),
                Icon(Icons.chevron_right, color: colorScheme.secondary),
              ],
            ),
            Gap(12.h),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Color(0xFFbe6735),
                ),
                Gap(8.w),
                Expanded(
                  child: CustomText(
                    name,
                    variant: TextVariant.headlineSmall,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            Gap(8.0.h),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomText(
                  location,
                  variant: TextVariant.bodyMedium,
                  color: colorScheme.secondary,
                ),
              ],
            ),
            Gap(16.h),
            Divider(color: colorScheme.secondary.withValues(alpha: 0.1)),
            Gap(12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16.r,
                      color: colorScheme.secondary,
                    ),
                    Gap(8.w),
                    CustomText(
                      time,
                      variant: TextVariant.bodyMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                CustomText(
                  "$weight MT",
                  variant: TextVariant.bodyLarge,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            text == "Pending" ? Icons.access_time : Icons.check_circle_outline,
            size: 14.r,
            color: color,
          ),
          Gap(4.w),
          CustomText(
            text,
            variant: TextVariant.bodySmall,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
