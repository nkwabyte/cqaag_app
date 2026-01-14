import 'package:flutter/material.dart';
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

  // Define pages based on role
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

    // Invalidate providers to force refresh on dashboard load
    // This ensures data is fresh when user lands on dashboard from splash or login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(recentInspectionsProvider);
      ref.invalidate(userPrioritizedInspectionsProvider);
      ref.invalidate(userUncompletedInspectionsProvider);
    });
  }

  void _initializeLayout() {
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

  void _updateAdminStatus(bool isAdmin) {
    if (_isAdmin != isAdmin) {
      setState(() {
        _isAdmin = isAdmin;
        _initializeLayout();
        // Reset index if out of bounds after removing admin tab
        if (_selectedIndex >= pages.length) {
          _selectedIndex = 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for user profile changes
    ref.listen(currentUserProfileProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // Check for verification status
          if (user.verificationStatus != VerificationStatus.verified && user.verificationStatus != VerificationStatus.pending) {
            // Only show dialog if not already showing?
            // The original code just added post frame callback.
            // We should probably check if it's the first time or specific transition.
            // For now keeping original logic but wrapped safely.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Verify context is still valid and maybe check if dialog is open?
              // Simplified as per original request to just move checks.
              _showVerificationDialog(context);
            });
          }

          // Update admin status if changed
          _updateAdminStatus(user.isAdmin);
        }
      });
    });

    // NOTE: Users might flicker if they are admin.
    // To solve this, we can check the provider verification in initState if it was already alive.
    // See note below.

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
  }

  void _showVerificationDialog(BuildContext context) {
    // Prevent multiple dialogs if possible, but sticking to basic implementation
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: StatusDialog(
            type: DialogType.info,
            title: "Verification",
            message: "Please verify your account to continue using the application.",
            buttonText: "Ok",
            onConfirm: () {
              context.goNamed(VerificationUploadScreen.id);
            },
          ),
        );
      },
    );
  }
}
