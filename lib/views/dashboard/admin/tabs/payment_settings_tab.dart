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
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  MomoNetwork _network = MomoNetwork.mtn;

  bool _isSaving = false;
  bool _hydrated = false;
  PaymentStatus? _selectedStatusFilter;

  /// The fee schedule column currently being edited. The schedule prices every
  /// line item per category, so it is edited one column at a time rather than
  /// as a grid that would not fit a phone.
  FeeCategory _editingCategory = FeeCategory.full;

  /// The schedule as edited, committed to Firestore on save.
  late FeeSchedule _schedule;

  /// One controller per amount cell, keyed `<section>:<itemKey>:<categoryKey>`.
  final Map<String, TextEditingController> _amountControllers = {};

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _hydrate(PaymentSettings settings) {
    if (_hydrated) return;
    _numberController.text = settings.momoNumber;
    _nameController.text = settings.momoAccountName;
    _network = settings.network;
    _schedule = settings.schedule;
    _hydrated = true;
  }

  /// Controller for one amount cell, seeded from the schedule on first use.
  ///
  /// An unpriced item (a cell the Board has not decided yet) seeds blank rather
  /// than zero, so "no price set" stays distinguishable from "free".
  TextEditingController _amountController(String section, String itemKey, double? value) {
    final key = '$section:$itemKey:${_editingCategory.key}';
    return _amountControllers.putIfAbsent(
      key,
      () => TextEditingController(text: value == null ? '' : value.toStringAsFixed(2)),
    );
  }

  /// Reads a cell back, treating blank as "not priced".
  double? _readAmount(String section, String itemKey) {
    final text = _amountControllers['$section:$itemKey:${_editingCategory.key}']?.text.trim() ?? '';
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  /// Folds every edited cell for the current column back into [_schedule].
  ///
  /// Called before switching columns and before saving, so edits to one
  /// category are not lost when the admin moves to another.
  void _commitEditedColumn() {
    final category = _editingCategory;

    final registration = _schedule.registrationComponents
        .map((item) => item.copyWithAmount(category, _readAmount('reg', item.key) ?? item.amountFor(category)))
        .toList();

    final optional = _schedule.optionalItems
        .map((item) => item.copyWithAmount(category, _readAmount('opt', item.key)))
        .toList();

    final duesText = _amountControllers['dues:annual:${category.key}']?.text.trim();
    final dues = Map<String, double?>.from(_schedule.annualDues);
    if (duesText != null) {
      dues[category.key] = duesText.isEmpty ? null : double.tryParse(duesText);
    }

    _schedule = _schedule.copyWith(
      registrationComponents: registration,
      annualDues: dues,
      optionalItems: optional,
    );
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
          // Section 1: Mobile Money account
          _buildPaymentSettingsCard(colorScheme, settings),

          Gap(24.h),

          // Section 2: The Board's fee schedule
          _buildFeeScheduleCard(colorScheme, settings),

          Gap(20.h),

          // One save covers both: they are two halves of the same document.
          CustomButton(
            text: _isSaving ? "Saving..." : "Save Payment Settings & Fee Schedule",
            isLoading: _isSaving,
            onPressed: _isSaving ? () {} : _save,
          ),

          Gap(32.h),
          const Divider(),
          Gap(24.h),

          // Section 3: Payments Registry & Verification
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
                "Mobile Money Account",
                variant: TextVariant.headlineMedium,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          Gap(8.h),
          CustomText(
            "The Mobile Money account applicants pay into. Applies across both the "
            "mobile app and the website. Fees themselves live in the schedule below.",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
          Gap(20.h),

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

          if (settings.updatedAt != null) ...[
            Gap(16.h),
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

                // What the total is actually made of, so an admin can reconcile
                // an odd-looking amount against the schedule without guessing.
                if (app.paymentRegistrationFee != null || app.paymentAnnualDues != null) ...[
                  Gap(6.h),
                  const Divider(height: 1),
                  Gap(6.h),
                  if (app.paymentRegistrationFee != null)
                    _buildBreakdownRow("Registration Fee", app.money(app.paymentRegistrationFee!)),
                  if (app.paymentAnnualDues != null)
                    _buildBreakdownRow("Annual Dues", app.money(app.paymentAnnualDues!)),
                  if (app.hasOptionalItems)
                    _buildBreakdownRow(
                      "Optional items (${app.paymentOptionalItems.map((e) => e.displayLabel).join(', ')})",
                      app.money(app.paymentOptionalTotal),
                    )
                  else
                    _buildBreakdownRow("Optional items", "None taken"),
                ],
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

  /// Editor for the CQAAG Membership Categories, Fees & Dues Schedule.
  ///
  /// The schedule is a grid — every line item priced per category — which will
  /// not fit a phone, so it is edited one category column at a time. Leaving a
  /// cell blank records "no Board-approved price", which keeps the item off the
  /// applicant's list rather than offering it free.
  Widget _buildFeeScheduleCard(ColorScheme colorScheme, PaymentSettings settings) {
    final category = _editingCategory;
    final isExempt = category.isExempt;

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
              Icon(Icons.table_chart_outlined, color: colorScheme.primary, size: 24.r),
              Gap(12.w),
              const Expanded(
                child: CustomText(
                  "Fees & Dues Schedule",
                  variant: TextVariant.headlineMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Gap(8.h),
          CustomText(
            "Registration Fee components, Annual Dues and optional kit items, per "
            "membership category (Constitution Art. 2, as amended).",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
          Gap(16.h),

          // Category selector — switching commits the column being left.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in FeeCategory.values) ...[
                  ChoiceChip(
                    label: Text(option.label),
                    selected: option == category,
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(() {
                        _commitEditedColumn();
                        _editingCategory = option;
                      });
                    },
                    selectedColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      color: option == category ? Colors.white : colorScheme.onSurface,
                      fontWeight: option == category ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Gap(8.w),
                ],
              ],
            ),
          ),
          Gap(20.h),

          if (isExempt)
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: CustomText(
                "Honorary Members pay no fees (Constitution Art. 2, Categories), so this "
                "column is fixed at zero and is not editable.",
                variant: TextVariant.bodySmall,
                color: colorScheme.secondary,
              ),
            )
          else ...[
            _buildScheduleSectionHeader("Registration Fee components", colorScheme),
            ..._schedule.registrationComponents.map(
              (item) => _buildAmountField('reg', item, colorScheme),
            ),
            Gap(8.h),
            _buildScheduleTotalRow(
              "Registration Fee total",
              settings.money(_schedule.registrationFeeFor(category)),
              colorScheme,
            ),

            Gap(20.h),
            _buildScheduleSectionHeader("Annual Dues", colorScheme),
            _buildRawAmountField(
              label: "Annual Dues (inclusive of TCDA recommendation letter, where applicable)",
              controller: _amountController('dues', 'annual', _schedule.annualDuesFor(category)),
              colorScheme: colorScheme,
            ),

            Gap(20.h),
            _buildScheduleSectionHeader("Optional kit items", colorScheme),
            CustomText(
              "Leave blank where the Board has not set a price. Blank and zero items "
              "are not offered to applicants.",
              variant: TextVariant.bodySmall,
              color: colorScheme.secondary,
            ),
            Gap(10.h),
            ..._schedule.optionalItems.map(
              (item) => _buildAmountField('opt', item, colorScheme),
            ),

            Gap(16.h),
            _buildScheduleTotalRow(
              "Schedule Grand Total (all optional items taken)",
              settings.money(_schedule.grandTotalFor(category)),
              colorScheme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleSectionHeader(String title, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: CustomText(
        title.toUpperCase(),
        variant: TextVariant.bodySmall,
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildAmountField(String section, FeeLineItem item, ColorScheme colorScheme) {
    return _buildRawAmountField(
      label: item.requiresSize ? '${item.label} (size collected at payment)' : item.label,
      controller: _amountController(section, item.key, item.amountFor(_editingCategory)),
      colorScheme: colorScheme,
    );
  }

  Widget _buildRawAmountField({
    required String label,
    required TextEditingController controller,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: CustomText(label, variant: TextVariant.bodySmall),
          ),
          Gap(12.w),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              // Rebuild so the totals below follow the edit as it is typed.
              onChanged: (_) => setState(() {}),
              decoration: _inputDecoration(colorScheme, hint: 'Not set').copyWith(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTotalRow(String label, String amount, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CustomText(label, variant: TextVariant.bodySmall, fontWeight: FontWeight.bold),
          ),
          Gap(8.w),
          CustomText(amount, variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: CustomText(label, variant: TextVariant.bodySmall)),
          Gap(8.w),
          CustomText(value, variant: TextVariant.bodySmall, fontWeight: FontWeight.bold),
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

    // Fold the column the admin is currently looking at back into the schedule
    // before writing, so the edit they can see on screen is the edit that saves.
    _commitEditedColumn();

    // A category that owes nothing would leave applicants with no fee to pay,
    // so this is almost certainly a cleared field rather than a Board decision.
    for (final category in FeeCategory.values) {
      if (category.isExempt) continue;
      if (_schedule.mandatoryTotalFor(category) <= 0) {
        CustomSnackBar.error(
          context,
          message: '${category.label} has no Registration Fee or Annual Dues set. '
              'Enter an amount before saving.',
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final admin = ref.read(authServiceProvider).currentUser;
      if (admin == null) throw Exception('Not authenticated');

      await ref.read(paymentSettingsServiceProvider).updateSettings(
        momoNetwork: _network,
        momoNumber: number,
        momoAccountName: accountName,
        updatedBy: admin.uid,
        feeSchedule: _schedule,
      );

      if (!mounted) return;
      CustomSnackBar.success(
        context,
        message: 'Payment settings and fee schedule saved. The website and app now use these values.',
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, message: 'Could not save settings: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
