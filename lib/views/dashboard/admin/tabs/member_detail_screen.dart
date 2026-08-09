import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class AdminMemberDetailScreen extends ConsumerStatefulWidget {
  static const String id = 'admin_member_detail_screen';
  final MembershipApplication application;

  const AdminMemberDetailScreen({super.key, required this.application});

  @override
  ConsumerState<AdminMemberDetailScreen> createState() => _AdminMemberDetailScreenState();
}

class _AdminMemberDetailScreenState extends ConsumerState<AdminMemberDetailScreen> {
  final TextEditingController _reviewNotesController = TextEditingController();
  bool _isProcessing = false;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate review notes if they exist
    if (widget.application.reviewNotes != null) {
      _reviewNotesController.text = widget.application.reviewNotes!;
    }
  }

  @override
  void dispose() {
    _reviewNotesController.dispose();
    super.dispose();
  }

  Future<void> _handleApprove() async {
    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(
      title: 'Approve Application',
      message: 'Are you sure you want to approve this membership application?',
      confirmText: 'Approve',
      confirmColor: Colors.green,
    );

    if (!confirmed) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final user = ref.read(authServiceProvider).currentUser;
      final membershipService = ref.read(membershipServiceProvider);

      await membershipService.updateApplicationStatus(
        applicationId: widget.application.id,
        status: ApplicationStatus.approved,
        reviewNotes: _reviewNotesController.text.trim().isEmpty ? null : _reviewNotesController.text.trim(),
        reviewerId: user?.uid,
      );

      if (!mounted) return;

      context.pop();
      CustomSnackBar.success(
        context,
        message: 'Application approved successfully!',
        title: 'Success',
      );
    } catch (e) {
      if (!mounted) return;

      CustomSnackBar.error(
        context,
        message: 'Failed to approve application: ${e.toString()}',
        title: 'Error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handleReject() async {
    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(
      title: 'Reject Application',
      message:
          'Are you sure you want to reject this membership application? Please provide a reason in the review notes.',
      confirmText: 'Reject',
      confirmColor: Colors.red,
    );

    if (!mounted) return;
    if (!confirmed) return;

    // Validate that review notes are provided for rejection
    if (_reviewNotesController.text.trim().isEmpty) {
      CustomSnackBar.warning(
        context,
        message: 'Please provide a reason for rejection in the review notes.',
        title: 'Review Notes Required',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final user = ref.read(authServiceProvider).currentUser;
      final membershipService = ref.read(membershipServiceProvider);

      await membershipService.updateApplicationStatus(
        applicationId: widget.application.id,
        status: ApplicationStatus.rejected,
        reviewNotes: _reviewNotesController.text.trim(),
        reviewerId: user?.uid,
      );

      if (!mounted) return;

      context.pop();
      CustomSnackBar.success(
        context,
        message: 'Application rejected.',
        title: 'Success',
      );
    } catch (e) {
      if (!mounted) return;

      // Show error snackbar
      CustomSnackBar.error(
        context,
        message: 'Failed to reject application: ${e.toString()}',
        title: 'Error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              confirmText,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = ref.watch(currentUserProfileProvider).value;
    final isCallerAdmin = currentUser?.isAdmin ?? false;
    final isReviewed =
        widget.application.status == ApplicationStatus.approved ||
        widget.application.status == ApplicationStatus.rejected;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const CustomText("Application Details", variant: TextVariant.headlineMedium),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                // Header Status
                Container(
                  padding: EdgeInsets.all(16.r),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.application.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: _getStatusColor(widget.application.status).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final userState = ref.watch(userControllerProvider).value;
                          final user = userState?.allUsers.where((u) => u.id == widget.application.userId).firstOrNull;

                          return AppAvatar(
                            profilePicture: user?.profilePicture,
                            selfieUrl: user?.verification?.selfieUrl,
                            name: widget.application.firstName,
                            radius: 40,
                          );
                        },
                      ),
                      Gap(12.h),
                      CustomText(
                        "Status: ${widget.application.status.displayName}",
                        variant: TextVariant.headlineMedium,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(widget.application.status),
                      ),
                      if (widget.application.submittedAt != null) ...[
                        Gap(4.h),
                        CustomText(
                          "Submitted on ${widget.application.submittedAt.toString().split(' ')[0]}",
                          variant: TextVariant.bodySmall,
                          color: colorScheme.secondary,
                        ),
                      ],
                      if (widget.application.reviewedAt != null) ...[
                        Gap(4.h),
                        CustomText(
                          "Reviewed on ${widget.application.reviewedAt.toString().split(' ')[0]}",
                          variant: TextVariant.bodySmall,
                          color: colorScheme.secondary,
                        ),
                      ],
                    ],
                  ),
                ),

                Gap(20.h),

                _buildInfoCard(
                  context,
                  title: "Applicant Info",
                  children: [
                    _buildInfoRow("Name", "${widget.application.firstName} ${widget.application.lastName}"),
                    _buildInfoRow("Title", widget.application.title.displayName),
                    _buildInfoRow("Gender", widget.application.gender.displayName),
                    _buildInfoRow("Category", widget.application.membershipCategory.displayName),
                    _buildInfoRow("Email", widget.application.emailAddress),
                    _buildInfoRow("Phone", widget.application.phoneNumberPrimary),
                    if (widget.application.phoneNumberSecondary != null)
                      _buildInfoRow("Alt Phone", widget.application.phoneNumberSecondary!),
                    _buildInfoRow("Address", widget.application.residentialAddress),
                    _buildInfoRow("Date of Birth", widget.application.dateOfBirth.split('T')[0]),
                    _buildInfoRow("Nationality", widget.application.nationality),
                    _buildInfoRow("Region/District", widget.application.regionDistrict),
                    if (widget.application.ghanaCardNumber != null)
                      _buildInfoRow("Ghana Card", widget.application.ghanaCardNumber!),
                  ],
                ),

                Gap(16.h),

                _buildInfoCard(
                  context,
                  title: "Professional Details",
                  children: [
                    _buildInfoRow("Employer", widget.application.employerOrganization),
                    _buildInfoRow("Job Title", widget.application.currentJobTitle),
                  ],
                ),

                Gap(16.h),

                _buildPaymentCard(context, colorScheme),

                Gap(20.h),

                // Review Notes Section
                Container(
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
                      CustomText(
                        "Review Notes",
                        variant: TextVariant.bodyLarge,
                        fontWeight: FontWeight.bold,
                      ),
                      Gap(12.h),
                      TextField(
                        controller: _reviewNotesController,
                        maxLines: 4,
                        readOnly: isReviewed,
                        decoration: InputDecoration(
                          hintText: isReviewed
                              ? 'No review notes provided'
                              : 'Enter review notes or feedback for the applicant...',
                          filled: true,
                          fillColor: isReviewed ? Colors.grey[100] : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Gap(40.h),

                // Admin Actions
                if (isCallerAdmin && (widget.application.status == ApplicationStatus.submitted ||
                    widget.application.status == ApplicationStatus.underReview)) ...[
                  CustomText(
                    "Review Actions",
                    variant: TextVariant.headlineMedium,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  Gap(16.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: "Reject",
                          backgroundColor: Colors.red,
                          onPressed: _isProcessing ? () {} : _handleReject,
                        ),
                      ),
                      Gap(12.w),
                      Expanded(
                        child: CustomButton(
                          text: "Approve",
                          backgroundColor: Colors.green,
                          onPressed: _isProcessing ? () {} : _handleApprove,
                        ),
                      ),
                    ],
                  ),
                  Gap(40.h),
                ],
              ],
            ),
          ),

          // Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.submitted:
      case ApplicationStatus.underReview:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Registration payment summary, with verification actions while the payment
  /// is still awaiting a decision.
  Widget _buildPaymentCard(BuildContext context, ColorScheme colorScheme) {
    final app = widget.application;
    final status = app.payment;

    // Applications created before payments existed carry no payment fields.
    if (app.paymentMethod == null && status == PaymentStatus.unpaid) {
      return _buildInfoCard(
        context,
        title: "Registration Payment",
        children: [
          _buildInfoRow("Status", "No payment recorded"),
        ],
      );
    }

    final statusColor = switch (status) {
      PaymentStatus.verified => Colors.green,
      PaymentStatus.pendingVerification => Colors.orange,
      PaymentStatus.rejected => Colors.red,
      PaymentStatus.unpaid => Colors.grey,
    };

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
              const CustomText("Registration Payment", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(color: statusColor, fontSize: 10.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Gap(12.h),
          _buildInfoRow("Amount", app.formattedPaymentAmount ?? "Not recorded"),
          if (app.paymentMethod != null) _buildInfoRow("Method", app.paymentMethod == 'momo' ? 'Mobile Money' : 'Paystack'),
          if (app.paymentMomoNumber != null)
            _buildInfoRow("Paid to", "${app.paymentMomoNetwork ?? ''} ${app.paymentMomoNumber}".trim()),
          _buildInfoRow("Reference", app.paymentReference ?? "Not provided"),

          if (app.paymentEvidenceUrl != null) ...[
            Gap(12.h),
            InkWell(
              onTap: () => _showEvidence(app.paymentEvidenceUrl!),
              child: Row(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 18.r, color: colorScheme.primary),
                  Gap(6.w),
                  CustomText(
                    "View payment evidence",
                    variant: TextVariant.bodyMedium,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ],

          if ((ref.watch(currentUserProfileProvider).value?.isAdmin == true) && status == PaymentStatus.pendingVerification) ...[
            Gap(16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessingPayment ? null : () => _setPaymentStatus(PaymentStatus.rejected),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 44.h),
                      side: BorderSide(color: colorScheme.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: CustomText("Reject Payment", variant: TextVariant.bodyMedium, color: colorScheme.error),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: CustomButton(
                    text: "Verify Payment",
                    isLoading: _isProcessingPayment,
                    height: 44.h,
                    onPressed: _isProcessingPayment ? () {} : () => _setPaymentStatus(PaymentStatus.verified),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showEvidence(String url) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const CustomText("Payment Evidence", variant: TextVariant.bodyLarge),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: url,
                  placeholder: (_, _) => Padding(
                    padding: EdgeInsets.all(32.r),
                    child: const CircularProgressIndicator(),
                  ),
                  errorWidget: (_, _, _) => Padding(
                    padding: EdgeInsets.all(32.r),
                    child: const CustomText("Could not load the evidence image."),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setPaymentStatus(PaymentStatus status) async {
    final verb = status == PaymentStatus.verified ? 'verify' : 'reject';
    final confirmed = await _showConfirmationDialog(
      title: '${verb[0].toUpperCase()}${verb.substring(1)} payment?',
      message: status == PaymentStatus.verified
          ? 'Confirm that this payment was received in the CQAAG Mobile Money account.'
          : 'The applicant will need to submit valid payment evidence.',
      confirmText: status == PaymentStatus.verified ? 'Verify' : 'Reject',
      confirmColor: status == PaymentStatus.verified ? Colors.green : Colors.red,
    );

    if (!confirmed) return;

    setState(() => _isProcessingPayment = true);

    try {
      final admin = ref.read(authServiceProvider).currentUser;
      if (admin == null) throw Exception('Not authenticated');

      await ref.read(membershipServiceProvider).updatePaymentStatus(
        applicationId: widget.application.id,
        status: status,
        verifiedBy: admin.uid,
      );

      if (!mounted) return;
      CustomSnackBar.success(context, message: 'Payment ${status.label.toLowerCase()}.');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, message: 'Could not update payment: $e');
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> children}) {
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
        children: [
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
        children: [
          SizedBox(
            width: 120.w,
            child: CustomText(label, variant: TextVariant.bodyMedium, color: Colors.grey[600]),
          ),
          Expanded(
            child: CustomText(value, variant: TextVariant.bodyMedium, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
