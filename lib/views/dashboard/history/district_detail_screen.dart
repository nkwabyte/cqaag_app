import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DistrictDetailScreen extends StatefulWidget {
  static final String id = 'district_detail_screen';
  const DistrictDetailScreen({super.key});

  @override
  State<DistrictDetailScreen> createState() => _DistrictDetailScreenState();
}

class _DistrictDetailScreenState extends State<DistrictDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          buildHistoryHeader(
            context,
            "Wenchi District",
            "2 communities",
            colorScheme,
            showBack: true,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(24.r),
              children: [
                HistoryCard(
                  title: "Wenchi Town",
                  inspectionsCount: "2",
                  totalMT: "8.9",
                  onTap: () => context.pushNamed(TownDetailScreen.id),
                ),
                HistoryCard(
                  title: "Nkoranza",
                  inspectionsCount: "2",
                  totalMT: "8.3",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
