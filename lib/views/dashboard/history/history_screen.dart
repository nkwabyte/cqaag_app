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
    final inspectionsAsync = ref.watch(allCompletedInspectionsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header with data stats
          if (inspectionsAsync.hasValue)
            buildHistoryHeader(
              context,
              "Districts",
              "${_groupByDistrict(inspectionsAsync.value!).length} districts",
              colorScheme,
            )
          else if (inspectionsAsync.isLoading)
            buildHistoryHeader(
              context,
              "Districts",
              "Loading...",
              colorScheme,
            )
          else
            buildHistoryHeader(
              context,
              "Districts",
              "0 districts",
              colorScheme,
            ),

          Expanded(
            child: Builder(
              builder: (context) {
                final inspections = inspectionsAsync.value;

                // If we have data (even if refreshing), show the list
                if (inspections != null) {
                  if (inspections.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.history,
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
                    );
                  }

                  final grouped = _groupByDistrict(inspections);
                  final districts = grouped.entries.toList();

                  return ListView.builder(
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
                  );
                }

                // If no data and loading, show spinner
                if (inspectionsAsync.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // If error and no data
                if (inspectionsAsync.hasError) {
                  debugPrint("error on history screen: ${inspectionsAsync.error}");
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          size: 64.r,
                          color: colorScheme.error.withValues(alpha: 0.3),
                        ),
                        SizedBox(height: 16.h),
                        CustomText(
                          "Error loading history",
                          variant: TextVariant.headlineMedium,
                          color: colorScheme.error,
                        ),
                      ],
                    ).bounceIn(),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
