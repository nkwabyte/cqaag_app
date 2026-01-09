import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class AdminUserDetailScreen extends ConsumerWidget {
  static const String id = 'admin_user_detail_screen';
  final AppUser user;

  const AdminUserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = ref.read(userControllerProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const CustomText("User Details", variant: TextVariant.headlineMedium),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundImage: NetworkImage(user.profilePicture),
                    onBackgroundImageError: (ctx, err) {},
                    child: Text(user.firstName[0], style: TextStyle(fontSize: 32.sp)),
                  ),
                  Gap(16.h),
                  CustomText(
                    "${user.firstName} ${user.lastName}",
                    variant: TextVariant.headlineMedium,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(4.h),
                  CustomText(
                    user.email,
                    variant: TextVariant.bodyMedium,
                    color: colorScheme.secondary,
                  ),
                  Gap(8.h),
                  _buildStatusBadge(user.status, colorScheme),
                ],
              ),
            ),

            Gap(32.h),

            // Info Section
            _buildInfoCard(
              context,
              title: "Contact Information",
              children: [
                _buildInfoRow("Phone", user.phoneNumber ?? "N/A"),
                // AppUser actually doesn't typically have address/district fields based on common patterns unless added
                // Checking user model in next step to be sure, using generic safe access for now
              ],
            ),

            Gap(20.h),

            _buildInfoCard(
              context,
              title: "System Status",
              children: [
                _buildInfoRow("User ID", user.id),
                _buildInfoRow("Verification", user.verificationStatus.value),
                _buildInfoRow("Membership", user.membershipStatus.value),
                _buildInfoRow("Role", user.isAdmin ? "Admin" : "Standard User"),
              ],
            ),

            Gap(40.h),

            // Admin Actions
            CustomText(
              "Admin Actions",
              variant: TextVariant.headlineMedium,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            Gap(16.h),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: user.status == AppUserStatus.suspended ? "Unsuspend" : "Suspend User",
                    variant: ButtonVariant.outlined,
                    backgroundColor: user.status == AppUserStatus.suspended ? Colors.orange.withValues(alpha: 0.1) : null,
                    textColor: Colors.orange,
                    borderColor: Colors.orange,
                    onPressed: () async {
                      final newStatus = user.status == AppUserStatus.suspended ? AppUserStatus.active : AppUserStatus.suspended;
                      await controller.updateUserStatus(user.id, newStatus);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: CustomButton(
                    text: user.status == AppUserStatus.banned ? "Unban" : "Ban User",
                    backgroundColor: user.status == AppUserStatus.banned ? Colors.grey : Colors.red,
                    onPressed: () async {
                      final newStatus = user.status == AppUserStatus.banned ? AppUserStatus.active : AppUserStatus.banned;
                      await controller.updateUserStatus(user.id, newStatus);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppUserStatus status, ColorScheme colorScheme) {
    Color color;
    switch (status) {
      case AppUserStatus.active:
        color = Colors.green;
        break;
      case AppUserStatus.suspended:
        color = Colors.orange;
        break;
      case AppUserStatus.banned:
        color = Colors.red;
        break;
      case AppUserStatus.inactive:
        color = Colors.grey;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.value.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12.sp),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> children}) {
    // If no children, don't show card
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(title, variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: CustomText(label, variant: TextVariant.bodyMedium, color: Colors.grey[600]),
          ),
          Expanded(
            child: CustomText(value, variant: TextVariant.bodyMedium, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
