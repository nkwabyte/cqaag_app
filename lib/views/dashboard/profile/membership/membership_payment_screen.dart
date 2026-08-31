import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart' as uuid_pkg;

import 'package:cqaag_app/index.dart';
import 'package:cqaag_app/models/membership/membership_category.dart' as membership_models;

/// Final step of registration: pay the fee, then submit.
///
/// The application is only written to Firestore once payment has been provided,
/// so a member is registered pending admin approval rather than sitting in an
/// unpaid state.
class MembershipPaymentScreen extends ConsumerStatefulWidget {
  static const String id = 'membership_payment_screen';
  final Map<String, dynamic> applicationData;

  const MembershipPaymentScreen({super.key, required this.applicationData});

  @override
  ConsumerState<MembershipPaymentScreen> createState() => _MembershipPaymentScreenState();
}

class _MembershipPaymentScreenState extends ConsumerState<MembershipPaymentScreen> {
  PaymentMethod? _selectedMethod = PaymentMethod.momo;
  File? _evidenceFile;
  final TextEditingController _referenceController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settingsAsync = ref.watch(paymentSettingsProvider);

    // Defaults keep the screen usable even if settings/payment cannot be read.
    final settings = settingsAsync.value ?? PaymentSettings.defaults;
    final isUploadingForExistingApp = widget.applicationData['existing_application_id'] != null;
    final category = _parseMembershipCategory(widget.applicationData['membership_category'] as String?);
    final formattedFee = settings.formattedFeeFor(category);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(colorScheme, formattedFee),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    isUploadingForExistingApp ? "Upload Payment Evidence" : "Choose how to pay",
                    variant: TextVariant.headlineMedium,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(8.h),
                  CustomText(
                    isUploadingForExistingApp
                        ? "Upload evidence of your Mobile Money payment to complete verification of your membership application."
                        : "You can upload your Mobile Money payment evidence now, or skip and upload it later from your profile.",
                    variant: TextVariant.bodyMedium,
                    color: colorScheme.secondary,
                  ),
                  Gap(24.h),

                  _buildMethodCard(
                    colorScheme: colorScheme,
                    method: PaymentMethod.momo,
                    icon: Icons.smartphone_outlined,
                    title: "Pay via Mobile Money",
                    description: "Send the fee to the CQAAG MoMo account and upload your payment evidence.",
                    enabled: true,
                  ),
                  Gap(12.h),
                  _buildMethodCard(
                    colorScheme: colorScheme,
                    method: PaymentMethod.paystack,
                    icon: Icons.credit_card_outlined,
                    title: "Pay with Paystack",
                    description: "Card and instant mobile money. Not available yet — please use Mobile Money.",
                    enabled: false,
                  ),

                  if (_selectedMethod == PaymentMethod.momo) ...[
                    Gap(24.h),
                    _buildMomoInstructions(colorScheme, settings, formattedFee),
                    Gap(24.h),
                    _buildEvidenceUpload(colorScheme),
                    Gap(24.h),
                    _buildReferenceField(colorScheme),
                  ],

                  Gap(32.h),
                  CustomButton(
                    text: _isSubmitting
                        ? "Submitting..."
                        : (_evidenceFile != null
                            ? "Submit Application with Evidence"
                            : (isUploadingForExistingApp ? "Upload Evidence" : "Submit Application (Pay Later)")),
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? () {} : () => _handleSubmit(settings),
                  ),
                  if (!isUploadingForExistingApp && _evidenceFile == null) ...[
                    Gap(12.h),
                    Center(
                      child: CustomText(
                        "Payment is optional right now. You can upload evidence anytime from your Profile.",
                        variant: TextVariant.bodySmall,
                        color: colorScheme.secondary,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  Gap(40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, String formattedFee) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50.r),
          bottomRight: Radius.circular(50.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.pop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 20.r),
                Gap(8.w),
                const CustomText("Back", color: Colors.white),
              ],
            ),
          ),
          Gap(24.h),
          const CustomText("Registration Payment", variant: TextVariant.displaySmall, color: Colors.white),
          Gap(8.h),
          CustomText(
            "Amount due: $formattedFee",
            variant: TextVariant.bodyLarge,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required ColorScheme colorScheme,
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String description,
    required bool enabled,
  }) {
    final selected = _selectedMethod == method;

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: InkWell(
        onTap: enabled ? () => setState(() => _selectedMethod = method) : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary.withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.secondary.withValues(alpha: 0.3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colorScheme.primary, size: 28.r),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: CustomText(title, variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
                        ),
                        if (!enabled) ...[
                          Gap(8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(99.r),
                            ),
                            child: const CustomText("Coming soon", variant: TextVariant.bodySmall),
                          ),
                        ],
                      ],
                    ),
                    Gap(4.h),
                    CustomText(description, variant: TextVariant.bodySmall, color: colorScheme.secondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMomoInstructions(ColorScheme colorScheme, PaymentSettings settings, String formattedFee) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            "Send $formattedFee to",
            variant: TextVariant.bodyLarge,
            fontWeight: FontWeight.bold,
          ),
          Gap(12.h),
          _buildDetailRow("Network", settings.network.label),
          Gap(8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText("Number", variant: TextVariant.bodyMedium, color: colorScheme.secondary),
              Row(
                children: [
                  CustomText(settings.momoNumber, variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
                  Gap(4.w),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: settings.momoNumber));
                      if (mounted) {
                        CustomSnackBar.success(context, message: 'Number copied');
                      }
                    },
                    child: Icon(Icons.copy_outlined, size: 18.r, color: colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
          Gap(8.h),
          _buildDetailRow("Account name", settings.momoAccountName),
          Gap(16.h),
          const Divider(),
          Gap(8.h),
          CustomText(
            "1. Send the exact amount from your Mobile Money wallet.\n"
            "2. Use your full name as the reference.\n"
            "3. Screenshot the confirmation message.\n"
            "4. Upload it below for verification (or upload later).",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
          Gap(16.h),
          // Instant MTN MoMo USSD Prompt button
          CustomButton(
            text: "Request MTN MoMo Prompt",
            backgroundColor: AppColors.primaryGreen,
            textColor: Colors.white,
            leadingIcon: const Icon(Icons.touch_app_outlined, color: Colors.white),
            onPressed: () => _handleMtnMomoPush(settings),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(label, variant: TextVariant.bodyMedium, color: Theme.of(context).colorScheme.secondary),
        Flexible(
          child: CustomText(value, variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEvidenceUpload(ColorScheme colorScheme) {
    final file = _evidenceFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomText("Payment evidence", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
            CustomText("(Optional)", variant: TextVariant.bodySmall, color: colorScheme.secondary),
          ],
        ),
        Gap(8.h),
        InkWell(
          onTap: _pickEvidence,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: file != null ? colorScheme.primary : colorScheme.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: file == null
                ? Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 36.r, color: colorScheme.secondary),
                      Gap(8.h),
                      CustomText(
                        "Take a photo or upload your payment screenshot\n(You can also skip and upload later from your profile)",
                        variant: TextVariant.bodySmall,
                        color: colorScheme.secondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(file, height: 160.h, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Gap(8.h),
                      const CustomText("Tap to change", variant: TextVariant.bodySmall),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceField(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText("Transaction ID (optional)", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
        Gap(8.h),
        TextField(
          controller: _referenceController,
          decoration: InputDecoration(
            hintText: "e.g. MP250804.1523.A12345",
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.3)),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
        Gap(4.h),
        CustomText(
          "Speeds up verification, but you can leave it blank.",
          variant: TextVariant.bodySmall,
          color: colorScheme.secondary,
        ),
      ],
    );
  }

  Future<void> _pickEvidence() async {
    try {
      final file = await ImageSourcePicker.pick(
        context,
        cameraLabel: 'Take a photo of the receipt',
      );
      if (file != null) {
        setState(() => _evidenceFile = file);
      }
    } catch (e) {
      if (mounted) CustomSnackBar.error(context, message: 'Error picking evidence: $e');
    }
  }

  Future<void> _handleMtnMomoPush(PaymentSettings settings) async {
    final phone = widget.applicationData['phone'] as String? ?? '';
    if (phone.isEmpty) {
      CustomSnackBar.error(context, message: 'Please provide a valid phone number for MTN MoMo.');
      return;
    }

    setState(() => _isSubmitting = true);
    AppDialogs.showLoadingDialog(context, message: 'Sending MTN MoMo prompt to $phone...');

    try {
      final momoService = ref.read(mtnMomoServiceProvider);
      final refId = const uuid_pkg.Uuid().v4();

      final result = await momoService.requestToPay(
        phoneNumber: phone,
        amount: settings.registrationFee,
        currency: settings.currency,
        referenceId: refId,
        payerMessage: 'CQAAG Membership Fee',
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        if (result.success) {
          _referenceController.text = refId;
          CustomSnackBar.success(
            context,
            message: result.message ?? 'Payment prompt sent! Please authorize on your phone.',
            title: 'MTN MoMo Prompt Sent',
          );
        } else {
          CustomSnackBar.warning(
            context,
            message: result.message ?? 'Could not initiate automatic prompt. Please make manual transfer and upload receipt.',
            title: 'Manual Transfer Required',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        CustomSnackBar.error(context, message: 'MTN MoMo Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleSubmit(PaymentSettings settings) async {
    final existingAppId = widget.applicationData['existing_application_id'] as String?;
    final evidence = _evidenceFile;

    if (existingAppId != null && evidence == null) {
      CustomSnackBar.error(context, message: 'Please upload evidence of your Mobile Money payment.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authServiceProvider).currentUser;
      final applicantEmail = widget.applicationData['email'] as String? ?? (user?.email ?? '');
      final applicantUserId = user?.uid ?? 'guest_${const uuid_pkg.Uuid().v4().substring(0, 8)}';

      String? evidenceUrl;
      if (evidence != null) {
        evidenceUrl = await ref.read(cloudinaryServiceProvider).uploadPaymentEvidence(evidence);
        if (evidenceUrl == null) {
          throw Exception('Could not upload your payment evidence. Please try again.');
        }
      }

      if (existingAppId != null && evidenceUrl != null) {
        // Updating existing unpaid application with payment evidence
        await ref.read(membershipServiceProvider).submitPaymentEvidence(
          applicationId: existingAppId,
          evidenceUrl: evidenceUrl,
          reference: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
          settings: settings,
        );

        if (!mounted) return;

        CustomSnackBar.success(
          context,
          message: 'Payment evidence submitted successfully! An administrator will verify it shortly.',
          title: 'Evidence Uploaded',
        );
        context.goNamed(DashboardScreen.id);
      } else {
        // Submitting new application (guest or logged-in user)
        final application = _buildApplication(
          userId: applicantUserId,
          userEmail: applicantEmail,
          settings: settings,
          evidenceUrl: evidenceUrl,
        );

        await ref.read(membershipServiceProvider).submitApplication(application);

        if (!mounted) return;

        CustomSnackBar.success(
          context,
          message: user != null
              ? 'Your application and payment were submitted. An administrator will verify them shortly.'
              : 'Membership application submitted successfully! Once approved by admin, you can create your account.',
          title: 'Application Submitted',
        );

        if (user != null) {
          context.goNamed(DashboardScreen.id);
        } else {
          context.goNamed(GuestHomeScreen.id);
        }
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(
        context,
        message: 'Failed to submit application: ${e.toString()}',
        title: 'Submission Failed',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  MembershipApplication _buildApplication({
    required String userId,
    required String userEmail,
    required PaymentSettings settings,
    required String? evidenceUrl,
  }) {
    final formData = widget.applicationData;

    final titleStr = (formData['title'] as String?)?.toLowerCase() ?? 'mr';
    final title = membership_models.Title.values.firstWhere(
      (t) => t.name == titleStr,
      orElse: () => membership_models.Title.mr,
    );

    final dobDateTime = formData['dob'] as DateTime?;
    final dateOfBirth = dobDateTime?.toIso8601String() ?? DateTime.now().toIso8601String();

    final now = DateTime.now();
    final hasEvidence = evidenceUrl != null;
    final category = _parseMembershipCategory(formData['membership_category'] as String?);

    return MembershipApplication(
      id: const uuid_pkg.Uuid().v4(),
      userId: userId,
      title: title,
      firstName: formData['first_name'] as String? ?? '',
      lastName: formData['last_name'] as String? ?? '',
      dateOfBirth: dateOfBirth,
      gender: _parseGender(formData['gender'] as String?),
      nationality: formData['nationality'] as String? ?? 'Ghanaian',
      phoneNumberPrimary: formData['phone'] as String? ?? '',
      emailAddress: userEmail,
      residentialAddress: formData['address'] as String? ?? '',
      regionDistrict: formData['region'] as String? ?? '',
      currentJobTitle: formData['job_title'] as String? ?? '',
      employerOrganization: formData['employer'] as String? ?? '',
      membershipCategory: category,
      status: ApplicationStatus.submitted,
      createdAt: now,
      submittedAt: now,

      // Payment details
      paymentMethod: PaymentMethod.momo.value,
      paymentStatus: hasEvidence ? PaymentStatus.pendingVerification.value : PaymentStatus.unpaid.value,
      paymentAmount: settings.feeForCategory(category),
      paymentCurrency: settings.currency,
      paymentEvidenceUrl: evidenceUrl,
      paymentReference: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
      paymentMomoNetwork: settings.network.value,
      paymentMomoNumber: settings.momoNumber,
      paymentSubmittedAt: hasEvidence ? now : null,
    );
  }

  MembershipCategory _parseMembershipCategory(String? categoryStr) {
    final lower = categoryStr?.toLowerCase().trim() ?? '';
    if (lower.contains('foreign') || lower == 'full_foreign') {
      return MembershipCategory.fullForeign;
    }
    if (lower.contains('associate')) {
      return MembershipCategory.associate;
    }
    if (lower.contains('corporate')) {
      return MembershipCategory.corporate;
    }
    if (lower.contains('honorary')) {
      return MembershipCategory.honorary;
    }
    return MembershipCategory.full;
  }

  membership_models.Gender _parseGender(String? genderStr) {
    switch (genderStr?.toLowerCase()) {
      case 'female':
        return membership_models.Gender.female;
      case 'prefer not to say':
        return membership_models.Gender.preferNotToSay;
      default:
        return membership_models.Gender.male;
    }
  }
}
