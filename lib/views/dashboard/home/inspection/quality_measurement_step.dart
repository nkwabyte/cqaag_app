import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class QualityMetricsStep extends StatefulWidget {
  static final String id = 'quality_metrics_step';
  final Widget? footer;
  const QualityMetricsStep({super.key, this.footer});

  @override
  State<QualityMetricsStep> createState() => _QualityMetricsStepState();
}

class _QualityMetricsStepState extends State<QualityMetricsStep> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CustomText("Quality Measurements", variant: TextVariant.displaySmall),
          CustomText(
            "Enter cashew quality metrics",
            variant: TextVariant.bodyMedium,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Gap(24.h),
          const CustomTextField(
            name: "nut_count",
            label: "Raw Nut Count (per kg)",
            hint: "e.g., 170",
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.inventory_2_outlined,
          ),
          Gap(20.h),
          const CustomTextField(
            name: "moisture",
            label: "Moisture Content (%)",
            hint: "e.g., 8.5",
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.water_drop_outlined,
          ),
          Gap(20.h),
          const CustomTextField(
            name: "kor",
            label: "KOR (lbs)",
            hint: "e.g., 48",
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.balance,
          ),
          Gap(24.h),
          const Divider(),
          Gap(16.h),
          const CustomText(
            "Defect Analysis (grams)",
            variant: TextVariant.headlineSmall,
          ),
          Gap(16.h),
          Row(
            children: <Widget>[
              Expanded(
                child: const CustomTextField(
                  name: "good_kernels",
                  label: "Good Kernels",
                  hint: "g",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: const CustomTextField(
                  name: "spotted_kernels",
                  label: "Spotted",
                  hint: "g",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          Gap(16.h),
          Row(
            children: <Widget>[
              Expanded(
                child: const CustomTextField(
                  name: "immature_kernels",
                  label: "Immature",
                  hint: "g",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: const CustomTextField(
                  name: "oily_kernels",
                  label: "Oily",
                  hint: "g",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          Gap(16.h),
          Row(
            children: <Widget>[
              Expanded(
                child: const CustomTextField(
                  name: "void_kernels",
                  label: "Void / Fungi",
                  hint: "g",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: const CustomTextField(
                  name: "total_defective",
                  label: "Total Defective",
                  hint: "g",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          Gap(16.h),
          const CustomTextField(
            name: "total_spotted",
            label: "Total Spotted",
            hint: "g",
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),

          if (widget.footer != null) ...[
            Gap(40.h),
            widget.footer!,
          ],
        ],
      ),
    );
  }
}
