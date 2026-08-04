import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DistrictDetailScreen extends StatefulWidget {
  static final String id = 'district_detail_screen';
  final String district;
  final List<Inspection> inspections;

  const DistrictDetailScreen({
    super.key,
    required this.district,
    required this.inspections,
  });

  @override
  State<DistrictDetailScreen> createState() => _DistrictDetailScreenState();
}

class _DistrictDetailScreenState extends State<DistrictDetailScreen> {
  Map<String, List<Inspection>> _groupByTown(List<Inspection> inspections) {
    final grouped = <String, List<Inspection>>{};
    for (final inspection in inspections) {
      // Prioritize town, then farmerName, then Unknown
      final town = inspection.town ?? inspection.farmerName ?? 'Unknown Community';
      grouped.putIfAbsent(town, () => []).add(inspection);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final grouped = _groupByTown(widget.inspections);
    final towns = grouped.entries.toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          buildHistoryHeader(
            context,
            widget.district,
            "${towns.length} communities",
            colorScheme,
            showBack: true,
          ),
          Expanded(
            child: towns.isEmpty
                ? Center(
                    child: CustomText(
                      "No inspections found in this district",
                      variant: TextVariant.bodyMedium,
                      color: colorScheme.secondary,
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(24.r),
                    itemCount: towns.length,
                    itemBuilder: (context, index) {
                      final entry = towns[index];
                      final town = entry.key;
                      final townInspections = entry.value;

                      final totalMT = townInspections.fold<double>(
                        0.0,
                        (sum, inspection) => sum + inspection.quantity,
                      );

                      return HistoryCard(
                        title: town,
                        inspectionsCount: "${townInspections.length}",
                        totalMT: totalMT.toStringAsFixed(1),
                        onTap: () => context.pushNamed(
                          TownDetailScreen.id,
                          extra: {
                            'town': town,
                            'inspections': townInspections,
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
