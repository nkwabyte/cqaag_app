import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryScreen extends StatefulWidget {
  static final String id = 'history_screen';
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          buildHistoryHeader(
            context,
            "Districts",
            "3 districts",
            colorScheme,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(24.r),
              children: [
                HistoryCard(
                  title: "Wenchi District",
                  inspectionsCount: "4",
                  communitiesCount: "2",
                  totalMT: "17.2",
                  onTap: () => context.pushNamed(DistrictDetailScreen.id),
                ),
                HistoryCard(
                  title: "Techiman Municipality",
                  inspectionsCount: "3",
                  communitiesCount: "2",
                  totalMT: "8.9",
                  onTap: () {},
                ),
                HistoryCard(
                  title: "Jaman North District",
                  inspectionsCount: "3",
                  communitiesCount: "2",
                  totalMT: "8.5",
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
