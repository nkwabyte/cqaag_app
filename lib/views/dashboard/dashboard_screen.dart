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

  @override
  Widget build(BuildContext context) {
    // Watch user profile to check admin status
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    // Listen for verification updates to redirect unverified users
    ref.listen(currentUserProfileProvider, (previous, next) {
      next.whenData((user) {
        if (user != null &&
            (user.verificationStatus != VerificationStatus.verified &&
                user.verificationStatus != VerificationStatus.pending)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showVerificationDialog(context);
          });
        }
      });
    });

    return userProfileAsync.when(
      data: (user) {
        // debugPrint("User profile: $user");
        final isAdmin = user?.isAdmin ?? false;

        // Trigger dialog on initial load if needed
        if (user != null &&
            (user.verificationStatus != VerificationStatus.verified &&
                user.verificationStatus != VerificationStatus.pending)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showVerificationDialog(context);
          });
        }

        // Define navigation items based on role
        final List<CustomNavItem> navItems = [
          CustomNavItem(icon: Icons.home_filled, label: "Home"),
          CustomNavItem(icon: Icons.assignment_outlined, label: "History"),
          if (isAdmin) CustomNavItem(icon: Icons.admin_panel_settings_outlined, label: "Admin"),
          CustomNavItem(icon: Icons.person_outline, label: "Profile"),
        ];

        // Define pages based on role
        final List<Widget> pages = <Widget>[
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

  void _showVerificationDialog(BuildContext context) {
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
