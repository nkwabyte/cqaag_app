import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable avatar widget that enforces the fallback hierarchy:
/// 1. User uploaded profile picture (if non-null, non-empty, and not gravatar/placeholder)
/// 2. User account verification selfie photo (if non-null, non-empty)
/// 3. Default gravatar / network profile picture (if present)
/// 4. Placeholder initial / person icon
class AppAvatar extends StatelessWidget {
  final String? profilePicture;
  final String? selfieUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.profilePicture,
    this.selfieUrl,
    this.name,
    this.radius = 24,
    this.backgroundColor,
  });

  /// Resolves the effective avatar image URL according to hierarchy:
  /// 1. Custom account profile picture (if uploaded & non-default)
  /// 2. Verification selfie photo (if uploaded)
  /// 3. Default profile picture / gravatar URL (if present)
  /// 4. Fallback placeholder icon
  static String? resolveAvatarUrl({String? profilePicture, String? selfieUrl}) {
    // Check custom account profile picture first
    if (profilePicture != null &&
        profilePicture.isNotEmpty &&
        !profilePicture.contains('gravatar.com/avatar/?d=identicon') &&
        !profilePicture.contains('via.placeholder.com')) {
      return profilePicture;
    }

    // Check account verification selfie photo second
    if (selfieUrl != null && selfieUrl.isNotEmpty) {
      return selfieUrl;
    }

    // Fallback to profile picture (e.g. gravatar) if present
    if (profilePicture != null && profilePicture.isNotEmpty) {
      return profilePicture;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = resolveAvatarUrl(
      profilePicture: profilePicture,
      selfieUrl: selfieUrl,
    );

    final colorScheme = Theme.of(context).colorScheme;
    final diameter = radius * 2;

    Widget placeholderWidget = Container(
      width: diameter.r,
      height: diameter.r,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: name != null && name!.trim().isNotEmpty
            ? Text(
                name!.trim()[0].toUpperCase(),
                style: TextStyle(
                  fontSize: (radius * 0.8).sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              )
            : Icon(
                Icons.person,
                size: radius.r,
                color: colorScheme.primary,
              ),
      ),
    );

    if (effectiveUrl == null || effectiveUrl.isEmpty) {
      return ClipOval(child: placeholderWidget);
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: effectiveUrl,
        width: diameter.r,
        height: diameter.r,
        fit: BoxFit.cover,
        placeholder: (context, url) => placeholderWidget,
        errorWidget: (context, url, error) => placeholderWidget,
      ),
    );
  }
}
