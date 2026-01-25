import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';

class AppDrawer extends ConsumerWidget {
  final VoidCallback? onDashboardTap;
  final VoidCallback? onHomeTap;
  final VoidCallback? onSettingsTap;

  const AppDrawer({
    super.key,
    this.onDashboardTap,
    this.onHomeTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProfileProvider).value;
    final isAuthenticated = user != null;

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkRed,
            ),
            child: SafeArea(
              top: true,
              bottom: false,
              left: false,
              right: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
                child: isAuthenticated ? _buildAuthHeader(user) : _buildGuestHeader(),
              ),
            ),
          ),

          // Navigation Items (Scrollable)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Column(
                    children: [
                      if (isAuthenticated) ...[
                        _buildDrawerItem(
                          context: context,
                          colorScheme: colorScheme,
                          icon: Icons.dashboard_outlined,
                          title: 'Dashboard',
                          onTap:
                              onDashboardTap ??
                              () {
                                Navigator.pop(context);
                                context.goNamed(DashboardScreen.id);
                              },
                        ),
                        _buildDrawerItem(
                          context: context,
                          colorScheme: colorScheme,
                          icon: Icons.home_outlined,
                          title: 'Home',
                          onTap:
                              onHomeTap ??
                              () {
                                Navigator.pop(context);
                                context.goNamed(DashboardScreen.id);
                              },
                        ),
                      ] else ...[
                        _buildDrawerItem(
                          context: context,
                          colorScheme: colorScheme,
                          icon: Icons.home_outlined,
                          title: 'Home',
                          onTap: () {
                            Navigator.pop(context);
                            context.goNamed(DashboardScreen.id); // Or DashboardScreen if unified
                          },
                        ),
                      ],

                      _buildDrawerItem(
                        context: context,
                        colorScheme: colorScheme,
                        icon: Icons.info_outline,
                        title: 'About Us',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(AboutScreen.id);
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        colorScheme: colorScheme,
                        icon: Icons.contact_mail_outlined,
                        title: 'Contact Us',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(ContactUsScreen.id);
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        colorScheme: colorScheme,
                        icon: Icons.verified_outlined,
                        title: 'Quality Standards',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(QualityStandardsScreen.id);
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        colorScheme: colorScheme,
                        icon: Icons.gavel,
                        title: 'Code of Ethics',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(CodeOfEthicsScreen.id);
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        colorScheme: colorScheme,
                        icon: Icons.article_outlined,
                        title: 'Constitution',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(ConstitutionScreen.id);
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        colorScheme: colorScheme,
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(TermsAndConditionsScreen.id);
                        },
                      ),

                      Divider(
                        height: 25.h,
                        thickness: 1,
                        indent: 20.w,
                        endIndent: 20.w,
                      ),

                      if (isAuthenticated) ...[
                        _buildDrawerItem(
                          context: context,
                          colorScheme: colorScheme,
                          icon: Icons.settings,
                          title: 'Settings',
                          onTap:
                              onSettingsTap ??
                              () {
                                // Default behavior if not provided
                                Navigator.pop(context);
                              },
                        ),
                      ] else ...[
                        _buildDrawerItem(
                          context: context,
                          colorScheme: colorScheme,
                          icon: Icons.login,
                          title: 'Login',
                          onTap: () {
                            Navigator.pop(context);
                            ref.read(guestModeProvider.notifier).disableGuestMode();
                            context.goNamed(LoginScreen.id);
                          },
                        ),
                        _buildDrawerItem(
                          context: context,
                          colorScheme: colorScheme,
                          icon: Icons.person_add,
                          title: 'Sign Up',
                          onTap: () {
                            Navigator.pop(context);
                            ref.read(guestModeProvider.notifier).disableGuestMode();
                            context.goNamed(RegisterScreen.id);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer
          if (isAuthenticated)
            _buildAuthFooter(context, colorScheme, user, ref)
          else
            Container(
              padding: EdgeInsets.all(20.r),
              child: CustomText(
                'C.Q.A.A.G © 2025',
                variant: TextVariant.bodySmall,
                color: colorScheme.secondary,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthHeader(AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomText(
              UIHelpers.getGreeting(),
              variant: TextVariant.bodyLarge,
              color: Colors.white70,
            ),
            if (user.verificationStatus == VerificationStatus.verified) ...[
              Gap(8.w),
              Icon(Icons.verified, color: Colors.blue, size: 24.r).shimmer(),
            ],
          ],
        ),
        Gap(12.h),
        Row(
          children: <Widget>[
            Expanded(
              child: CustomText(
                user.firstName,
                variant: TextVariant.displaySmall,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Gap(4.h),
        CustomText(
          "${user.role ?? "User"} • ID: ${user.id.substring(0, 8).toUpperCase()}",
          variant: TextVariant.bodySmall,
          color: Colors.white70,
        ),
      ],
    );
  }

  Widget _buildGuestHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.person_outline,
          size: 60.r,
          color: Colors.white,
        ),
        Gap(12.h),
        const CustomText(
          'Guest User',
          variant: TextVariant.headlineMedium,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        Gap(4.h),
        CustomText(
          'Exploring C.Q.A.A.G',
          variant: TextVariant.bodySmall,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  Widget _buildAuthFooter(BuildContext context, ColorScheme colorScheme, AppUser user, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        right: false,
        left: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: colorScheme.secondary.withValues(alpha: 0.2),
              backgroundImage: user.profilePicture.isNotEmpty ? CachedNetworkImageProvider(user.profilePicture) : null,
              child: user.profilePicture.isEmpty ? Icon(Icons.person, size: 24.r, color: Colors.white) : null,
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "${user.firstName} ${user.lastName}",
                    variant: TextVariant.bodySmall,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(2.h),
                  Row(
                    children: [
                      CustomText(
                        user.role ?? "User",
                        variant: TextVariant.bodySmall,
                        color: colorScheme.secondary,
                      ),
                      CustomText(
                        " • ",
                        variant: TextVariant.bodySmall,
                        color: colorScheme.secondary,
                      ),
                      CustomText(
                        user.id.substring(0, 8).toUpperCase(),
                        variant: TextVariant.bodySmall,
                        color: colorScheme.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: colorScheme.primary,
        size: 24.r,
      ),
      title: CustomText(
        title,
        variant: TextVariant.bodyMedium,
        fontWeight: FontWeight.w500,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
    );
  }
}
