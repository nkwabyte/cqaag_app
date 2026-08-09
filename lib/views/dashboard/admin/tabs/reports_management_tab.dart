import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';
import 'package:cqaag_app/models/inspection/report_filter.dart';
import 'package:cqaag_app/views/components/report_filter_modal.dart';
import 'package:cqaag_app/services/export/excel_export_service.dart';

class ReportsManagementTab extends ConsumerStatefulWidget {
  const ReportsManagementTab({super.key});

  @override
  ConsumerState<ReportsManagementTab> createState() => _ReportsManagementTabState();
}

class _ReportsManagementTabState extends ConsumerState<ReportsManagementTab> {
  ReportFilterCriteria _filterCriteria = const ReportFilterCriteria();

  List<Inspection> get _filteredInspections {
    final inspectionState = ref.watch(inspectionControllerProvider).value;
    if (inspectionState == null) return [];

    final allInspections = inspectionState.allCompletedInspections;
    return _filterCriteria.apply(allInspections);
  }

  void _showFilterDialog() async {
    final newCriteria = await ReportFilterModal.show(
      context,
      initialCriteria: _filterCriteria,
      onApply: (criteria) {
        setState(() {
          _filterCriteria = criteria;
        });
      },
    );

    if (newCriteria != null && mounted) {
      setState(() {
        _filterCriteria = newCriteria;
      });
    }
  }

  Future<void> _exportToExcel() async {
    final currentUser = ref.read(currentUserProfileProvider).value;
    if (currentUser == null) {
      CustomSnackBar.error(context, message: 'User not authenticated');
      return;
    }

    final inspectionsToExport = _filteredInspections;
    if (inspectionsToExport.isEmpty) {
      CustomSnackBar.warning(context, message: 'No inspection reports available to export.');
      return;
    }

    AppDialogs.showLoadingDialog(context, message: 'Exporting to Excel...');
    try {
      await ExcelExportService.exportInspections(
        inspections: inspectionsToExport,
        currentUser: currentUser,
      );
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
        CustomSnackBar.success(context, message: 'Excel export ready!');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        CustomSnackBar.error(context, message: 'Export failed: ${e.toString()}');
      }
    }
  }

  void _scanQRCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );

    if (result != null && mounted) {
      if (result.startsWith('inspection:')) {
        final inspectionId = result.substring('inspection:'.length);

        final inspectionState = ref.read(inspectionControllerProvider).value;
        if (inspectionState != null) {
          final inspection = inspectionState.allCompletedInspections
              .where((i) => i.id == inspectionId || i.inspectionId == inspectionId)
              .firstOrNull;

          if (inspection != null) {
            context.pushNamed(QualityResultScreen.id, extra: inspection);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report not found')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid QR code')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredInspections = _filteredInspections;
    final currentUser = ref.watch(currentUserProfileProvider).value;

    return Scaffold(
      body: Column(
        children: [
          // Search, Filter & Excel Export Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        name: 'search_reports',
                        label: 'Search Reports',
                        hint: "Search by batch, farmer, location...",
                        prefixIcon: Icons.search,
                        onChanged: (value) {
                          setState(() {
                            _filterCriteria = _filterCriteria.copyWith(searchQuery: value ?? '');
                          });
                        },
                      ),
                    ),
                    Gap(8.w),
                    // Filter Modal Button
                    Stack(
                      children: [
                        InkWell(
                          onTap: _showFilterDialog,
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: _filterCriteria.isNotEmpty
                                  ? colorScheme.primary
                                  : colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.filter_list,
                              color: _filterCriteria.isNotEmpty ? Colors.white : colorScheme.primary,
                            ),
                          ),
                        ),
                        if (_filterCriteria.activeFilterCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                              child: Text(
                                '${_filterCriteria.activeFilterCount}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Gap(8.w),
                    // Export to Excel Button
                    InkWell(
                      onTap: _exportToExcel,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Tooltip(
                          message: currentUser?.isAdmin == true ? 'Export All Data to Excel' : 'Export My Data to Excel',
                          child: Icon(
                            Icons.explicit_outlined,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_filterCriteria.isNotEmpty) ...[
                  Gap(8.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CustomText(
                          'Active Filters (${_filterCriteria.activeFilterCount}):',
                          variant: TextVariant.bodySmall,
                          color: colorScheme.secondary,
                        ),
                        Gap(8.w),
                        InputChip(
                          label: const Text('Clear All'),
                          onPressed: () {
                            setState(() {
                              _filterCriteria = const ReportFilterCriteria();
                            });
                          },
                          deleteIcon: const Icon(Icons.close, size: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Reports List
          Expanded(
            child: filteredInspections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 48.r, color: colorScheme.secondary),
                        Gap(10.h),
                        CustomText(
                          "No reports found matching criteria",
                          variant: TextVariant.bodyMedium,
                          color: colorScheme.secondary,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(12.r),
                    itemCount: filteredInspections.length,
                    separatorBuilder: (context, index) => Gap(12.h),
                    itemBuilder: (context, index) {
                      final inspection = filteredInspections[index];
                      final dateStr = inspection.completedAt != null
                          ? "${inspection.completedAt!.year}-${inspection.completedAt!.month.toString().padLeft(2, '0')}-${inspection.completedAt!.day.toString().padLeft(2, '0')}"
                          : "Unknown Date";

                      return GestureDetector(
                        onTap: () => context.pushNamed(
                          QualityResultScreen.id,
                          extra: inspection,
                        ),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final inspectorAsync = ref.watch(
                              inspectorProfileProvider(inspection.inspectorId),
                            );

                            final inspectorName = inspectorAsync.when(
                              data: (user) => user != null ? "${user.firstName} ${user.lastName}" : inspection.inspectorId,
                              loading: () => "Loading...",
                              error: (error, stack) => inspection.inspectorId,
                            );

                            return InspectionCard(
                              status: inspection.status.name.toUpperCase(),
                              statusColor: inspection.status == InspectionStatus.completed ? Colors.green : Colors.orange,
                              batchId: inspection.batchId ?? "N/A",
                              name: inspectorName,
                              location: inspection.location ?? "Unknown",
                              time: dateStr,
                              weight: inspection.quantity.toString(),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanQRCode,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
