import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cqaag_app/index.dart';

class NotificationsScreen extends ConsumerWidget {
  static const String id = 'notifications_screen';

  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notificationsAsync = ref.watch(userNotificationsStreamProvider);
    final readIds = ref.watch(readNotificationIdsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.darkRed,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          notificationsAsync.when(
            data: (notifications) {
              if (notifications.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                icon: const Icon(Icons.done_all, size: 18, color: Colors.white),
                label: const Text(
                  'Mark All Read',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () {
                  final allIds = notifications.map((n) => n.id).toList();
                  ref.read(readNotificationIdsProvider.notifier).markAllAsRead(allIds);
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          Gap(8.w),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => Gap(12.h),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isRead = readIds.contains(notif.id);

              return _buildNotificationCard(
                context: context,
                ref: ref,
                notification: notif,
                isRead: isRead,
                colorScheme: colorScheme,
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.r, color: Colors.red),
                Gap(12.h),
                CustomText(
                  "Failed to load notifications: $err",
                  variant: TextVariant.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                size: 64.r,
                color: AppColors.darkRed,
              ),
            ),
            Gap(20.h),
            const CustomText(
              "No Notifications Yet",
              variant: TextVariant.headlineMedium,
              fontWeight: FontWeight.bold,
            ),
            Gap(8.h),
            CustomText(
              "System alerts and broadcast bulletins from CQAAG National Secretariat will appear here.",
              variant: TextVariant.bodyMedium,
              color: colorScheme.secondary.withValues(alpha: 0.7),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required WidgetRef ref,
    required SystemNotification notification,
    required bool isRead,
    required ColorScheme colorScheme,
  }) {
    final formattedDate = notification.createdAt != null
        ? DateFormat('MMM d, y • h:mm a').format(notification.createdAt!)
        : 'Recent';

    final isTargetUser = notification.target.startsWith('user:');
    final isTargetCategory = notification.target.startsWith('category:');

    String targetLabel = "ALL MEMBERS";
    Color targetColor = AppColors.darkRed;

    if (isTargetUser) {
      targetLabel = "DIRECT MESSAGE";
      targetColor = Colors.purple;
    } else if (isTargetCategory) {
      targetLabel = notification.target.replaceAll('category:', '').toUpperCase();
      targetColor = Colors.blue.shade700;
    }

    return InkWell(
      onTap: () {
        ref.read(readNotificationIdsProvider.notifier).markAsRead(notification.id);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppColors.darkRed.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isRead ? colorScheme.secondary.withValues(alpha: 0.15) : AppColors.darkRed.withValues(alpha: 0.4),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: [
            if (!isRead)
              BoxShadow(
                color: AppColors.darkRed.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: targetColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isTargetUser ? Icons.mark_email_unread_outlined : Icons.campaign_outlined,
                    size: 18.r,
                    color: targetColor,
                  ),
                ),
                Gap(10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomText(
                              notification.title,
                              variant: TextVariant.headlineSmall,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                            ),
                          ),
                          if (!isRead) ...[
                            Gap(6.w),
                            Container(
                              width: 10.r,
                              height: 10.r,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Gap(2.h),
                      CustomText(
                        formattedDate,
                        variant: TextVariant.bodySmall,
                        color: colorScheme.secondary.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(12.h),
            CustomText(
              notification.body,
              variant: TextVariant.bodyMedium,
              color: colorScheme.onSurface,
            ),
            Gap(12.h),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: targetColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: CustomText(
                  targetLabel,
                  variant: TextVariant.bodySmall,
                  fontWeight: FontWeight.bold,
                  color: targetColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
