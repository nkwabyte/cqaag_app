import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cqaag_app/index.dart';

// A section header like "Account" or "App Settings"
class ProfileSectionHeader extends StatelessWidget {
  final String title;
  const ProfileSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: CustomText(
        title,
        variant: TextVariant.headlineMedium,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// A generic tile for profile items (Edit Profile, Change Password, etc.)
class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: colorScheme.secondary, size: 22.r),
      ),
      title: CustomText(
        title,
        variant: TextVariant.bodySmall,
        fontWeight: FontWeight.w600,
      ),
      subtitle: subtitle != null
          ? CustomText(
              subtitle!,
              variant: TextVariant.bodySmall,
              color: colorScheme.secondary,
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: colorScheme.secondary,
            size: 20.r,
          ),
    );
  }
}
