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
  bool _hasAgreed = false;
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
            padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 36.h),
            decoration: BoxDecoration(
              color: colorScheme.onSurface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(44.r),
                bottomRight: Radius.circular(44.r),
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
                      const CustomText("Back to Application", color: Colors.white),
                    ],
                  ),
                ),
                Gap(20.h),
                const CustomText(
                  "Membership Agreement & Code of Conduct",
                  variant: TextVariant.headlineMedium,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                Gap(6.h),
                CustomText(
                  "Official Statutory Governance • C.Q.A.A.G Constitution",
                  variant: TextVariant.bodySmall,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ],
            ),
          ),

          // 2. Full Scrollable Agreement & Ethics Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          "Preamble & Binding Obligation",
                          variant: TextVariant.headlineSmall,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                        Gap(8.h),
                        CustomText(
                          "This Agreement constitutes a binding legal and professional covenant between the Cashew Quality Analysts' Association, Ghana (C.Q.A.A.G) and you as an applicant or member. Membership in CQAAG requires unreserved commitment to the Association's Constitution, the statutory mandates of the Tree Crops Development Authority (TCDA), and the rigorous ethical code governing the cashew sector in Ghana and West Africa.",
                          variant: TextVariant.bodyMedium,
                          textAlign: TextAlign.justify,
                          color: Colors.grey.shade900,
                        ),
                      ],
                    ),
                  ),
                  Gap(24.h),

                  _buildLegalSection(
                    "Section 1: Membership Categories & Entitlements",
                    "1.1 Categories: Membership is organized into Full Members, National Associate Members, Foreign Associate Members, Corporate Members, and Honorary Members per Constitution Article 2.\n\n"
                    "1.2 Voting & Office: Only Full Members in good financial standing hold the constitutional right to vote and stand for executive office.\n\n"
                    "1.3 Statutory Licensing: Full and Foreign Associate Members in good standing are eligible for formal recommendation to the Tree Crops Development Authority (TCDA) for licensing to practice nationwide.",
                  ),

                  _buildLegalSection(
                    "Section 2: Professional Standards & Quality Benchmarking",
                    "2.1 Scientific Rigor: Every member shall conduct raw cashew nut (RCN) quality analysis strictly adhering to verified testing protocols (Moisture Content determination ≤ 10%, Out-turn Ratio/KOR calculation, Defect Analysis < 85g, and Kernel Count between 160–180 kernels/kg).\n\n"
                    "2.2 Independent Sampling: Analysts must adhere to random, representative sampling techniques in warehouse and farmgate environments, rejecting cherry-picked samples or falsified lot assessments.",
                  ),

                  _buildLegalSection(
                    "Section 3: Comprehensive Code of Ethics (Disciplinary Enforcement)",
                    "3.1 Article 1 - Integrity & Impartiality:\n"
                    "• Members shall carry out every analysis with uncompromising honesty and independence.\n"
                    "• Members shall strictly decline any gift, cash payment, commission, favor, or inducement intended to alter or influence quality results.\n"
                    "• Any conflict of interest must be disclosed immediately to the Secretariat.\n\n"
                    "3.2 Article 2 - Anti-Collusion & Trade Ethics:\n"
                    "• Analysts shall never collude with buyers, traders, aggregators, or sellers to under-grade or over-grade cashew parcels.\n"
                    "• Falsification of KOR or moisture certificates constitutes immediate grounds for professional disqualification.\n\n"
                    "3.3 Article 3 - Disciplinary Jurisdiction & Sanctions:\n"
                    "• All members submit to the investigative authority of the CQAAG Disciplinary Committee.\n"
                    "• Penalties for ethical breach include formal censure, fines, immediate revocation of Association credentials, withdrawal of TCDA licensing recommendations, and blacklisting from all national buying centers.",
                  ),

                  _buildLegalSection(
                    "Section 4: Financial Obligations & Annual Dues",
                    "4.1 Fee Schedule: Members agree to promptly pay the prescribed one-time registration fee and recurrent annual dues according to the approved schedule of fees set by the General Assembly.\n\n"
                    "4.2 Arrears & Suspension: Failure to settle annual dues within sixty (60) days of the renewal notice results in automatic suspension of certified analyst status, active listing removal, and loss of member benefits.",
                  ),

                  _buildLegalSection(
                    "Section 5: Data Protection & Verification Consent",
                    "5.1 Identity Validation: The applicant grants explicit consent to CQAAG to verify submitted identity data against national registers (including the National Identification Authority / Ghana Card portal) in accordance with the Data Protection Act, 2012 (Act 843).\n\n"
                    "5.2 Member Directory: Approved members will be published on the official national registry for buyer and stakeholder verification.",
                  ),

                  Gap(12.h),
                  const Divider(),
                  Gap(16.h),

                  // Mandatory Checkbox Declaration
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: _hasAgreed
                          ? AppColors.primaryGreen.withValues(alpha: 0.08)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: _hasAgreed
                            ? AppColors.primaryGreen
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _hasAgreed,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (val) {
                            setState(() {
                              _hasAgreed = val ?? false;
                            });
                          },
                        ),
                        Gap(8.w),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _hasAgreed = !_hasAgreed;
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomText(
                                  "Solemn Declaration & Confirmation",
                                  variant: TextVariant.bodyLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                                Gap(4.h),
                                CustomText(
                                  "I certify that all information submitted in my application is true and complete. I have read, understood, and solemnly agree to abide by the C.Q.A.A.G Constitution, Code of Ethics, and Membership Agreement. I submit to the authority of the Disciplinary Committee in all professional matters.",
                                  variant: TextVariant.bodySmall,
                                  color: Colors.grey.shade800,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(40.h),
                ],
              ),
            ),
          ),

          // 3. Sticky Action Footer
          Container(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                  text: _isSubmitting ? "Submitting Application..." : "Accept & Submit Application",
                  isLoading: _isSubmitting,
                  onPressed: (_hasAgreed && !_isSubmitting) ? () => _handleAcceptAndSubmit() : null,
                ),
                Gap(10.h),
                OutlinedButton(
                  onPressed: _isSubmitting ? null : _handleDecline,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: CustomText(
                    "Decline & Exit",
                    variant: TextVariant.bodyMedium,
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
          color: AppColors.darkRed,
        ),
        Gap(8.h),
        CustomText(
          content,
          variant: TextVariant.bodyMedium,
          textAlign: TextAlign.left,
        ),
        Gap(20.h),
      ],
    );
  }

  void _handleDecline() {
    final user = ref.read(authServiceProvider).currentUser;
    final isGuest = user == null || ref.read(guestModeProvider) == AuthMode.guest;
    if (isGuest) {
      ref.read(guestModeProvider.notifier).enableGuestMode();
    }
    context.goNamed(DashboardScreen.id);
  }

  Future<void> _handleAcceptAndSubmit() async {
    if (!_hasAgreed) return;

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authServiceProvider).currentUser;
      final applicantEmail = widget.applicationData['email'] as String? ?? (user?.email ?? '');
      final applicantUserId = user?.uid ?? 'guest_${const uuid_pkg.Uuid().v4().substring(0, 8)}';
      final settings = ref.read(paymentSettingsProvider).value ?? PaymentSettings.defaults;
      final category = _parseMembershipCategory(widget.applicationData['membership_category'] as String?);
      final feeCategory = FeeCategory.fromMembership(category);
      final quote = settings.schedule.quote(feeCategory);

      final application = _buildApplication(
        userId: applicantUserId,
        userEmail: applicantEmail,
        settings: settings,
        quote: quote,
        category: category,
      );

      await ref.read(membershipServiceProvider).submitApplication(application);

      // If registered user, update user profile state
      if (user != null) {
        final ghanaCardNumber = application.ghanaCardNumber;
        await ref.read(userServiceProvider).updateUserData(user.uid, {
          'membership_status': 'applied',
          if (ghanaCardNumber != null)
            'verification': VerificationData(idCardNumber: ghanaCardNumber).toJson(),
          'verification_status': VerificationStatus.pending.value,
        });
      }

      if (!mounted) return;

      _showSubmissionSuccessDialog(isGuest: user == null);
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

  void _showSubmissionSuccessDialog({required bool isGuest}) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.primaryGreen, size: 54.r),
              Gap(14.h),
              const CustomText(
                "Application Submitted for Review",
                variant: TextVariant.headlineMedium,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              Gap(8.h),
              CustomText(
                "Your membership application and verification credentials have been successfully delivered to the C.Q.A.A.G Secretariat.",
                variant: TextVariant.bodyMedium,
                color: Colors.grey.shade700,
                textAlign: TextAlign.center,
              ),
              Gap(14.h),
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 20.r),
                    Gap(10.w),
                    Expanded(
                      child: CustomText(
                        "Stage 1 Review: The Secretariat is reviewing your KYC and qualification details. Upon first approval, you will receive an in-app prompt to complete your registration payment.",
                        variant: TextVariant.bodySmall,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(24.h),
              CustomButton(
                text: "Return to Home",
                onPressed: () {
                  Navigator.of(bottomSheetContext).pop();
                  if (isGuest) {
                    ref.read(guestModeProvider.notifier).enableGuestMode();
                  }
                  context.goNamed(DashboardScreen.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  MembershipApplication _buildApplication({
    required String userId,
    required String userEmail,
    required PaymentSettings settings,
    required FeeQuote quote,
    required MembershipCategory category,
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
      ghanaCardNumber: GhanaCard.normalise(formData['ghana_card_number'] as String?),
      phoneNumberPrimary: formData['phone'] as String? ?? '',
      emailAddress: userEmail,
      residentialAddress: formData['address'] as String? ?? '',
      regionDistrict: formData['region'] as String? ?? '',
      currentJobTitle: formData['job_title'] as String? ?? '',
      employerOrganization: formData['employer'] as String? ?? '',
      employerType: formData['employer_type'] as String?,
      highestEducationLevel: formData['highest_education_level'] as String?,
      fieldOfStudy: formData['field_of_study'] as String?,
      yearQualificationObtained: formData['year_qualification_obtained']?.toString(),
      membershipCategory: category,
      status: ApplicationStatus.submitted,
      createdAt: now,
      submittedAt: now,
      paymentMethod: PaymentMethod.momo.value,
      paymentStatus: PaymentStatus.unpaid.value,
      paymentAmount: quote.total,
      paymentRegistrationFee: quote.registrationFee,
      paymentAnnualDues: quote.annualDues,
      paymentOptionalTotal: quote.optionalTotal,
      paymentOptionalItems: quote.optionalItems,
      paymentRegistrationComponents: quote.registrationComponents,
      paymentCurrency: settings.currency,
      paymentMomoNetwork: settings.network.value,
      paymentMomoNumber: settings.momoNumber,
    );
  }

  Gender _parseGender(String? genderStr) {
    final lower = genderStr?.toLowerCase().trim();
    if (lower == 'female') return Gender.female;
    if (lower == 'other' || lower == 'prefer not to say' || lower == 'prefer_not_to_say') {
      return Gender.preferNotToSay;
    }
    return Gender.male;
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
}
