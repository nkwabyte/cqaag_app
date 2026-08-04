import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class ReportsManagementTab extends ConsumerStatefulWidget {
  const ReportsManagementTab({super.key});

  @override
  ConsumerState<ReportsManagementTab> createState() => _ReportsManagementTabState();
}

class _ReportsManagementTabState extends ConsumerState<ReportsManagementTab> {
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minKOR;
  double? _maxKOR;

  List<Inspection> get _filteredInspections {
    final inspectionState = ref.watch(inspectionControllerProvider).value;
    if (inspectionState == null) return [];

    var inspections = inspectionState.allCompletedInspections;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      inspections = inspections.where((inspection) {
        final batchId = inspection.batchId?.toLowerCase() ?? '';
        final farmerName = inspection.farmerName?.toLowerCase() ?? '';
        final location = inspection.location?.toLowerCase() ?? '';
        final inspectorId = inspection.inspectorId.toLowerCase();

        return batchId.contains(query) || farmerName.contains(query) || location.contains(query) || inspectorId.contains(query);
      }).toList();
    }

    // Apply date range filter
    if (_startDate != null || _endDate != null) {
      inspections = inspections.where((inspection) {
        if (inspection.completedAt == null) return false;
        final completedDate = inspection.completedAt!;

        if (_startDate != null && completedDate.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && completedDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
          return false;
        }
        return true;
      }).toList();
    }

    // Apply KOR range filter
    if (_minKOR != null || _maxKOR != null) {
      inspections = inspections.where((inspection) {
        if (_minKOR != null && inspection.kor < _minKOR!) return false;
        if (_maxKOR != null && inspection.kor > _maxKOR!) return false;
        return true;
      }).toList();
    }

    return inspections;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Reports'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
              Gap(8.h),
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
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_startDate != null ? '${_startDate!.year}-${_startDate!.month}-${_startDate!.day}' : 'Start Date'),
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
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_endDate != null ? '${_endDate!.year}-${_endDate!.month}-${_endDate!.day}' : 'End Date'),
                    ),
                  ),
                ],
              ),
              Gap(16.h),
              const Text('KOR Range', style: TextStyle(fontWeight: FontWeight.bold)),
              Gap(8.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Min KOR',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() => _minKOR = double.tryParse(value));
                      },
                    ),
                  ),
                  Gap(8.w),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Max KOR',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() => _maxKOR = double.tryParse(value));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
                _minKOR = null;
                _maxKOR = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _scanQRCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );

    if (result != null && mounted) {
      // Parse QR code result
      if (result.startsWith('inspection:')) {
        final inspectionId = result.substring('inspection:'.length);

        // Find inspection by ID
        final inspectionState = ref.read(inspectionControllerProvider).value;
        if (inspectionState != null) {
          final inspection = inspectionState.allCompletedInspections.where((i) => i.id == inspectionId || i.inspectionId == inspectionId).firstOrNull;

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

    return Scaffold(
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    name: 'search_reports',
                    label: 'Search Reports',
                    hint: "Search by batch, farmer, location...",
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value ?? '';
                      });
                    },
                  ),
                ),
                Gap(10.w),
                InkWell(
                  onTap: _showFilterDialog,
                  child: Container(
                    padding: EdgeInsets.all(16.0.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
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
                          "No reports found",
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
                              status: "Completed",
                              statusColor: Colors.green,
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
