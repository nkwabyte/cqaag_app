import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class PreviewAndConfirmStep extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final ValueChanged<int> onJumpToStep;
  final Widget footer;

  const PreviewAndConfirmStep({
    super.key,
    required this.formKey,
    required this.onJumpToStep,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final formData = formKey.currentState?.value ?? {};
    final analysisType = formData['analysis_type'] as String? ?? '';
    final truckLabel = analysisType == 'Export' ? 'Truck/Container Number' : 'Truck Number';
    String farmerLabel = 'Supplier / Farmer Name';
    if (analysisType == 'Dispatch') {
      farmerLabel = 'Supplier/Company';
    } else if (analysisType == 'Export') {
      farmerLabel = 'Exporter/Export Company';
    }

    // Photos
    final photos = formData['inspection_photos'] as Map<String, File?>?;
    final rawNutsPhoto = photos?['raw_nuts'];
    final packagingPhoto = photos?['packaging'];
    final storagePhoto = photos?['storage'];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.rate_review_outlined, color: Colors.blue[800], size: 24.r),
                Gap(10.w),
                Expanded(
                  child: Text(
                    'Please review all inspection parameters below. You can tap "Edit" on any section to update details before submitting.',
                    style: TextStyle(fontSize: 12.sp, color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),
          Gap(16.h),

          // 1. Basic Info Section
          _buildPreviewCard(
            context,
            title: '1. Basic Information',
            stepIndex: 0,
            children: [
              _buildRow('Batch ID', formData['batch_id'] as String? ?? 'N/A'),
              _buildRow(farmerLabel, formData['farmer_name'] as String? ?? 'N/A'),
              _buildRow('Analysis Type', analysisType.isEmpty ? 'N/A' : analysisType),
              _buildRow('Quantity (MT)', '${formData['quantity'] ?? '0.0'} MT'),
              _buildRow('Bags', '${formData['quantity_bags'] ?? '0'} Bags'),
              _buildRow(truckLabel, formData['truck_number'] as String? ?? 'N/A'),
              _buildRow('Supplier / Supplying Co.', formData['company'] as String? ?? 'N/A'),
              _buildRow('Buyer Name', formData['buyer_name'] as String? ?? 'N/A'),
              _buildRow('Waybill Number', formData['waybill_number'] as String? ?? 'N/A'),
            ],
          ),
          Gap(16.h),

          // 2. Farm Location Section
          _buildPreviewCard(
            context,
            title: '2. Location & Chapter',
            stepIndex: 1,
            children: [
              _buildRow('Location/District', formData['location'] as String? ?? 'N/A'),
              _buildRow('Exact Location', formData['exact_location'] as String? ?? 'N/A'),
              _buildRow('Town', formData['town'] as String? ?? 'N/A'),
              _buildRow('Chapter', formData['chapter'] as String? ?? 'N/A'),
            ],
          ),
          Gap(16.h),

          // 3. Quality Metrics Summary
          _buildPreviewCard(
            context,
            title: '3. Quality Metrics Summary',
            stepIndex: 2,
            children: [
              _buildRow('Moisture Content', '${formData['c1_moisture'] ?? 'N/A'}%'),
              _buildRow('Nut Count', '${formData['c1_nut_count'] ?? 'N/A'} nuts/kg'),
              _buildRow('Fully Damaged', '${formData['c1_fully_damaged'] ?? '0'}%'),
              _buildRow('Good Kernels', '${formData['c1_good_kernels'] ?? '0'}%'),
              _buildRow('Spotted', '${formData['c1_spotted'] ?? '0'}%'),
              _buildRow('Immature', '${formData['c1_immature'] ?? '0'}%'),
            ],
          ),
          Gap(16.h),

          // 4. Photo Documentation Summary
          _buildPreviewCard(
            context,
            title: '4. Photo Documentation',
            stepIndex: 3,
            children: [
              Row(
                children: [
                  _buildPhotoThumbnail(context, 'Raw Nuts', rawNutsPhoto),
                  Gap(8.w),
                  _buildPhotoThumbnail(context, 'Packaging', packagingPhoto),
                  Gap(8.w),
                  _buildPhotoThumbnail(context, 'Storage', storagePhoto),
                ],
              ),
            ],
          ),
          Gap(24.h),

          footer,
          Gap(20.h),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(
    BuildContext context, {
    required String title,
    required int stepIndex,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                title,
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.bold,
              ),
              OutlinedButton.icon(
                onPressed: () => onJumpToStep(stepIndex),
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Edit', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(label, variant: TextVariant.bodySmall, color: Colors.grey[700]),
          CustomText(value, variant: TextVariant.bodySmall, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail(BuildContext context, String label, File? photo) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 70.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey[200],
              border: Border.all(color: photo != null ? Colors.green : Colors.red),
              image: photo != null ? DecorationImage(image: FileImage(photo), fit: BoxFit.cover) : null,
            ),
            child: photo == null
                ? Center(
                    child: Icon(Icons.broken_image, color: Colors.red[300], size: 24.r),
                  )
                : null,
          ),
          Gap(4.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: photo != null ? Colors.black : Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
