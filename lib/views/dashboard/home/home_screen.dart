import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class HomeScreen extends StatefulWidget {
  static final String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 1. Curved Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 40.h),
              decoration: BoxDecoration(
                color: colorScheme.onSurface, // darkRed
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.r),
                  bottomRight: Radius.circular(50.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText("Good Morning", variant: TextVariant.bodyLarge, color: colorScheme.secondary),
                          CustomText("Emmanuel Adjei", variant: TextVariant.displaySmall, color: Colors.white),
                          CustomText(
                            "Field Inspector • ID: INS-042",
                            variant: TextVariant.bodySmall,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                      // Network Status Indicator
                      Row(
                        children: [
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          ),
                          Gap(8.w),
                          const Icon(Icons.wifi, color: Colors.green, size: 20),
                        ],
                      ),
                    ],
                  ),
                  Gap(30.h),
                  // Summary Cards Row
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SummaryCard(label: "Today", count: "3"),
                      SummaryCard(label: "Pending", count: "2"),
                      SummaryCard(label: "Done", count: "1"),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  // 2. Action Bar
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: "New Inspection",
                          leadingIcon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                      Gap(16.w),
                      // Sync/Offline Toggle Button
                      Container(
                        height: 56.h,
                        width: 56.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                        ),
                        child: Icon(Icons.sync_disabled, color: colorScheme.onSurface),
                      ),
                    ],
                  ),

                  Gap(30.h),

                  // 3. Schedule Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomText("Today's Schedule", variant: TextVariant.displaySmall),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: CustomText(
                          "3 Tasks",
                          variant: TextVariant.bodySmall,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Gap(20.h),

                  // 4. Inspection List
                  const InspectionCard(
                    status: "Pending",
                    statusColor: Color(0xFFD6A467), // grayOrange
                    batchId: "BATCH-GH-001",
                    name: "Kwame Mensah",
                    location: "Wenchi District",
                    time: "09:00 AM",
                    weight: "2.5",
                  ),
                  const InspectionCard(
                    status: "In Progress",
                    statusColor: Color(0xFF2E7D32),
                    batchId: "BATCH-GH-002",
                    name: "Akosua Frimpong",
                    location: "Techiman Municipality",
                    time: "11:30 AM",
                    weight: "3.2",
                  ),
                  const InspectionCard(
                    status: "Pending",
                    statusColor: Color(0xFFD6A467),
                    batchId: "BATCH-GH-003",
                    name: "Yaw Boateng",
                    location: "Jaman North District",
                    time: "02:00 PM",
                    weight: "1.8",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
