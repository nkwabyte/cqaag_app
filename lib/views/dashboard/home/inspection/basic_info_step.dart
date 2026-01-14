import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class BasicInfoStep extends ConsumerStatefulWidget {
  static final String id = 'basic_info_step';
  final String? inspectionId;
  final Widget? footer;

  const BasicInfoStep({
    super.key,
    this.inspectionId,
    this.footer,
  });

  @override
  ConsumerState<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends ConsumerState<BasicInfoStep> {
  int _inspectionCount = 0;
  String _qcId = '';
  String _batchId = '';

  // Controllers for the editable fields
  late TextEditingController _qcIdController;
  late TextEditingController _batchIdController;

  @override
  void initState() {
    super.initState();
    _qcIdController = TextEditingController();
    _batchIdController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInspectionCount();
    });
  }

  @override
  void dispose() {
    _qcIdController.dispose();
    _batchIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchInspectionCount() async {
    try {
      final inspectionService = ref.read(inspectionServiceProvider);
      final count = await inspectionService.getInspectionCount();

      if (mounted) {
        setState(() {
          _inspectionCount = count;
          _qcId = IdUtils.generateQcId(count);
          _batchId = IdUtils.generateBatchId('', count); // Will update when company is entered

          // Update controllers
          _qcIdController.text = _qcId;
          _batchIdController.text = _batchId;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _qcId = 'INSP-1';
          _batchId = 'BATCH-GH-UNKNOWN-1';

          // Update controllers
          _qcIdController.text = _qcId;
          _batchIdController.text = _batchId;
        });
      }
    }
  }

  void _updateBatchId(String? company) {
    if (company != null && company.isNotEmpty) {
      setState(() {
        _batchId = IdUtils.generateBatchId(company, _inspectionCount);
        // Update the controller to reflect the change in the UI
        _batchIdController.text = _batchId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProfileProvider).value;
    final inspectorName = user != null ? '${user.firstName} ${user.lastName}' : 'Unknown Inspector';
    final defaultLocation = user != null ? '${user.district}, ${user.region}' : '';
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomText("Basic Information", variant: TextVariant.displaySmall),
          CustomText(
            "Enter basic inspection details",
            variant: TextVariant.bodyMedium,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Gap(24.h),
          _buildInfoSummary(context, _qcId, _batchId, inspectorName),
          Gap(24.h),
          // Location Fields
          CustomTextField(
            name: "location",
            label: "Region / District",
            hint: "e.g., Wenchi District, Bono Region",
            initialValue: defaultLocation,
            prefixIcon: Icons.location_on_outlined,
          ),
          Gap(20.h),
          Row(
            children: <Widget>[
              Expanded(
                child: const CustomTextField(
                  name: "town",
                  label: "Town",
                  hint: "e.g., Techiman",
                  prefixIcon: Icons.location_city_outlined,
                ),
              ),
              Gap(16.w),
              Expanded(
                child: const CustomTextField(
                  name: "chapter",
                  label: "Chapter / Zone",
                  hint: "e.g., Techiman-Bole",
                  prefixIcon: Icons.map_outlined,
                ),
              ),
            ],
          ),
          Gap(20.h),
          const CustomTextField(
            name: "truck_number",
            label: "Truck Number",
            hint: "e.g., TN 1234 ABC",
            prefixIcon: Icons.local_shipping_outlined,
          ),
          Gap(20.h),
          CustomText(
            "Company / Buying Agency",
            variant: TextVariant.bodyLarge,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          FormBuilderTextField(
            name: "company",
            decoration: InputDecoration(
              hintText: "e.g., Ghana Cashew Co.",
              prefixIcon: Icon(Icons.business_outlined, color: colorScheme.secondary),
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.secondary.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: colorScheme.secondary.withValues(alpha: 0.3),
                  width: 1.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colorScheme.secondary, width: 1.5.w),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.redAccent, width: 1.w),
              ),
            ),
            onChanged: _updateBatchId,
          ),
          Gap(20.h),
          const CustomTextField(
            name: "farmer_name",
            label: "Supplier / Farmer Name",
            hint: "e.g., Ama Darko",
            prefixIcon: Icons.person_outline,
          ),
          Gap(20.h),
          Row(
            children: <Widget>[
              Expanded(
                child: const CustomTextField(
                  name: "quantity",
                  label: "Quantity (kg)",
                  hint: "e.g., 4000",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.scale_outlined,
                ),
              ),
              Gap(16.w),
              Expanded(
                child: const CustomTextField(
                  name: "quantity_bags",
                  label: "Quantity (Bags)",
                  hint: "e.g., 50",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.shopping_bag_outlined,
                ),
              ),
            ],
          ),
          Gap(4.h),
          CustomText(
            "Enter either quantity in kg or bags",
            variant: TextVariant.bodySmall,
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
          ),
          Gap(20.h),
          // Q.C ID Field
          CustomText(
            "Q.C ID No",
            variant: TextVariant.bodyLarge,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          FormBuilderTextField(
            name: "qc_id",
            controller: _qcIdController,
            decoration: InputDecoration(
              hintText: "e.g., INSP-124",
              prefixIcon: Icon(Icons.qr_code_outlined, color: colorScheme.secondary),
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.secondary.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: colorScheme.secondary.withValues(alpha: 0.3),
                  width: 1.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colorScheme.secondary, width: 1.5.w),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.redAccent, width: 1.w),
              ),
            ),
            onChanged: (value) {
              if (value != null && value.isNotEmpty) {
                setState(() {
                  _qcId = value;
                });
              }
            },
          ),
          Gap(20.h),
          // Batch ID Field
          CustomText(
            "Batch / Lot No",
            variant: TextVariant.bodyLarge,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          FormBuilderTextField(
            name: "batch_id",
            controller: _batchIdController,
            decoration: InputDecoration(
              hintText: "e.g., BATCH-GH-OLAM-124",
              prefixIcon: Icon(
                Icons.inventory_outlined,
                color: colorScheme.secondary,
              ),
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.secondary.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: colorScheme.secondary.withValues(alpha: 0.3),
                  width: 1.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colorScheme.secondary, width: 1.5.w),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.redAccent, width: 1.w),
              ),
            ),
            onChanged: (value) {
              if (value != null && value.isNotEmpty) {
                setState(() {
                  _batchId = value;
                });
              }
            },
          ),
          if (widget.footer != null) ...[
            Gap(40.h),
            widget.footer!,
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSummary(BuildContext context, String qcId, String batchId, String inspector) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: <Widget>[
          _summaryRow("Q.C ID No", qcId),
          const Divider(),
          _summaryRow("Batch / Lot No", batchId),
          const Divider(),
          _summaryRow("Inspector", inspector),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String val) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CustomText(
            label,
            variant: TextVariant.bodySmall,
            fontWeight: FontWeight.w700,
          ),
          Expanded(
            child: CustomText(
              val,
              variant: TextVariant.bodySmall,
              fontWeight: FontWeight.normal,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
