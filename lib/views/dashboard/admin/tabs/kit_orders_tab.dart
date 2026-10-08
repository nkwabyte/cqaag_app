import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cqaag_app/index.dart';

/// Direct kit orders from the `kit_orders` collection.
final directKitOrdersProvider = StreamProvider<List<KitOrder>>((ref) {
  return ref.watch(kitOrderServiceProvider).streamAllOrders();
});

/// Combined kit orders: both standalone purchases from `kit_orders`
/// and membership applications that ordered optional cutting kit items.
final kitOrdersProvider = Provider<AsyncValue<List<KitOrder>>>((ref) {
  final directAsync = ref.watch(directKitOrdersProvider);
  final applicationsAsync = ref.watch(allMembershipApplicationsProvider);

  final directOrders = directAsync.value ?? <KitOrder>[];
  final applications = applicationsAsync.value ?? <MembershipApplication>[];

  final membershipKitOrders = <KitOrder>[];
  for (final app in applications) {
    if (app.hasOptionalItems) {
      final totalKitCost = app.paymentOptionalItems.fold<double>(0, (sum, item) => sum + item.amount);
      membershipKitOrders.add(KitOrder(
        id: app.id,
        buyerName: app.fullName.trim().isNotEmpty ? app.fullName.trim() : app.emailAddress,
        phoneNumber: app.phoneNumberPrimary,
        emailAddress: app.emailAddress,
        organisation: app.employerOrganization,
        deliveryLocation: app.residentialAddress,
        buyerUserId: app.userId,
        items: app.paymentOptionalItems,
        total: totalKitCost,
        currency: app.paymentCurrency,
        paymentEvidenceUrl: app.paymentEvidenceUrl,
        paymentReference: app.paymentReference,
        paymentMomoNetwork: app.paymentMomoNetwork,
        paymentMomoNumber: app.paymentMomoNumber,
        status: switch (app.payment) {
          PaymentStatus.verified => KitOrderStatus.paid,
          PaymentStatus.rejected => KitOrderStatus.rejected,
          _ => KitOrderStatus.pendingVerification,
        },
        createdAt: app.paymentSubmittedAt ?? app.createdAt ?? DateTime.now(),
        notes: 'Membership Application (${app.membershipCategory.displayName})',
      ));
    }
  }

  // Combine and deduplicate by id
  final seenIds = <String>{};
  final combined = <KitOrder>[];
  for (final order in [...directOrders, ...membershipKitOrders]) {
    if (seenIds.add(order.id)) {
      combined.add(order);
    }
  }
  combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // If neither stream has provided any value yet and either is still loading, show loading:
  final hasAnyValue = directAsync.hasValue || applicationsAsync.hasValue;
  if (!hasAnyValue && (directAsync.isLoading || applicationsAsync.isLoading)) {
    return const AsyncValue.loading();
  }

  // If both errored and neither has a value, show error:
  if (!hasAnyValue && directAsync.hasError && applicationsAsync.hasError) {
    return AsyncValue.error(
      applicationsAsync.error ?? directAsync.error ?? 'Failed to load kit orders',
      applicationsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncValue.data(combined);
});

/// Quality cutting kit orders from guests, members, and membership applicants:
/// check payment evidence, verify or reject, and mark delivered.
class KitOrdersTab extends ConsumerStatefulWidget {
  const KitOrdersTab({super.key});

  @override
  ConsumerState<KitOrdersTab> createState() => _KitOrdersTabState();
}

class _KitOrdersTabState extends ConsumerState<KitOrdersTab> {
  KitOrderStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ordersAsync = ref.watch(kitOrdersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(directKitOrdersProvider);
        ref.invalidate(allMembershipApplicationsProvider);
      },
      child: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.r, color: colorScheme.error),
                Gap(12.h),
                CustomText('Could not load kit orders: $e', textAlign: TextAlign.center),
                Gap(16.h),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(directKitOrdersProvider);
                    ref.invalidate(allMembershipApplicationsProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (allOrders) {
          final filtered = _statusFilter == null
              ? allOrders
              : allOrders.where((o) => o.status == _statusFilter).toList();

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All (${allOrders.length})', null),
                            Gap(8.w),
                            _buildFilterChip(
                              'Awaiting Check (${allOrders.where((o) => o.status == KitOrderStatus.pendingVerification).length})',
                              KitOrderStatus.pendingVerification,
                            ),
                            Gap(8.w),
                            _buildFilterChip(
                              'Paid (${allOrders.where((o) => o.status == KitOrderStatus.paid).length})',
                              KitOrderStatus.paid,
                            ),
                            Gap(8.w),
                            _buildFilterChip(
                              'Delivered (${allOrders.where((o) => o.status == KitOrderStatus.fulfilled).length})',
                              KitOrderStatus.fulfilled,
                            ),
                            Gap(8.w),
                            _buildFilterChip(
                              'Rejected (${allOrders.where((o) => o.status == KitOrderStatus.rejected).length})',
                              KitOrderStatus.rejected,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 56.r, color: colorScheme.secondary.withValues(alpha: 0.5)),
                          Gap(12.h),
                          CustomText(
                            _statusFilter == null ? 'No kit orders recorded yet.' : 'No orders in this status.',
                            variant: TextVariant.bodyMedium,
                            color: colorScheme.secondary,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _KitOrderCard(order: filtered[index]),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, KitOrderStatus? status) {
    final selected = _statusFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _statusFilter = status),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  '${order.reference} • ${order.buyerName}',
                  variant: TextVariant.bodyLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(color: _statusColor, fontSize: 10.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Gap(4.h),
          CustomText(
            '${order.isGuest ? 'Guest' : 'Member'} • ${DateFormat('d MMM yyyy, HH:mm').format(order.createdAt)}',
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            Gap(4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                order.notes!,
                style: TextStyle(fontSize: 10.sp, color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
          Gap(8.h),
          for (final item in order.items)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: CustomText(
                      item.displayLabel,
                      variant: TextVariant.bodySmall,
                    ),
                  ),
                  CustomText(order.money(item.amount), variant: TextVariant.bodySmall),
                ],
              ),
            ),
          const Divider(),
          Row(
            children: [
              const Expanded(child: CustomText('Total', fontWeight: FontWeight.bold)),
              CustomText(order.money(order.total), fontWeight: FontWeight.bold),
            ],
          ),
          Gap(6.h),
          if (order.phoneNumber.isNotEmpty)
            InkWell(
              onTap: () => launchUrl(Uri.parse('tel:${order.phoneNumber}')),
              child: CustomText(
                '📞 ${order.phoneNumber}',
                variant: TextVariant.bodySmall,
                color: colorScheme.primary,
              ),
            ),
          if (order.emailAddress != null && order.emailAddress!.isNotEmpty)
            CustomText('✉️ ${order.emailAddress}', variant: TextVariant.bodySmall),
          if (order.organisation != null && order.organisation!.isNotEmpty)
            CustomText('🏢 ${order.organisation}', variant: TextVariant.bodySmall),
          if (order.deliveryLocation != null && order.deliveryLocation!.isNotEmpty)
            CustomText('📍 ${order.deliveryLocation}', variant: TextVariant.bodySmall),
          if (order.paymentReference != null && order.paymentReference!.isNotEmpty)
            CustomText('Ref: ${order.paymentReference}', variant: TextVariant.bodySmall),
          Gap(8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              if (order.paymentEvidenceUrl != null && order.paymentEvidenceUrl!.isNotEmpty)
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
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (context, url) => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => const SizedBox(
              height: 200,
              child: Center(child: Text('Could not load payment receipt image')),
            ),
          ),
        ),
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
      ref.invalidate(directKitOrdersProvider);
      ref.invalidate(allMembershipApplicationsProvider);
      if (context.mounted) {
        CustomSnackBar.success(context, message: 'Order ${order.reference}: ${status.label}.');
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.error(context, message: 'Could not update the order: $e');
      }
    }
  }
}
