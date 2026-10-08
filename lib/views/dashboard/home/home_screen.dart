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
    final user = ref.watch(currentUserProfileProvider).value;
    final InspectionState? inspectionState = ref.watch(inspectionControllerProvider).value;

    final allInspections = inspectionState?.allInspections ?? [];
    final today = DateTime.now();
    final todayInspections = allInspections.where((i) {
      final createdAt = i.createdAt;
      return createdAt != null &&
          createdAt.year == today.year &&
          createdAt.month == today.month &&
          createdAt.day == today.day;
    }).length;

    final pendingCount = inspectionState?.uncompleted.length ?? 0;
    final completedCount = inspectionState?.completed.length ?? 0;
    final recentInspections = inspectionState?.recent ?? [];

    final membershipState = ref.watch(membershipControllerProvider).value;
    final memberApp = membershipState?.myApplication;
    final displayMemberId = memberApp?.id ??
        (user != null ? (user.id.length > 8 ? user.id.substring(0, 8).toUpperCase() : user.id) : "...");

    final isApproved = user?.isApproved ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(inspectionControllerProvider);
          ref.invalidate(currentUserProfileProvider);
          ref.invalidate(membershipControllerProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Sleek Compact Header with Slim Metrics Strip (scrolls with content)
            SliverToBoxAdapter(
              child: _buildCompactHeader(
                context: context,
                user: user,
                displayMemberId: displayMemberId,
                todayCount: todayInspections,
                pendingCount: pendingCount,
                completedCount: completedCount,
              ),
            ),

            // 2. Unapproved User / KYC Warning Banner (if any)
            if (user != null && !isApproved)
              SliverToBoxAdapter(
                child: _buildApprovalWarningBanner(memberApp: memberApp),
              ),

            // 3. Primary Action Button
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 4.h),
                child: CustomButton(
                  text: "Start New Inspection",
                  leadingIcon: const Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
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
                ),
              ),
            ),

            // 4. Recent Activities Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 6.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Activities",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkRed,
                      ),
                    ),
                    if (recentInspections.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "${recentInspections.length} Recent",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 5. Recent Activities List or Empty State
            if (recentInspections.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(
                  context: context,
                  isApproved: isApproved,
                  memberApp: memberApp,
                  user: user,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 24.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final inspection = recentInspections[index];
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
                          if (inspection.status == InspectionStatus.pending ||
                              inspection.status == InspectionStatus.inProgress ||
                              inspection.status == InspectionStatus.pendingSync) {
                            context.pushNamed(
                              QualityInspectionWizard.id,
                              extra: inspection,
                            );
                          } else {
                            context.pushNamed(
                              QualityResultScreen.id,
                              extra: inspection,
                            );
                          }
                        },
                      );
                    },
                    childCount: recentInspections.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Compact header that matches the HistoryScreen design language.
  /// Drastically reduces vertical footprint and scrolls away naturally with list content.
  Widget _buildCompactHeader({
    required BuildContext context,
    required AppUser? user,
    required String displayMemberId,
    required int todayCount,
    required int pendingCount,
    required int completedCount,
  }) {
    final topPadding = MediaQuery.of(context).padding.top + 54.h;
    final isApproved = user?.isApproved ?? false;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, topPadding + 4.h, 16.w, 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkRed,
            Color(0xFF063312),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Identity Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user?.firstName != null ? 'Welcome, ${user!.firstName}' : 'Welcome Back',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user?.verificationStatus == VerificationStatus.verified) ...[
                          Gap(6.w),
                          Icon(Icons.verified, color: Colors.lightBlueAccent, size: 18.r),
                        ],
                      ],
                    ),
                    Gap(2.h),
                    Text(
                      "${user?.role ?? "Inspector"} • ID: $displayMemberId",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.mintLight.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Gap(8.w),
              // Compact Status Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isApproved
                      ? AppColors.primaryGreen.withValues(alpha: 0.35)
                      : Colors.amber.shade700.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isApproved
                        ? AppColors.mintLight.withValues(alpha: 0.5)
                        : Colors.amber.shade300.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isApproved ? Colors.greenAccent : Colors.amberAccent,
                      ),
                    ),
                    Gap(5.w),
                    Text(
                      isApproved ? "Active" : "Pending",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Gap(10.h),

          // Slim Segmented Metrics Strip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildCompactMetric(
                    icon: Icons.calendar_today_outlined,
                    value: "$todayCount",
                    label: "Today",
                  ),
                ),
                Container(
                  width: 1,
                  height: 22.h,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildCompactMetric(
                    icon: Icons.hourglass_top_outlined,
                    value: "$pendingCount",
                    label: "Pending",
                  ),
                ),
                Container(
                  width: 1,
                  height: 22.h,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildCompactMetric(
                    icon: Icons.task_alt_outlined,
                    value: "$completedCount",
                    label: "Done",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 15.r, color: AppColors.mintLight),
        Gap(6.w),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                color: AppColors.mintLight.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApprovalWarningBanner({MembershipApplication? memberApp}) {
    final isKycApproved = memberApp?.status == ApplicationStatus.approved;
    final isPaymentPending = memberApp?.paymentStatus != 'verified';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: Colors.amber.shade900, size: 20.r),
          Gap(10.w),
          Expanded(
            child: Text(
              (isKycApproved && isPaymentPending)
                  ? 'Your KYC application is approved! Please complete your registration payment in Profile to activate inspection tools.'
                  : 'Your account is undergoing KYC verification. Creating inspections and accessing certificate exports will be unlocked upon approval and payment confirmation.',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Illustrated empty state matching the design in HistoryScreen
  Widget _buildEmptyState({
    required BuildContext context,
    required bool isApproved,
    MembershipApplication? memberApp,
    AppUser? user,
  }) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Gap(20.h),
            Container(
              width: 88.r,
              height: 88.r,
              decoration: BoxDecoration(
                color: AppColors.mintLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.tcdaAccentGreen.withValues(alpha: 0.25),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tcdaAccentGreen.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.assignment_outlined,
                  size: 42.r,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            Gap(18.h),
            Text(
              "No Recent Inspections",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.darkRed,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(8.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300.w),
              child: Text(
                "Completed or ongoing cashew inspections will appear here for quick access.",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Gap(22.h),
            if (isApproved)
              ElevatedButton.icon(
                onPressed: () => context.pushNamed(QualityInspectionWizard.id),
                icon: const Icon(Icons.add_task_rounded, size: 18),
                label: const Text("Start New Inspection"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
          ],
        ),
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
      case InspectionStatus.pendingApproval:
        return 'Awaiting Approval';
      case InspectionStatus.approvalDeclined:
        return 'Not Approved';
    }
  }

  Color _getStatusColor(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.pending:
      case InspectionStatus.pendingSync:
        return AppColors.cashewGold;
      case InspectionStatus.inProgress:
        return const Color(0xFF2E7D32);
      case InspectionStatus.completed:
        return const Color(0xFF1976D2);
      case InspectionStatus.rejected:
      case InspectionStatus.approvalDeclined:
        return const Color(0xFFD32F2F);
      case InspectionStatus.pendingApproval:
        return const Color(0xFFB45309);
    }
  }
}
