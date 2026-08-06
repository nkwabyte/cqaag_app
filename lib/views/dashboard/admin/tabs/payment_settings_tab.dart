import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:cqaag_app/index.dart';

/// Admin control over the registration fee and the Mobile Money account
/// applicants pay into.
///
/// Writes `settings/payment`, the same document the CQAAG website reads, so a
/// change here takes effect on both platforms.
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

  /// Set once the fields have been seeded, so live updates from Firestore do
  /// not overwrite what the admin is part-way through typing.
  bool _hydrated = false;

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

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: CustomText(
            'Could not load payment settings: $err',
            variant: TextVariant.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (settings) {
        _hydrate(settings);

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                "Payment Settings",
                variant: TextVariant.headlineMedium,
                fontWeight: FontWeight.bold,
              ),
              Gap(8.h),
              CustomText(
                "The registration fee and Mobile Money account applicants pay into. "
                "These values are shared with the CQAAG website.",
                variant: TextVariant.bodySmall,
                color: colorScheme.secondary,
              ),
              Gap(24.h),

              _buildLabel("Registration Fee (GHS)"),
              Gap(8.h),
              TextField(
                controller: _feeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(colorScheme, prefixText: 'GHS  ', hint: '500.00'),
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
              Gap(20.h),

              _buildLabel("Mobile Money Number"),
              Gap(8.h),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(colorScheme, hint: '+233 55 333 0931'),
              ),
              Gap(20.h),

              _buildLabel("Account Name"),
              Gap(8.h),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(colorScheme, hint: 'Amoafo Ebenezer'),
              ),
              Gap(8.h),
              CustomText(
                "Shown to applicants so they can confirm the name before sending.",
                variant: TextVariant.bodySmall,
                color: colorScheme.secondary,
              ),

              Gap(32.h),
              CustomButton(
                text: _isSaving ? "Saving..." : "Save Payment Settings",
                isLoading: _isSaving,
                onPressed: _isSaving ? () {} : _save,
              ),

              if (settings.updatedAt != null) ...[
                Gap(16.h),
                CustomText(
                  "Last updated ${settings.updatedAt.toString().split('.').first}",
                  variant: TextVariant.bodySmall,
                  color: colorScheme.secondary,
                ),
              ],
              Gap(40.h),
            ],
          ),
        );
      },
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
