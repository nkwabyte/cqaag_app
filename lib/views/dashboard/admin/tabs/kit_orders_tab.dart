import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cqaag_app/index.dart';

final kitOrdersProvider = StreamProvider<List<KitOrder>>((ref) {
  return ref.watch(kitOrderServiceProvider).streamAllOrders();
});

/// Quality cutting kit orders from guests and members: check the payment,
/// then mark the order delivered.
class KitOrdersTab extends ConsumerWidget {
  const KitOrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(kitOrdersProvider);

    return orders.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: CustomText('Could not load kit orders: $e', textAlign: TextAlign.center)),
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: CustomText('No kit orders yet.'));
        }
        return ListView.separated(
          padding: EdgeInsets.all(12.r),
          itemCount: list.length,
          separatorBuilder: (_, _) => Gap(12.h),
          itemBuilder: (context, index) => _KitOrderCard(order: list[index]),
        );
      },
    );
  }
}

class _KitOrderCard extends ConsumerWidget {
  const _KitOrderCard({required this.order});

  final KitOrder order;

  Color get _statusColor => switch (order.status) {
    KitOrderStatus.pendingVerification => Colors.orange.shade800,
    KitOrderStatus.paid => Colors.blue.shade800,
    KitOrderStatus.fulfilled => Colors.green.shade800,
    KitOrderStatus.rejected => Colors.red.shade800,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _statusColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText('${order.reference} • ${order.buyerName}', variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4.r)),
                child: Text(order.status.label, style: TextStyle(color: _statusColor, fontSize: 10.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Gap(4.h),
          CustomText(
            '${order.isGuest ? 'Guest' : 'Member'} • ${DateFormat('d MMM yyyy, HH:mm').format(order.createdAt)}',
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
          Gap(8.h),
          for (final item in order.items)
            Row(
              children: [
                Expanded(child: CustomText(item.displayLabel, variant: TextVariant.bodySmall)),
                CustomText(order.money(item.amount), variant: TextVariant.bodySmall),
              ],
            ),
          const Divider(),
          Row(
            children: [
              const Expanded(child: CustomText('Total', fontWeight: FontWeight.bold)),
              CustomText(order.money(order.total), fontWeight: FontWeight.bold),
            ],
          ),
          Gap(6.h),
          InkWell(
            onTap: () => launchUrl(Uri.parse('tel:${order.phoneNumber}')),
            child: CustomText('📞 ${order.phoneNumber}', variant: TextVariant.bodySmall, color: colorScheme.primary),
          ),
          if (order.emailAddress != null) CustomText('✉️ ${order.emailAddress}', variant: TextVariant.bodySmall),
          if (order.organisation != null) CustomText('🏢 ${order.organisation}', variant: TextVariant.bodySmall),
          if (order.deliveryLocation != null) CustomText('📍 ${order.deliveryLocation}', variant: TextVariant.bodySmall),
          if (order.paymentReference != null) CustomText('Ref: ${order.paymentReference}', variant: TextVariant.bodySmall),
          Gap(8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              if (order.paymentEvidenceUrl != null)
                OutlinedButton.icon(
                  onPressed: () => _showEvidence(context, order.paymentEvidenceUrl!),
                  icon: const Icon(Icons.receipt_long_outlined, size: 16),
                  label: const Text('Evidence'),
                ),
              if (order.status == KitOrderStatus.pendingVerification) ...[
                OutlinedButton(
                  onPressed: () => _setStatus(context, ref, KitOrderStatus.rejected),
                  style: OutlinedButton.styleFrom(foregroundColor: colorScheme.error),
                  child: const Text('Reject'),
                ),
                ElevatedButton(
                  onPressed: () => _setStatus(context, ref, KitOrderStatus.paid),
                  child: const Text('Confirm payment'),
                ),
              ],
              if (order.status == KitOrderStatus.paid)
                ElevatedButton(
                  onPressed: () => _setStatus(context, ref, KitOrderStatus.fulfilled),
                  child: const Text('Mark delivered'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEvidence(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: EdgeInsets.all(16.r),
        child: InteractiveViewer(child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain)),
      ),
    );
  }

  Future<void> _setStatus(BuildContext context, WidgetRef ref, KitOrderStatus status) async {
    try {
      await ref.read(kitOrderServiceProvider).updateStatus(
        orderId: order.id,
        status: status,
        adminUid: ref.read(authServiceProvider).currentUser?.uid ?? '',
      );
      if (context.mounted) CustomSnackBar.success(context, message: 'Order ${order.reference}: ${status.label}.');
    } catch (e) {
      if (context.mounted) CustomSnackBar.error(context, message: 'Could not update the order: $e');
    }
  }
}
