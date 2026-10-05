import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';

class AdminDashboardScreen extends ConsumerWidget {
  static const String id = 'admin_dashboard_screen';
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(currentUserProfileProvider).value;

    final isAdmin = user?.isAdmin ?? false;

    if (!isAdmin) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.darkRed,
          title: const CustomText(
            "Admin Management",
            variant: TextVariant.headlineMedium,
            color: Colors.white,
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 64.r,
                  color: Colors.red[300],
                ),
                Gap(16.h),
                const CustomText(
                  "Access Restricted",
                  variant: TextVariant.headlineMedium,
                  fontWeight: FontWeight.bold,
                ),
                Gap(8.h),
                CustomText(
                  "System Management and Admin Maintenance tabs are restricted strictly to system administrators.",
                  variant: TextVariant.bodyMedium,
                  textAlign: TextAlign.center,
                  color: colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.darkRed,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: colorScheme.secondary,
            indicatorColor: AppColors.grayOrange,
            indicatorSize: TabBarIndicatorSize.tab,
            isScrollable: true,
            tabs: const <Widget>[
              Tab(text: "Users"),
              Tab(text: "Members"),
              Tab(text: "Reports"),
              Tab(child: _ApprovalsTabLabel()),
              Tab(text: "Kit Orders"),
              Tab(text: "Payments"),
              Tab(text: "System"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UserManagementTab(),
            MembershipManagementTab(),
            ReportsManagementTab(),
            ExportApprovalsTab(),
            KitOrdersTab(),
            PaymentSettingsTab(),
            SystemMaintenanceTab(),
          ],
        ),
      ),
    );
  }
}

/// "Approvals" with a count of Export certificates waiting, so a new request
/// is visible from any admin tab.
class _ApprovalsTabLabel extends ConsumerWidget {
  const _ApprovalsTabLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(pendingExportApprovalsProvider).value?.length ?? 0;
    if (count == 0) return const Text("Approvals");
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Approvals"),
        Gap(6.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
          decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(10.r)),
          child: Text('$count', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
