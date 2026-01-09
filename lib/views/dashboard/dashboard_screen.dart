import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  static const String id = 'dashboard_screen';
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Watch user profile to check admin status
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return userProfileAsync.when(
      data: (user) {
        final isAdmin = user?.isAdmin ?? false;

        // Define navigation items based on role
        final List<CustomNavItem> navItems = [
          CustomNavItem(icon: Icons.home_filled, label: "Home"),
          CustomNavItem(icon: Icons.assignment_outlined, label: "History"),
          if (isAdmin) CustomNavItem(icon: Icons.admin_panel_settings_outlined, label: "Admin"),
          CustomNavItem(icon: Icons.person_outline, label: "Profile"),
        ];

        // Define pages based on role
        final List<Widget> pages = [
          const HomeScreen(),
          const HistoryScreen(),
          if (isAdmin) const AdminDashboardScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: AnimatedBottomNavBar(
            currentIndex: _selectedIndex,
            items: navItems,
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
