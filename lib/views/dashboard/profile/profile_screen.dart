import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class ProfileScreen extends StatefulWidget {
  static final String id = 'profile_screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 1. Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40.h),
              decoration: BoxDecoration(
                color: colorScheme.onSurface, // darkRed
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60.r),
                  bottomRight: Radius.circular(60.r),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Gap(20.h),
                  // Avatar with Edit Button
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 55.r,
                        backgroundColor: colorScheme.secondary.withValues(alpha: 0.2),
                        child: Icon(Icons.person, size: 60.r, color: Colors.white),
                      ),
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.w),
                        ),
                        child: Icon(Icons.camera_alt, size: 16.r, color: Colors.white),
                      ),
                    ],
                  ),
                  Gap(16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomText("Emmanuel Adjei", variant: TextVariant.displaySmall, color: Colors.white),
                      Gap(8.w),
                      Icon(Icons.verified, color: Colors.blueAccent, size: 20.r),
                    ],
                  ),
                  const CustomText("Field Inspector", variant: TextVariant.bodyMedium, color: Colors.white70),
                  Gap(8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: const CustomText("ID: INS-042", variant: TextVariant.bodySmall, color: Colors.white),
                  ),
                ],
              ),
            ),

            // 2. Profile Content Section
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Details Card
                  _buildCard(context, [
                    const ProfileTile(icon: Icons.phone_outlined, title: "+233 24 123 4567", subtitle: "Phone"),
                    const ProfileTile(icon: Icons.location_on_outlined, title: "Bono East Region", subtitle: "Region"),
                    const ProfileTile(icon: Icons.calendar_today_outlined, title: "January 2024", subtitle: "Joined"),
                  ]),

                  Gap(24.h),
                  const ProfileSectionHeader(title: "Account"),

                  // Verification Banner
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.blue, size: 40.r),
                        Gap(16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CustomText(
                                "Account Verification",
                                variant: TextVariant.bodyLarge,
                                fontWeight: FontWeight.bold,
                              ),
                              CustomText("Verified Analyst", variant: TextVariant.bodySmall, color: Colors.blue),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(12.h),

                  _buildCard(context, [
                    const ProfileTile(icon: Icons.edit_outlined, title: "Edit Profile"),
                    const ProfileTile(icon: Icons.lock_outline, title: "Change Password"),
                  ]),

                  Gap(24.h),
                  const ProfileSectionHeader(title: "App Settings"),
                  _buildCard(context, [
                    ProfileTile(
                      icon: Icons.notifications_outlined,
                      title: "Notifications",
                      subtitle: "Push notifications",
                      trailing: Switch(
                        value: true,
                        onChanged: (v) {},
                        activeThumbColor: Colors.green,
                      ),
                    ),
                    const ProfileTile(icon: Icons.language_outlined, title: "Language", subtitle: "English"),
                  ]),

                  Gap(24.h),
                  const ProfileSectionHeader(title: "Data & Storage"),
                  _buildCard(context, [
                    ProfileTile(
                      icon: Icons.sync,
                      title: "Auto Sync",
                      subtitle: "Sync when connected",
                      trailing: Switch(
                        value: true,
                        onChanged: (v) {},
                        activeThumbColor: Colors.green,
                      ),
                    ),
                    ProfileTile(
                      icon: Icons.cloud_off,
                      title: "Offline Mode",
                      subtitle: "Save data locally",
                      trailing: Switch(value: false, onChanged: (v) {}),
                    ),
                  ]),

                  Gap(32.h),
                  // Logout Button
                  CustomButton(
                    text: "Logout",
                    backgroundColor: Colors.redAccent,
                    leadingIcon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {},
                  ),

                  Gap(40.h),
                  // Footer Logo/Text
                  Center(
                    child: Column(
                      children: [
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
