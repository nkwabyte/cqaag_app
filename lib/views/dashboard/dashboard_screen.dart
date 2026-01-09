import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';

class DashboardScreen extends StatefulWidget {
  static const String id = 'dashboard_screen';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Define the navigation items
  final List<CustomNavItem> _navItems = <CustomNavItem>[
    CustomNavItem(icon: Icons.home_filled, label: "Home"),
    CustomNavItem(icon: Icons.assignment_outlined, label: "History"),
    CustomNavItem(icon: Icons.person_outline, label: "Profile"),
  ];

  // Placeholder pages for History and Profile
  final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: AnimatedBottomNavBar(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
