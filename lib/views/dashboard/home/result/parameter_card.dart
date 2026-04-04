import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class ParameterCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String status;
  final bool isExcellent;

  const ParameterCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    this.isExcellent = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(label, variant: TextVariant.bodySmall, color: colorScheme.secondary),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(value, variant: TextVariant.displaySmall, fontWeight: FontWeight.bold),
              Gap(4.w),
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: CustomText(unit, variant: TextVariant.bodySmall, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.check, color: Colors.green, size: 14.r),
              Gap(4.w),
              CustomText(status, variant: TextVariant.bodySmall, color: Colors.green, fontWeight: FontWeight.w600),
            ],
          ),
        ],
      ),
    );
  }
}
