import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cqaag_app/models/inspection/inspection.dart';
import 'package:cqaag_app/models/inspection/report_filter.dart';
import 'package:cqaag_app/views/widgets/custom_button.dart';
import 'package:cqaag_app/views/widgets/custom_text.dart';

class ReportFilterModal extends StatefulWidget {
  final ReportFilterCriteria initialCriteria;
  final ValueChanged<ReportFilterCriteria> onApply;

  const ReportFilterModal({
    super.key,
    required this.initialCriteria,
    required this.onApply,
  });

  static Future<ReportFilterCriteria?> show(
    BuildContext context, {
    required ReportFilterCriteria initialCriteria,
    required ValueChanged<ReportFilterCriteria> onApply,
  }) {
    return showDialog<ReportFilterCriteria>(
      context: context,
      builder: (context) => ReportFilterModal(
        initialCriteria: initialCriteria,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ReportFilterModal> createState() => _ReportFilterModalState();
}

class _ReportFilterModalState extends State<ReportFilterModal> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late double? _minKOR;
  late double? _maxKOR;
  late double? _minMoisture;
  late double? _maxMoisture;
  late int? _minNutCount;
  late int? _maxNutCount;
  late double? _minQuantity;
  late double? _maxQuantity;
  late double? _maxDefectRate;
  late InspectionStatus? _status;
  late TextEditingController _analysisTypeController;
  late TextEditingController _locationController;
  late TextEditingController _chapterController;
  late TextEditingController _inspectorIdController;

  @override
  void initState() {
    super.initState();
    final c = widget.initialCriteria;
    _startDate = c.startDate;
    _endDate = c.endDate;
    _minKOR = c.minKOR;
    _maxKOR = c.maxKOR;
    _minMoisture = c.minMoisture;
    _maxMoisture = c.maxMoisture;
    _minNutCount = c.minNutCount;
    _maxNutCount = c.maxNutCount;
    _minQuantity = c.minQuantity;
    _maxQuantity = c.maxQuantity;
    _maxDefectRate = c.maxDefectRate;
    _status = c.status;

    _analysisTypeController = TextEditingController(text: c.analysisType ?? '');
    _locationController = TextEditingController(text: c.location ?? '');
    _chapterController = TextEditingController(text: c.chapter ?? '');
    _inspectorIdController = TextEditingController(text: c.inspectorId ?? '');
  }

  @override
  void dispose() {
    _analysisTypeController.dispose();
    _locationController.dispose();
    _chapterController.dispose();
    _inspectorIdController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _minKOR = null;
      _maxKOR = null;
      _minMoisture = null;
      _maxMoisture = null;
      _minNutCount = null;
      _maxNutCount = null;
      _minQuantity = null;
      _maxQuantity = null;
      _maxDefectRate = null;
      _status = null;
      _analysisTypeController.clear();
      _locationController.clear();
      _chapterController.clear();
      _inspectorIdController.clear();
    });
  }

  void _applyFilters() {
    final criteria = widget.initialCriteria.copyWith(
      startDate: _startDate,
      endDate: _endDate,
      minKOR: _minKOR,
      maxKOR: _maxKOR,
      minMoisture: _minMoisture,
      maxMoisture: _maxMoisture,
      minNutCount: _minNutCount,
      maxNutCount: _maxNutCount,
      minQuantity: _minQuantity,
      maxQuantity: _maxQuantity,
      maxDefectRate: _maxDefectRate,
      status: _status,
      analysisType: _analysisTypeController.text.trim().isEmpty ? null : _analysisTypeController.text.trim(),
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      chapter: _chapterController.text.trim().isEmpty ? null : _chapterController.text.trim(),
      inspectorId: _inspectorIdController.text.trim().isEmpty ? null : _inspectorIdController.text.trim(),
    );

    widget.onApply(criteria);
    Navigator.of(context).pop(criteria);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, color: colorScheme.primary, size: 24.r),
                    Gap(8.w),
                    const CustomText(
                      'Filter Reports',
                      variant: TextVariant.headlineMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Status Filter Chips
                    _buildSectionHeader('Report Status'),
                    Gap(6.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        _buildStatusChip('All', null),
                        _buildStatusChip('Completed', InspectionStatus.completed),
                        _buildStatusChip('Pending', InspectionStatus.pending),
                        _buildStatusChip('In Progress', InspectionStatus.inProgress),
                        _buildStatusChip('Rejected', InspectionStatus.rejected),
                        _buildStatusChip('Pending Sync', InspectionStatus.pendingSync),
                      ],
                    ),
                    Gap(16.h),

                    // 2. Date Range
                    _buildSectionHeader('Date Range'),
                    Gap(6.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) setState(() => _startDate = date);
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Start Date'),
                          ),
                        ),
                        Gap(8.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) setState(() => _endDate = date);
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'End Date'),
                          ),
                        ),
                      ],
                    ),
                    Gap(16.h),

                    // 3. KOR Range
                    _buildSectionHeader('KOR Range (lbs/bag)'),
                    Gap(6.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberInput(
                            label: 'Min KOR',
                            initialValue: _minKOR?.toString(),
                            onChanged: (val) => _minKOR = double.tryParse(val),
                          ),
                        ),
                        Gap(8.w),
                        Expanded(
                          child: _buildNumberInput(
                            label: 'Max KOR',
                            initialValue: _maxKOR?.toString(),
                            onChanged: (val) => _maxKOR = double.tryParse(val),
                          ),
                        ),
                      ],
                    ),
                    Gap(16.h),

                    // 4. Moisture Range
                    _buildSectionHeader('Moisture Content (%)'),
                    Gap(6.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberInput(
                            label: 'Min Moisture %',
                            initialValue: _minMoisture?.toString(),
                            onChanged: (val) => _minMoisture = double.tryParse(val),
                          ),
                        ),
                        Gap(8.w),
                        Expanded(
                          child: _buildNumberInput(
                            label: 'Max Moisture %',
                            initialValue: _maxMoisture?.toString(),
                            onChanged: (val) => _maxMoisture = double.tryParse(val),
                          ),
                        ),
                      ],
                    ),
                    Gap(16.h),

                    // 5. Nut Count Range
                    _buildSectionHeader('Nut Count (Nuts/kg)'),
                    Gap(6.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberInput(
                            label: 'Min Nut Count',
                            initialValue: _minNutCount?.toString(),
                            onChanged: (val) => _minNutCount = int.tryParse(val),
                          ),
                        ),
                        Gap(8.w),
                        Expanded(
                          child: _buildNumberInput(
                            label: 'Max Nut Count',
                            initialValue: _maxNutCount?.toString(),
                            onChanged: (val) => _maxNutCount = int.tryParse(val),
                          ),
                        ),
                      ],
                    ),
                    Gap(16.h),

                    // 6. Quantity / Weight Range
                    _buildSectionHeader('Quantity (MT)'),
                    Gap(6.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberInput(
                            label: 'Min Quantity',
                            initialValue: _minQuantity?.toString(),
                            onChanged: (val) => _minQuantity = double.tryParse(val),
                          ),
                        ),
                        Gap(8.w),
                        Expanded(
                          child: _buildNumberInput(
                            label: 'Max Quantity',
                            initialValue: _maxQuantity?.toString(),
                            onChanged: (val) => _maxQuantity = double.tryParse(val),
                          ),
                        ),
                      ],
                    ),
                    Gap(16.h),

                    // 7. Max Defect %
                    _buildSectionHeader('Max Defective Rate (%)'),
                    Gap(6.h),
                    _buildNumberInput(
                      label: 'Max Defect % (e.g. 15.0)',
                      initialValue: _maxDefectRate?.toString(),
                      onChanged: (val) => _maxDefectRate = double.tryParse(val),
                    ),
                    Gap(16.h),

                    // 8. Text Fields Section (Location, Chapter, Inspector, Analysis Type)
                    _buildSectionHeader('Location & Inspector Variables'),
                    Gap(6.h),
                    _buildTextInput(
                      controller: _locationController,
                      label: 'Location / District',
                      hint: 'e.g. Wenchi District',
                    ),
                    Gap(8.h),
                    _buildTextInput(
                      controller: _chapterController,
                      label: 'Chapter',
                      hint: 'e.g. Bono Chapter / Tema Port',
                    ),
                    Gap(8.h),
                    _buildTextInput(
                      controller: _inspectorIdController,
                      label: 'QC Inspector ID / Name',
                      hint: 'e.g. INS-001',
                    ),
                    Gap(8.h),
                    _buildTextInput(
                      controller: _analysisTypeController,
                      label: 'Analysis Type',
                      hint: 'e.g. RCN / Kernel / Outturn',
                    ),
                  ],
                ),
              ),
            ),

            const Divider(),
            Gap(8.h),

            // Actions Bottom Row
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Clear All',
                    variant: ButtonVariant.outlined,
                    onPressed: _clearAll,
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: CustomButton(
                    text: 'Apply Filters',
                    onPressed: _applyFilters,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return CustomText(
      title,
      variant: TextVariant.bodyMedium,
      fontWeight: FontWeight.bold,
    );
  }

  Widget _buildStatusChip(String label, InspectionStatus? status) {
    final isSelected = _status == status;
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: colorScheme.primary,
      onSelected: (_) {
        setState(() {
          _status = status;
        });
      },
    );
  }

  Widget _buildNumberInput({
    required String label,
    String? initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      ),
    );
  }
}
