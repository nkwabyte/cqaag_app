import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:cqaag_app/index.dart';

/// Admin control over the registration fee, Mobile Money account,
/// and verification of applicant registration payments.
///
/// Shares `settings/payment` with the CQAAG website.
class PaymentSettingsTab extends ConsumerStatefulWidget {
  const PaymentSettingsTab({super.key});

  @override
  ConsumerState<PaymentSettingsTab> createState() => _PaymentSettingsTabState();
}

class _PaymentSettingsTabState extends ConsumerState<PaymentSettingsTab> {
  final _feeController = TextEditingController();
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  MomoNetwork _network = MomoNetwork.mtn;

  bool _isSaving = false;
  bool _hydrated = false;
  PaymentStatus? _selectedStatusFilter;

  @override
  void dispose() {
    _feeController.dispose();
    _numberController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _hydrate(PaymentSettings settings) {
    if (_hydrated) return;
    _feeController.text = settings.registrationFee.toStringAsFixed(2);
    _numberController.text = settings.momoNumber;
    _nameController.text = settings.momoAccountName;
    _network = settings.network;
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settingsAsync = ref.watch(paymentSettingsProvider);
    final applicationsAsync = ref.watch(allMembershipApplicationsProvider);

    final settings = settingsAsync.value ?? PaymentSettings.defaults;
    _hydrate(settings);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Payment Settings Form
          _buildPaymentSettingsCard(colorScheme, settings),

          Gap(32.h),
          const Divider(),
          Gap(24.h),

          // Section 2: Payments Registry & Verification
          _buildPaymentRegistrySection(colorScheme, applicationsAsync),

          Gap(40.h),
        ],
      ),
    );
  }

  Widget _buildPaymentSettingsCard(ColorScheme colorScheme, PaymentSettings settings) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined, color: colorScheme.primary, size: 24.r),
              Gap(12.w),
              const CustomText(
                "Payment Settings",
                variant: TextVariant.headlineMedium,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          Gap(8.h),
          CustomText(
            "Configure the registration fee and Mobile Money account applicants pay into. "
            "These settings apply across both the mobile app and website.",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
          Gap(20.h),

          _buildLabel("Registration Fee (GHS)"),
          Gap(8.h),
          TextField(
            controller: _feeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration(colorScheme, prefixText: 'GHS  ', hint: '500.00'),
          ),
          Gap(16.h),

          _buildLabel("Mobile Money Network"),
          Gap(8.h),
          DropdownButtonFormField<MomoNetwork>(
            initialValue: _network,
            decoration: _inputDecoration(colorScheme),
            items: MomoNetwork.values
                .map((n) => DropdownMenuItem(value: n, child: CustomText(n.label)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _network = value);
            },
          ),
          Gap(16.h),

          _buildLabel("Mobile Money Number"),
          Gap(8.h),
          TextField(
            controller: _numberController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(colorScheme, hint: '+233 55 333 0931'),
          ),
          Gap(16.h),

          _buildLabel("Account Name"),
          Gap(8.h),
          TextField(
            controller: _nameController,
            decoration: _inputDecoration(colorScheme, hint: 'Amoafo Ebenezer'),
          ),
          Gap(6.h),
          CustomText(
            "Shown to applicants so they can confirm the recipient before sending money.",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),

          Gap(24.h),
          CustomButton(
            text: _isSaving ? "Saving..." : "Save Payment Settings",
            isLoading: _isSaving,
            onPressed: _isSaving ? () {} : _save,
          ),

          if (settings.updatedAt != null) ...[
            Gap(12.h),
            CustomText(
              "Last updated ${settings.updatedAt.toString().split('.').first}",
              variant: TextVariant.bodySmall,
              color: colorScheme.secondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentRegistrySection(
    ColorScheme colorScheme,
    AsyncValue<List<MembershipApplication>> applicationsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    "Payment Verification",
                    variant: TextVariant.headlineMedium,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(4.h),
                  CustomText(
                    "Verify applicant mobile money payment submissions.",
                    variant: TextVariant.bodySmall,
                    color: colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
        Gap(16.h),

        // Status Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip("All", null, colorScheme),
              Gap(8.w),
              _buildFilterChip("Pending", PaymentStatus.pendingVerification, colorScheme),
              Gap(8.w),
              _buildFilterChip("Verified", PaymentStatus.verified, colorScheme),
              Gap(8.w),
              _buildFilterChip("Rejected", PaymentStatus.rejected, colorScheme),
            ],
          ),
        ),
        Gap(20.h),

        // Applications List
        applicationsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Center(
            child: CustomText("Error loading payment applications: $err", color: Colors.red),
          ),
          data: (apps) {
            final paymentApps = apps.where((app) {
              if (_selectedStatusFilter == null) {
                return app.paymentStatus != 'unpaid' || app.paymentEvidenceUrl != null;
              }
              return app.payment == _selectedStatusFilter;
            }).toList();

            if (paymentApps.isEmpty) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(32.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48.r, color: colorScheme.secondary),
                    Gap(12.h),
                    CustomText(
                      "No payment records found",
                      variant: TextVariant.bodyLarge,
                      color: colorScheme.secondary,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paymentApps.length,
              separatorBuilder: (ctx, idx) => Gap(12.h),
              itemBuilder: (context, index) {
                final app = paymentApps[index];
                return _buildPaymentCard(app, colorScheme);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, PaymentStatus? status, ColorScheme colorScheme) {
    final isSelected = _selectedStatusFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedStatusFilter = status);
        }
      },
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildPaymentCard(MembershipApplication app, ColorScheme colorScheme) {
    final status = app.payment;
    final statusColor = switch (status) {
      PaymentStatus.verified => Colors.green,
      PaymentStatus.pendingVerification => Colors.orange,
      PaymentStatus.rejected => Colors.red,
      PaymentStatus.unpaid => Colors.grey,
    };

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomText(
                  "${app.firstName} ${app.lastName}",
                  variant: TextVariant.bodyLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: CustomText(
                  status.label.toUpperCase(),
                  variant: TextVariant.bodySmall,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Gap(4.h),
          CustomText(
            app.membershipCategory.displayName,
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
          Gap(12.h),

          // Payment Details Box
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomText(
                      "Amount: ",
                      variant: TextVariant.bodySmall,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomText(
                      "${app.paymentCurrency} ${(app.paymentAmount ?? 500).toStringAsFixed(2)}",
                      variant: TextVariant.bodySmall,
                    ),
                    const Spacer(),
                    CustomText(
                      "Method: ",
                      variant: TextVariant.bodySmall,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomText(
                      app.paymentMethod == 'momo' ? 'Mobile Money' : (app.paymentMethod ?? 'MOMO'),
                      variant: TextVariant.bodySmall,
                    ),
                  ],
                ),
                Gap(4.h),
                Row(
                  children: [
                    CustomText(
                      "Reference: ",
                      variant: TextVariant.bodySmall,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomText(
                      app.paymentReference ?? "Not provided",
                      variant: TextVariant.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap(12.h),

          // Evidence Image Preview if available
          if (app.paymentEvidenceUrl != null && app.paymentEvidenceUrl!.isNotEmpty) ...[
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: CachedNetworkImage(
                          imageUrl: app.paymentEvidenceUrl!,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: app.paymentEvidenceUrl!,
                      width: 60.r,
                      height: 60.r,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                Gap(12.w),
                const Expanded(
                  child: CustomText(
                    "Payment Evidence Uploaded (Tap thumbnail to view full image)",
                    variant: TextVariant.bodySmall,
                  ),
                ),
              ],
            ),
            Gap(12.h),
          ],

          // Quick Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pushNamed(AdminMemberDetailScreen.id, extra: app),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: const Text("View Details"),
                ),
              ),
              if (status == PaymentStatus.pendingVerification) ...[
                Gap(8.w),
                IconButton(
                  onPressed: () => _updatePayment(app.id, PaymentStatus.rejected),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  tooltip: "Reject Payment",
                ),
                IconButton(
                  onPressed: () => _updatePayment(app.id, PaymentStatus.verified),
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  tooltip: "Verify Payment",
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return CustomText(text, variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold);
  }

  InputDecoration _inputDecoration(ColorScheme colorScheme, {String? hint, String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
    );
  }

  Future<void> _updatePayment(String appId, PaymentStatus newStatus) async {
    final verb = newStatus == PaymentStatus.verified ? 'verify' : 'reject';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("${verb[0].toUpperCase()}${verb.substring(1)} Payment?"),
        content: Text(
          newStatus == PaymentStatus.verified
              ? "Confirm that this registration payment has been verified."
              : "Mark this payment as rejected?",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == PaymentStatus.verified ? Colors.green : Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(newStatus == PaymentStatus.verified ? "Verify" : "Reject"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final admin = ref.read(authServiceProvider).currentUser;
      if (admin == null) throw Exception('Not authenticated');

      await ref.read(membershipServiceProvider).updatePaymentStatus(
        applicationId: appId,
        status: newStatus,
        verifiedBy: admin.uid,
      );

      if (!mounted) return;
      CustomSnackBar.success(context, message: "Payment status updated to ${newStatus.label}.");
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, message: "Failed to update payment status: $e");
    }
  }

  Future<void> _save() async {
    final fee = double.tryParse(_feeController.text.trim());
    if (fee == null || fee <= 0) {
      CustomSnackBar.error(context, message: 'Enter a registration fee greater than zero.');
      return;
    }

    final number = _numberController.text.trim();
    if (number.isEmpty) {
      CustomSnackBar.error(context, message: 'Enter the Mobile Money number applicants should pay into.');
      return;
    }

    final accountName = _nameController.text.trim();
    if (accountName.isEmpty) {
      CustomSnackBar.error(context, message: 'Enter the Mobile Money account name.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final admin = ref.read(authServiceProvider).currentUser;
      if (admin == null) throw Exception('Not authenticated');

      await ref.read(paymentSettingsServiceProvider).updateSettings(
        registrationFee: fee,
        momoNetwork: _network,
        momoNumber: number,
        momoAccountName: accountName,
        updatedBy: admin.uid,
      );

      if (!mounted) return;
      CustomSnackBar.success(
        context,
        message: 'Payment settings saved. The website and app now use these values.',
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, message: 'Could not save settings: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
