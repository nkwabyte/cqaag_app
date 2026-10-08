import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';

/// What the analyst supplied as proof the certificate fee was paid.
class ReportFeeInput {
  const ReportFeeInput({this.evidence, this.reference = ''});

  final File? evidence;
  final String reference;

  ReportFeeInput copyWith({File? evidence, String? reference}) {
    return ReportFeeInput(evidence: evidence ?? this.evidence, reference: reference ?? this.reference);
  }
}

/// The certificate fee, paid by Mobile Money before a Moisture Control,
/// Dispatch, Arbitration or Export certificate can be submitted.
///
/// A form field named `report_fee`, so the wizard reads it with the rest of
/// the inspection.
class ReportFeeField extends ConsumerWidget {
  const ReportFeeField({super.key, required this.analysisType});

  static const String fieldName = 'report_fee';

  final String analysisType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(paymentSettingsProvider).value ?? PaymentSettings.defaults;
    final fee = settings.money(AnalysisTypes.reportFeeCedis);

    return FormBuilderField<ReportFeeInput>(
      name: fieldName,
      initialValue: const ReportFeeInput(),
      validator: (value) {
        if (value?.evidence == null) {
          return 'Upload evidence of the $fee certificate fee';
        }
        if ((value?.reference.trim() ?? '').isEmpty) {
          return 'Enter the Mobile Money transaction reference ID';
        }
        return null;
      },
      builder: (field) {
        final value = field.value ?? const ReportFeeInput();
        final evidence = value.evidence;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: field.hasError ? colorScheme.error : colorScheme.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.payments_outlined, color: colorScheme.primary, size: 22.r),
                  Gap(10.w),
                  Expanded(
                    child: CustomText(
                      "Certificate Fee — $fee",
                      variant: TextVariant.bodyLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Gap(6.h),
              CustomText(
                "$analysisType certificates are completed only after the fee is paid. "
                "Send $fee by Mobile Money and upload the confirmation.",
                variant: TextVariant.bodySmall,
                color: colorScheme.secondary,
              ),
              Gap(12.h),
              _detail(context, "Network", settings.network.label),
              _detail(
                context,
                "Number",
                settings.momoNumber,
                trailing: InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: settings.momoNumber));
                    if (context.mounted) CustomSnackBar.success(context, message: 'Number copied');
                  },
                  child: Icon(Icons.copy_outlined, size: 16.r, color: colorScheme.primary),
                ),
              ),
              _detail(context, "Account name", settings.momoAccountName),
              Gap(12.h),
              InkWell(
                onTap: () async {
                  final file = await ImageSourcePicker.pick(context, cameraLabel: 'Take a photo of the receipt');
                  if (file != null) field.didChange(value.copyWith(evidence: file));
                },
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
                  ),
                  child: evidence == null
                      ? Row(
                          children: [
                            Icon(Icons.receipt_long_outlined, color: colorScheme.secondary),
                            Gap(10.w),
                            const Expanded(child: CustomText("Upload payment evidence", variant: TextVariant.bodyMedium)),
                          ],
                        )
                      : Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6.r),
                              child: Image.file(evidence, width: 56.r, height: 56.r, fit: BoxFit.cover),
                            ),
                            Gap(10.w),
                            const Expanded(child: CustomText("Evidence attached — tap to change", variant: TextVariant.bodySmall)),
                          ],
                        ),
                ),
              ),
              Gap(10.h),
              TextFormField(
                initialValue: value.reference,
                onChanged: (text) => field.didChange(value.copyWith(reference: text.trim())),
                decoration: InputDecoration(
                  labelText: "Transaction ID / Mobile Money Reference *",
                  hintText: "e.g. MP260105.1234.B56789",
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
              if (field.hasError) ...[
                Gap(6.h),
                CustomText(field.errorText!, variant: TextVariant.bodySmall, color: colorScheme.error),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _detail(BuildContext context, String label, String value, {Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          SizedBox(
            width: 110.w,
            child: CustomText(label, variant: TextVariant.bodySmall, color: Theme.of(context).colorScheme.secondary),
          ),
          Expanded(child: CustomText(value, variant: TextVariant.bodySmall, fontWeight: FontWeight.bold)),
          ?trailing,
        ],
      ),
    );
  }
}
