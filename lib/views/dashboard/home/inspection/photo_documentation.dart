import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class PhotoDocumentationStep extends StatefulWidget {
  static final String id = 'photo_documentation_step';
  const PhotoDocumentationStep({super.key});

  @override
  State<PhotoDocumentationStep> createState() => _PhotoDocumentationStepState();
}

class _PhotoDocumentationStepState extends State<PhotoDocumentationStep> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText("Photo Documentation", variant: TextVariant.displaySmall),
          CustomText(
            "Capture evidence photos (3 required)",
            variant: TextVariant.bodyMedium,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Gap(24.h),
          _buildPhotoPicker(context, "Raw Cashew Nuts Sample"),
          Gap(20.h),
          _buildPhotoPicker(context, "Packaging & Sacks"),
          Gap(20.h),
          _buildPhotoPicker(context, "Storage Conditions"),
        ],
      ),
    );
  }

  Widget _buildPhotoPicker(BuildContext context, String label) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                child: const Icon(Icons.inventory_2_outlined),
              ),
              Gap(12.w),
              CustomText(label, variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
            ],
          ),
          Gap(16.h),
          Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, size: 30.r, color: Theme.of(context).colorScheme.primary),
                Gap(8.h),
                const CustomText("Tap to Capture", variant: TextVariant.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
