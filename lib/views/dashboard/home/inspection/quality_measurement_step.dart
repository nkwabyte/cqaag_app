import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class QualityMetricsStep extends StatefulWidget {
  static final String id = 'quality_metrics_step';
  const QualityMetricsStep({super.key});

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
        children: [
          const CustomText("Quality Measurements", variant: TextVariant.displaySmall),
          CustomText(
            "Enter cashew quality metrics",
            variant: TextVariant.bodyMedium,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Gap(24.h),
          const CustomTextField(
            name: "moisture",
            label: "Moisture Content (%)",
            hint: "e.g., 8.5",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.water_drop_outlined,
          ),
          Gap(20.h),
          const CustomTextField(
            name: "nut_count",
            label: "Nut Count (g)",
            hint: "e.g., 185",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.inventory_2_outlined,
          ),
          Gap(20.h),
          const CustomTextField(
            name: "kor",
            label: "KOR (lbs)",
            hint: "e.g., 52",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.balance,
          ),
          Gap(4.h),
          CustomText(
            "Kernel Outturn Ratio in pounds",
            variant: TextVariant.bodySmall,
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
