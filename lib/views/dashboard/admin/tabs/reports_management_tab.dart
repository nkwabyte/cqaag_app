import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';
import 'package:cqaag_app/models/inspection/report_filter.dart';
import 'package:cqaag_app/views/components/report_filter_modal.dart';

class ReportsManagementTab extends ConsumerStatefulWidget {
  const ReportsManagementTab({super.key});

  @override
  ConsumerState<ReportsManagementTab> createState() => _ReportsManagementTabState();
}

class _ReportsManagementTabState extends ConsumerState<ReportsManagementTab> {
  ReportFilterCriteria _filterCriteria = const ReportFilterCriteria();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      CustomSnackBar.warning(context, message: 'No quality certificates available to export.');
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
              const SnackBar(content: Text('Certificate not found')),
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
          // Centered Search, Filter & Excel Export Bar
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Center-aligned Search Bar
                Container(
                  height: 44.h,
                  constraints: BoxConstraints(maxWidth: 520.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _filterCriteria = _filterCriteria.copyWith(searchQuery: value);
                      });
                    },
                    style: TextStyle(fontSize: 13.sp),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Search by batch, farmer, location...",
                      hintStyle: TextStyle(fontSize: 12.sp, color: Colors.black38),
                      prefixIcon: Icon(Icons.search, size: 20.r, color: AppColors.primaryGreen),
                      suffixIcon: (_filterCriteria.searchQuery?.isNotEmpty == true)
                          ? IconButton(
                              icon: Icon(Icons.cancel, size: 18.r, color: Colors.black38),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _filterCriteria = _filterCriteria.copyWith(searchQuery: '');
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                  ),
                ),
                Gap(10.h),

                // 2. Center-aligned Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Filter Modal Button
                    OutlinedButton.icon(
                      onPressed: _showFilterDialog,
                      icon: Icon(
                        Icons.tune_rounded,
                        size: 16.r,
                        color: _filterCriteria.isNotEmpty ? AppColors.primaryGreen : Colors.black87,
                      ),
                      label: Text(
                        _filterCriteria.isNotEmpty
                            ? 'Filter (${_filterCriteria.activeFilterCount})'
                            : 'Filter Options',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _filterCriteria.isNotEmpty ? AppColors.primaryGreen : Colors.black87,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _filterCriteria.isNotEmpty
                            ? AppColors.mintLight.withValues(alpha: 0.7)
                            : Colors.white,
                        side: BorderSide(
                          color: _filterCriteria.isNotEmpty
                              ? AppColors.tcdaAccentGreen
                              : Colors.black.withValues(alpha: 0.15),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                    Gap(10.w),

                    // Export to Excel Button
                    ElevatedButton.icon(
                      onPressed: filteredInspections.isEmpty ? null : _exportToExcel,
                      icon: Icon(Icons.table_chart_outlined, size: 16.r),
                      label: Text(
                        currentUser?.isAdmin == true ? 'Export (All)' : 'Export Excel',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade200,
                        disabledForegroundColor: Colors.black38,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),

                    if (_filterCriteria.isNotEmpty) ...[
                      Gap(8.w),
                      TextButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _filterCriteria = const ReportFilterCriteria();
                          });
                        },
                        icon: Icon(Icons.close, size: 14.r, color: Colors.red.shade700),
                        label: Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (_filterCriteria.isNotEmpty) ...[
                  Gap(8.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Active Filters (${_filterCriteria.activeFilterCount})',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(8.w),
                        InputChip(
                          label: const Text('Clear All'),
                          onPressed: () {
                            _searchController.clear();
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
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 76.r,
                            height: 76.r,
                            decoration: BoxDecoration(
                              color: AppColors.mintLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.tcdaAccentGreen.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _filterCriteria.isNotEmpty
                                    ? Icons.search_off_rounded
                                    : Icons.assignment_outlined,
                                size: 38.r,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          Gap(16.h),
                          CustomText(
                            _filterCriteria.isNotEmpty
                                ? "No certificates match your search"
                                : "No certificates found",
                            variant: TextVariant.bodyLarge,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkRed,
                          ),
                          Gap(6.h),
                          Text(
                            _filterCriteria.isNotEmpty
                                ? "Try adjusting keywords or clearing active filters."
                                : "Completed inspection certificates will appear here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                          ),
                          if (_filterCriteria.isNotEmpty) ...[
                            Gap(14.h),
                            ElevatedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _filterCriteria = const ReportFilterCriteria();
                                });
                              },
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Reset Search & Filters'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                              ),
                            ),
                          ],
                        ],
                      ),
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
