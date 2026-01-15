import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TownDetailScreen extends StatefulWidget {
  static final String id = 'town_detail_screen';
  final String town;
  final List<Inspection> inspections;

  const TownDetailScreen({
    super.key,
    required this.town,
    required this.inspections,
  });

  @override
  State<TownDetailScreen> createState() => _TownDetailScreenState();
}

class _TownDetailScreenState extends State<TownDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          buildHistoryHeader(
            context,
            widget.town,
            "${widget.inspections.length} inspections",
            colorScheme,
            showBack: true,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 0.h, 24.w, 0),
            child: Column(
              children: <Widget>[
                const CustomTextField(
                  name: 'search',
                  label: '',
                  hint: 'Search by analyst, batch, or farm',
                  prefixIcon: Icons.search,
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.inspections.isEmpty
                ? Center(
                    child: CustomText(
                      "No inspections found",
                      variant: TextVariant.bodyMedium,
                      color: colorScheme.secondary,
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(24.r),
                    itemCount: widget.inspections.length,
                    itemBuilder: (context, index) {
                      final inspection = widget.inspections[index];
                      // Format date: "Yesterday • 02:45 PM" (simplified for now)
                      // You might want to use a DateFormat utility here
                      final dateStr = inspection.completedAt != null
                          ? "${inspection.completedAt!.year}-${inspection.completedAt!.month}-${inspection.completedAt!.day}"
                          : "Unknown Date";

                      return GestureDetector(
                        onTap: () => context.pushNamed(
                          QualityResultScreen.id,
                          extra: inspection,
                        ),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final params = inspection.inspectorId;
                            final inspectorAsync = ref.watch(inspectorProfileProvider(params));

                            final inspectorName = inspectorAsync.when(
                              data: (user) =>
                                  user != null ? "${user.firstName} ${user.lastName}" : inspection.inspectorId,
                              loading: () => "Loading...",
                              error: (error, stack) => inspection.inspectorId,
                            );

                            return InspectionCard(
                              status: inspection.status == InspectionStatus.completed
                                  ? "Completed"
                                  : inspection.status.name,
                              statusColor: inspection.status == InspectionStatus.completed
                                  ? Colors.green
                                  : Colors.orange,
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
    );
  }
}
