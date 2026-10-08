import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cqaag_app/index.dart';
import 'package:cqaag_app/models/inspection/report_filter.dart';
import 'package:cqaag_app/views/components/report_filter_modal.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  static const String id = 'history_screen';
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  ReportFilterCriteria _filterCriteria = const ReportFilterCriteria();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<Inspection>> _groupByDistrict(List<Inspection> inspections) {
    final grouped = <String, List<Inspection>>{};
    for (final inspection in inspections) {
      final district = inspection.location?.trim().isNotEmpty == true
          ? inspection.location!.trim()
          : (inspection.chapter?.trim().isNotEmpty == true ? inspection.chapter!.trim() : 'Unspecified District');
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

  void _clearAllFilters() {
    setState(() {
      _filterCriteria = const ReportFilterCriteria();
      _searchController.clear();
      _searchQuery = '';
    });
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

  List<Inspection> _applySearch(List<Inspection> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final query = _searchQuery.trim().toLowerCase();

    return list.where((i) {
      final district = (i.location ?? '').toLowerCase();
      final town = (i.town ?? '').toLowerCase();
      final farmer = (i.farmerName ?? '').toLowerCase();
      final batch = (i.batchId ?? '').toLowerCase();
      final insId = (i.inspectionId ?? '').toLowerCase();
      final truck = (i.truckNumber ?? '').toLowerCase();
      final buyer = (i.buyerName ?? '').toLowerCase();

      return district.contains(query) ||
          town.contains(query) ||
          farmer.contains(query) ||
          batch.contains(query) ||
          insId.contains(query) ||
          truck.contains(query) ||
          buyer.contains(query);
    }).toList();
  }

  String _formatTotalWeight(double kg) {
    if (kg >= 1000) {
      final mt = kg / 1000;
      return '${mt.toStringAsFixed(1)} MT';
    }
    return '${kg.toStringAsFixed(0)} KG';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProfileProvider).value;
    final inspectionState = ref.watch(inspectionControllerProvider).value;

    // Scoped Data Access: Admin sees all QCs data, QC only sees own data
    final allReports = inspectionState?.allCompletedInspections ?? [];
    final rawInspections = user?.isAdmin == true
        ? allReports
        : allReports.where((i) => i.inspectorId == user?.id).toList();

    final filteredByCriteria = _filterCriteria.apply(rawInspections);
    final filteredInspections = _applySearch(filteredByCriteria);

    final grouped = _groupByDistrict(filteredInspections);
    final districts = grouped.entries.toList();
    final isApproved = user?.isApproved ?? false;

    // KPI Metrics
    final totalCertificates = filteredInspections.length;
    final totalDistricts = districts.length;
    final totalKg = filteredInspections.fold<double>(
      0.0,
      (sum, inspection) => sum + inspection.quantity,
    );
    final totalWeightFormatted = _formatTotalWeight(totalKg);

    final isFiltered = _filterCriteria.isNotEmpty || _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(inspectionControllerProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Sleek Compact Header with Slim Metrics Strip (scrolls with content)
            SliverToBoxAdapter(
              child: _buildCompactHeader(
                context: context,
                totalCertificates: totalCertificates,
                totalDistricts: totalDistricts,
                totalWeight: totalWeightFormatted,
              ),
            ),

            // 2. Unapproved User Warning Banner (if any)
            if (user != null && !isApproved)
              SliverToBoxAdapter(
                child: _buildApprovalWarningBanner(),
              ),

            // 3. Search and Action Toolbar
            SliverToBoxAdapter(
              child: _buildSearchAndToolbar(
                context: context,
                user: user,
                filteredInspections: filteredInspections,
                isFiltered: isFiltered,
              ),
            ),

            // 4. Active Filters Chips Row
            if (isFiltered)
              SliverToBoxAdapter(
                child: _buildActiveFiltersBar(),
              ),

            // 5. Body Area: Empty State or Districts List
            if (filteredInspections.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(
                  context: context,
                  isFiltered: isFiltered,
                  isAdmin: user?.isAdmin == true,
                  isApproved: isApproved,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = districts[index];
                      final district = entry.key;
                      final districtInspections = entry.value;

                      final totalKg = districtInspections.fold<double>(
                        0.0,
                        (sum, inspection) => sum + inspection.quantity,
                      );

                      final communities = districtInspections
                          .map((i) => i.town?.trim().isNotEmpty == true ? i.town!.trim() : (i.farmerName ?? 'Unknown'))
                          .toSet()
                          .length;

                      return HistoryCard(
                        title: district,
                        inspectionsCount: "${districtInspections.length}",
                        communitiesCount: "$communities",
                        totalKg: totalKg.toStringAsFixed(1),
                        onTap: () {
                          if (!isApproved) {
                            CustomSnackBar.warning(
                              context,
                              message: 'Your account is pending admin approval before viewing detailed quality certificates.',
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
                      );
                    },
                    childCount: districts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Compact header that seamlessly connects to the AppBar with a slim, space-efficient metrics strip.
  /// Drastically reduces vertical footprint and scrolls away naturally with list content.
  Widget _buildCompactHeader({
    required BuildContext context,
    required int totalCertificates,
    required int totalDistricts,
    required String totalWeight,
  }) {
    final topPadding = MediaQuery.of(context).padding.top + 54.h;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, topPadding + 4.h, 16.w, 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkRed,
            Color(0xFF063312),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildCompactMetric(
                icon: Icons.workspace_premium_outlined,
                value: "$totalCertificates",
                label: "Certificates",
              ),
            ),
            Container(
              width: 1,
              height: 22.h,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _buildCompactMetric(
                icon: Icons.location_on_outlined,
                value: "$totalDistricts",
                label: "Districts",
              ),
            ),
            Container(
              width: 1,
              height: 22.h,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _buildCompactMetric(
                icon: Icons.scale_outlined,
                value: totalWeight,
                label: "Volume",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 15.r, color: AppColors.mintLight),
        Gap(6.w),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                color: AppColors.mintLight.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApprovalWarningBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: Colors.amber.shade900, size: 20.r),
          Gap(10.w),
          Expanded(
            child: Text(
              'Account Pending Approval. Access to full inspection operations is restricted until verified by an Admin.',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndToolbar({
    required BuildContext context,
    required AppUser? user,
    required List<Inspection> filteredInspections,
    required bool isFiltered,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
      child: Column(
        children: [
          // Search input box
          Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
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
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: "Search district, town, farmer, batch...",
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.black38),
                prefixIcon: Icon(Icons.search, size: 20.r, color: AppColors.primaryGreen),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.cancel, size: 18.r, color: Colors.black38),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
          Gap(10.h),

          // Action Toolbar: Filter, Report, Export
          Row(
            children: [
              // Filter Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showFilterDialog,
                  icon: Icon(
                    Icons.tune_rounded,
                    size: 16.r,
                    color: _filterCriteria.isNotEmpty ? AppColors.primaryGreen : Colors.black87,
                  ),
                  label: Text(
                    _filterCriteria.isNotEmpty
                        ? 'Filter (${_filterCriteria.activeFilterCount})'
                        : 'Filter',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _filterCriteria.isNotEmpty ? AppColors.primaryGreen : Colors.black87,
                    ),
                    maxLines: 1,
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _filterCriteria.isNotEmpty
                        ? AppColors.mintLight.withValues(alpha: 0.6)
                        : Colors.white,
                    side: BorderSide(
                      color: _filterCriteria.isNotEmpty
                          ? AppColors.tcdaAccentGreen
                          : Colors.black.withValues(alpha: 0.12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ),
              Gap(8.w),

              // Export Excel Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: filteredInspections.isEmpty ? null : () => _exportToExcel(filteredInspections),
                  icon: Icon(Icons.table_chart_outlined, size: 16.r),
                  label: Text(
                    user?.isAdmin == true ? 'Export (All)' : 'Export Excel',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                    maxLines: 1,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.black38,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ),
              Gap(8.w),

              // Report Issue / Ticket Modal
              OutlinedButton(
                onPressed: () => RaiseTicketModal.show(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.support_agent_outlined, size: 16.r, color: Colors.orange.shade800),
                    Gap(4.w),
                    Text(
                      "Report",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 6.h),
      child: Row(
        children: [
          Icon(Icons.filter_alt_outlined, size: 14.r, color: AppColors.primaryGreen),
          Gap(4.w),
          Text(
            "Filters Active",
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _clearAllFilters,
            child: Text(
              "Clear All",
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Modern, illustrated empty state with contextual action buttons.
  Widget _buildEmptyState({
    required BuildContext context,
    required bool isFiltered,
    required bool isAdmin,
    required bool isApproved,
  }) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Gap(20.h),
            // Layered badge icon
            Container(
              width: 88.r,
              height: 88.r,
              decoration: BoxDecoration(
                color: AppColors.mintLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.tcdaAccentGreen.withValues(alpha: 0.25),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tcdaAccentGreen.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isFiltered ? Icons.search_off_rounded : Icons.verified_outlined,
                  size: 42.r,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            Gap(18.h),
            Text(
              isFiltered ? "No Matching Certificates" : "No Quality Certificates Yet",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.darkRed,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(8.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300.w),
              child: Text(
                isFiltered
                    ? "We couldn't find any inspection records matching your filters or search keywords. Try clearing or adjusting them."
                    : (isAdmin
                        ? "Completed inspections and certified export lots will appear here organized by cashew growing district."
                        : "Official certificates for batches you inspect will be archived here once completed and certified."),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Gap(22.h),

            // Call to Action Buttons
            if (isFiltered)
              ElevatedButton.icon(
                onPressed: _clearAllFilters,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Reset Search & Filters"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              )
            else if (!isAdmin && isApproved)
              ElevatedButton.icon(
                onPressed: () => context.pushNamed(QualityInspectionWizard.id),
                icon: const Icon(Icons.add_task_rounded, size: 18),
                label: const Text("Start New Inspection"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),

            Gap(12.h),
            TextButton.icon(
              onPressed: () => RaiseTicketModal.show(context),
              icon: Icon(Icons.help_outline, size: 16.r, color: Colors.black54),
              label: Text(
                "Need assistance? Report an issue",
                style: TextStyle(fontSize: 12.sp, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
