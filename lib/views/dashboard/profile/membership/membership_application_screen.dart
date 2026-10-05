import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:cqaag_app/index.dart';

class MembershipApplicationScreen extends ConsumerStatefulWidget {
  static const String id = 'membership_application_screen';
  const MembershipApplicationScreen({super.key});

  @override
  ConsumerState<MembershipApplicationScreen> createState() => _MembershipApplicationScreenState();
}

class _MembershipApplicationScreenState extends ConsumerState<MembershipApplicationScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  /// Drives the fee preview below the category dropdown.
  MembershipCategory _selectedCategory = MembershipCategory.full;

  /// Whether to show the free-text "Other" boxes.
  bool _otherSectorSelected = false;
  bool _otherEducationSelected = false;

  @override
  void initState() {
    super.initState();
    // A revised application may already have "Other" ticked.
    final previous = ref.read(membershipControllerProvider).value?.myApplication;
    if (previous != null && previous.status == ApplicationStatus.rejected) {
      _otherSectorSelected = previous.industrySectors.contains('other');
      _otherEducationSelected = previous.highestEducationLevel == 'other';
    }
  }

  void _navigateToNextStep() {
    // Applications, their signed documents and the later sign-in password are
    // all tied to an account, as on the website.
    if (ref.read(authServiceProvider).currentUser == null) {
      _showSignInRequired();
      return;
    }

    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      CustomSnackBar.error(
        context,
        message: 'Please complete all required fields (Category, Date of Birth, Industry Sector, Qualifications, etc.) before proceeding.',
      );
      return;
    }

    final formData = Map<String, dynamic>.from(_formKey.currentState!.value);
    final problem = _profileProblem(formData);
    if (problem != null) {
      CustomSnackBar.error(context, message: problem);
      return;
    }

    // Foreign Associate applicants identify with a national ID or passport,
    // which needs no Ghana Card check.
    if (_selectedCategory == MembershipCategory.fullForeign) {
      formData['national_id_number'] = (formData['national_id_number'] as String?)?.trim();
      context.pushNamed(MembershipAgreementScreen.id, extra: formData);
      return;
    }

    final user = ref.read(currentUserProfileProvider).value;
    final isAlreadyVerifiedOrPending = user?.verificationStatus == VerificationStatus.verified ||
        user?.verificationStatus == VerificationStatus.pending ||
        user?.verification != null;

    // A member who already has a valid Ghana Card number on file is not asked
    // for it again; anything else — including a number stored before the
    // format was enforced — goes back through verification.
    final existingNumber = user?.verification?.idCardNumber;
    final hasUsableNumber = isAlreadyVerifiedOrPending && GhanaCard.isValid(existingNumber);

    if (hasUsableNumber) {
      formData['ghana_card_number'] = GhanaCard.normalise(existingNumber);
      context.pushNamed(MembershipAgreementScreen.id, extra: formData);
    } else {
      context.pushNamed(VerificationUploadScreen.id, extra: formData);
    }
  }

  /// Checks the website applies too, beyond what each field validates alone.
  String? _profileProblem(Map<String, dynamic> formData) {
    final dob = formData['dob'] as DateTime?;
    if (dob == null || _ageOn(dob, DateTime.now()) < 18) {
      return 'Applicants must be at least 18 years of age.';
    }

    final sectors = List<String>.from(formData['industry_sectors'] as List? ?? const []);
    if (sectors.isEmpty) return 'Select at least one industry sector.';
    if (sectors.contains('other') && ((formData['industry_sector_other'] as String?)?.trim().length ?? 0) < 2) {
      return 'Name the other industry sector.';
    }

    if (formData['education_level'] == 'other' && ((formData['education_level_other'] as String?)?.trim().length ?? 0) < 2) {
      return 'Name the other educational qualification.';
    }

    final yearObtained = int.tryParse('${formData['year_qualification_obtained'] ?? ''}');
    if (yearObtained == null || yearObtained < 1950 || yearObtained > DateTime.now().year) {
      return 'Enter the year the qualification was obtained.';
    }

    final ghanaian = RegExp('ghana', caseSensitive: false).hasMatch((formData['nationality'] as String?) ?? '');
    if ((_selectedCategory == MembershipCategory.full || _selectedCategory == MembershipCategory.associate) && !ghanaian) {
      return 'Full Members and National Associate Members must be Ghanaian nationals.';
    }
    if (_selectedCategory == MembershipCategory.fullForeign && ghanaian) {
      return 'Foreign Associate Membership is for analysts who are not Ghanaian nationals.';
    }
    if (_selectedCategory == MembershipCategory.fullForeign && ((formData['national_id_number'] as String?)?.trim().length ?? 0) < 4) {
      return 'Enter the national ID or passport number for this application.';
    }
    return null;
  }

  static int _ageOn(DateTime dob, DateTime today) {
    var age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) age--;
    return age;
  }

  void _showSignInRequired() {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_person_outlined, color: AppColors.primaryGreen, size: 44.r),
            Gap(12.h),
            const CustomText("Sign in to apply", variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
            Gap(8.h),
            CustomText(
              "Your application, the agreements you sign and your membership payment are kept on your CQAAG account. "
              "Create an account with the email address you want on your membership, or sign in, then apply from your Profile.",
              variant: TextVariant.bodyMedium,
              textAlign: TextAlign.center,
              color: Colors.grey.shade700,
            ),
            Gap(20.h),
            CustomButton(
              text: "Create Account",
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.goNamed(RegisterScreen.id);
              },
            ),
            Gap(10.h),
            CustomButton(
              text: "Sign In",
              variant: ButtonVariant.outlined,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.goNamed(LoginScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(currentUserProfileProvider).value;

    final hasUsableNumber = (user?.verificationStatus == VerificationStatus.verified ||
            user?.verificationStatus == VerificationStatus.pending) &&
        GhanaCard.isValid(user?.verification?.idCardNumber);

    // A rejected applicant revises their previous application.
    final previous = ref.watch(membershipControllerProvider).value?.myApplication;
    final revising = previous != null && previous.status == ApplicationStatus.rejected ? previous : null;

    final initialValues = <String, dynamic>{
      if (revising != null) ...{
        'place_of_birth': revising.placeOfBirth,
        'address': revising.residentialAddress,
        'region': revising.regionDistrict,
        'employer': revising.employerOrganization,
        'industry_sectors': revising.industrySectors,
        'industry_sector_other': revising.industrySectorOther,
        'experience': revising.yearsOfExperience?.toString(),
        'professional_qualifications': revising.professionalQualifications,
        'education_level': EducationLevels.labels.containsKey(revising.highestEducationLevel) ? revising.highestEducationLevel : null,
        'education_level_other': revising.educationLevelOther,
        'field_of_study': revising.fieldOfStudy,
        'institution': revising.institution,
        'year_qualification_obtained': revising.yearQualificationObtained,
        'national_id_number': revising.nationalIdNumber,
      },
      'membership_category': MembershipCategory.full.value,
      'title': 'Mr',
      'first_name': user?.firstName ?? '',
      'last_name': user?.lastName ?? '',
      'nationality': 'Ghanaian',
      'gender': 'Male',
      'phone': user?.phoneNumber ?? '',
      'email': user?.email ?? '',
      'job_title': user?.role?.toString().split('.').last.capitalize() ?? '',
    };

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          initialValue: initialValues,
          child: Column(
            children: [
              // 1. Header with Back Button
              _buildHeader(colorScheme, context),

              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Category
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle("1. Membership Category"),
                        IconButton(
                          tooltip: "Category details & entitlements",
                          icon: Icon(Icons.info_outline, color: colorScheme.primary),
                          onPressed: () => _showCategoryExplanationDialog(context),
                        ),
                      ],
                    ),
                    _buildCategoryDropdown(colorScheme),
                    _buildFeePreview(colorScheme),

                    Gap(30.h),
                    // Section 2: Personal
                    _buildSectionTitle("2. Personal Information"),
                    const CustomTextField(
                      name: 'title',
                      label: "Title",
                      hint: "e.g. Mr, Mrs, Dr",
                      prefixIcon: Icons.badge_outlined,
                    ),
                    Gap(16.h),
                    const CustomTextField(
                      name: 'first_name',
                      label: "First Name",
                      hint: "Enter first name",
                      prefixIcon: Icons.person_outline,
                    ),
                    Gap(16.h),
                    const CustomTextField(
                      name: 'last_name',
                      label: "Last Name",
                      hint: "Enter last name",
                      prefixIcon: Icons.person_outline,
                    ),
                    Gap(16.h),
                    _buildDatePicker("Date of Birth", "dob", colorScheme),
                    Gap(16.h),
                    CustomTextField(
                      name: 'place_of_birth',
                      label: "Place of Birth",
                      hint: "e.g. Wenchi, Bono Region",
                      prefixIcon: Icons.place_outlined,
                      validator: FormBuilderValidators.required(errorText: 'Enter your place of birth'),
                    ),
                    Gap(16.h),
                    const CustomTextField(
                      name: 'nationality',
                      label: "Nationality",
                      hint: "e.g. Ghanaian, Ivorian, Indian, etc.",
                      prefixIcon: Icons.flag_outlined,
                    ),
                    if (_selectedCategory == MembershipCategory.fullForeign) ...[
                      Gap(6.h),
                      CustomText(
                        "Foreign Associate Membership: Open to foreign cashew quality analysts practising in Ghana.",
                        variant: TextVariant.bodySmall,
                        color: colorScheme.primary,
                      ),
                      Gap(16.h),
                      const CustomTextField(
                        name: 'national_id_number',
                        label: "National ID / Passport Number",
                        hint: "Passport or national ID number",
                        prefixIcon: Icons.badge_outlined,
                      ),
                    ],
                    Gap(16.h),
                    _buildGenderDropdown(colorScheme),
                    Gap(16.h),
                    const CustomTextField(
                      name: 'phone',
                      label: "Primary Phone Number",
                      hint: "e.g. +233 XXX XXX XXX",
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    Gap(16.h),
                    // The application email is the account's: decisions and the
                    // generated sign-in password are sent only to it.
                    _buildAccountEmail(colorScheme, user?.email),
                    Gap(16.h),
                    const CustomTextField(
                      name: 'address',
                      label: "Residential Address",
                      hint: "Enter your residential address",
                      prefixIcon: Icons.home_outlined,
                    ),
                    Gap(16.h),
                    const CustomTextField(
                      name: 'region',
                      label: "Region/District",
                      hint: "e.g. Bono / Wenchi",
                      prefixIcon: Icons.location_on_outlined,
                    ),

                    Gap(30.h),
                    // Section 3: Professional Information
                    _buildSectionTitle("3. Professional & Employment Details"),
                    const CustomTextField(
                      name: 'job_title',
                      label: "Current Job Title",
                      hint: "e.g. Quality Analyst / QC Manager",
                      prefixIcon: Icons.work_outline,
                    ),
                    Gap(16.h),
                    const CustomTextField(
                      name: 'employer',
                      label: "Employer / Organization",
                      hint: "e.g. Olam Ghana, Mim Cashew, etc.",
                      prefixIcon: Icons.business_outlined,
                    ),
                    Gap(16.h),
                    _buildIndustrySectors(colorScheme),

                    Gap(30.h),
                    // Section 4: Professional Qualifications
                    _buildSectionTitle("4. Experience & Qualifications"),
                    CustomTextField(
                      name: 'experience',
                      label: "Years of Experience in Cashew Quality Analysis / Related Field",
                      hint: "e.g. 5",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.timeline_outlined,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Enter your years of experience'),
                        FormBuilderValidators.integer(errorText: 'Enter whole years'),
                        FormBuilderValidators.min(0),
                        FormBuilderValidators.max(70),
                      ]),
                    ),
                    Gap(16.h),
                    CustomTextField(
                      name: 'professional_qualifications',
                      label: "Professional Qualifications / Certifications",
                      hint: "e.g. TCDA training, lab technician certificate",
                      prefixIcon: Icons.workspace_premium_outlined,
                      maxLines: 3,
                      validator: FormBuilderValidators.required(errorText: 'List your qualifications, or write "None"'),
                    ),
                    Gap(16.h),
                    _buildEducationLevel(colorScheme),
                    Gap(16.h),
                    CustomTextField(
                      name: 'field_of_study',
                      label: "Field of Study",
                      hint: "e.g. Agricultural Science, Food Technology, Agronomy",
                      prefixIcon: Icons.school_outlined,
                      validator: FormBuilderValidators.required(errorText: 'Enter your field of study'),
                    ),
                    Gap(16.h),
                    CustomTextField(
                      name: 'institution',
                      label: "Institution",
                      hint: "e.g. University of Ghana",
                      prefixIcon: Icons.account_balance_outlined,
                      validator: FormBuilderValidators.required(errorText: 'Enter the institution'),
                    ),
                    Gap(16.h),
                    CustomTextField(
                      name: 'year_qualification_obtained',
                      label: "Year Obtained",
                      hint: "e.g. 2021",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.calendar_today_outlined,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Enter the year obtained'),
                        FormBuilderValidators.integer(),
                      ]),
                    ),

                    Gap(40.h),
                    // Action Button to proceed to Agreement
                    CustomButton(
                      text: hasUsableNumber || _selectedCategory == MembershipCategory.fullForeign
                          ? "Review & Sign Agreements"
                          : "Continue to Ghana Card Verification",
                      onPressed: _navigateToNextStep,
                    ),
                    Gap(40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 40.h),
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
                const CustomText("Back to Profile", color: Colors.white),
              ],
            ),
          ),
          Gap(24.h),
          const CustomText("Membership Application", variant: TextVariant.displaySmall, color: Colors.white),
          Gap(8.h),
          CustomText(
            "Guardians of Ghana’s Cashew Quality",
            variant: TextVariant.bodySmall,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountEmail(ColorScheme colorScheme, String? email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText("Email Address", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
        Gap(8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.email_outlined, color: colorScheme.secondary),
              Gap(12.w),
              Expanded(child: CustomText(email ?? 'Sign in to apply', variant: TextVariant.bodyMedium)),
              Icon(Icons.lock_outline, size: 16.r, color: colorScheme.secondary),
            ],
          ),
        ),
        Gap(4.h),
        CustomText(
          "Your account email. Decisions and your sign-in password are sent here.",
          variant: TextVariant.bodySmall,
          color: colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: CustomText(title, variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoryDropdown(ColorScheme colorScheme) {
    return FormBuilderDropdown<String>(
      name: 'membership_category',
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.3)),
        ),
      ),
      hint: const CustomText("Select category", variant: TextVariant.bodyMedium),
      // Driven by the enum so the labels here can never drift from the ones the
      // fee schedule and the admin screens use.
      items: MembershipCategory.values
          .map((cat) => DropdownMenuItem(value: cat.value, child: CustomText(cat.displayName)))
          .toList(),
      onChanged: (value) => setState(() => _selectedCategory = _categoryFromValue(value)),
      validator: FormBuilderValidators.required(),
    );
  }

  MembershipCategory _categoryFromValue(String? value) {
    return MembershipCategory.values.firstWhere(
      (cat) => cat.value == value,
      orElse: () => MembershipCategory.full,
    );
  }

  /// What the selected category owes, shown before the applicant commits to it.
  ///
  /// The dues differ sharply between categories — a Foreign Associate Member
  /// pays five times a Full Member's annual dues — so choosing blind and finding
  /// out at the payment step would be a poor surprise.
  Widget _buildFeePreview(ColorScheme colorScheme) {
    final settings = ref.watch(paymentSettingsProvider).value ?? PaymentSettings.defaults;
    final feeCategory = FeeCategory.fromMembership(_selectedCategory);
    final schedule = settings.schedule;

    if (feeCategory.isExempt) {
      return _buildFeePreviewShell(
        colorScheme,
        child: CustomText(
          "Honorary Members pay no registration fee and no annual dues.",
          variant: TextVariant.bodySmall,
          color: colorScheme.secondary,
        ),
      );
    }

    return _buildFeePreviewShell(
      colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeePreviewRow("Registration Fee", settings.money(schedule.registrationFeeFor(feeCategory))),
          Gap(4.h),
          _buildFeePreviewRow("Annual Dues", settings.money(schedule.annualDuesFor(feeCategory))),
          Gap(6.h),
          const Divider(height: 1),
          Gap(6.h),
          _buildFeePreviewRow(
            "Payable on registration",
            settings.money(schedule.mandatoryTotalFor(feeCategory)),
            isBold: true,
          ),
          Gap(6.h),
          CustomText(
            "Optional kit items can be added at the payment step.",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildFeePreviewShell(ColorScheme colorScheme, {required Widget child}) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }

  Widget _buildFeePreviewRow(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CustomText(
            label,
            variant: TextVariant.bodySmall,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        CustomText(
          amount,
          variant: TextVariant.bodySmall,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, String name, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(label, variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
        Gap(8.h),
        FormBuilderDateTimePicker(
          name: name,
          inputType: InputType.date,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.calendar_month_outlined, color: colorScheme.secondary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.3)),
            ),
          ),
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

  InputDecoration _groupDecoration(ColorScheme colorScheme) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
    );
  }

  /// Industry Sector, multi-select, with a free-text "Other".
  Widget _buildIndustrySectors(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText("Industry Sector", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
        Gap(4.h),
        CustomText("Tick every sector you work in.", variant: TextVariant.bodySmall, color: colorScheme.secondary),
        Gap(8.h),
        FormBuilderCheckboxGroup<String>(
          name: 'industry_sectors',
          decoration: _groupDecoration(colorScheme),
          activeColor: colorScheme.primary,
          orientation: OptionsOrientation.vertical,
          options: IndustrySectors.labels.entries
              .map((e) => FormBuilderFieldOption(value: e.key, child: CustomText(e.value)))
              .toList(),
          onChanged: (values) => setState(() => _otherSectorSelected = values?.contains('other') ?? false),
          validator: FormBuilderValidators.minLength(1, errorText: 'Select at least one industry sector'),
        ),
        if (_otherSectorSelected) ...[
          Gap(12.h),
          const CustomTextField(
            name: 'industry_sector_other',
            label: "Other sector",
            hint: "Name the sector",
            prefixIcon: Icons.edit_outlined,
          ),
        ],
      ],
    );
  }

  /// Highest Educational Qualification, with a free-text "Other".
  Widget _buildEducationLevel(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText("Highest Educational Qualification", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
        Gap(8.h),
        FormBuilderRadioGroup<String>(
          name: 'education_level',
          decoration: _groupDecoration(colorScheme),
          activeColor: colorScheme.primary,
          orientation: OptionsOrientation.vertical,
          options: EducationLevels.labels.entries
              .map((e) => FormBuilderFieldOption(value: e.key, child: CustomText(e.value)))
              .toList(),
          onChanged: (value) => setState(() => _otherEducationSelected = value == 'other'),
          validator: FormBuilderValidators.required(errorText: 'Select your highest qualification'),
        ),
        if (_otherEducationSelected) ...[
          Gap(12.h),
          const CustomTextField(
            name: 'education_level_other',
            label: "Other qualification",
            hint: "Name the qualification",
            prefixIcon: Icons.edit_outlined,
          ),
        ],
      ],
    );
  }

  void _showCategoryExplanationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 48.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  Gap(16.h),
                  const CustomText(
                    "C.Q.A.A.G Membership Categories",
                    variant: TextVariant.headlineMedium,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  Gap(8.h),
                  CustomText(
                    "Select the tier matching your citizenship, credentials, and institutional role:",
                    variant: TextVariant.bodySmall,
                    color: Colors.grey.shade700,
                    textAlign: TextAlign.center,
                  ),
                  Gap(20.h),
                  ...MembershipCategory.values.map((cat) => _buildCategoryInfoCard(cat)),
                  Gap(16.h),
                  CustomButton(
                    text: "Got It",
                    onPressed: () => Navigator.of(bottomSheetContext).pop(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryInfoCard(MembershipCategory cat) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined, color: AppColors.primaryGreen, size: 20.r),
              Gap(8.w),
              Expanded(
                child: CustomText(
                  cat.displayName,
                  variant: TextVariant.bodyLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              if (cat.hasVotingRights)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: const CustomText(
                    "Voting",
                    variant: TextVariant.bodySmall,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
            ],
          ),
          Gap(6.h),
          CustomText(
            cat.description,
            variant: TextVariant.bodySmall,
            color: Colors.grey.shade800,
          ),
          Gap(6.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              _buildEntitlementPill(
                cat.isTcdaLicensingEligible ? "TCDA Recommendation" : "No TCDA Recommendation",
                cat.isTcdaLicensingEligible,
              ),
              _buildEntitlementPill(
                cat.canHoldOffice ? "Can Hold Office" : "Non-Office Holding",
                cat.canHoldOffice,
              ),
              if (cat.isFeeExempt)
                _buildEntitlementPill("Fee Exempt", true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntitlementPill(String label, bool isPositive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: isPositive ? Colors.green.shade800 : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(ColorScheme colorScheme) {
    return FormBuilderDropdown<String>(
      name: 'gender',
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: "Gender",
        prefixIcon: Icon(Icons.person_outline, color: colorScheme.secondary),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.3)),
        ),
      ),
      hint: const CustomText("Select gender", variant: TextVariant.bodyMedium),
      items: [
        'Male',
        'Female',
        'Prefer not to say',
      ].map((gender) => DropdownMenuItem(value: gender, child: CustomText(gender))).toList(),
      validator: FormBuilderValidators.required(),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
