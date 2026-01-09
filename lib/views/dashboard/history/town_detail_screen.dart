import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class TownDetailScreen extends StatefulWidget {
  static final String id = 'town_detail_screen';
  const TownDetailScreen({super.key});

  @override
  State<TownDetailScreen> createState() => _TownDetailScreenState();
}

class _TownDetailScreenState extends State<TownDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          buildHistoryHeader(
            context,
            "Wenchi Town",
            "2 inspections",
            colorScheme,
            showBack: true,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
            child: Column(
              children: [
                const CustomTextField(
                  name: 'search',
                  label: '',
                  hint: 'Search by analyst, batch, or farm',
                  prefixIcon: Icons.search,
                ),
                Gap(16.h),
                CustomButton(
                  text: "Filters",
                  width: 120.w,
                  height: 45.h,
                  variant: ButtonVariant.outlined,
                  leadingIcon: Icon(Icons.tune, size: 18.r, color: colorScheme.primary),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(24.r),
              children: [
                // Reuse InspectionCard with navigation to QualityResultScreen
                GestureDetector(
                  onTap: () => context.pushNamed(QualityResultScreen.id),
                  child: const InspectionCard(
                    // Assuming you add the score bar to the component
                    status: "Completed",
                    statusColor: Colors.green,
                    batchId: "BATCH-GH-124",
                    name: "Ama Darko",
                    location: "Wenchi District",
                    time: "Yesterday • 02:45 PM",
                    weight: "4.2",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
