import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

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

  String? _selectedAnalysisType;

  static const List<String> analysisTypes = [
    'Arrival Upcountry Warehouse',
    'Dispatch',
    'Arrival Port Warehouse',
    'Arbitration',
    'Export',
  ];

  @override
  void initState() {
    super.initState();
    _qcIdController = TextEditingController();
    _batchIdController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initQcAndBatch();
    });
  }

  @override
  void dispose() {
    _qcIdController.dispose();
    _batchIdController.dispose();
    super.dispose();
  }

  Future<void> _initQcAndBatch() async {
    final user = ref.read(currentUserProfileProvider).value;
    final persistentQcCode = user?.effectiveQcCode ?? IdUtils.getPermanentQcId(userId: user?.id);

    try {
      final inspectionService = ref.read(inspectionServiceProvider);
      final count = await inspectionService.getInspectionCount();

      if (mounted) {
        setState(() {
          _inspectionCount = count;
          _qcId = persistentQcCode;
          _batchId = IdUtils.generateBatchId('', count);

          _qcIdController.text = _qcId;
          _batchIdController.text = _batchId;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _qcId = persistentQcCode;
          _batchId = 'BATCH-GH-UNKNOWN-1';

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

    final activeAnalysisType = _selectedAnalysisType ??
        (FormBuilder.of(context)?.fields['analysis_type']?.value as String?);

    final isExport = activeAnalysisType == 'Export';

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomText(
            isExport ? "Export Inspection Details" : "Basic Information",
            variant: TextVariant.displaySmall,
          ),
          CustomText(
            isExport
                ? "Enter comprehensive Export RCN Quality Report parameters"
                : "Enter basic inspection details",
            variant: TextVariant.bodyMedium,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Gap(24.h),
          _buildInfoSummary(context, _qcId, _batchId, inspectorName),
          Gap(24.h),

          // Analysis Type Dropdown (Top selection)
          CustomText(
            "Analysis Type",
            variant: TextVariant.bodyLarge,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          Gap(4.h),
          FormBuilderDropdown<String>(
            name: "analysis_type",
            initialValue: _selectedAnalysisType ?? 'Arrival Upcountry Warehouse',
            decoration: InputDecoration(
              hintText: "Select Analysis Type",
              prefixIcon: Icon(Icons.analytics_outlined, color: colorScheme.secondary),
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
            ),
            items: analysisTypes
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            validator: FormBuilderValidators.required(errorText: "Select the analysis type"),
            onChanged: (val) {
              if (val != _selectedAnalysisType) {
                setState(() {
                  _selectedAnalysisType = val;
                });
              }
            },
          ),
          Gap(20.h),

          // IF EXPORT: Render the complete Export RCN Quality Report form fields
          if (isExport) ...[
            _buildExportSection(colorScheme, defaultLocation),
          ] else ...[
            _buildStandardSection(colorScheme, defaultLocation, activeAnalysisType),
          ],

          Gap(20.h),

          // Q.C ID Field (Persistent, Unique per QC)
          CustomText(
            "QC-CODE (Unique Analyst ID)",
            variant: TextVariant.bodyLarge,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          FormBuilderTextField(
            name: "qc_id",
            controller: _qcIdController,
            readOnly: true, // Permanent per QC, does not change per report
            decoration: InputDecoration(
              hintText: "e.g., CQAAG-QC-001",
              prefixIcon: Icon(Icons.verified_user_outlined, color: Colors.green.shade800),
              suffixIcon: const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          Gap(4.h),
          CustomText(
            "Your unique permanent QC identifier assigned by CQAAG",
            variant: TextVariant.bodySmall,
            color: Colors.grey.shade700,
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
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
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

  Widget _buildStandardSection(ColorScheme colorScheme, String defaultLocation, String? activeAnalysisType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        CustomTextField(
          name: "truck_number",
          label: "Truck Number",
          hint: "e.g., TN 1234 ABC",
          prefixIcon: Icons.local_shipping_outlined,
        ),
        Gap(20.h),
        CustomText(
          "Supplier / Supplying Company",
          variant: TextVariant.bodyLarge,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        FormBuilderTextField(
          name: "company",
          decoration: InputDecoration(
            hintText: "e.g., Ghana Cashew Co.",
            prefixIcon: Icon(Icons.business_outlined, color: colorScheme.secondary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          onChanged: _updateBatchId,
        ),
        Gap(20.h),
        CustomTextField(
          name: "buyer_name",
          label: "Buyer / Company Name",
          hint: "e.g., Global Traders Ltd",
          prefixIcon: Icons.shopping_cart_outlined,
          validator: FormBuilderValidators.required(errorText: "Enter the buyer or company name"),
        ),
        Gap(20.h),
        CustomTextField(
          name: "waybill_number",
          label: "Waybill or B/L N°",
          hint: "e.g., WB-99812",
          prefixIcon: Icons.receipt_long_outlined,
          validator: FormBuilderValidators.required(errorText: "Enter the waybill or B/L number"),
        ),
        Gap(20.h),
        CustomTextField(
          name: "farmer_name",
          label: "Farmer / Supplier Name",
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
          "Enter volume in kg (>=10,000kg requires minimum 2 cut tests)",
          variant: TextVariant.bodySmall,
          color: colorScheme.secondary.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  /// Full EXPORT RCN QUALITY REPORT Interface
  Widget _buildExportSection(ColorScheme colorScheme, String defaultLocation) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.amber.shade50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.darkRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_boat_outlined, color: AppColors.darkRed, size: 22.r),
              Gap(8.w),
              CustomText(
                "EXPORT RCN QUALITY SPECIFICATIONS",
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.darkRed,
              ),
            ],
          ),
          Gap(16.h),

          // B/L No.
          CustomTextField(
            name: "bl_number",
            label: "B/L No.",
            hint: "e.g. BL-GH-2026-9812",
            prefixIcon: Icons.receipt_long_outlined,
            validator: FormBuilderValidators.required(errorText: "Enter Bill of Lading (B/L) number"),
          ),
          Gap(16.h),

          // Shipper Details
          CustomTextField(
            name: "shipper_details",
            label: "SHIPPER DETAILS :",
            hint: "Shipper / Exporter Name, Address & Contact",
            prefixIcon: Icons.business_outlined,
            validator: FormBuilderValidators.required(errorText: "Enter Shipper details"),
          ),
          Gap(16.h),

          // Consignee Details
          CustomTextField(
            name: "consignee_details",
            label: "CONSIGNEE DETAILS :",
            hint: "Consignee Name & Destination Address",
            prefixIcon: Icons.apartment_outlined,
            validator: FormBuilderValidators.required(errorText: "Enter Consignee details"),
          ),
          Gap(16.h),

          // Origin & Destination
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: "origin_country",
                  label: "ORIGIN (COUNTRY) :",
                  hint: "e.g., GHANA",
                  initialValue: "GHANA",
                  prefixIcon: Icons.flag_outlined,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: CustomTextField(
                  name: "destination_country",
                  label: "DESTINATION (COUNTRY) :",
                  hint: "e.g., Vietnam, India",
                  prefixIcon: Icons.public_outlined,
                  validator: FormBuilderValidators.required(errorText: "Enter Destination country"),
                ),
              ),
            ],
          ),
          Gap(16.h),

          // Name and Description of Transport
          CustomTextField(
            name: "transport_description",
            label: "NAME AND DESCRIPTION OF TRANSPORT :",
            hint: "e.g. Vessel: MSC EMMA V.24 / Truck & Trailer",
            prefixIcon: Icons.directions_boat_outlined,
            validator: FormBuilderValidators.required(errorText: "Enter transport description"),
          ),
          Gap(16.h),

          // POL & POD
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: "pol",
                  label: "POL (Port Of Loading) :",
                  hint: "e.g., PORT OF TEMA",
                  initialValue: "PORT OF TEMA",
                  prefixIcon: Icons.anchor_outlined,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: CustomTextField(
                  name: "pod",
                  label: "POD (Port of Destination) :",
                  hint: "e.g., Hai Phong, Tuticorin",
                  prefixIcon: Icons.location_on_outlined,
                  validator: FormBuilderValidators.required(errorText: "Enter Port of Destination"),
                ),
              ),
            ],
          ),
          Gap(16.h),

          // Containers & Sizes
          CustomTextField(
            name: "container_count_and_sizes",
            label: "NUMBER OF CONTAINERS AND SIZES :",
            hint: "e.g. 2 x 40ft HC (MSCU1234567, MSCU7654321)",
            prefixIcon: Icons.inventory_2_outlined,
            validator: FormBuilderValidators.required(errorText: "Enter container count and sizes"),
          ),
          Gap(16.h),

          // Gross & Net Weight
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: "gross_weight",
                  label: "GROSS WEIGHT (KG) :",
                  hint: "e.g. 50500",
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.scale_outlined,
                  validator: FormBuilderValidators.required(errorText: "Enter Gross Weight"),
                ),
              ),
              Gap(12.w),
              Expanded(
                child: CustomTextField(
                  name: "net_weight",
                  label: "NET WEIGHT (KG) :",
                  hint: "e.g. 50000",
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.scale_outlined,
                  validator: FormBuilderValidators.required(errorText: "Enter Net Weight"),
                ),
              ),
            ],
          ),
          Gap(16.h),

          // Packages Description
          CustomTextField(
            name: "package_description",
            label: "NUMBER AND DESCRIPTION OF PACKAGES :",
            hint: "e.g. 625 Jute Bags (80kg net per bag)",
            prefixIcon: Icons.shopping_bag_outlined,
            validator: FormBuilderValidators.required(errorText: "Enter packages description"),
          ),
          Gap(16.h),

          // Place & Date of Sample
          CustomTextField(
            name: "sample_place_and_date",
            label: "PLACE AND DATE OF SAMPLE :",
            hint: "e.g. Tema Port Warehouse - 2026-08-27",
            prefixIcon: Icons.calendar_today_outlined,
          ),
          Gap(16.h),

          // Place & Date of Cutting Test
          CustomTextField(
            name: "cutting_test_place_and_date",
            label: "PLACE AND DATE OF CUTTING TEST :",
            hint: "e.g. CQAAG Quality Lab, Tema - 2026-08-27",
            prefixIcon: Icons.science_outlined,
          ),
          Gap(16.h),

          // Authorization
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.green.shade700),
            ),
            child: FormBuilderCheckbox(
              name: "is_authorized",
              initialValue: true,
              title: CustomText(
                "AUTHORIZED EXPORT QUALITY INSPECTION",
                variant: TextVariant.bodyMedium,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
              subtitle: CustomText(
                "*NOTE: Export has to be authorised and requires cutting pictures.*",
                variant: TextVariant.bodySmall,
                color: Colors.red.shade900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
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
          _summaryRow("QC-CODE", qcId),
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
