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
    final guestMode = ref.read(guestModeProvider);

    // Check if user is null (guest) or explicitly in guest mode
    if (user == null || guestMode == AuthMode.guest) {
      navItems = [];
      pages = <Widget>[
        const GuestHomeScreen(),
      ];
    } else {
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showVerificationDialog(context);
            });
          }

          // Update admin status if changed
          _updateAdminStatus(user.isAdmin);
        }
      });
    });

    // Listen for guest mode changes
    ref.listen(guestModeProvider, (previous, next) {
      _initializeLayout();
      setState(() {});
    });

    final colorScheme = Theme.of(context).colorScheme;

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
          InkWell(
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
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
          Gap(10.w),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(
        onDashboardTap: () {
          Navigator.pop(context);
          if (ref.read(guestModeProvider) == AuthMode.guest) {
            ref.read(guestModeProvider.notifier).disableGuestMode();
            // Maybe setAuthenticated? Depends on logic. disable sets to unauth.
            // But user provider still present. Dashboard checks user != null.
            // So disableGuestMode is fine (clears guest flag).
          }
          setState(() {
            _selectedIndex = 0; // Navigate to Home tab
          });
        },
        onHomeTap: () {
          Navigator.pop(context);
          ref.read(guestModeProvider.notifier).enableGuestMode();
          // No need to set index, Guest layout has 1 page.
        },
        onSettingsTap: () {
          Navigator.pop(context);
          // If in guest mode, maybe switch back to auth mode to show profile?
          if (ref.read(guestModeProvider) == AuthMode.guest) {
            ref.read(guestModeProvider.notifier).disableGuestMode();
          }
          setState(() {
            _selectedIndex = 3; // Navigate to Profile tab
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
