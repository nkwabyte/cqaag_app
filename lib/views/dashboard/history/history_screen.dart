import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  static final String id = 'history_screen';
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  Map<String, List<Inspection>> _groupByDistrict(List<Inspection> inspections) {
    final grouped = <String, List<Inspection>>{};
    for (final inspection in inspections) {
      final district = inspection.location ?? 'Unknown District';
      grouped.putIfAbsent(district, () => []).add(inspection);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inspectionState = ref.watch(inspectionControllerProvider).value;

    final inspections = inspectionState?.allCompletedInspections ?? [];
    final grouped = _groupByDistrict(inspections);
    final districts = grouped.entries.toList();

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
            "Districts",
            "${districts.length} districts",
            colorScheme,
          ),

          if (inspections.isEmpty)
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
                        "No completed inspections yet",
                        variant: TextVariant.headlineMedium,
                        color: colorScheme.secondary,
                      ),
                    ],
                  ).bounceIn(),
                ),
              ),
            ),

          if (inspections.isNotEmpty)
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

                    // Calculate total MT for district
                    final totalMT = districtInspections.fold<double>(
                      0.0,
                      (sum, inspection) => sum + inspection.quantity,
                    );

                    // Get unique communities/towns
                    final communities = districtInspections.map((i) => i.farmerName ?? 'Unknown').toSet().length;

                    return HistoryCard(
                      title: district,
                      inspectionsCount: "${districtInspections.length}",
                      communitiesCount: "$communities",
                      totalMT: totalMT.toStringAsFixed(1),
                      onTap: () => context.pushNamed(
                        DistrictDetailScreen.id,
                        extra: {
                          'district': district,
                          'inspections': districtInspections,
                        },
                      ),
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
