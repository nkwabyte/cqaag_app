import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart' as uuid_pkg;
import 'package:cqaag_app/index.dart';
import 'package:cqaag_app/models/membership/membership_category.dart' as membership_models;

class MembershipAgreementScreen extends ConsumerStatefulWidget {
  static const String id = 'membership_agreement_screen';
  final Map<String, dynamic> applicationData;

  const MembershipAgreementScreen({super.key, required this.applicationData});

  @override
  ConsumerState<MembershipAgreementScreen> createState() => _MembershipAgreementScreenState();
}

class _MembershipAgreementScreenState extends ConsumerState<MembershipAgreementScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: <Widget>[
          // 1. Curved Focused Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 40.h),
            decoration: BoxDecoration(
              color: colorScheme.onSurface, // darkRed
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50.r),
                bottomRight: Radius.circular(50.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
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
                const CustomText(
                  "Membership Agreement",
                  variant: TextVariant.displaySmall,
                  color: Colors.white,
                ),
                Gap(8.h),
                CustomText(
                  "Effective Date: January 05, 2026",
                  variant: TextVariant.bodySmall,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),

          // 2. Agreement Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "This Agreement is entered into between C.Q.A.A.G and you upon submission and approval of your membership application.",
                    variant: TextVariant.bodyLarge,
                    color: colorScheme.secondary,
                  ),
                  Gap(24.h),

                  _buildLegalSection(
                    "1. Membership Categories",
                    "C.Q.A.A.G offers Full, Associate, Corporate, and Honorary memberships. Eligibility, rights, and benefits for each category are subject to approval by the Membership Committee.",
                  ),

                  _buildLegalSection(
                    "2. Member Benefits",
                    "Members in good standing enjoy access to training programs, workshops, certification courses, networking opportunities, and exclusive industry research.",
                  ),

                  _buildLegalSection(
                    "3. Membership Obligations",
                    "You agree to uphold high professional standards, comply with the Code of Conduct, pay registration and annual dues promptly, and promote the objectives of C.Q.A.A.G.",
                  ),

                  _buildLegalSection(
                    "4. Code of Conduct",
                    "Members must act with integrity and professionalism, avoid conflicts of interest, and maintain confidentiality of sensitive industry information.",
                  ),

                  _buildLegalSection(
                    "5. Term and Termination",
                    "Membership runs for one year and terminates upon non-payment of fees or breach of the Code of Conduct or Association Constitution.",
                  ),

                  Gap(10.h),
                  const Divider(),
                  Gap(24.h),

                  // Final Declaration Section
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          "Declaration",
                          variant: TextVariant.headlineMedium,
                          fontWeight: FontWeight.bold,
                        ),
                        Gap(8.h),
                        const CustomText(
                          "I hereby apply for membership and confirm that the information provided is true. I agree to abide by the C.Q.A.A.G Constitution, Code of Conduct, and Membership Agreement.",
                          variant: TextVariant.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Gap(40.h),
                ],
              ),
            ),
          ),

          // 3. Sticky Acceptance Footer - Only show when there's application data
          if (widget.applicationData.isNotEmpty)
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomButton(
                    text: _isSubmitting ? "Registering..." : "Accept & Submit Application",
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? () {} : _handleAcceptAndRegister,
                  ),
                  Gap(12.h),
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : _handleDecline,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(
                        color: colorScheme.error,
                        width: 1.5,
                      ),
                    ),
                    child: CustomText(
                      "Decline",
                      variant: TextVariant.bodyLarge,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title,
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        Gap(8.h),
        CustomText(
          content,
          variant: TextVariant.bodyMedium,
          textAlign: TextAlign.justify,
        ),
        Gap(24.h),
      ],
    );
  }

  void _handleDecline() {
    context.goNamed(DashboardScreen.id);
  }

  Future<void> _handleAcceptAndRegister() async {
    final user = ref.read(authServiceProvider).currentUser;

    // If guest applicant, proceed directly to Payment screen with full data
    if (user == null) {
      context.pushNamed(
        MembershipPaymentScreen.id,
        extra: widget.applicationData,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final settings = await ref.read(paymentSettingsServiceProvider).getSettings();

      final application = _buildApplication(
        userId: user.uid,
        userEmail: user.email ?? '',
        settings: settings,
      );

      await ref.read(membershipControllerProvider.notifier).submitApplication(application);

      final currentUserProfile = ref.read(currentUserProfileProvider).value;
      final isAlreadyVerified = currentUserProfile?.verificationStatus == VerificationStatus.verified;

      final formData = widget.applicationData;
      final updateData = <String, dynamic>{
        'membership_status': 'applied',
      };

      if (!isAlreadyVerified) {
        updateData['verification_status'] = 'pending';
        updateData['verification'] = {
          'id_card_front_url': formData['id_card_front_url'] as String? ?? '',
          'id_card_back_url': formData['id_card_back_url'] as String? ?? '',
          'selfie_url': formData['selfie_url'] as String? ?? '',
          'id_card_number': formData['ghana_card_number'] as String? ?? '',
        };
      }

      await ref.read(userServiceProvider).updateUserData(
        user.uid,
        updateData,
      );

      if (!mounted) return;

      _showRegistrationSuccessDialog(application.id);
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(
        context,
        message: 'Failed to submit application: ${e.toString()}',
        title: 'Registration Failed',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showRegistrationSuccessDialog(String applicationId) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 48.r),
              Gap(12.h),
              const CustomText(
                "Application Registered!",
                variant: TextVariant.headlineMedium,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              Gap(8.h),
              CustomText(
                "Your membership application has been submitted and registered. An administrator will review your application and details for approval.",
                variant: TextVariant.bodyMedium,
                color: colorScheme.secondary,
                textAlign: TextAlign.center,
              ),
              Gap(12.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
                ),
                child: CustomText(
                  "You can pay the registration fee now to expedite verification, or wait for admin approval before paying.",
                  variant: TextVariant.bodySmall,
                  color: colorScheme.secondary,
                  textAlign: TextAlign.center,
                ),
              ),
              Gap(16.h),
              CustomButton(
                text: "Pay Registration Fee Now",
                onPressed: () {
                  Navigator.of(bottomSheetContext).pop();
                  context.pushReplacementNamed(
                    MembershipPaymentScreen.id,
                    extra: {'existing_application_id': applicationId},
                  );
                },
              ),
              Gap(10.h),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(bottomSheetContext).pop();
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                  context.goNamed(DashboardScreen.id);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const CustomText(
                  "Wait for Approval (Pay Later)",
                  variant: TextVariant.bodyLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MembershipApplication _buildApplication({
    required String userId,
    required String userEmail,
    required PaymentSettings settings,
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

    return MembershipApplication(
      id: const uuid_pkg.Uuid().v4(),
      userId: userId,
      title: title,
      firstName: formData['first_name'] as String? ?? '',
      lastName: formData['last_name'] as String? ?? '',
      dateOfBirth: dateOfBirth,
      gender: _parseGender(formData['gender'] as String?),
      nationality: formData['nationality'] as String? ?? 'Ghanaian',
      ghanaCardNumber: formData['ghana_card_number'] as String?,
      phoneNumberPrimary: formData['phone'] as String? ?? '',
      emailAddress: userEmail,
      residentialAddress: formData['address'] as String? ?? '',
      regionDistrict: formData['region'] as String? ?? '',
      currentJobTitle: formData['job_title'] as String? ?? '',
      employerOrganization: formData['employer'] as String? ?? '',
      membershipCategory: _parseMembershipCategory(formData['membership_category'] as String?),
      status: ApplicationStatus.submitted,
      createdAt: now,
      submittedAt: now,

      paymentMethod: PaymentMethod.momo.value,
      paymentStatus: PaymentStatus.unpaid.value,
      paymentAmount: settings.registrationFee,
      paymentCurrency: settings.currency,
      paymentEvidenceUrl: null,
      paymentReference: null,
      paymentMomoNetwork: settings.network.value,
      paymentMomoNumber: settings.momoNumber,
      paymentSubmittedAt: null,
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
