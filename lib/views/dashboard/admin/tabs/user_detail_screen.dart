import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cqaag_app/index.dart';

class AdminUserDetailScreen extends ConsumerStatefulWidget {
  static const String id = 'admin_user_detail_screen';
  final AppUser user;

  const AdminUserDetailScreen({super.key, required this.user});

  @override
  ConsumerState<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends ConsumerState<AdminUserDetailScreen> {
  late AppUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = ref.read(userControllerProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const CustomText(
          "User Details",
          variant: TextVariant.headlineMedium,
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundImage: CachedNetworkImageProvider(_user.profilePicture),
                    onBackgroundImageError: (ctx, err) {},
                    child: CustomText(_user.firstName[0], variant: TextVariant.headlineMedium),
                  ),
                  Gap(16.h),
                  CustomText(
                    "${_user.firstName} ${_user.lastName}",
                    variant: TextVariant.headlineMedium,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(4.h),
                  CustomText(
                    _user.email,
                    variant: TextVariant.bodyMedium,
                    color: colorScheme.secondary,
                  ),
                  Gap(8.h),
                  _buildStatusBadge(_user.status, colorScheme),
                ],
              ),
            ),

            Gap(32.h),

            // Info Section
            _buildInfoCard(
              context,
              title: "Contact Information",
              children: [
                _buildInfoRow("Phone", _user.phoneNumber ?? "N/A"),
                // AppUser actually doesn't typically have address/district fields based on common patterns unless added
                // Checking user model in next step to be sure, using generic safe access for now
              ],
            ),

            Gap(20.h),

            _buildInfoCard(
              context,
              title: "System Status",
              children: [
                _buildInfoRow("User ID", _user.id),
                _buildInfoRow("Verification", _user.verificationStatus.value),
                _buildInfoRow("Membership", _user.membershipStatus.value),
                _buildInfoRow("Role", _user.isAdmin ? "Admin" : "Standard User"),
              ],
            ),

            Gap(20.h),

            // Editable Role Section
            _RoleEditSection(
              user: _user,
              onRoleChanged: (newRole) {
                if (mounted) {
                  setState(() {
                    _user = _user.copyWith(role: newRole);
                  });
                }
              },
            ),

            if (_user.verification != null) ...[
              Gap(20.h),
              _buildInfoCard(
                context,
                title: "Identity Verification",
                children: <Widget>[
                  _buildInfoRow("Ghana Card Number", _user.verification!.idCardNumber),
                  Gap(12.h),
                  CustomText("Documents", variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
                  Gap(8.h),
                  Row(
                    children: <Widget>[
                      _buildDocumentThumbnail(context, "Front", _user.verification!.idCardFrontUrl),
                      Gap(12.w),
                      _buildDocumentThumbnail(context, "Back", _user.verification!.idCardBackUrl),
                      Gap(12.w),
                      _buildDocumentThumbnail(context, "Selfie", _user.verification!.selfieUrl),
                    ],
                  ),
                ],
              ),
              if (_user.verificationStatus != VerificationStatus.verified && _user.verification != null) ...[
                Gap(18.h),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Verify User",
                    backgroundColor: Colors.green,
                    onPressed: () => _showVerifyConfirmation(context, ref, _user),
                  ),
                ),
              ],
            ],

            Gap(40.h),

            // Admin Actions
            CustomText(
              "Admin Actions",
              variant: TextVariant.headlineMedium,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            Gap(16.h),

            Row(
              children: <Widget>[
                Expanded(
                  child: CustomButton(
                    text: _user.isAdmin ? "Revoke Admin Access" : "Grant Admin Access",
                    variant: _user.isAdmin ? ButtonVariant.outlined : ButtonVariant.filled,
                    backgroundColor: _user.isAdmin ? null : colorScheme.primary,
                    borderColor: _user.isAdmin ? Colors.red : null,
                    textColor: _user.isAdmin ? Colors.red : Colors.white,
                    onPressed: () => _showAdminToggleConfirmation(context, ref, _user),
                  ),
                ),
              ],
            ),
            Gap(12.h),

            Row(
              children: <Widget>[
                Expanded(
                  child: CustomButton(
                    text: _user.status == AppUserStatus.suspended ? "Unsuspend" : "Suspend User",
                    variant: ButtonVariant.outlined,
                    backgroundColor: _user.status == AppUserStatus.suspended ? Colors.orange.withValues(alpha: 0.1) : null,
                    textColor: Colors.orange,
                    borderColor: Colors.orange,
                    onPressed: () async {
                      final newStatus = _user.status == AppUserStatus.suspended ? AppUserStatus.active : AppUserStatus.suspended;
                      await controller.updateUserStatus(_user.id, newStatus);
                      if (mounted) {
                        setState(() {
                          _user = _user.copyWith(status: newStatus);
                        });
                      }
                    },
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: CustomButton(
                    text: _user.status == AppUserStatus.banned ? "Unban" : "Ban User",
                    backgroundColor: _user.status == AppUserStatus.banned ? Colors.grey : Colors.red,
                    onPressed: () async {
                      final newStatus = _user.status == AppUserStatus.banned ? AppUserStatus.active : AppUserStatus.banned;
                      await controller.updateUserStatus(_user.id, newStatus);
                      if (mounted) {
                        setState(() {
                          _user = _user.copyWith(status: newStatus);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppUserStatus status, ColorScheme colorScheme) {
    Color color;
    switch (status) {
      case AppUserStatus.active:
        color = Colors.green;
        break;
      case AppUserStatus.suspended:
        color = Colors.orange;
        break;
      case AppUserStatus.banned:
        color = Colors.red;
        break;
      case AppUserStatus.inactive:
        color = Colors.grey;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: CustomText(
        status.value.toUpperCase(),
        variant: TextVariant.bodySmall,
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> children}) {
    // If no children, don't show card
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomText(title, variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 100.w,
            child: CustomText(label, variant: TextVariant.bodyMedium, color: Colors.grey[600]),
          ),
          Expanded(
            child: CustomText(value, variant: TextVariant.bodyMedium, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentThumbnail(BuildContext context, String label, String url) {
    return Expanded(
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onTap: () => _showFullImage(context, url),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(url),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Gap(4.h),
          CustomText(label, variant: TextVariant.bodySmall),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => context.pop(),
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: url,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _showVerifyConfirmation(BuildContext context, WidgetRef ref, AppUser user) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "Confirm Verification",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Text(
          "Are you sure you want to verify ${user.firstName} ${user.lastName}?",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => _verifyConfirmation(context, ref, user),
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  void _verifyConfirmation(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
  ) async {
    debugPrint("=== Starting verification process ===");
    context.pop(); // Close dialog
    debugPrint("Closed confirmation dialog");

    AppDialogs.showLoadingDialog(context, message: "Verifying user...");
    debugPrint("Showing loading dialog");

    // Capture navigator before async operations to avoid context unmounting
    final navigator = Navigator.of(context, rootNavigator: true);

    try {
      debugPrint("Getting current user...");
      final currentUser = ref.read(authServiceProvider).currentUser;
      debugPrint("Current user UID: ${currentUser?.uid}");

      debugPrint("Creating verification data...");
      final verificationData = user.verification!.copyWith(
        verifiedBy: currentUser?.uid,
        dateVerified: DateTime.now(),
      );
      debugPrint("Verification data created");

      debugPrint("Calling updateUserData for user: ${user.id}");
      await ref.read(userServiceProvider).updateUserData(
        user.id,
        {
          'verification_status': VerificationStatus.verified.name,
          'verification': verificationData.toJson(),
        },
      );
      debugPrint("updateUserData completed successfully");

      // Use captured navigator instead of context
      debugPrint("Closing loading dialog");
      navigator.pop(); // Close loading
      debugPrint("Showing success message");

      if (context.mounted) {
        if (mounted) {
          setState(() {
            _user = _user.copyWith(
              verificationStatus: VerificationStatus.verified,
              verification: verificationData,
            );
          });
        }
        CustomSnackBar.success(context, message: "User verified successfully");
        debugPrint("=== Verification completed successfully ===");
      }
    } catch (e, stackTrace) {
      debugPrint("=== Verification error occurred ===");
      debugPrint("Error: $e");
      debugPrint("Stack trace: $stackTrace");

      // Use captured navigator instead of context
      debugPrint("Closing loading dialog after error");
      navigator.pop();
      debugPrint("Showing error message");

      if (context.mounted) {
        CustomSnackBar.error(context, message: "Verification failed: $e");
      }
      debugPrint("=== Error handling completed ===");
    }
  }

  void _showAdminToggleConfirmation(BuildContext parentContext, WidgetRef ref, AppUser user) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(user.isAdmin ? "Revoke Admin Access?" : "Grant Admin Access?"),
        content: Text(
          user.isAdmin ? "This user will no longer be able to access the admin dashboard." : "This user will gain full access to the admin dashboard.",
        ),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(), child: const Text("Cancel")),
          TextButton(
            onPressed: () => _performAdminToggle(parentContext, dialogContext, ref, user),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _performAdminToggle(
    BuildContext parentContext,
    BuildContext dialogContext,
    WidgetRef ref,
    AppUser user,
  ) async {
    dialogContext.pop(); // Close dialog

    if (!parentContext.mounted) return;
    AppDialogs.showLoadingDialog(parentContext, message: "Updating access...");

    final navigator = Navigator.of(parentContext, rootNavigator: true);

    try {
      await ref.read(userServiceProvider).updateUserData(
        user.id,
        {'is_admin': !user.isAdmin},
      );

      navigator.pop(); // Close loading

      if (parentContext.mounted) {
        if (mounted) {
          setState(() {
            _user = _user.copyWith(isAdmin: !user.isAdmin);
          });
        }
        CustomSnackBar.success(
          parentContext,
          message: user.isAdmin ? "Admin access revoked" : "Admin access granted",
        );
      }
    } catch (e) {
      navigator.pop();
      if (parentContext.mounted) {
        CustomSnackBar.error(parentContext, message: "Failed to update access: $e");
      }
    }
  }
}

// Role Edit Section Widget
class _RoleEditSection extends ConsumerStatefulWidget {
  final AppUser user;
  final ValueChanged<String?>? onRoleChanged;

  const _RoleEditSection({required this.user, this.onRoleChanged});

  @override
  ConsumerState<_RoleEditSection> createState() => _RoleEditSectionState();
}

class _RoleEditSectionState extends ConsumerState<_RoleEditSection> {
  late TextEditingController _roleController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController(text: widget.user.role ?? '');
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _saveRole() async {
    setState(() => _isSaving = true);

    try {
      await ref.read(userServiceProvider).updateUserData(
        widget.user.id,
        {'role': _roleController.text.trim().isEmpty ? null : _roleController.text.trim()},
      );

      if (mounted) {
        // Notify parent
        widget.onRoleChanged?.call(_roleController.text.trim().isEmpty ? null : _roleController.text.trim());

        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        CustomSnackBar.success(context, message: 'Role updated successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        CustomSnackBar.error(context, message: 'Failed to update role: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                'User Role',
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.bold,
              ),
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => setState(() => _isEditing = true),
                  tooltip: 'Edit role',
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          if (_isEditing)
            Column(
              children: [
                TextField(
                  controller: _roleController,
                  decoration: InputDecoration(
                    hintText: 'Enter user role (e.g., Quality Inspector, Field Officer)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                  enabled: !_isSaving,
                ),
                Gap(12.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        variant: ButtonVariant.outlined,
                        onPressed: () {
                          if (_isSaving) return;
                          setState(() {
                            _isEditing = false;
                            _roleController.text = widget.user.role ?? '';
                          });
                        },
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: CustomButton(
                        text: 'Save',
                        isLoading: _isSaving,
                        onPressed: () {
                          if (_isSaving) return;
                          _saveRole();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            CustomText(
              widget.user.role?.isEmpty ?? true ? 'No role assigned' : widget.user.role!,
              variant: TextVariant.bodyMedium,
              color: widget.user.role?.isEmpty ?? true ? Colors.grey[600] : null,
              fontStyle: widget.user.role?.isEmpty ?? true ? FontStyle.italic : null,
            ),
        ],
      ),
    );
  }
}
