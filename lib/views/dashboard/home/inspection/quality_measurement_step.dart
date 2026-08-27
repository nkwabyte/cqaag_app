import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

/// Field-name prefix for a given cut test, e.g. `c1_moisture`.
String cutTestField(int cutting, String name) => 'c${cutting}_$name';

/// Maximum cut tests the CQAAG protocol calls for.
const int kMaxCutTests = 3;

class QualityMetricsStep extends StatefulWidget {
  static final String id = 'quality_metrics_step';
  final Widget? footer;

  /// Cut tests to restore when resuming an existing inspection.
  final List<CutTest> initialCutTests;

  const QualityMetricsStep({
    super.key,
    this.footer,
    this.initialCutTests = const <CutTest>[],
  });

  @override
  State<QualityMetricsStep> createState() => _QualityMetricsStepState();
}

class _QualityMetricsStepState extends State<QualityMetricsStep> {
  late int _cuttingCount;

  @override
  void initState() {
    super.initState();
    _cuttingCount = widget.initialCutTests.isEmpty ? 1 : widget.initialCutTests.length.clamp(1, kMaxCutTests);
  }

  CutTest? _initialFor(int cutting) {
    final index = cutting - 1;
    if (index < 0 || index >= widget.initialCutTests.length) return null;
    return widget.initialCutTests[index];
  }

  String _ordinal(int cutting) => switch (cutting) {
    1 => '1st Cutting',
    2 => '2nd Cutting',
    3 => '3rd Cutting',
    _ => 'Cutting $cutting',
  };

  double _getVolume(BuildContext context) {
    final form = FormBuilder.of(context);
    if (form == null) return 0.0;

    double parse(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    final qty = parse(form.fields['quantity']?.value);
    final gross = parse(form.fields['gross_weight']?.value);
    final net = parse(form.fields['net_weight']?.value);

    return [qty, gross, net].reduce((max, e) => e > max ? e : max);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final volume = _getVolume(context);

    final isSmallVolume = volume > 0 && volume <= 10000;
    final isLargeVolume = volume >= 10000;

    // Enforce small volume rule: <= 10,000kg only 1 cutting test
    final effectiveCuttingCount = isSmallVolume ? 1 : (_cuttingCount < 2 && isLargeVolume ? 2 : _cuttingCount);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CustomText("Quality Measurements", variant: TextVariant.displaySmall),
          CustomText(
            "Record each cut test separately. The report displays each cutting and computes the official average.",
            variant: TextVariant.bodyMedium,
            color: colorScheme.secondary,
          ),
          Gap(16.h),

          // Protocol Weight Rule Banner
          if (isSmallVolume)
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade800, size: 20.r),
                  Gap(10.w),
                  Expanded(
                    child: CustomText(
                      "Volume <= 10,000 kg (${volume.toStringAsFixed(0)} kg): CQAAG protocol mandates exactly one (1) cut test.",
                      variant: TextVariant.bodySmall,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else if (isLargeVolume)
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.amber.shade600),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 20.r),
                  Gap(10.w),
                  Expanded(
                    child: CustomText(
                      "Volume >= 10,000 kg (${volume.toStringAsFixed(0)} kg): Minimum two (2) cut tests mandatory before processing.",
                      variant: TextVariant.bodySmall,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Gap(20.h),

          for (int cutting = 1; cutting <= effectiveCuttingCount; cutting++) ...[
            _buildCuttingCard(cutting, colorScheme, effectiveCuttingCount, isLargeVolume),
            Gap(20.h),
          ],

          // Only allow adding 2nd/3rd cutting if volume is NOT <= 10,000kg
          if (!isSmallVolume && effectiveCuttingCount < kMaxCutTests)
            OutlinedButton.icon(
              onPressed: () => setState(() => _cuttingCount = effectiveCuttingCount + 1),
              icon: const Icon(Icons.add),
              label: CustomText("Add ${_ordinal(effectiveCuttingCount + 1)}", variant: TextVariant.bodyMedium),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                side: BorderSide(color: colorScheme.primary),
              ),
            ),

          if (widget.footer != null) ...[
            Gap(40.h),
            widget.footer!,
          ],
        ],
      ),
    );
  }

  Widget _buildCuttingCard(int cutting, ColorScheme colorScheme, int totalCuts, bool isLargeVolume) {
    final initial = _initialFor(cutting);
    final isLast = cutting == totalCuts;

    // Can only remove if cutting > 2 when volume >= 10,000kg
    final canRemove = isLast && cutting > (isLargeVolume ? 2 : 1);

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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: CustomText(
                  _ordinal(cutting),
                  variant: TextVariant.bodyMedium,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              if (canRemove)
                IconButton(
                  tooltip: 'Remove ${_ordinal(cutting)}',
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: () => setState(() => _cuttingCount = totalCuts - 1),
                ),
            ],
          ),
          Gap(12.h),

          CustomTextField(
            name: cutTestField(cutting, 'label'),
            label: "Sample Location (optional)",
            hint: "e.g. Sawla / Lot A",
            initialValue: initial?.label,
            prefixIcon: Icons.place_outlined,
          ),
          Gap(16.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'nut_count'),
                  label: "Nut Count (per kg)",
                  hint: "e.g. 170",
                  initialValue: _numText(initial?.nutCount),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'moisture'),
                  label: "Moisture (%)",
                  hint: "e.g. 8.5",
                  initialValue: _numText(initial?.moistureContent),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          Gap(16.h),

          CustomText(
            "Defect Breakdown (in grams)",
            variant: TextVariant.bodyLarge,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
          Gap(12.h),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'good_kernels'),
                  label: "Good Kernels (g)",
                  hint: "e.g. 230",
                  initialValue: _numText(initial?.goodKernels),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'spotted'),
                  label: "Spotted (g)",
                  hint: "e.g. 15",
                  initialValue: _numText(initial?.spottedNuts),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          Gap(16.h),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'immature'),
                  label: "Immature (g)",
                  hint: "e.g. 8",
                  initialValue: _numText(initial?.immatureNuts),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'void'),
                  label: "Void Nuts (g)",
                  hint: "e.g. 5",
                  initialValue: _numText(initial?.voidNuts),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          Gap(16.h),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'oil'),
                  label: "Oily Nuts (g)",
                  hint: "e.g. 3",
                  initialValue: _numText(initial?.oilNuts),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'fully_damaged'),
                  label: "Fully Damaged (g)",
                  hint: "e.g. 12",
                  initialValue: _numText(initial?.fullyDamagedNuts),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          Gap(16.h),

          CustomTextField(
            name: cutTestField(cutting, 'empty_shells'),
            label: "Empty Shells (g)",
            hint: "e.g. 720",
            initialValue: _numText(initial?.emptyShells),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  String? _numText(num? value) => value != null && value > 0 ? value.toString() : null;
}
