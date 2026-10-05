import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart' as uuid_pkg;
import 'package:cqaag_app/index.dart';
import 'package:cqaag_app/models/membership/membership_category.dart' as membership_models;

/// One page of the signing flow. Terms of Service and Privacy Policy are read
/// and accepted together, as on the website.
enum _SigningStep {
  agreement([LegalDocumentType.membershipAgreement]),
  ethics([LegalDocumentType.codeOfEthics]),
  terms([LegalDocumentType.termsOfService, LegalDocumentType.privacyPolicy]),
  declaration([LegalDocumentType.membershipDeclaration]);

  const _SigningStep(this.documents);

  final List<LegalDocumentType> documents;

  bool get isLast => this == _SigningStep.declaration;

  String get title => documents.map((d) => d.title).join(' & ');
}

/// The applicant reads each governing document and accepts it, by drawing a
/// signature or ticking a box. Their name, date of birth, place of birth and ID
/// number are printed on each A4 copy automatically, and the copies are filed
/// in the association's agreements database when the application is submitted.
///
/// The Membership Declaration is the single consent gate: accepting it submits
/// the application; declining discards it without creating a member record.
class MembershipAgreementScreen extends ConsumerStatefulWidget {
  static const String id = 'membership_agreement_screen';
  final Map<String, dynamic> applicationData;

  const MembershipAgreementScreen({super.key, required this.applicationData});

  @override
  ConsumerState<MembershipAgreementScreen> createState() => _MembershipAgreementScreenState();
}

class _MembershipAgreementScreenState extends ConsumerState<MembershipAgreementScreen> {
  final ScrollController _scrollController = ScrollController();
  final SignatureController _signature = SignatureController();
  final AgreementPdfService _pdfService = AgreementPdfService();

  _SigningStep _step = _SigningStep.agreement;
  AcceptanceMethod _method = AcceptanceMethod.signature;
  bool _ticked = false;
  bool _isBusy = false;
  String? _busyMessage;

  /// Accepted documents so far.
  final Map<LegalDocumentType, SignedPacket> _packets = {};

  @override
  void dispose() {
    _scrollController.dispose();
    _signature.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _data => widget.applicationData;

  String _text(String key) => (_data[key] as String?)?.trim() ?? '';

  String get _fullName => [_text('first_name'), _text('last_name')].where((p) => p.isNotEmpty).join(' ');

  ApplicantIdentity get _identity {
    final dob = _data['dob'] as DateTime?;
    final ghanaCard = GhanaCard.normalise(_data['ghana_card_number'] as String?);
    final nationalId = _text('national_id_number');
    return ApplicantIdentity(
      fullName: _fullName,
      dateOfBirth: dob == null ? '' : DateFormat('yyyy-MM-dd').format(dob),
      placeOfBirth: _text('place_of_birth'),
      ghanaCardNumber: ghanaCard,
      nationalIdNumber: ghanaCard ?? (nationalId.isEmpty ? null : nationalId),
    );
  }

  MembershipCategory get _category => _parseMembershipCategory(_data['membership_category'] as String?);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stepNumber = _step.index + 1;

    return PopScope(
      canPop: _step == _SigningStep.agreement && !_isBusy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isBusy) _goBack();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: <Widget>[
            LegalDocumentHeader(
              title: _step.title,
              subtitle: 'Step $stepNumber of ${_SigningStep.values.length} • ${_step.isLast ? "Final consent" : "Read, then accept"}',
              backLabel: _step == _SigningStep.agreement ? 'Back to Application' : 'Previous document',
              onBack: _isBusy ? () {} : _goBack,
            ),
            LinearProgressIndicator(
              value: stepNumber / _SigningStep.values.length,
              minHeight: 3,
              color: AppColors.primaryGreen,
              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final type in _step.documents) ..._buildDocument(type, colorScheme),
                    _buildIdentityBlock(colorScheme),
                    Gap(20.h),
                    _buildAcceptance(colorScheme),
                    Gap(32.h),
                  ],
                ),
              ),
            ),
            _buildFooter(colorScheme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDocument(LegalDocumentType type, ColorScheme colorScheme) {
    final document = LegalDocuments.of(type);
    return [
      if (_step.documents.length > 1) ...[
        CustomText(document.title, variant: TextVariant.displaySmall, color: colorScheme.primary),
        Gap(4.h),
      ],
      CustomText(
        LegalDocumentBody.effectiveDateLine(document, effectiveDate: DateTime.now()),
        variant: TextVariant.bodySmall,
        color: colorScheme.secondary,
      ),
      Gap(12.h),
      LegalDocumentBody(document: document),
      if (document.declaration != null) ...[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.25)),
          ),
          child: CustomText(document.declaration!, variant: TextVariant.bodyMedium),
        ),
        Gap(16.h),
      ],
      if (_step.documents.length > 1) ...[const Divider(), Gap(16.h)],
    ];
  }

  /// Read-only: it comes from the application, not re-entered here.
  Widget _buildIdentityBlock(ColorScheme colorScheme) {
    final identity = _identity;

    Widget row(String label, String value) => Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130.w, child: CustomText(label, variant: TextVariant.bodySmall, color: colorScheme.secondary)),
          Expanded(child: CustomText(value.isEmpty ? '—' : value, variant: TextVariant.bodySmall, fontWeight: FontWeight.w600)),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.badge_outlined, size: 18.r, color: colorScheme.primary),
              Gap(8.w),
              const Expanded(
                child: CustomText("Applicant identity", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.lock_outline, size: 14.r, color: colorScheme.secondary),
            ],
          ),
          Gap(4.h),
          CustomText(
            "Filled in from your application and printed on the signed copy.",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
          Gap(8.h),
          row("Full Name", identity.fullName),
          row("Date of Birth", identity.dateOfBirth),
          row("Place of Birth", identity.placeOfBirth),
          row("Ghana Card / National ID", identity.idNumber),
        ],
      ),
    );
  }

  Widget _buildAcceptance(ColorScheme colorScheme) {
    final verb = _step.isLast ? 'agree to the Membership Declaration' : 'have read and accept the ${_step.title}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText("How do you accept?", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
        Gap(10.h),
        SegmentedButton<AcceptanceMethod>(
          segments: const [
            ButtonSegment(value: AcceptanceMethod.signature, icon: Icon(Icons.draw_outlined), label: Text('Digital signature')),
            ButtonSegment(value: AcceptanceMethod.tick, icon: Icon(Icons.check_box_outlined), label: Text('Tick box')),
          ],
          selected: {_method},
          showSelectedIcon: false,
          onSelectionChanged: _isBusy ? null : (selection) => setState(() => _method = selection.first),
        ),
        Gap(14.h),
        if (_method == AcceptanceMethod.signature) ...[
          SignaturePad(controller: _signature),
          Row(
            children: [
              Expanded(
                child: CustomText(
                  "Signed in the name of ${_identity.fullName}",
                  variant: TextVariant.bodySmall,
                  color: colorScheme.secondary,
                ),
              ),
              TextButton.icon(
                onPressed: _isBusy ? null : _signature.clear,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Clear'),
              ),
            ],
          ),
        ] else
          InkWell(
            onTap: _isBusy ? null : () => setState(() => _ticked = !_ticked),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: _ticked ? AppColors.primaryGreen.withValues(alpha: 0.08) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _ticked ? AppColors.primaryGreen : Colors.grey.shade300, width: 1.5),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _ticked,
                    activeColor: AppColors.primaryGreen,
                    onChanged: _isBusy ? null : (v) => setState(() => _ticked = v ?? false),
                  ),
                  Expanded(
                    child: CustomText(
                      "I, ${_identity.fullName}, $verb.",
                      variant: TextVariant.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Gap(8.h),
        CustomText(
          "The date and time are recorded automatically.",
          variant: TextVariant.bodySmall,
          color: colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              text: _isBusy ? (_busyMessage ?? 'Please wait...') : (_step.isLast ? "Accept & Submit Application" : "Accept & Continue"),
              isLoading: _isBusy,
              onPressed: _isBusy ? null : _acceptStep,
            ),
            if (_step.isLast) ...[
              Gap(10.h),
              OutlinedButton(
                onPressed: _isBusy ? null : _handleDecline,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  side: BorderSide(color: colorScheme.error.withValues(alpha: 0.6), width: 1.2),
                ),
                child: CustomText("Decline", variant: TextVariant.bodyMedium, fontWeight: FontWeight.w600, color: colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _goBack() {
    if (_step == _SigningStep.agreement) {
      context.pop();
      return;
    }
    _moveTo(_SigningStep.values[_step.index - 1]);
  }

  void _moveTo(_SigningStep step) {
    setState(() {
      _step = step;
      _ticked = false;
      _signature.clear();
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  Future<void> _acceptStep() async {
    if (_identity.fullName.isEmpty) {
      CustomSnackBar.error(context, message: 'Your first and last name are needed on each agreement. Go back and add them.');
      return;
    }
    if (_method == AcceptanceMethod.signature && !_signature.hasInk) {
      CustomSnackBar.error(context, message: 'Draw your signature, or choose the tick box.');
      return;
    }
    if (_method == AcceptanceMethod.tick && !_ticked) {
      CustomSnackBar.error(context, message: 'Tick the box, or draw a signature.');
      return;
    }

    setState(() {
      _isBusy = true;
      _busyMessage = 'Preparing signed copy...';
    });

    try {
      final signaturePng = _method == AcceptanceMethod.signature ? await _signature.toPng() : null;
      final signedAt = DateTime.now();
      for (final type in _step.documents) {
        _packets[type] = await _pdfService.build(
          type: type,
          method: _method,
          identity: _identity,
          signedAt: signedAt,
          signaturePng: signaturePng,
          extraLines: type == LegalDocumentType.membershipDeclaration ? _declarationLines() : const [],
        );
      }

      if (_step.isLast) {
        await _submit();
      } else {
        if (!mounted) return;
        setState(() => _isBusy = false);
        _moveTo(_SigningStep.values[_step.index + 1]);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      CustomSnackBar.error(context, message: e.toString().replaceFirst('Exception: ', ''), title: 'Not accepted');
    }
  }

  List<String> _declarationLines() {
    final sectors = List<String>.from(_data['industry_sectors'] as List? ?? const []);
    return [
      'Directory listing consented to',
      'Name: $_fullName',
      'Job title: ${_text('job_title')}',
      'Employer: ${_text('employer')}',
      'Industry: ${IndustrySectors.describe(sectors, _text('industry_sector_other'))}',
      'Years of experience: ${_text('experience')}',
      'Qualifications: ${_text('professional_qualifications')}',
      'Education: ${[EducationLevels.describe(_data['education_level'] as String?, _text('education_level_other')), _text('field_of_study'), _text('institution'), _text('year_qualification_obtained')].where((p) => p.isNotEmpty).join(', ')}',
    ];
  }

  Future<void> _submit() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      throw Exception('Sign in is required before the agreements can be filed.');
    }

    // Every document must carry today's identity; if the applicant went back
    // and changed details, the earlier copies no longer match.
    final identity = _identity;
    final complete = LegalDocuments.signingOrder.every((t) => _packets[t]?.identity == identity);
    if (!complete) {
      _moveTo(_SigningStep.agreement);
      throw Exception('Your details changed after you accepted. Accept each document again.');
    }

    final membership = ref.read(membershipServiceProvider);
    final existing = await membership.getApplicationByUserId(user.uid);
    final revising = await membership.findRejectedApplication(user.uid);
    if (existing != null && existing.status != ApplicationStatus.rejected && revising == null) {
      throw Exception('You already have a membership application on file. Wait for the Secretariat to finish it before sending another.');
    }

    setState(() => _busyMessage = 'Filing signed agreements...');

    // The agreements database prints the name on the account, so keep the
    // account in step with the application.
    await ref.read(userServiceProvider).updateUserData(user.uid, {
      'first_name': _text('first_name'),
      'last_name': _text('last_name'),
    });

    final settings = ref.read(paymentSettingsProvider).value ?? PaymentSettings.defaults;
    final application = _buildApplication(
      id: revising?.id ?? const uuid_pkg.Uuid().v4(),
      createdAt: revising?.createdAt,
      userId: user.uid,
      email: user.email ?? _text('email'),
      settings: settings,
      quote: settings.schedule.quote(FeeCategory.fromMembership(_category)),
    );

    await membership.submitSignedApplication(
      application: application,
      packets: LegalDocuments.signingOrder.map((t) => _packets[t]!).toList(),
      website: ref.read(websiteApiServiceProvider),
    );

    setState(() => _busyMessage = 'Updating your profile...');
    await ref.read(userServiceProvider).updateUserData(user.uid, {
      'membership_status': 'applied',
      'verification': VerificationData(idCardNumber: identity.idNumber).toJson(),
      'verification_status': VerificationStatus.pending.value,
    });

    if (!mounted) return;
    setState(() => _isBusy = false);
    _showSubmissionSuccessDialog();
  }

  void _handleDecline() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Decline application'),
        content: const Text('Declining discards this application. No membership record will be created.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Keep reviewing')),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              final user = ref.read(authServiceProvider).currentUser;
              context.goNamed(user == null ? LoginScreen.id : DashboardScreen.id);
              CustomSnackBar.info(context, message: 'Application declined. No membership record was created.');
            },
            child: Text('Decline', style: TextStyle(color: Theme.of(dialogContext).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showSubmissionSuccessDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
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
                "Your application and your signed agreements have been filed with the C.Q.A.A.G Secretariat.",
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
                    Icon(Icons.mark_email_unread_outlined, color: AppColors.primaryGreen, size: 20.r),
                    Gap(10.w),
                    Expanded(
                      child: CustomText(
                        "You will receive an email when the Secretariat decides. If approved, you pay the membership fee "
                        "(and can add quality cutting kits); a sign-in password is then emailed to your application address. "
                        "If not approved, the email explains how to re-apply.",
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
    required String id,
    required DateTime? createdAt,
    required String userId,
    required String email,
    required PaymentSettings settings,
    required FeeQuote quote,
  }) {
    final titleStr = _text('title').toLowerCase().replaceAll('.', '');
    final title = membership_models.Title.values.firstWhere(
      (t) => t.name == titleStr,
      orElse: () => membership_models.Title.mr,
    );
    final dob = _data['dob'] as DateTime?;
    final identity = _identity;
    final now = DateTime.now();

    return MembershipApplication(
      id: id,
      userId: userId,
      title: title,
      firstName: _text('first_name'),
      lastName: _text('last_name'),
      dateOfBirth: dob == null ? '' : '${DateFormat('yyyy-MM-dd').format(dob)}T00:00:00.000',
      gender: _parseGender(_data['gender'] as String?),
      nationality: _text('nationality').isEmpty ? 'Ghanaian' : _text('nationality'),
      placeOfBirth: identity.placeOfBirth,
      ghanaCardNumber: identity.ghanaCardNumber,
      nationalIdNumber: identity.nationalIdNumber,
      phoneNumberPrimary: _text('phone'),
      emailAddress: email.toLowerCase(),
      residentialAddress: _text('address'),
      regionDistrict: _text('region'),
      currentJobTitle: _text('job_title'),
      employerOrganization: _text('employer'),
      industrySectors: List<String>.from(_data['industry_sectors'] as List? ?? const []),
      industrySectorOther: _text('industry_sector_other').isEmpty ? null : _text('industry_sector_other'),
      yearsOfExperience: int.tryParse(_text('experience')),
      professionalQualifications: _text('professional_qualifications'),
      highestEducationLevel: _data['education_level'] as String?,
      educationLevelOther: _text('education_level_other').isEmpty ? null : _text('education_level_other'),
      fieldOfStudy: _text('field_of_study'),
      institution: _text('institution'),
      yearQualificationObtained: _text('year_qualification_obtained'),
      membershipCategory: _category,
      status: ApplicationStatus.submitted,
      createdAt: createdAt ?? now,
      submittedAt: now,
      // The fee is paid after approval; this records what will be owed.
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
