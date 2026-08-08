import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

/// Field-name prefix for a given cut test, e.g. `c1_moisture`.
///
/// Shared with the wizard so entry and parsing cannot drift apart.
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
    // Always at least one cut test; the report shows it as the 1st Cutting.
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CustomText("Quality Measurements", variant: TextVariant.displaySmall),
          CustomText(
            "Record each cut test separately. The report shows every cut test in "
            "its own column and averages them.",
            variant: TextVariant.bodyMedium,
            color: colorScheme.secondary,
          ),
          Gap(24.h),

          for (int cutting = 1; cutting <= _cuttingCount; cutting++) ...[
            _buildCuttingCard(cutting, colorScheme),
            Gap(20.h),
          ],

          if (_cuttingCount < kMaxCutTests)
            OutlinedButton.icon(
              onPressed: () => setState(() => _cuttingCount++),
              icon: const Icon(Icons.add),
              label: CustomText("Add ${_ordinal(_cuttingCount + 1)}", variant: TextVariant.bodyMedium),
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

  Widget _buildCuttingCard(int cutting, ColorScheme colorScheme) {
    final initial = _initialFor(cutting);
    final isLast = cutting == _cuttingCount;

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
              // Only the last cut test can be removed, so the numbering of the
              // remaining ones never shifts underneath the user.
              if (isLast && cutting > 1)
                IconButton(
                  tooltip: 'Remove ${_ordinal(cutting)}',
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: () => setState(() => _cuttingCount--),
                ),
            ],
          ),
          Gap(12.h),

          CustomTextField(
            name: cutTestField(cutting, 'label'),
            label: "Sample Location (optional)",
            hint: "e.g. Sawla",
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

          Gap(20.h),
          _buildGroupLabel("Fully Damaged Nuts (gm)", colorScheme),
          Gap(12.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'fully_damaged'),
                  label: "Fully Damaged",
                  hint: "g",
                  initialValue: _numText(initial?.fullyDamagedNuts),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'void'),
                  label: "Void Nuts",
                  hint: "g",
                  initialValue: _numText(initial?.voidNuts),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          Gap(16.h),
          CustomTextField(
            name: cutTestField(cutting, 'oil'),
            label: "Oil Nuts",
            hint: "g",
            initialValue: _numText(initial?.oilNuts),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),

          Gap(20.h),
          _buildGroupLabel("Spotted / Partly Sound Nuts (gm)", colorScheme),
          Gap(12.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'spotted'),
                  label: "Spotted",
                  hint: "g",
                  initialValue: _numText(initial?.spottedNuts),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'immature'),
                  label: "Immature",
                  hint: "g",
                  initialValue: _numText(initial?.immatureNuts),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),

          Gap(20.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'good_kernels'),
                  label: "Good Kernels",
                  hint: "g",
                  initialValue: _numText(initial?.goodKernels),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: CustomTextField(
                  name: cutTestField(cutting, 'empty_shells'),
                  label: "Empty Shells",
                  hint: "g",
                  initialValue: _numText(initial?.emptyShells),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),

          Gap(12.h),
          CustomText(
            "Total yield and OUTTURN (KOR) are calculated from these figures.",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupLabel(String text, ColorScheme colorScheme) {
    return CustomText(
      text,
      variant: TextVariant.bodyMedium,
      fontWeight: FontWeight.bold,
      color: colorScheme.secondary,
    );
  }

  /// Blank rather than "0" for unset values, so the fields read as empty.
  String? _numText(num? value) {
    if (value == null || value == 0) return null;
    if (value is int) return value.toString();
    return (value as double).toString();
  }
}
