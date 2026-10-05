import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
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
  bool _isAdmin = false;

  // Define navigation items based on role
  late List<CustomNavItem> navItems;

  // Define screens based on role
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    // Try to get initial state if available to prevent flicker
    final userAsync = ref.read(currentUserProfileProvider);
    if (userAsync.hasValue && userAsync.value != null) {
      _isAdmin = userAsync.value!.isAdmin;
    }
    _initializeLayout();
  }

  void _initializeLayout() {
    final user = ref.read(currentUserProfileProvider).value;

    if (user == null) {
      // Profile still loading (the router keeps signed-out users away from here).
      navItems = [];
      pages = const <Widget>[
        Center(child: CircularProgressIndicator()),
      ];
    } else {
      _isAdmin = user.isAdmin;
      navItems = [
        CustomNavItem(icon: Icons.home_filled, label: "Home"),
        CustomNavItem(icon: Icons.assignment_outlined, label: "History"),
        if (_isAdmin) CustomNavItem(icon: Icons.admin_panel_settings_outlined, label: "Admin"),
        CustomNavItem(icon: Icons.person_outline, label: "Profile"),
      ];

      pages = <Widget>[
        const HomeScreen(),
        const HistoryScreen(),
        if (_isAdmin) const AdminDashboardScreen(),
        const ProfileScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for user profile changes
    ref.listen(currentUserProfileProvider, (previous, next) {
      next.whenData((user) {
        if (mounted) {
          setState(() {
            _initializeLayout();
            if (_selectedIndex >= pages.length) {
              _selectedIndex = 0;
            }
          });
        }
      });
    });

    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProfileProvider).value;
    final isAuthenticated = user != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.darkRed,
        title: Row(
          children: <Widget>[
            CustomText(
              UIHelpers.getGreeting(),
              variant: TextVariant.bodyLarge,
              color: colorScheme.secondary,
            ),
          ],
        ),
        actions: [
          if (isAuthenticated)
            InkWell(
              onTap: () {
                context.pushNamed(NotificationsScreen.id);
              },
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.lightOrange,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.notifications,
                  color: Colors.black,
                  size: 24.r,
                ),
              ),
            ),
          if (isAuthenticated) Gap(10.w),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(
        onDashboardTap: () {
          Navigator.pop(context);
          setState(() {
            _selectedIndex = 0; // Navigate to Home tab
          });
        },
        onHomeTap: () {
          Navigator.pop(context);
          setState(() {
            _selectedIndex = 0; // Navigate to Home tab
          });
        },
        onSettingsTap: () {
          Navigator.pop(context);
          setState(() {
            _selectedIndex = pages.length - 1; // Profile is always the last tab
          });
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: navItems.isNotEmpty
          ? AnimatedBottomNavBar(
              currentIndex: _selectedIndex,
              items: navItems,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            )
          : null,
    );
  }
}
