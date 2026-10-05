import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart' as uuid_pkg;

import 'package:cqaag_app/index.dart';

/// Paying for an approved membership: see the fee broken down, choose which
/// optional quality cutting kit items to take, then pay.
///
/// Applications are reviewed before anything is paid, so this screen always
/// works on an existing, approved application (`existing_application_id`).
/// Once the payment is submitted, a generated sign-in password is emailed to
/// the address on the application.
///
/// The fee is assembled here rather than fixed earlier in the flow, because
/// what an applicant owes is not one number: it is the Registration Fee, plus
/// the Annual Dues for their category, plus whatever optional kit items they
/// decide to take. The itemised quote is snapshotted onto the application, so a
/// later change to the schedule never rewrites what somebody was asked to pay.
class MembershipPaymentScreen extends ConsumerStatefulWidget {
  static const String id = 'membership_payment_screen';
  final Map<String, dynamic> applicationData;

  const MembershipPaymentScreen({super.key, required this.applicationData});

  @override
  ConsumerState<MembershipPaymentScreen> createState() => _MembershipPaymentScreenState();
}

class _MembershipPaymentScreenState extends ConsumerState<MembershipPaymentScreen> {
  PaymentMethod? _selectedMethod = PaymentMethod.momo;
  File? _evidenceFile;
  final TextEditingController _referenceController = TextEditingController();
  bool _isSubmitting = false;

  /// Keys of the optional kit items the applicant has taken.
  final Set<String> _selectedOptionalKeys = <String>{};

  /// Sizes entered for optional items that need one, keyed by item key.
  final Map<String, TextEditingController> _sizeControllers = {};

  @override
  void dispose() {
    _referenceController.dispose();
    for (final controller in _sizeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? get _applicationId => widget.applicationData['existing_application_id'] as String?;

  /// The application being paid for, loaded so the fee is quoted for its own
  /// category rather than assumed.
  MembershipApplication? _application;
  bool _isLoadingApplication = true;

  MembershipCategory get _category => _application?.membershipCategory ?? MembershipCategory.full;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    final id = _applicationId;
    final application = id == null ? null : await ref.read(membershipServiceProvider).getApplicationById(id);
    if (!mounted) return;
    setState(() {
      _application = application;
      _isLoadingApplication = false;
      // Keep whatever kit items they picked before, if they come back.
      for (final item in application?.paymentOptionalItems ?? const <SelectedFeeItem>[]) {
        _selectedOptionalKeys.add(item.key);
        if (item.size != null) {
          _sizeControllers.putIfAbsent(item.key, () => TextEditingController(text: item.size));
        }
      }
    });
  }

  /// Builds the applicant's quote from what they have selected.
  FeeQuote _quote(PaymentSettings settings) {
    final feeCategory = FeeCategory.fromMembership(_category);
    final selected = settings.schedule
        .optionalItemsFor(feeCategory)
        .where((item) => _selectedOptionalKeys.contains(item.key))
        .map(
          (item) => SelectedFeeItem(
            key: item.key,
            label: item.label,
            amount: item.amountFor(feeCategory)!,
            size: item.requiresSize ? _sizeControllers[item.key]?.text.trim() : null,
          ),
        )
        .toList();

    return settings.schedule.quote(feeCategory, selectedOptionalItems: selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settingsAsync = ref.watch(paymentSettingsProvider);

    if (_isLoadingApplication) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Membership Payment')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: const CustomText(
              'This membership application could not be found. Open your Profile and try again.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Defaults keep the screen usable even if settings/payment cannot be read.
    final settings = settingsAsync.value ?? PaymentSettings.defaults;
    final quote = _quote(settings);
    final isExempt = quote.isExempt;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(colorScheme, settings.money(quote.total), isExempt),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeeBreakdown(colorScheme, settings, quote),
                  Gap(24.h),

                  if (!isExempt) ...[
                    _buildOptionalItems(colorScheme, settings),
                    Gap(24.h),
                  ],

                  const CustomText(
                    "Choose how to pay",
                    variant: TextVariant.headlineMedium,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(8.h),
                  CustomText(
                    isExempt
                        ? "Honorary Members pay no fees. Continue to have your sign-in password emailed."
                        : "Pay by Mobile Money and upload the evidence. Once it is submitted, a sign-in password is emailed to your application address.",
                    variant: TextVariant.bodyMedium,
                    color: colorScheme.secondary,
                  ),
                  Gap(24.h),

                  if (!isExempt) ...[
                    _buildMethodCard(
                      colorScheme: colorScheme,
                      method: PaymentMethod.momo,
                      icon: Icons.smartphone_outlined,
                      title: "Pay via Mobile Money",
                      description: "Send the fee to the CQAAG MoMo account and upload your payment evidence.",
                      enabled: true,
                    ),
                    Gap(12.h),
                    _buildMethodCard(
                      colorScheme: colorScheme,
                      method: PaymentMethod.paystack,
                      icon: Icons.credit_card_outlined,
                      title: "Pay with Paystack",
                      description: "Card and instant mobile money. Not available yet — please use Mobile Money.",
                      enabled: false,
                    ),
                    if (_selectedMethod == PaymentMethod.momo) ...[
                      Gap(24.h),
                      _buildMomoInstructions(colorScheme, settings, quote),
                      Gap(24.h),
                      _buildEvidenceUpload(colorScheme),
                      Gap(24.h),
                      _buildReferenceField(colorScheme),
                    ],
                  ],

                  Gap(32.h),
                  CustomButton(
                    text: _submitLabel(isExempt),
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? () {} : () => _handleSubmit(settings),
                  ),
                  Gap(40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _submitLabel(bool isExempt) {
    if (_isSubmitting) return "Submitting...";
    if (isExempt) return "Email My Sign-in Password";
    return "Submit Payment";
  }

  Widget _buildHeader(ColorScheme colorScheme, String formattedTotal, bool isExempt) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50.r),
          bottomRight: Radius.circular(50.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.pop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 20.r),
                Gap(8.w),
                const CustomText("Back", color: Colors.white),
              ],
            ),
          ),
          Gap(24.h),
          const CustomText("Membership Payment", variant: TextVariant.displaySmall, color: Colors.white),
          Gap(8.h),
          CustomText(
            isExempt ? "No fees payable" : "Amount due: $formattedTotal",
            variant: TextVariant.bodyLarge,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ],
      ),
    );
  }

  /// The applicant's fee, line by line, so the total is never an unexplained
  /// number. Mirrors the Board's fee schedule.
  Widget _buildFeeBreakdown(ColorScheme colorScheme, PaymentSettings settings, FeeQuote quote) {
    final feeCategory = quote.category;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: colorScheme.primary, size: 22.r),
              Gap(10.w),
              Expanded(
                child: CustomText(
                  "Fee Breakdown",
                  variant: TextVariant.bodyLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: CustomText(
                  feeCategory.label,
                  variant: TextVariant.bodySmall,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Gap(14.h),

          if (quote.isExempt)
            CustomText(
              "Honorary Members pay no registration fee, no annual dues, and no kit charges "
              "(Constitution Art. 2, Categories).",
              variant: TextVariant.bodySmall,
              color: colorScheme.secondary,
            )
          else ...[
            // Registration Fee, expanded into its components.
            _buildFeeRow("Registration Fee", settings.money(quote.registrationFee), isBold: true),
            Gap(6.h),
            ...quote.registrationComponents.map(
              (item) => Padding(
                padding: EdgeInsets.only(left: 12.w, bottom: 4.h),
                child: _buildFeeRow(item.label, settings.money(item.amount), isSubtle: true),
              ),
            ),
            Gap(10.h),
            const Divider(height: 1),
            Gap(10.h),

            _buildFeeRow("Annual Dues", settings.money(quote.annualDues), isBold: true),
            Gap(4.h),
            CustomText(
              "Inclusive of the TCDA recommendation letter, where applicable.",
              variant: TextVariant.bodySmall,
              color: colorScheme.secondary,
            ),

            if (quote.optionalItems.isNotEmpty) ...[
              Gap(10.h),
              const Divider(height: 1),
              Gap(10.h),
              _buildFeeRow("Optional items", settings.money(quote.optionalTotal), isBold: true),
              Gap(6.h),
              ...quote.optionalItems.map(
                (item) => Padding(
                  padding: EdgeInsets.only(left: 12.w, bottom: 4.h),
                  child: _buildFeeRow(item.displayLabel, settings.money(item.amount), isSubtle: true),
                ),
              ),
            ],

            Gap(12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: _buildFeeRow("Total payable", settings.money(quote.total), isBold: true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String amount, {bool isBold = false, bool isSubtle = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSubtle ? colorScheme.secondary : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomText(
            label,
            variant: isSubtle ? TextVariant.bodySmall : TextVariant.bodyMedium,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Gap(12.w),
        CustomText(
          amount,
          variant: isSubtle ? TextVariant.bodySmall : TextVariant.bodyMedium,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ],
    );
  }

  /// Quality cutting kit items the applicant may take or decline. Nothing here
  /// is charged unless it is ticked.
  Widget _buildOptionalItems(ColorScheme colorScheme, PaymentSettings settings) {
    final feeCategory = FeeCategory.fromMembership(_category);
    final available = settings.schedule.optionalItemsFor(feeCategory);
    final unpriced = settings.schedule.unpricedOptionalItemsFor(feeCategory);

    if (available.isEmpty && unpriced.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checkroom_outlined, color: colorScheme.primary, size: 22.r),
              Gap(10.w),
              const Expanded(
                child: CustomText("Quality Cutting Kits (Optional)", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Gap(6.h),
          CustomText(
            "Tick only what you want. Declining these does not affect your membership.",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
          Gap(12.h),

          if (available.isEmpty)
            CustomText(
              "No kit items are currently priced for your category.",
              variant: TextVariant.bodySmall,
              color: colorScheme.secondary,
            ),

          ...available.map((item) => _buildOptionalItemTile(item, feeCategory, settings, colorScheme)),

          if (unpriced.isNotEmpty) ...[
            Gap(10.h),
            const Divider(height: 1),
            Gap(10.h),
            CustomText(
              "Awaiting Board pricing: ${unpriced.map((e) => e.label).join(', ')}. "
              "These will become available once the Board approves their cost.",
              variant: TextVariant.bodySmall,
              color: colorScheme.secondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionalItemTile(
    FeeLineItem item,
    FeeCategory feeCategory,
    PaymentSettings settings,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedOptionalKeys.contains(item.key);
    final amount = item.amountFor(feeCategory)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: isSelected,
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _selectedOptionalKeys.add(item.key);
                if (item.requiresSize) {
                  _sizeControllers.putIfAbsent(item.key, () => TextEditingController());
                }
              } else {
                _selectedOptionalKeys.remove(item.key);
              }
            });
          },
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          activeColor: colorScheme.primary,
          title: CustomText(item.label, variant: TextVariant.bodyMedium),
          secondary: CustomText(
            settings.money(amount),
            variant: TextVariant.bodyMedium,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Items such as the safety boot are only useful if we know the size.
        if (isSelected && item.requiresSize)
          Padding(
            padding: EdgeInsets.only(left: 40.w, bottom: 10.h),
            child: TextField(
              controller: _sizeControllers[item.key],
              // The size shows in the breakdown line, so reflect it as typed.
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: "${item.label} size",
                hintText: "e.g. 42",
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.3)),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMethodCard({
    required ColorScheme colorScheme,
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String description,
    required bool enabled,
  }) {
    final selected = _selectedMethod == method;

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: InkWell(
        onTap: enabled ? () => setState(() => _selectedMethod = method) : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary.withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.secondary.withValues(alpha: 0.3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colorScheme.primary, size: 28.r),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: CustomText(title, variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
                        ),
                        if (!enabled) ...[
                          Gap(8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(99.r),
                            ),
                            child: const CustomText("Coming soon", variant: TextVariant.bodySmall),
                          ),
                        ],
                      ],
                    ),
                    Gap(4.h),
                    CustomText(description, variant: TextVariant.bodySmall, color: colorScheme.secondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMomoInstructions(ColorScheme colorScheme, PaymentSettings settings, FeeQuote quote) {
    final formattedTotal = settings.money(quote.total);

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
          CustomText(
            "Send $formattedTotal to",
            variant: TextVariant.bodyLarge,
            fontWeight: FontWeight.bold,
          ),
          Gap(12.h),
          _buildDetailRow("Network", settings.network.label),
          Gap(8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText("Number", variant: TextVariant.bodyMedium, color: colorScheme.secondary),
              Row(
                children: [
                  CustomText(settings.momoNumber, variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
                  Gap(4.w),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: settings.momoNumber));
                      if (mounted) {
                        CustomSnackBar.success(context, message: 'Number copied');
                      }
                    },
                    child: Icon(Icons.copy_outlined, size: 18.r, color: colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
          Gap(8.h),
          _buildDetailRow("Account name", settings.momoAccountName),
          Gap(16.h),
          const Divider(),
          Gap(8.h),
          CustomText(
            "1. Send the exact amount from your Mobile Money wallet.\n"
            "2. Use your full name as the reference.\n"
            "3. Screenshot the confirmation message.\n"
            "4. Upload it below for verification.",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
          Gap(16.h),
          // Instant MTN MoMo USSD Prompt button
          CustomButton(
            text: "Request MTN MoMo Prompt",
            backgroundColor: AppColors.primaryGreen,
            textColor: Colors.white,
            leadingIcon: const Icon(Icons.touch_app_outlined, color: Colors.white),
            onPressed: () => _handleMtnMomoPush(settings, quote),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(label, variant: TextVariant.bodyMedium, color: Theme.of(context).colorScheme.secondary),
        Flexible(
          child: CustomText(value, variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEvidenceUpload(ColorScheme colorScheme) {
    final file = _evidenceFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomText("Payment evidence", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
            CustomText("(Required)", variant: TextVariant.bodySmall, color: colorScheme.secondary),
          ],
        ),
        Gap(8.h),
        InkWell(
          onTap: _pickEvidence,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: file != null ? colorScheme.primary : colorScheme.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: file == null
                ? Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 36.r, color: colorScheme.secondary),
                      Gap(8.h),
                      CustomText(
                        "Take a photo or upload your payment screenshot",
                        variant: TextVariant.bodySmall,
                        color: colorScheme.secondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(file, height: 160.h, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Gap(8.h),
                      const CustomText("Tap to change", variant: TextVariant.bodySmall),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceField(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText("Transaction ID (optional)", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
        Gap(8.h),
        TextField(
          controller: _referenceController,
          decoration: InputDecoration(
            hintText: "e.g. MP250804.1523.A12345",
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.3)),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
        Gap(4.h),
        CustomText(
          "Speeds up verification, but you can leave it blank.",
          variant: TextVariant.bodySmall,
          color: colorScheme.secondary,
        ),
      ],
    );
  }

  Future<void> _pickEvidence() async {
    try {
      final file = await ImageSourcePicker.pick(
        context,
        cameraLabel: 'Take a photo of the receipt',
      );
      if (file != null) {
        setState(() => _evidenceFile = file);
      }
    } catch (e) {
      if (mounted) CustomSnackBar.error(context, message: 'Error picking evidence: $e');
    }
  }

  Future<void> _handleMtnMomoPush(PaymentSettings settings, FeeQuote quote) async {
    final phone = _application?.phoneNumberPrimary ?? '';
    if (phone.isEmpty) {
      CustomSnackBar.error(context, message: 'Please provide a valid phone number for MTN MoMo.');
      return;
    }

    setState(() => _isSubmitting = true);
    AppDialogs.showLoadingDialog(context, message: 'Sending MTN MoMo prompt to $phone...');

    try {
      final momoService = ref.read(mtnMomoServiceProvider);
      final refId = const uuid_pkg.Uuid().v4();

      final result = await momoService.requestToPay(
        phoneNumber: phone,
        // Charge exactly what the breakdown shows, optional items included.
        amount: quote.total,
        currency: settings.currency,
        referenceId: refId,
        payerMessage: 'CQAAG Membership Fee',
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        if (result.success) {
          _referenceController.text = refId;
          CustomSnackBar.success(
            context,
            message: result.message ?? 'Payment prompt sent! Please authorize on your phone.',
            title: 'MTN MoMo Prompt Sent',
          );
        } else {
          CustomSnackBar.warning(
            context,
            message: result.message ?? 'Could not initiate automatic prompt. Please make manual transfer and upload receipt.',
            title: 'Manual Transfer Required',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        CustomSnackBar.error(context, message: 'MTN MoMo Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleSubmit(PaymentSettings settings) async {
    final application = _application!;
    final evidence = _evidenceFile;
    final quote = _quote(settings);

    if (!quote.isExempt && evidence == null) {
      CustomSnackBar.error(context, message: 'Please upload evidence of your Mobile Money payment.');
      return;
    }

    // A size-bearing item without a size cannot be fulfilled, so ask before
    // taking the money rather than chasing the applicant afterwards.
    final missingSize = _firstItemMissingSize(settings);
    if (missingSize != null) {
      CustomSnackBar.error(context, message: 'Please enter a size for ${missingSize.label}.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (!quote.isExempt) {
        final evidenceUrl = await ref.read(cloudinaryServiceProvider).uploadPaymentEvidence(evidence!);
        if (evidenceUrl == null) {
          throw Exception('Could not upload your payment evidence. Please try again.');
        }

        await ref.read(membershipServiceProvider).submitPaymentEvidence(
          applicationId: application.id,
          evidenceUrl: evidenceUrl,
          reference: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
          settings: settings,
          quote: quote,
        );
      }

      // With payment submitted, the website emails a generated sign-in
      // password to the application address.
      final credentials = await ref.read(memberCredentialsServiceProvider).requestForApplicant(application.id);
      if (!mounted) return;

      if (credentials.isDone) {
        CustomSnackBar.success(
          context,
          title: quote.isExempt ? 'Password emailed' : 'Payment submitted',
          message: 'A sign-in password has been emailed to ${application.emailAddress}. You can change it in your Profile after signing in.',
        );
      } else {
        CustomSnackBar.warning(
          context,
          title: quote.isExempt ? 'Not sent yet' : 'Payment submitted',
          message: credentials.message ?? 'The sign-in password email could not be sent yet. You can retry from your Profile.',
        );
      }
      context.goNamed(DashboardScreen.id);
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(
        context,
        message: 'Failed to submit payment: ${e.toString().replaceFirst('Exception: ', '')}',
        title: 'Submission Failed',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// The first selected item that needs a size but has not been given one.
  FeeLineItem? _firstItemMissingSize(PaymentSettings settings) {
    final feeCategory = FeeCategory.fromMembership(_category);
    for (final item in settings.schedule.optionalItemsFor(feeCategory)) {
      if (!item.requiresSize || !_selectedOptionalKeys.contains(item.key)) continue;
      if ((_sizeControllers[item.key]?.text.trim() ?? '').isEmpty) return item;
    }
    return null;
  }
}
