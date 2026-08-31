import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static final String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProfileProvider).value;
    final InspectionState? inspectionState = ref.watch(inspectionControllerProvider).value;

    final allInspections = inspectionState?.allInspections;
    final today = DateTime.now();
    final todayInspections = allInspections?.where((i) {
      final createdAt = i.createdAt;
      return createdAt != null && createdAt.year == today.year && createdAt.month == today.month && createdAt.day == today.day;
    }).length;

    final pendingCount = inspectionState?.uncompleted.length;
    final completedCount = inspectionState?.completed.length;

    final notificationsAsync = ref.watch(userNotificationsStreamProvider);
    final readIds = ref.watch(readNotificationIdsProvider);
    final unreadCount = notificationsAsync.asData?.value.where((n) => !readIds.contains(n.id)).length ?? 0;

    final membershipState = ref.watch(membershipControllerProvider).value;
    final memberApp = membershipState?.myApplication;
    final displayMemberId = memberApp?.id ?? (user != null ? (user.id.length > 8 ? user.id.substring(0, 8).toUpperCase() : user.id) : "...");

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Column(
        children: <Widget>[
          // 1. Curved Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 15.h),
            decoration: BoxDecoration(
              color: AppColors.darkRed,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50.r),
                bottomRight: Radius.circular(50.r),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: CustomText(
                                    user?.firstName ?? 'User',
                                    variant: TextVariant.displaySmall,
                                    color: Colors.white,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (user?.verificationStatus == VerificationStatus.verified) ...[
                                  Gap(8.w),
                                  Icon(Icons.verified, color: Colors.blue, size: 24.r).shimmer(),
                                ],
                              ],
                            ),
                            CustomText(
                              "${user?.role ?? "User"} • ID: $displayMemberId",
                              variant: TextVariant.bodySmall,
                              color: Colors.white70,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Gap(12.w),
                      InkWell(
                        onTap: () {
                          context.pushNamed(NotificationsScreen.id);
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 22.r,
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: -4.w,
                                  top: -4.h,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                                    child: Text(
                                      '$unreadCount',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(18.h),
                  // Summary Cards Row - Watch inspections for counts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SummaryCard(label: "Today", count: "${todayInspections ?? 0}"),
                      SummaryCard(label: "Pending", count: "${pendingCount ?? 0}"),
                      SummaryCard(label: "Done", count: "${completedCount ?? 0}"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    children: <Widget>[
                      // Pending Approval Warning Banner
                      if (user != null && !user.isApproved) ...[
                        Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: AppColors.tcdaAccentGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.primaryGreen),
                              Gap(10.w),
                              Expanded(
                                child: Text(
                                  (memberApp?.status == ApplicationStatus.approved && memberApp?.paymentStatus != 'verified')
                                      ? 'Your KYC application is approved! Please complete your registration payment in Profile to activate inspection tools.'
                                      : 'Your account is undergoing KYC verification. Creating inspections and accessing report exports will be unlocked upon approval and payment confirmation.',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(16.h),
                      ],

                      // 2. Action Bar
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: CustomButton(
                              text: "New Inspection",
                              leadingIcon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () {
                                if (user != null && !user.isApproved) {
                                  final isKycApproved = memberApp?.status == ApplicationStatus.approved;
                                  CustomSnackBar.warning(
                                    context,
                                    message: isKycApproved
                                        ? 'Your KYC is approved! Please complete your registration payment in Profile to activate inspections.'
                                        : 'Only verified members can start inspections. Please await KYC approval and complete payment verification.',
                                    title: 'Verification Required',
                                  );
                                  return;
                                }
                                context.pushNamed(QualityInspectionWizard.id);
                              },
                            ).fadeInScale(delay: const Duration(milliseconds: 500)).pulse(delay: const Duration(seconds: 2)),
                          ),
                        ],
                      ),

                      Gap(30.h),

                      // 4. Inspection List - Dynamic from Firebase
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const CustomText("Recent Activities", variant: TextVariant.displaySmall),
                              if (inspectionState?.recent.isNotEmpty ?? false)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: CustomText(
                                    "${inspectionState?.recent.length} Recent",
                                    variant: TextVariant.bodySmall,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          Gap(20.h),
                          if (inspectionState?.recent.isEmpty ?? false)
                            Center(
                              child: Column(
                                children: [
                                  Gap(40.h),
                                  Icon(
                                    Icons.assignment_outlined,
                                    size: 64.r,
                                    color: colorScheme.secondary.withValues(alpha: 0.3),
                                  ),
                                  Gap(16.h),
                                  CustomText(
                                    "No inspections yet",
                                    variant: TextVariant.headlineMedium,
                                    color: colorScheme.secondary,
                                  ),
                                  Gap(8.h),
                                  CustomText(
                                    "Tap 'New Inspection' to get started",
                                    variant: TextVariant.bodyMedium,
                                    color: colorScheme.secondary.withValues(alpha: 0.7),
                                  ),
                                ],
                              ),
                            ),
                          if (inspectionState?.recent.isNotEmpty ?? false)
                            Column(
                              children: inspectionState!.recent.map((inspection) {
                                return InspectionCard(
                                  status: _getStatusText(inspection.status),
                                  statusColor: _getStatusColor(inspection.status),
                                  batchId: inspection.batchId ?? 'N/A',
                                  name: inspection.farmerName ?? 'Unknown',
                                  location: inspection.location ?? 'Unknown Location',
                                  time: inspection.createdAt != null
                                      ? '${inspection.createdAt?.hour.toString().padLeft(2, '0')}:${inspection.createdAt?.minute.toString().padLeft(2, '0')}'
                                      : 'N/A',
                                  weight: inspection.quantity.toStringAsFixed(1),
                                  onTap: () {
                                    // Resume pending or view completed
                                    if (inspection.status == InspectionStatus.pending || inspection.status == InspectionStatus.inProgress || inspection.status == InspectionStatus.pendingSync) {
                                      context.pushNamed(
                                        QualityInspectionWizard.id,
                                        extra: inspection,
                                      );
                                    } else {
                                      // For completed, view details
                                      context.pushNamed(
                                        QualityResultScreen.id,
                                        extra: inspection,
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.pending:
        return 'Pending';
      case InspectionStatus.pendingSync:
        return 'Pending Sync';
      case InspectionStatus.inProgress:
        return 'In Progress';
      case InspectionStatus.completed:
        return 'Completed';
      case InspectionStatus.rejected:
        return 'Rejected';
    }
  }

  Color _getStatusColor(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.pending:
      case InspectionStatus.pendingSync:
        return AppColors.cashewGold;
      case InspectionStatus.inProgress:
        return const Color(0xFF2E7D32); // green
      case InspectionStatus.completed:
        return const Color(0xFF1976D2); // blue
      case InspectionStatus.rejected:
        return const Color(0xFFD32F2F); // red
    }
  }
}
