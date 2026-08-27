import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cqaag_app/index.dart';
import 'package:cqaag_app/models/inspection/report_filter.dart';
import 'package:cqaag_app/views/components/report_filter_modal.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  static final String id = 'history_screen';
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  ReportFilterCriteria _filterCriteria = const ReportFilterCriteria();

  Map<String, List<Inspection>> _groupByDistrict(List<Inspection> inspections) {
    final grouped = <String, List<Inspection>>{};
    for (final inspection in inspections) {
      final district = inspection.location ?? 'Unknown District';
      grouped.putIfAbsent(district, () => []).add(inspection);
    }
    return grouped;
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

  Future<void> _exportToExcel(List<Inspection> inspections) async {
    final user = ref.read(currentUserProfileProvider).value;
    if (user == null) {
      CustomSnackBar.error(context, message: 'User not authenticated');
      return;
    }

    if (inspections.isEmpty) {
      CustomSnackBar.warning(context, message: 'No inspection records to export.');
      return;
    }

    AppDialogs.showLoadingDialog(context, message: 'Exporting to Excel...');
    try {
      await ExcelExportService.exportInspections(
        inspections: inspections,
        currentUser: user,
      );
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        CustomSnackBar.success(
          context,
          message: user.isAdmin
              ? 'Exported all inspection records to Excel'
              : 'Exported your inspection records to Excel',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        CustomSnackBar.error(context, message: 'Export failed: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProfileProvider).value;
    final inspectionState = ref.watch(inspectionControllerProvider).value;

    // Scoped Data Access: Admin sees all QCs data, QC only sees own data
    final allReports = inspectionState?.allCompletedInspections ?? [];
    final rawInspections = user?.isAdmin == true
        ? allReports
        : allReports.where((i) => i.inspectorId == user?.id).toList();

    final filteredInspections = _filterCriteria.apply(rawInspections);

    final grouped = _groupByDistrict(filteredInspections);
    final districts = grouped.entries.toList();

    final isApproved = user?.isApproved ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header with data stats
          buildHistoryHeader(
            context,
            user?.isAdmin == true ? "National Inspection Reports" : "My Inspection Reports",
            "${districts.length} districts (${filteredInspections.length} reports)",
            colorScheme,
          ),

          // Unapproved User Warning Banner
          if (user != null && !isApproved)
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
                  Gap(10.w),
                  Expanded(
                    child: Text(
                      'Account Pending Approval. Access to full inspection operations is restricted until verified by an Admin.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Action Toolbar: Filter, Ticket & Export to Excel Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _showFilterDialog,
                  icon: Icon(
                    Icons.filter_list,
                    size: 16,
                    color: _filterCriteria.isNotEmpty ? colorScheme.primary : colorScheme.onSurface,
                  ),
                  label: Text(
                    _filterCriteria.isNotEmpty
                        ? 'Filtered (${_filterCriteria.activeFilterCount})'
                        : 'Filter',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _filterCriteria.isNotEmpty ? colorScheme.primary : null,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  ),
                ),
                if (_filterCriteria.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _filterCriteria = const ReportFilterCriteria()),
                    child: Text('Clear', style: TextStyle(fontSize: 12.sp)),
                  ),
                OutlinedButton.icon(
                  onPressed: () => RaiseTicketModal.show(context),
                  icon: const Icon(Icons.support_agent_outlined, size: 16, color: Colors.red),
                  label: Text('Report Issue / Mistake', style: TextStyle(fontSize: 12.sp, color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: filteredInspections.isEmpty ? null : () => _exportToExcel(filteredInspections),
                  icon: const Icon(Icons.download, size: 16),
                  label: Text(
                    user?.isAdmin == true ? 'Excel Export (All)' : 'Excel Export (My Data)',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  ),
                ),
              ],
            ),
          ),

          if (filteredInspections.isEmpty)
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.history_outlined,
                        size: 64.r,
                        color: colorScheme.secondary.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: 16.h),
                      CustomText(
                        "No completed inspections found",
                        variant: TextVariant.headlineMedium,
                        color: colorScheme.secondary,
                      ),
                    ],
                  ).bounceIn(),
                ),
              ),
            ),

          if (filteredInspections.isNotEmpty)
            Expanded(
              child: SafeArea(
                top: false,
                child: ListView.builder(
                  padding: EdgeInsets.all(24.r),
                  itemCount: districts.length,
                  itemBuilder: (context, index) {
                    final entry = districts[index];
                    final district = entry.key;
                    final districtInspections = entry.value;

                    final totalKg = districtInspections.fold<double>(
                      0.0,
                      (sum, inspection) => sum + inspection.quantity,
                    );

                    final communities = districtInspections.map((i) => i.farmerName ?? 'Unknown').toSet().length;

                    return HistoryCard(
                      title: district,
                      inspectionsCount: "${districtInspections.length}",
                      communitiesCount: "$communities",
                      totalKg: totalKg.toStringAsFixed(1),
                      onTap: () {
                        if (!isApproved) {
                          CustomSnackBar.warning(
                            context,
                            message: 'Your account is pending admin approval before viewing detailed inspection reports.',
                          );
                          return;
                        }
                        context.pushNamed(
                          DistrictDetailScreen.id,
                          extra: {
                            'district': district,
                            'inspections': districtInspections,
                          },
                        );
                      },
                    ).staggeredListItem(index);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
