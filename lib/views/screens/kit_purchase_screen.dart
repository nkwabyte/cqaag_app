import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart' as uuid_pkg;
import 'package:cqaag_app/index.dart';

/// Buying quality cutting kits for registered members.
///
/// Items and prices come from the Board's fee schedule (the Kits / Optional
/// rows), priced at the standard Full Membership rate. Items the Board has not
/// priced yet are listed but cannot be ordered.
class KitPurchaseScreen extends ConsumerStatefulWidget {
  static const String id = 'kit_purchase_screen';

  const KitPurchaseScreen({super.key});

  @override
  ConsumerState<KitPurchaseScreen> createState() => _KitPurchaseScreenState();
}

class _KitPurchaseScreenState extends ConsumerState<KitPurchaseScreen> {
  /// The schedule column kits are sold at.
  static const FeeCategory _priceColumn = FeeCategory.full;

  final _formKey = GlobalKey<FormBuilderState>();
  final Map<String, int> _quantities = {};
  final Map<String, TextEditingController> _sizes = {};
  File? _evidence;
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final c in _sizes.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<SelectedFeeItem> _selection(FeeSchedule schedule) {
    final items = <SelectedFeeItem>[];
    for (final item in schedule.optionalItemsFor(_priceColumn)) {
      final qty = _quantities[item.key] ?? 0;
      if (qty <= 0) continue;
      final size = item.requiresSize ? _sizes[item.key]?.text.trim() : null;
      final label = qty > 1 ? '${item.label} × $qty' : item.label;
      items.add(SelectedFeeItem(key: item.key, label: label, amount: item.amountFor(_priceColumn)! * qty, size: size));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(paymentSettingsProvider).value ?? PaymentSettings.defaults;
    final schedule = settings.schedule;
    final available = schedule.optionalItemsFor(_priceColumn);
    final unpriced = schedule.unpricedOptionalItemsFor(_priceColumn);
    final selection = _selection(schedule);
    final total = selection.fold<double>(0, (sum, item) => sum + item.amount);
    final user = ref.watch(currentUserProfileProvider).value;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const LegalDocumentHeader(
            title: 'Quality Cutting Kits',
            subtitle: 'Order quality checking kits from CQAAG',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: FormBuilder(
                key: _formKey,
                initialValue: {
                  'buyer_name': user == null ? '' : '${user.firstName} ${user.lastName}'.trim(),
                  'phone_number': user?.phoneNumber ?? '',
                  'email_address': user?.email ?? '',
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText("1. Choose items", variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
                    Gap(10.h),
                    if (available.isEmpty)
                      CustomText("No kit items are priced yet.", variant: TextVariant.bodyMedium, color: colorScheme.secondary),
                    for (final item in available) _buildItemRow(item, settings, colorScheme),
                    if (unpriced.isNotEmpty) ...[
                      Gap(8.h),
                      CustomText(
                        "Awaiting Board pricing: ${unpriced.map((e) => e.label).join(', ')}. Contact the Secretariat to order these.",
                        variant: TextVariant.bodySmall,
                        color: colorScheme.secondary,
                      ),
                    ],
                    Gap(24.h),
                    const CustomText("2. Your details", variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
                    Gap(10.h),
                    CustomTextField(
                      name: 'buyer_name',
                      label: "Full Name",
                      hint: "Name for the order",
                      prefixIcon: Icons.person_outline,
                      validator: FormBuilderValidators.required(),
                    ),
                    Gap(12.h),
                    CustomTextField(
                      name: 'phone_number',
                      label: "Phone Number",
                      hint: "e.g. +233 XX XXX XXXX",
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: FormBuilderValidators.required(),
                    ),
                    Gap(12.h),
                    CustomTextField(
                      name: 'email_address',
                      label: "Email (optional)",
                      hint: "For order updates",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: FormBuilderValidators.email(checkNullOrEmpty: false),
                    ),
                    Gap(12.h),
                    const CustomTextField(
                      name: 'organisation',
                      label: "Company / Organisation (optional)",
                      hint: "e.g. Ghana Cashew Co.",
                      prefixIcon: Icons.business_outlined,
                    ),
                    Gap(12.h),
                    CustomTextField(
                      name: 'delivery_location',
                      label: "Delivery / Pick-up Location",
                      hint: "Town, region or CQAAG office",
                      prefixIcon: Icons.location_on_outlined,
                      validator: FormBuilderValidators.required(),
                    ),
                    Gap(24.h),
                    const CustomText("3. Pay", variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
                    Gap(10.h),
                    _buildPayment(settings, total, colorScheme),
                    Gap(32.h),
                    CustomButton(
                      text: selection.isEmpty ? "Choose at least one item" : "Place Order — ${settings.money(total)}",
                      isLoading: _isSubmitting,
                      onPressed: selection.isEmpty || _isSubmitting ? null : () => _placeOrder(settings),
                    ),
                    Gap(40.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(FeeLineItem item, PaymentSettings settings, ColorScheme colorScheme) {
    final qty = _quantities[item.key] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: qty > 0 ? colorScheme.primary : colorScheme.secondary.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(item.label, variant: TextVariant.bodyMedium, fontWeight: FontWeight.w600),
                    CustomText(settings.money(item.amountFor(_priceColumn)!), variant: TextVariant.bodySmall, color: colorScheme.secondary),
                  ],
                ),
              ),
              IconButton(
                onPressed: qty == 0 ? null : () => setState(() => _quantities[item.key] = qty - 1),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              CustomText('$qty', variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
              IconButton(
                onPressed: () => setState(() {
                  _quantities[item.key] = qty + 1;
                  if (item.requiresSize) _sizes.putIfAbsent(item.key, () => TextEditingController());
                }),
                icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
              ),
            ],
          ),
          if (qty > 0 && item.requiresSize)
            TextField(
              controller: _sizes[item.key],
              decoration: InputDecoration(labelText: '${item.label} size', hintText: 'e.g. 42', isDense: true),
            ),
        ],
      ),
    );
  }

  Widget _buildPayment(PaymentSettings settings, double total, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText("Send ${settings.money(total)} by Mobile Money to", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
          Gap(10.h),
          _detail("Network", settings.network.label),
          Row(
            children: [
              Expanded(child: _detail("Number", settings.momoNumber)),
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: settings.momoNumber));
                  if (mounted) CustomSnackBar.success(context, message: 'Number copied');
                },
                child: Icon(Icons.copy_outlined, size: 18.r, color: colorScheme.primary),
              ),
            ],
          ),
          _detail("Account name", settings.momoAccountName),
          Gap(12.h),
          InkWell(
            onTap: () async {
              final file = await ImageSourcePicker.pick(context, cameraLabel: 'Take a photo of the receipt');
              if (file != null) setState(() => _evidence = file);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
              ),
              child: _evidence == null
                  ? const Row(
                      children: [
                        Icon(Icons.receipt_long_outlined),
                        SizedBox(width: 10),
                        Expanded(child: CustomText("Upload payment evidence")),
                      ],
                    )
                  : Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: Image.file(_evidence!, width: 56.r, height: 56.r, fit: BoxFit.cover),
                        ),
                        Gap(10.w),
                        const Expanded(child: CustomText("Evidence attached — tap to change", variant: TextVariant.bodySmall)),
                      ],
                    ),
            ),
          ),
          Gap(10.h),
          const CustomTextField(
            name: 'payment_reference',
            label: "Transaction ID (optional)",
            hint: "e.g. MP250804.1523.A12345",
            prefixIcon: Icons.tag,
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          SizedBox(width: 110.w, child: CustomText(label, variant: TextVariant.bodySmall, color: Theme.of(context).colorScheme.secondary)),
          Expanded(child: CustomText(value, variant: TextVariant.bodySmall, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _placeOrder(PaymentSettings settings) async {
    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser == null) {
      CustomSnackBar.error(context, message: 'Please sign in to order cutting kits.');
      return;
    }
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final evidence = _evidence;
    if (evidence == null) {
      CustomSnackBar.error(context, message: 'Upload evidence of your Mobile Money payment.');
      return;
    }
    final schedule = settings.schedule;
    for (final item in schedule.optionalItemsFor(_priceColumn)) {
      if (item.requiresSize && (_quantities[item.key] ?? 0) > 0 && (_sizes[item.key]?.text.trim().isEmpty ?? true)) {
        CustomSnackBar.error(context, message: 'Please enter a size for ${item.label}.');
        return;
      }
    }

    final values = _formKey.currentState!.value;
    String? text(String key) {
      final v = (values[key] as String?)?.trim();
      return v == null || v.isEmpty ? null : v;
    }

    setState(() => _isSubmitting = true);
    try {
      final evidenceUrl = await ref.read(cloudinaryServiceProvider).uploadPaymentEvidence(evidence);
      if (evidenceUrl == null) throw Exception('Could not upload your payment evidence. Please try again.');

      final items = _selection(schedule);
      final order = KitOrder(
        id: const uuid_pkg.Uuid().v4(),
        buyerName: text('buyer_name')!,
        phoneNumber: text('phone_number')!,
        emailAddress: text('email_address')?.toLowerCase(),
        organisation: text('organisation'),
        deliveryLocation: text('delivery_location'),
        buyerUserId: ref.read(authServiceProvider).currentUser?.uid,
        items: items,
        total: items.fold<double>(0, (sum, item) => sum + item.amount),
        currency: settings.currency,
        paymentEvidenceUrl: evidenceUrl,
        paymentReference: text('payment_reference'),
        paymentMomoNetwork: settings.network.value,
        paymentMomoNumber: settings.momoNumber,
        createdAt: DateTime.now(),
      );
      await ref.read(kitOrderServiceProvider).placeOrder(order);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(Icons.check_circle_outline, color: AppColors.primaryGreen, size: 48.r),
          title: const Text('Order placed'),
          content: Text(
            'Your order reference is ${order.reference}. The Secretariat will confirm your payment '
            'and contact you on ${order.phoneNumber} about delivery.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Done')),
          ],
        ),
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) CustomSnackBar.error(context, message: 'Could not place the order: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
