import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const String id = 'admin_dashboard_screen';
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.darkRed,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: colorScheme.secondary,
            indicatorColor: AppColors.grayOrange,
            indicatorSize: TabBarIndicatorSize.tab,
            isScrollable: true,
            tabs: const <Widget>[
              Tab(text: "Users"),
              Tab(text: "Members"),
              Tab(text: "Reports"),
              Tab(text: "Payments"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UserManagementTab(),
            MembershipManagementTab(),
            ReportsManagementTab(),
            PaymentSettingsTab(),
          ],
        ),
      ),
    );
  }
}
