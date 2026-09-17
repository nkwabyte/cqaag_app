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
                    _buildSectionTitle("1. Membership Category"),
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
                      hint: "e.g. Ghanaian",
                      prefixIcon: Icons.flag_outlined,
                    ),
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
                      hint: "e.g. Greater Accra",
                      prefixIcon: Icons.location_on_outlined,
                    ),

                    Gap(30.h),
                    // Section 3: Professional
                    _buildSectionTitle("3. Professional Information"),
                    const CustomTextField(
                      name: 'job_title',
                      label: "Current Job Title",
                      hint: "e.g. Quality Analyst",
                      prefixIcon: Icons.work_outline,
                    ),
                    Gap(16.h),
                    const CustomTextField(
                      name: 'employer',
                      label: "Employer/Organization",
                      hint: "e.g. Ghana Cashew Board",
                      prefixIcon: Icons.business_outlined,
                    ),
                    Gap(16.h),
                    CustomTextField(
                      name: 'experience',
                      label: "Years of Experience",
                      hint: "Number of years",
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
