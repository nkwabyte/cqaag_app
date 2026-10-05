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

  void _navigateToNextStep() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = Map<String, dynamic>.from(_formKey.currentState!.value);
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

        context.pushNamed(
          MembershipAgreementScreen.id,
          extra: formData,
        );
      } else {
        context.pushNamed(
          VerificationUploadScreen.id,
          extra: formData,
        );
      }
    } else {
      CustomSnackBar.error(
        context,
        message: 'Please complete all required fields (Category, Date of Birth, Gender, etc.) before proceeding.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(currentUserProfileProvider).value;

    final hasUsableNumber = (user?.verificationStatus == VerificationStatus.verified ||
            user?.verificationStatus == VerificationStatus.pending) &&
        GhanaCard.isValid(user?.verification?.idCardNumber);

    final initialValues = {
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
                    const CustomTextField(
                      name: 'email',
                      label: "Email Address",
                      hint: "e.g. john.doe@example.com",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
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
                    _buildEmployerTypeDropdown(colorScheme),

                    Gap(30.h),
                    // Section 4: Professional Qualifications
                    _buildSectionTitle("4. Professional Qualifications"),
                    _buildEducationLevelDropdown(colorScheme),
                    Gap(16.h),
                    const CustomTextField(
                      name: 'field_of_study',
                      label: "Field of Study / Specialization",
                      hint: "e.g. Agricultural Science, Food Technology, Agronomy",
                      prefixIcon: Icons.school_outlined,
                    ),
                    Gap(16.h),
                    CustomTextField(
                      name: 'year_qualification_obtained',
                      label: "Year Qualification Obtained",
                      hint: "e.g. 2021",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.calendar_today_outlined,
                      validator: FormBuilderValidators.numeric(),
                    ),
                    Gap(16.h),
                    CustomTextField(
                      name: 'experience',
                      label: "Years of Experience in Cashew Quality",
                      hint: "e.g. 5",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.timeline_outlined,
                      validator: FormBuilderValidators.numeric(),
                    ),

                    Gap(40.h),
                    // Action Button to proceed to Agreement
                    CustomButton(
                      text: hasUsableNumber ? "Review & Sign Agreement" : "Continue to Ghana Card Verification",
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

  Widget _buildEmployerTypeDropdown(ColorScheme colorScheme) {
    return FormBuilderDropdown<String>(
      name: 'employer_type',
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: "Employer Sector / Type",
        prefixIcon: Icon(Icons.apartment_outlined, color: colorScheme.secondary),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.3)),
        ),
      ),
      hint: const CustomText("Select employer sector", variant: TextVariant.bodyMedium),
      items: const [
        'Cashew Processor',
        'Exporter',
        'Trader / Buying Agent',
        'Aggregator',
        'Farmer / Cooperative',
        'Testing Laboratory',
        'Regulatory Agency (TCDA, MOFA, GEPA)',
        'Academia & Research',
        'Other',
      ].map((sector) => DropdownMenuItem(value: sector, child: CustomText(sector))).toList(),
      validator: FormBuilderValidators.required(),
    );
  }

  Widget _buildEducationLevelDropdown(ColorScheme colorScheme) {
    return FormBuilderDropdown<String>(
      name: 'highest_education_level',
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: "Highest Educational Level",
        prefixIcon: Icon(Icons.school_outlined, color: colorScheme.secondary),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.3)),
        ),
      ),
      hint: const CustomText("Select educational level", variant: TextVariant.bodyMedium),
      items: const [
        'WASSCE / Senior High School (SHS)',
        'Diploma / HND',
        'Bachelor\'s Degree (BSc / BA)',
        'Master\'s Degree (MSc / MPhil / MBA)',
        'Doctorate (PhD)',
        'Professional QC Certification',
        'Other',
      ].map((level) => DropdownMenuItem(value: level, child: CustomText(level))).toList(),
      validator: FormBuilderValidators.required(),
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
