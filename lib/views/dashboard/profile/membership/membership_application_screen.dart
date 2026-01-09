import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';

import 'package:cqaag_app/index.dart';

class MembershipApplicationScreen extends StatefulWidget {
  static const String id = 'membership_application_screen';
  const MembershipApplicationScreen({super.key});

  @override
  State<MembershipApplicationScreen> createState() => _MembershipApplicationScreenState();
}

class _MembershipApplicationScreenState extends State<MembershipApplicationScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _navigateToAgreement() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;
      // Note: MembershipAgreementScreen needs formData - will need to handle this with GoRouter extra parameter
      context.pushNamed(
        MembershipAgreementScreen.id,
        extra: formData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              // 1. Header with Back Button
              _buildHeader(colorScheme, context),

              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Category [cite: 134]
                    _buildSectionTitle("1. Membership Category"),
                    _buildCategoryDropdown(colorScheme),

                    Gap(30.h),
                    // Section 2: Personal [cite: 139]
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
                    const CustomTextField(
                      name: 'phone',
                      label: "Primary Phone Number",
                      hint: "e.g. +233 XXX XXX XXX",
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),

                    Gap(30.h),
                    // Section 3: Professional [cite: 153]
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
                    const CustomTextField(
                      name: 'experience',
                      label: "Years of Experience",
                      hint: "Number of years",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.timeline_outlined,
                    ),

                    Gap(40.h),
                    // Action Button to proceed to Agreement [cite: 161]
                    CustomButton(
                      text: "Review & Sign Agreement",
                      onPressed: _navigateToAgreement,
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
      items: [
        'Full Member',
        'Associate Member',
        'Corporate Member',
        'Honorary Member',
      ].map((cat) => DropdownMenuItem(value: cat, child: CustomText(cat))).toList(),
      validator: FormBuilderValidators.required(),
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
}
