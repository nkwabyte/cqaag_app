import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class BasicInfoStep extends StatefulWidget {
  static final String id = 'basic_info_step';
  const BasicInfoStep({super.key});

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText("Basic Information", variant: TextVariant.displaySmall),
          CustomText(
            "Enter basic inspection details",
            variant: TextVariant.bodyMedium,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Gap(24.h),
          _buildInfoSummary(context),
          Gap(24.h),
          const CustomTextField(
            name: "truck_number",
            label: "Truck Number",
            hint: "e.g., TN 1234 ABC",
            prefixIcon: Icons.local_shipping_outlined,
          ),
          Gap(20.h),
          const CustomTextField(
            name: "company",
            label: "Company",
            hint: "e.g., Ghana Cashew Co.",
            prefixIcon: Icons.business_outlined,
          ),
          Gap(20.h),
          const CustomTextField(
            name: "quantity",
            label: "Quantity (kg)",
            hint: "e.g., 1000",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.scale_outlined,
          ),
          Gap(4.h),
          CustomText(
            "Total weight in kilograms",
            variant: TextVariant.bodySmall,
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSummary(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _summaryRow("Inspection ID", "new"),
          const Divider(),
          _summaryRow("Farmer", "Kwame Mensah"),
          const Divider(),
          _summaryRow("Location", "Wenchi District, Bono Region"),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String val) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(label, variant: TextVariant.bodySmall),
          CustomText(val, variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
