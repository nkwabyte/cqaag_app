import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static final String id = 'profile_screen';
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;
  String _selectedLanguage = 'English';
  bool _autoSyncEnabled = true;
  bool _offlineModeEnabled = false;

  Future<void> _handleAvatarUpload() async {
    try {
      final picked = await ImageSourcePicker.pick(
        context,
        useFrontCamera: true,
      );

      if (!mounted) return;

      if (picked != null) {
        setState(() => _isUploading = true);

        final file = picked;
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
                        Consumer(
                          builder: (context, ref, child) {
                            final currentUser = ref.watch(currentUserProfileProvider).value;
                            return AppAvatar(
                              profilePicture: currentUser?.profilePicture,
                              selfieUrl: currentUser?.verification?.selfieUrl,
                              name: currentUser?.firstName,
                              radius: 55,
                            );
                          },
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

                    // Membership Application & Payment Status Card
                    Consumer(
                      builder: (context, ref, child) {
                        final membershipState = ref.watch(membershipControllerProvider).value;
                        final myApp = membershipState?.myApplication;

                        if (myApp != null && (myApp.status == ApplicationStatus.submitted || myApp.status == ApplicationStatus.underReview || myApp.status == ApplicationStatus.draft)) {
                          final isUnpaid = myApp.paymentStatus == 'unpaid';

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: isUnpaid ? Colors.amber.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isUnpaid ? Colors.amber.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isUnpaid ? Icons.pending_actions : Icons.hourglass_top,
                                      color: isUnpaid ? Colors.amber.shade800 : Colors.blue,
                                      size: 28.r,
                                    ),
                                    Gap(12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            isUnpaid ? "Payment Evidence Pending" : "Application Under Review",
                                            variant: TextVariant.bodyLarge,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          CustomText(
                                            isUnpaid
                                                ? "Your registration is submitted! Upload your payment screenshot or wait for admin review."
                                                : "Your application and payment evidence are awaiting administrator verification.",
                                            variant: TextVariant.bodySmall,
                                            color: isUnpaid ? Colors.amber.shade900 : Colors.blue,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(12.h),
                                Row(
                                  children: [
                                    if (isUnpaid) ...[
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            context.pushNamed(
                                              MembershipPaymentScreen.id,
                                              extra: {'existing_application_id': myApp.id},
                                            );
                                          },
                                          icon: const Icon(Icons.upload_file, color: Colors.white, size: 16),
                                          label: const Text("Pay / Upload"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.amber.shade800,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                          ),
                                        ),
                                      ),
                                      Gap(8.w),
                                    ],
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _confirmWithdrawApplication(context, ref, myApp.id),
                                        icon: Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 16),
                                        label: Text(
                                          "Withdraw",
                                          style: TextStyle(color: Colors.red.shade700, fontSize: 13.sp),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.red.shade300),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }

                        if (myApp != null && myApp.status == ApplicationStatus.approved) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.workspace_premium, color: Colors.green, size: 36.r),
                                Gap(12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const CustomText(
                                        "CQAAG Membership Approved",
                                        variant: TextVariant.bodyLarge,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      CustomText(
                                        "Congratulations! Your official CQAAG membership application has been approved.",
                                        variant: TextVariant.bodySmall,
                                        color: Colors.green.shade800,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),

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
                      Consumer(
                        builder: (context, ref, child) {
                          final membershipState = ref.watch(membershipControllerProvider).value;
                          final myApp = membershipState?.myApplication;

                          return ProfileTile(
                            icon: Icons.card_membership_outlined,
                            title: "Membership Application",
                            subtitle: myApp != null
                                ? "Status: ${myApp.status.displayName}"
                                : "Apply to be a member",
                            onTap: () => context.pushNamed(MembershipApplicationScreen.id),
                          );
                        },
                      ),
                    ]),

                    Gap(24.h),
                    const ProfileSectionHeader(title: "App Settings"),
                    _buildCard(context, [
                      ProfileTile(
                        icon: Icons.notifications_outlined,
                        title: "System Bulletins & Notifications",
                        subtitle: "View broadcast alerts & messages",
                        onTap: () {
                          context.pushNamed(NotificationsScreen.id);
                        },
                        trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.secondary),
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
                        icon: Icons.privacy_tip_outlined,
                        title: "Privacy Policy",
                        subtitle: "Data protection & privacy policy",
                        onTap: () => context.pushNamed(PrivacyPolicyScreen.id),
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
            Material(
              color: Colors.transparent,
              child: ListTile(
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
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmWithdrawApplication(BuildContext context, WidgetRef ref, String applicationId) async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          "Withdraw Application?",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          "Are you sure you want to withdraw your membership application? This will cancel your pending submission and allow you to re-apply whenever you are ready.",
          style: TextStyle(
            fontSize: 14.sp,
            color: colorScheme.secondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              "Keep Application",
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              "Withdraw",
              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(membershipControllerProvider.notifier).withdrawApplication(applicationId);
        if (context.mounted) {
          CustomSnackBar.success(context, message: "Membership application withdrawn successfully.");
        }
      } catch (e) {
        if (context.mounted) {
          CustomSnackBar.error(context, message: "Failed to withdraw application: ${e.toString()}");
        }
      }
    }
  }

  // Helper to wrap items in a themed card look
  Widget _buildCard(BuildContext context, List<Widget> children) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(children: children),
        ),
      ),
    );
  }
}
