import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:cqaag_app/index.dart';
import 'package:cqaag_app/core/services/membership_card_pdf_service.dart';

class MembershipCardScreen extends ConsumerStatefulWidget {
  static const String id = 'membership_card_screen';

  const MembershipCardScreen({super.key});

  @override
  ConsumerState<MembershipCardScreen> createState() => _MembershipCardScreenState();
}

class _MembershipCardScreenState extends ConsumerState<MembershipCardScreen> {
  DateTime _statusReadAt = DateTime.now();
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _statusReadAt = DateTime.now();
  }

  Future<void> _handleUpdatePhoto(AppUser user) async {
    final file = await ImageSourcePicker.pick(
      context,
      useFrontCamera: true,
      cameraLabel: 'Take a portrait photo',
      galleryLabel: 'Choose from gallery',
      allowFiles: false,
    );
    if (file == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final cloudinary = ref.read(cloudinaryServiceProvider);
      final url = await cloudinary.uploadAvatar(file);
      await ref.read(userServiceProvider).updateUserData(user.id, {
        'profile_picture': url,
        'photo_updated_at': DateTime.now().toIso8601String(),
      });
      // Refresh current user
      ref.invalidate(currentUserProfileProvider);
      if (mounted) {
        CustomSnackBar.success(context, message: 'Card photo updated successfully');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, message: 'Failed to update photo: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  Future<void> _handlePrintOrSavePdf(AppUser user) async {
    try {
      final pdfService = MembershipCardPdfService();
      final pdfBytes = await pdfService.generateCardA6(user);
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'CQAAG_Membership_Card_${user.effectiveMemberCode}.pdf',
      );
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, message: 'Error generating card PDF: $e');
      }
    }
  }

  void _handleShareLink(AppUser user) {
    Share.share(
      'CQAAG Official Digital Membership Card verification for ${user.firstName} ${user.lastName} (${user.effectiveMemberCode}):\n${user.verificationQrUrl}',
      subject: 'CQAAG Member Verification - ${user.effectiveMemberCode}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('My Digital Membership Card'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share verification link',
            onPressed: () {
              final user = userAsync.value;
              if (user != null) _handleShareLink(user);
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print / Save A6 PDF',
            onPressed: () {
              final user = userAsync.value;
              if (user != null) _handlePrintOrSavePdf(user);
            },
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading member data: $err')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User profile not found'));
          }

          final isGoodStanding = user.isGoodStanding;
          final isHibernated = user.membershipStatus == MembershipStatus.hibernated;
          final isSuspended = user.membershipStatus == MembershipStatus.suspended;

          final statusLabel = isSuspended
              ? 'SUSPENDED'
              : (isHibernated ? 'HIBERNATED' : (isGoodStanding ? 'GOOD STANDING' : 'PENDING ACTIVATION'));

          final statusColor = isSuspended
              ? Colors.amber.shade800
              : (isHibernated ? Colors.grey.shade700 : (isGoodStanding ? const Color(0xFF1B5E20) : Colors.orange.shade800));

          final statusIcon = isGoodStanding
              ? Icons.check_circle
              : (isHibernated ? Icons.pause_circle_outline : Icons.warning_amber_rounded);

          final memberSinceStr = user.memberSince != null
              ? DateFormat('d MMM yyyy').format(user.memberSince!)
              : 'Registered Member';

          final readAtStr = DateFormat('d MMM yyyy, HH:mm').format(_statusReadAt);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Digital Membership Card (Figure 4, Spec Section 9)
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Green Band Header
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0A3D18), Color(0xFF1B5E20)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/cqaag_logo.png',
                                width: 36.r,
                                height: 36.r,
                                errorBuilder: (ctx, err, stack) => Icon(
                                  Icons.shield,
                                  color: Colors.amber,
                                  size: 32.r,
                                ),
                              ),
                              Gap(12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "CASHEW QUALITY ANALYSTS' ASSOC. GHANA",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      'OFFICIAL DIGITAL MEMBERSHIP CARD',
                                      style: TextStyle(
                                        color: Colors.amber.shade200,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Card Body
                        Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Photo Avatar
                                  Stack(
                                    children: [
                                      Container(
                                        width: 80.r,
                                        height: 80.r,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFF1B5E20), width: 2),
                                          color: Colors.grey.shade100,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: (user.profilePicture.isNotEmpty && !user.profilePicture.contains('gravatar.com'))
                                            ? CachedNetworkImage(
                                                imageUrl: user.profilePicture,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => const Center(
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                                errorWidget: (context, url, error) => _buildAvatarFallback(user),
                                              )
                                            : _buildAvatarFallback(user),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: _isUploadingPhoto ? null : () => _handleUpdatePhoto(user),
                                          child: CircleAvatar(
                                            radius: 13.r,
                                            backgroundColor: const Color(0xFF1B5E20),
                                            child: _isUploadingPhoto
                                                ? SizedBox(
                                                    width: 12.r,
                                                    height: 12.r,
                                                    child: const CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Icon(Icons.camera_alt, color: Colors.white, size: 14.r),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gap(14.w),

                                  // Name and Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${user.firstName} ${user.lastName}'.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        Gap(4.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F5E9),
                                            borderRadius: BorderRadius.circular(6.r),
                                            border: Border.all(color: const Color(0xFFA5D6A7)),
                                          ),
                                          child: Text(
                                            user.effectiveMemberCode,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1B5E20),
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                        Gap(6.h),
                                        Text(
                                          'Category: ${user.membershipCategory ?? "Full Member"}',
                                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade800),
                                        ),
                                        Text(
                                          'Chapter: ${user.chapter ?? user.region ?? "National"}',
                                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade800),
                                        ),
                                        if (user.companyName != null && user.companyName!.isNotEmpty) ...[
                                          Text(
                                            'Company: ${user.companyName}',
                                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                                          ),
                                          if (user.representativeName != null && user.representativeName!.isNotEmpty)
                                            Text(
                                              'Representative: ${user.representativeName}',
                                              style: TextStyle(fontSize: 10.5.sp, color: Colors.grey.shade700),
                                            ),
                                        ],
                                        Text(
                                          'Member Since: $memberSinceStr',
                                          style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Gap(16.h),

                              // Status Chip
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(statusIcon, color: Colors.white, size: 16.r),
                                    Gap(6.w),
                                    Text(
                                      statusLabel,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Gap(16.h),

                              // Center QR Code
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.r),
                                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.04),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: QrImageView(
                                        data: user.verificationQrUrl,
                                        version: QrVersions.auto,
                                        size: 150.r,
                                        gapless: true,
                                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                                      ),
                                    ),
                                    Gap(6.h),
                                    Text(
                                      'Scan to verify credentials on cqaaggh.org',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Card Footer Line
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          color: const Color(0xFFF1F5F9),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status read on $readAtStr',
                                style: TextStyle(
                                  fontSize: 9.5.sp,
                                  color: Colors.grey.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Text(
                                'Act 772 / Act 843',
                                style: TextStyle(
                                  fontSize: 9.5.sp,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Gap(20.h),

                // Action Buttons
                ElevatedButton.icon(
                  onPressed: () => _handlePrintOrSavePdf(user),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Download / Print A6 Card (PDF)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
                Gap(10.h),
                OutlinedButton.icon(
                  onPressed: () => _handleShareLink(user),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share Verification Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
                Gap(10.h),
                TextButton.icon(
                  onPressed: _isUploadingPhoto ? null : () => _handleUpdatePhoto(user),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Change Card Photograph'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarFallback(AppUser user) {
    final initials = '${user.firstName.isNotEmpty ? user.firstName[0] : ""}${user.lastName.isNotEmpty ? user.lastName[0] : ""}';
    return Container(
      color: const Color(0xFFE8F5E9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              initials.isNotEmpty ? initials : 'CQ',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
              ),
            ),
            Text(
              'Add photo',
              style: TextStyle(fontSize: 8.sp, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
