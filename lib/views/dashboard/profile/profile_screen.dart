import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static final String id = 'profile_screen';
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  bool _autoSyncEnabled = true;
  bool _offlineModeEnabled = false;

  Future<void> _handleAvatarUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (!mounted) return;

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null) {
          setState(() => _isUploading = true);

          final file = File(path);
          final cloudinaryService = ref.read(cloudinaryServiceProvider);
          final url = await cloudinaryService.uploadAvatar(file); // Changed to uploadAvatar

          if (url != null) {
            final currentUser = ref.read(currentUserProfileProvider).value;
            if (currentUser != null) {
              await ref.read(userServiceProvider).updateUserData(
                currentUser.id,
                {
                  'profile_picture': url,
                },
              );
              if (!mounted) return;
              CustomSnackBar.success(
                context,
                message: 'Profile picture updated!',
              );
              // Invalidate user provider to refresh UI if needed, usually stream updates automatically
            }
          } else {
            if (!mounted) return;
            CustomSnackBar.error(
              context,
              message: 'Failed to upload image',
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, message: 'Error updating profile: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      // Show loading dialog
      AppDialogs.showLoading(context);

      // Sign out via auth controller
      await ref.read(authControllerProvider.notifier).signOut();

      // Hide loading dialog
      if (!mounted) return;
      AppDialogs.hide(context);

      // Navigate directly to login screen using path
      if (!mounted) return;
      context.go('/${LoginScreen.id}');
    } catch (e) {
      if (!mounted) return;
      AppDialogs.hide(context);
      CustomSnackBar.error(context, message: 'Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 1. Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: colorScheme.onSurface, // darkRed
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60.r),
                  bottomRight: Radius.circular(60.r),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: <Widget>[
                    // Avatar with Edit Button
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 55.r,
                          backgroundColor: colorScheme.secondary.withValues(alpha: 0.2),
                          // Display actual profile picture using ref to watch current user
                          backgroundImage: ref.watch(currentUserProfileProvider).value?.profilePicture != null
                              ? CachedNetworkImageProvider(ref.watch(currentUserProfileProvider).value!.profilePicture)
                              : null,
                          child: ref.watch(currentUserProfileProvider).value?.profilePicture == null ? Icon(Icons.person, size: 60.r, color: Colors.white) : null,
                        ),
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.w),
                          ),
                          child: InkWell(
                            onTap: _isUploading ? null : _handleAvatarUpload,
                            child: _isUploading
                                ? SizedBox(
                                    width: 16.r,
                                    height: 16.r,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Icon(Icons.camera_alt, size: 16.r, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Gap(16.h),
                    // User Name with Conditional Verification Badge
                    Consumer(
                      builder: (context, ref, child) {
                        final user = ref.watch(currentUserProfileProvider).value;
                        final isVerified = user?.verificationStatus == VerificationStatus.verified;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CustomText(
                              user != null ? "${user.firstName} ${user.lastName}" : "Loading...",
                              variant: TextVariant.displaySmall,
                              color: Colors.white,
                            ),
                            if (isVerified) ...[
                              Gap(8.w),
                              Icon(Icons.verified, color: Colors.blueAccent, size: 20.r),
                            ],
                          ],
                        );
                      },
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final user = ref.watch(currentUserProfileProvider).value;
                        return CustomText(
                          user?.role ?? "User",
                          variant: TextVariant.bodyMedium,
                          color: Colors.white70,
                        );
                      },
                    ),
                    Gap(8.h),
                    Consumer(
                      builder: (context, ref, child) {
                        final user = ref.watch(currentUserProfileProvider).value;
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: CustomText(
                            user != null ? "ID: ${user.id.substring(0, 8).toUpperCase()}" : "ID: ...",
                            variant: TextVariant.bodySmall,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 2. Profile Content Section
            SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Contact Details Card
                    Consumer(
                      builder: (context, ref, child) {
                        final user = ref.watch(currentUserProfileProvider).value;
                        return _buildCard(
                          context,
                          <Widget>[
                            ProfileTile(
                              icon: Icons.email_outlined,
                              title: user?.email ?? "N/A",
                              subtitle: "Email",
                            ),
                            ProfileTile(
                              icon: Icons.phone_outlined,
                              title: user?.phoneNumber ?? "N/A",
                              subtitle: "Phone",
                            ),
                            ProfileTile(
                              icon: Icons.location_on_outlined,
                              title: user?.region ?? "N/A",
                              subtitle: "Region",
                            ),
                          ],
                        );
                      },
                    ),

                    Gap(24.h),
                    const ProfileSectionHeader(title: "Account"),

                    // Verification Banner - Conditional based on status
                    Consumer(
                      builder: (context, ref, child) {
                        final user = ref.watch(currentUserProfileProvider).value;
                        final verificationStatus = user?.verificationStatus ?? VerificationStatus.unverified;

                        // Show upload banner only for unverified users
                        if (verificationStatus == VerificationStatus.unverified) {
                          return InkWell(
                            onTap: () => context.pushNamed(VerificationUploadScreen.id),
                            child: Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.verified_user, color: Colors.blue, size: 40.r),
                                  Gap(16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const CustomText(
                                          "Account Verification",
                                          variant: TextVariant.bodyLarge,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        CustomText(
                                          "Upload ID & Documents",
                                          variant: TextVariant.bodySmall,
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 16.r, color: Colors.blue.withValues(alpha: 0.5)),
                                ],
                              ),
                            ),
                          );
                        }

                        // Show status badge for verified or pending users
                        Color statusColor;
                        String statusText;
                        IconData statusIcon;

                        switch (verificationStatus) {
                          case VerificationStatus.verified:
                            statusColor = Colors.green;
                            statusText = "Verified";
                            statusIcon = Icons.verified;
                            break;
                          case VerificationStatus.pending:
                            statusColor = Colors.orange;
                            statusText = "Pending Verification";
                            statusIcon = Icons.pending;
                            break;
                          case VerificationStatus.rejected:
                            statusColor = Colors.red;
                            statusText = "Verification Rejected";
                            statusIcon = Icons.cancel;
                            break;
                          default:
                            statusColor = Colors.grey;
                            statusText = "Not Verified";
                            statusIcon = Icons.info;
                        }

                        return Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(statusIcon, color: statusColor, size: 40.r),
                              Gap(16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const CustomText(
                                      "Verification Status",
                                      variant: TextVariant.bodyLarge,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    CustomText(
                                      statusText,
                                      variant: TextVariant.bodySmall,
                                      color: statusColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Gap(12.h),

                    _buildCard(context, [
                      ProfileTile(
                        icon: Icons.edit_outlined,
                        title: "Edit Profile",
                        onTap: () async {
                          final result = await context.pushNamed(EditProfileScreen.id);
                          if (result == true && context.mounted) {
                            CustomSnackBar.success(context, message: "Profile updated successfully");
                          }
                        },
                      ),
                      ProfileTile(
                        icon: Icons.card_membership_outlined,
                        title: "Membership Application",
                        subtitle: "Apply to be a member",
                        onTap: () => context.pushNamed(MembershipApplicationScreen.id),
                      ),
                    ]),

                    Gap(24.h),
                    const ProfileSectionHeader(title: "App Settings"),
                    _buildCard(context, [
                      ProfileTile(
                        icon: Icons.notifications_outlined,
                        title: "Notifications",
                        subtitle: "Push notifications",
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                          activeThumbColor: Colors.green,
                        ),
                      ),
                      ProfileTile(
                        icon: Icons.language_outlined,
                        title: "Language",
                        subtitle: _selectedLanguage,
                        onTap: () => _showLanguageDialog(),
                      ),
                    ]),

                    Gap(24.h),
                    const ProfileSectionHeader(title: "Data & Storage"),
                    _buildCard(context, [
                      ProfileTile(
                        icon: Icons.sync,
                        title: "Auto Sync",
                        subtitle: "Sync when connected",
                        trailing: Switch(
                          value: _autoSyncEnabled,
                          onChanged: (value) {
                            setState(() {
                              _autoSyncEnabled = value;
                            });
                          },
                          activeThumbColor: Colors.green,
                        ),
                      ),
                      ProfileTile(
                        icon: Icons.cloud_off,
                        title: "Offline Mode",
                        subtitle: "Save data locally",
                        trailing: Switch(
                          value: _offlineModeEnabled,
                          onChanged: (value) {
                            setState(() {
                              _offlineModeEnabled = value;
                            });
                          },
                          activeThumbColor: Colors.green,
                        ),
                      ),
                    ]),

                    Gap(24.h),
                    const ProfileSectionHeader(title: "Documents & Policies"),
                    _buildCard(context, [
                      ProfileTile(
                        icon: Icons.gavel,
                        title: "Code of Ethics",
                        subtitle: "Guardians of Ghana's Cashew Quality",
                        onTap: () => context.pushNamed(CodeOfEthicsScreen.id),
                      ),
                      ProfileTile(
                        icon: Icons.description,
                        title: "Constitution",
                        subtitle: "Association governing document",
                        onTap: () => context.pushNamed(ConstitutionScreen.id),
                      ),
                      ProfileTile(
                        icon: Icons.assignment,
                        title: "Membership Agreement",
                        subtitle: "Terms and obligations",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MembershipAgreementScreen(
                              applicationData: {},
                            ),
                          ),
                        ),
                      ),
                    ]),

                    Gap(32.h),
                    // Logout Button
                    CustomButton(
                      text: "Logout",
                      backgroundColor: Colors.redAccent,
                      leadingIcon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _handleLogout,
                    ),

                    Gap(40.h),
                    // Footer Logo/Text
                    Center(
                      child: Column(
                        children: <Widget>[
                          const CustomText(
                            "C.Q.A.A.G",
                            variant: TextVariant.headlineMedium,
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText(
                            "Cashew Quality Analysts Association Ghana\nGuardians of Ghana's Cashew Quality",
                            variant: TextVariant.bodySmall,
                            textAlign: TextAlign.center,
                            color: colorScheme.secondary.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                    Gap(20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show language selection dialog
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "Select Language",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("English"),
              trailing: _selectedLanguage == 'English' ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'English';
                });
                context.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("French"),
              trailing: _selectedLanguage == 'French' ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'French';
                });
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper to wrap items in a themed card look
  Widget _buildCard(BuildContext context, List<Widget> children) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
