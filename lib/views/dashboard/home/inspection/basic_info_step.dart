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
  late TextEditingController _sellerLicenceController;
  late TextEditingController _buyerLicenceController;

  String? _selectedAnalysisType;

  // TCDA party verification states
  TcdaParty? _sellerTcdaParty;
  TcdaParty? _buyerTcdaParty;
  bool _isBuyerForeignConsignee = false;

  // Warehouse selection and proximity states
  List<Facility> _facilities = [];
  Facility? _selectedFacility;
  Facility? get selectedFacility => _selectedFacility;
  FacilityProximityResult? _facilityProximityResult;
  bool _isCheckingProximity = false;

  static const List<String> analysisTypes = AnalysisTypes.all;

  @override
  void initState() {
    super.initState();
    _qcIdController = TextEditingController();
    _batchIdController = TextEditingController();
    _sellerLicenceController = TextEditingController();
    _buyerLicenceController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initQcAndBatch();
      _loadFacilities();
    });
  }

  @override
  void dispose() {
    _qcIdController.dispose();
    _batchIdController.dispose();
    _sellerLicenceController.dispose();
    _buyerLicenceController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    try {
      final facService = ref.read(facilityServiceProvider);
      final facilities = await facService.getFacilities();
      if (mounted) {
        setState(() {
          _facilities = facilities;
        });
      }
    } catch (_) {}
  }

  Future<void> _checkSellerLicence(String licenceNo) async {
    if (licenceNo.trim().isEmpty) {
      setState(() => _sellerTcdaParty = null);
      return;
    }
    final tcdaService = ref.read(tcdaLicenceServiceProvider);
    final party = await tcdaService.checkLicence(licenceNo);
    if (!mounted || party == null) return;
    setState(() => _sellerTcdaParty = party);

    if (party.state == TcdaLicenceState.blocked || party.state == TcdaLicenceState.expired) {
      _showBlockedPartyDialog(context, party, 'Seller / Supplier');
    }
  }

  Future<void> _checkBuyerLicence(String licenceNo) async {
    if (_isBuyerForeignConsignee || licenceNo.trim().isEmpty) {
      setState(() => _buyerTcdaParty = null);
      return;
    }
    final tcdaService = ref.read(tcdaLicenceServiceProvider);
    final party = await tcdaService.checkLicence(licenceNo);
    if (!mounted || party == null) return;
    setState(() => _buyerTcdaParty = party);

    if (party.state == TcdaLicenceState.blocked || party.state == TcdaLicenceState.expired) {
      _showBlockedPartyDialog(context, party, 'Buyer / Off-taker');
    }
  }

  Future<void> _onFacilitySelected(Facility? facility) async {
    setState(() {
      _selectedFacility = facility;
      _facilityProximityResult = null;
      _isCheckingProximity = facility != null;
    });

    if (facility == null) return;

    try {
      final locService = ref.read(locationServiceProvider);
      final pos = await locService.getCurrentPosition();
      final facService = ref.read(facilityServiceProvider);
      final result = await facService.checkProximityToFacility(
        facility.id,
        pos.latitude,
        pos.longitude,
      );
      if (mounted) {
        setState(() {
          _facilityProximityResult = result;
          _isCheckingProximity = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingProximity = false);
      }
    }
  }

  void _showBlockedPartyDialog(BuildContext context, TcdaParty party, String roleLabel) {
    final isBlocked = party.state == TcdaLicenceState.blocked;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        titlePadding: EdgeInsets.all(16.r),
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: isBlocked ? Colors.red.shade900 : Colors.orange.shade900,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              const Icon(Icons.block, color: Colors.white, size: 24),
              Gap(8.w),
              Expanded(
                child: Text(
                  isBlocked ? "BLOCKED BY TCDA" : "TCDA LICENCE EXPIRED",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Action Required for $roleLabel",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Gap(8.h),
            Text(
              "Entity: ${party.name}\n"
              "Licence: ${party.tcdaLicenceNumber}\n"
              "Status: ${party.state.displayName.toUpperCase()}\n\n"
              "By TCDA regulations (Rule R4), transactions involving this entity cannot be verified or certified until the status is resolved or the suspension is lifted by the CQAAG Secretariat.",
              style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Acknowledge & Reselect Party"),
          ),
        ],
      ),
    );
  }

  Widget _buildTcdaBadge(TcdaParty? party, {bool isExempt = false}) {
    if (isExempt) {
      return Container(
        margin: EdgeInsets.only(top: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public, color: Colors.blue.shade800, size: 14),
            Gap(6.w),
            Text(
              "FOREIGN CONSIGNEE (TCDA EXEMPT)",
              style: TextStyle(color: Colors.blue.shade900, fontSize: 11.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (party == null) return const SizedBox.shrink();

    Color bgColor = Colors.grey.shade100;
    Color fgColor = Colors.grey.shade800;
    IconData icon = Icons.help_outline;

    switch (party.state) {
      case TcdaLicenceState.verified:
        bgColor = Colors.green.shade50;
        fgColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case TcdaLicenceState.expiresSoon:
        bgColor = Colors.amber.shade50;
        fgColor = Colors.amber.shade900;
        icon = Icons.warning_amber;
        break;
      case TcdaLicenceState.expired:
        bgColor = Colors.red.shade50;
        fgColor = Colors.red.shade800;
        icon = Icons.error;
        break;
      case TcdaLicenceState.blocked:
        bgColor = Colors.red.shade100;
        fgColor = Colors.red.shade900;
        icon = Icons.block;
        break;
      case TcdaLicenceState.check:
        bgColor = Colors.blue.shade50;
        fgColor = Colors.blue.shade800;
        icon = Icons.info;
        break;
      case TcdaLicenceState.unverified:
        bgColor = Colors.grey.shade100;
        fgColor = Colors.grey.shade800;
        icon = Icons.help_outline;
        break;
    }

    return Container(
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: fgColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fgColor, size: 14),
          Gap(6.w),
          Text(
            "TCDA: ${party.state.displayName.toUpperCase()} (${party.name})",
            style: TextStyle(color: fgColor, fontSize: 11.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProximityBadge() {
    if (_isCheckingProximity) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Row(
          children: [
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            Gap(8.w),
            Text("Verifying GPS perimeter at warehouse gate...", style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
          ],
        ),
      );
    }

    if (_facilityProximityResult == null) return const SizedBox.shrink();

    final isWithin = _facilityProximityResult!.isWithin300m;
    final dist = _facilityProximityResult!.distanceMeters.toStringAsFixed(0);

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isWithin ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: isWithin ? Colors.green.shade300 : Colors.amber.shade600),
      ),
      child: Row(
        children: [
          Icon(isWithin ? Icons.check_circle : Icons.warning_amber,
              color: isWithin ? Colors.green.shade800 : Colors.amber.shade900, size: 16),
          Gap(8.w),
          Expanded(
            child: Text(
              isWithin
                  ? "Within Warehouse Perimeter (${dist}m from gate)"
                  : "GPS distance is > 300m (${dist}m away). Check-in flagged for audit.",
              style: TextStyle(
                color: isWithin ? Colors.green.shade900 : Colors.amber.shade900,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
          _batchId = IdUtils.formatLotNumber(sequenceNumber: count + 1);

          _qcIdController.text = _qcId;
          _batchIdController.text = _batchId;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _qcId = persistentQcCode;
          _batchId = IdUtils.formatLotNumber(sequenceNumber: 1);

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
                ? "Enter comprehensive Export RCN Quality Certificate parameters"
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

          // IF EXPORT: Render the complete Export RCN Quality Certificate form fields
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
              hintText: "e.g., CQAAG-L-261010-0001",
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
        // Warehouse / Facility Selection (Spec Section 27, Figures 15 & 16)
        CustomText(
          "Warehouse / Inspection Facility",
          variant: TextVariant.bodyLarge,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        Gap(4.h),
        FormBuilderDropdown<String>(
          name: "facility_id",
          decoration: InputDecoration(
            hintText: "Select Registered Warehouse / Weighbridge",
            prefixIcon: Icon(Icons.warehouse_outlined, color: colorScheme.secondary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          items: [
            const DropdownMenuItem(
              value: "unregistered",
              child: Text("Unregistered Facility / Farmgate"),
            ),
            ..._facilities.map(
              (f) => DropdownMenuItem(
                value: f.id,
                child: Text("${f.name} (${f.facilityType.displayName}) - ${f.district}, ${f.region}"),
              ),
            ),
          ],
          onChanged: (val) {
            if (val == null || val == "unregistered") {
              _onFacilitySelected(null);
            } else {
              final fac = _facilities.firstWhere((element) => element.id == val, orElse: () => _facilities.first);
              _onFacilitySelected(fac);
            }
          },
        ),
        _buildProximityBadge(),
        Gap(20.h),

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

        // Supplier / Seller Info with TCDA Licence (Rule R4, Section 23 & 26)
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
        Gap(8.h),
        FormBuilderTextField(
          name: "seller_tcda_licence",
          controller: _sellerLicenceController,
          decoration: InputDecoration(
            hintText: "Supplier TCDA Licence N° (e.g., TCDA/BUY/2026/089)",
            prefixIcon: Icon(Icons.verified_outlined, color: Colors.green.shade800),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              tooltip: "Verify TCDA Licence",
              onPressed: () => _checkSellerLicence(_sellerLicenceController.text),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          onChanged: (val) {
            if (val != null && val.length >= 6) _checkSellerLicence(val);
          },
        ),
        _buildTcdaBadge(_sellerTcdaParty),
        Gap(20.h),

        // Buyer Info with TCDA Licence
        CustomTextField(
          name: "buyer_name",
          label: "Buyer / Company Name",
          hint: "e.g., Global Traders Ltd",
          prefixIcon: Icons.shopping_cart_outlined,
          validator: FormBuilderValidators.required(errorText: "Enter the buyer or company name"),
        ),
        Gap(8.h),
        FormBuilderTextField(
          name: "buyer_tcda_licence",
          controller: _buyerLicenceController,
          decoration: InputDecoration(
            hintText: "Buyer TCDA Licence N° (or check Foreign Consignee)",
            prefixIcon: Icon(Icons.verified_outlined, color: Colors.green.shade800),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              tooltip: "Verify TCDA Licence",
              onPressed: () => _checkBuyerLicence(_buyerLicenceController.text),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          onChanged: (val) {
            if (val != null && val.length >= 6) _checkBuyerLicence(val);
          },
        ),
        _buildTcdaBadge(_buyerTcdaParty, isExempt: _isBuyerForeignConsignee),
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

  /// Full EXPORT RCN QUALITY CERTIFICATE Interface
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

          // Export Warehouse / Port Terminal Facility Selection (Figures 15 & 16)
          CustomText(
            "Port / Export Warehouse Facility",
            variant: TextVariant.bodyMedium,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          Gap(4.h),
          FormBuilderDropdown<String>(
            name: "export_facility_id",
            decoration: InputDecoration(
              hintText: "Select Port Terminal / Export Warehouse",
              prefixIcon: Icon(Icons.warehouse_outlined, color: AppColors.darkRed),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            items: [
              const DropdownMenuItem(
                value: "unregistered",
                child: Text("Unregistered Facility / Off-dock"),
              ),
              ..._facilities.map(
                (f) => DropdownMenuItem(
                  value: f.id,
                  child: Text("${f.name} (${f.facilityType.displayName}) - ${f.district}, ${f.region}"),
                ),
              ),
            ],
            onChanged: (val) {
              if (val == null || val == "unregistered") {
                _onFacilitySelected(null);
              } else {
                final fac = _facilities.firstWhere((element) => element.id == val, orElse: () => _facilities.first);
                _onFacilitySelected(fac);
              }
            },
          ),
          _buildProximityBadge(),
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

          // Shipper Details & TCDA Exporter Licence
          CustomTextField(
            name: "shipper_details",
            label: "SHIPPER DETAILS :",
            hint: "Shipper / Exporter Name, Address & Contact",
            prefixIcon: Icons.business_outlined,
            validator: FormBuilderValidators.required(errorText: "Enter Shipper details"),
          ),
          Gap(6.h),
          FormBuilderTextField(
            name: "shipper_tcda_licence",
            decoration: InputDecoration(
              hintText: "Shipper TCDA Exporter Licence N° (e.g., TCDA/EXP/2026/012)",
              prefixIcon: Icon(Icons.verified_outlined, color: Colors.green.shade800),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onChanged: (val) {
              if (val != null && val.length >= 6) _checkSellerLicence(val);
            },
          ),
          _buildTcdaBadge(_sellerTcdaParty),
          Gap(16.h),

          // Consignee Details & Foreign Exemption
          CustomTextField(
            name: "consignee_details",
            label: "CONSIGNEE DETAILS :",
            hint: "Consignee Name & Destination Address",
            prefixIcon: Icons.apartment_outlined,
            validator: FormBuilderValidators.required(errorText: "Enter Consignee details"),
          ),
          Gap(4.h),
          Row(
            children: [
              Checkbox(
                value: _isBuyerForeignConsignee,
                onChanged: (val) {
                  setState(() {
                    _isBuyerForeignConsignee = val ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  "Foreign Consignee (Exempt from TCDA licence outside Ghana)",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800),
                ),
              ),
            ],
          ),
          _buildTcdaBadge(null, isExempt: _isBuyerForeignConsignee),
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
