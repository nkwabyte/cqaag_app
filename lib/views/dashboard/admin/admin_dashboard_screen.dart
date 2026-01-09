import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const String id = 'admin_dashboard_screen';
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(60.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  "Admin Dashboard",
                  variant: TextVariant.displaySmall,
                  color: colorScheme.onSurface,
                ),
                Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 32.r,
                  color: colorScheme.primary,
                ),
              ],
            ),
            Gap(20.h),
            CustomText(
              "Manage memberships and inspections",
              variant: TextVariant.bodyMedium,
              color: colorScheme.secondary,
            ),
            Gap(40.h),

            // Pending Applications Card
            _buildStatCard(
              context,
              title: "Pending Applications",
              value: "0",
              icon: Icons.pending_actions_outlined,
              color: Colors.orange,
            ),
            Gap(16.h),

            // Total Members Card
            _buildStatCard(
              context,
              title: "Total Members",
              value: "0",
              icon: Icons.people_outline,
              color: Colors.blue,
            ),
            Gap(16.h),

            // Recent Activity Section
            Gap(20.h),
            CustomText(
              "Recent Activity",
              variant: TextVariant.bodyLarge,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            Gap(16.h),
            const Center(
              child: CustomText("No recent activity"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.r),
          ),
          Gap(16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                title,
                variant: TextVariant.bodyMedium,
                color: Theme.of(context).colorScheme.secondary,
              ),
              Gap(4.h),
              CustomText(
                value,
                variant: TextVariant.displaySmall,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
