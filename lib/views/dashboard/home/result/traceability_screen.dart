import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class TraceabilityScreen extends StatefulWidget {
  static const String id = 'traceability_screen';

  const TraceabilityScreen({super.key});

  @override
  State<TraceabilityScreen> createState() => _TraceabilityScreenState();
}

class _TraceabilityScreenState extends State<TraceabilityScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const CustomText("Batch Traceability", variant: TextVariant.headlineMedium, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Summary Card
            _buildBatchHeader(colorScheme),

            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText("Supply Chain Journey", variant: TextVariant.displaySmall),
                  CustomText(
                    "Complete traceability from farm to export",
                    variant: TextVariant.bodyMedium,
                    color: colorScheme.secondary,
                  ),
                  Gap(30.h),

                  // 2. The Timeline
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        children: [
                          JourneyNode(icon: Icons.location_on_outlined),
                          JourneyNode(icon: Icons.search),
                          JourneyNode(icon: Icons.verified_user),
                          JourneyNode(icon: Icons.warehouse_outlined),
                          JourneyNode(icon: Icons.local_shipping_outlined, isLast: true, isCompleted: false),
                        ],
                      ),
                      Gap(20.w),
                      Expanded(
                        child: Column(
                          children: const [
                            JourneyCard(
                              title: "Farm Collection",
                              subtitle: "Cashew harvested and registered",
                              location: "Wenchi District, Bono Region",
                              person: "Kwame Mensah",
                              role: "Farmer",
                              dateTime: "2024-12-10, 08:30 AM",
                            ),
                            JourneyCard(
                              title: "Quality Inspection",
                              subtitle: "Field inspection completed",
                              location: "Wenchi Collection Center",
                              person: "Emmanuel Adjei",
                              role: "Inspector",
                              dateTime: "2024-12-18, 10:15 AM",
                            ),
                            JourneyCard(
                              title: "District Validation",
                              subtitle: "Regional supervisor approval",
                              location: "Bono Regional Office",
                              person: "Akosua Frimpong",
                              role: "Regional Supervisor",
                              dateTime: "2024-12-18, 02:45 PM",
                            ),
                            JourneyCard(
                              title: "Warehouse Storage",
                              subtitle: "Stored in certified facility",
                              location: "Kumasi Central Warehouse",
                              person: "Yaw Boateng",
                              role: "Warehouse Manager",
                              dateTime: "2024-12-19, 09:00 AM",
                            ),
                            JourneyCard(
                              title: "Export Certification",
                              subtitle: "Ready for international export",
                              location: "CQAAG National HQ",
                              person: "Dr. Ama Asante",
                              role: "CEO",
                              dateTime: "2024-12-20, 11:30 AM",
                              isCompleted: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Gap(30.h),
                  _buildFinalSummary(colorScheme),
                  Gap(40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchHeader(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50.r),
          bottomRight: Radius.circular(50.r),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText("Batch ID", variant: TextVariant.bodySmall, color: Colors.white70),
                    const CustomText("BATCH-GH-001", variant: TextVariant.displaySmall, color: Colors.white),
                  ],
                ),
                _buildStatusBadge("Export Ready", Colors.green),
              ],
            ),
            Gap(20.h),
            const Divider(color: Colors.white24),
            Gap(20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat("Weight", "2.5 MT"),
                _buildStat("Grade", "Grade A"),
                _buildStat("Days", "10"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color),
      ),
      child: CustomText(text, variant: TextVariant.bodySmall, color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        CustomText(label, variant: TextVariant.bodySmall, color: Colors.white70),
        Gap(4.h),
        CustomText(value, variant: TextVariant.bodyLarge, color: const Color(0xFFbe6735), fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _buildFinalSummary(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: colorScheme.primary),
              Gap(12.w),
              const CustomText("Batch Summary", variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
            ],
          ),
          Gap(24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem("Total Weight", "2.5 MT"),
              _summaryItem("Quality Grade", "Grade A"),
            ],
          ),
          Gap(16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem("KOR Score", "185"),
              _summaryItem("Days in Chain", "10"),
            ],
          ),
          Gap(24.h),
          const Divider(),
          Gap(16.h),
          CustomText(
            "All checkpoints verified and digitally signed",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(label, variant: TextVariant.bodySmall, color: Colors.grey),
        CustomText(val, variant: TextVariant.displaySmall, fontWeight: FontWeight.bold),
      ],
    );
  }
}
