import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:cqaag_app/index.dart';

class ContactUsScreen extends StatefulWidget {
  static const String id = 'contact_us_screen';

  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  void _sendMessage() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomSnackBar.success(
          context,
          message: "Message sent successfully! We will get back to you soon.",
        );
        _formKey.currentState?.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkRed,
        title: const CustomText(
          'Contact Us',
          variant: TextVariant.bodyLarge,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          children: [
            // Header Text
            const CustomText(
              'Get in touch with our team for inquiries, support, or partnership opportunities',
              variant: TextVariant.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Gap(32.h),

            // Contact Form
            FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    name: 'fullName',
                    label: 'Full Name *',
                    hint: 'Enter your full name',
                    validator: FormBuilderValidators.required(),
                  ),
                  Gap(16.h),
                  CustomTextField(
                    name: 'email',
                    label: 'Email *',
                    hint: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                  ),
                  Gap(16.h),
                  CustomTextField(
                    name: 'phone',
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                  ),
                  Gap(16.h),

                  // Department Dropdown
                  CustomText(
                    'Department *',
                    variant: TextVariant.bodyLarge,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  Gap(8.h),
                  FormBuilderDropdown<String>(
                    name: 'department',
                    validator: FormBuilderValidators.required(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Select Department',
                      contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.secondary.withValues(alpha: 0.3),
                          width: 1.w,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: colorScheme.secondary, width: 1.5.w),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.redAccent, width: 1.w),
                      ),
                    ),
                    items: ['Quality Assurance', 'Certification Services', 'Training & Development', 'General Inquiries', 'President Office']
                        .map(
                          (dept) => DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          ),
                        )
                        .toList(),
                  ),
                  Gap(16.h),

                  CustomTextField(
                    name: 'subject',
                    label: 'Subject *',
                    hint: 'Enter subject',
                    validator: FormBuilderValidators.required(),
                  ),
                  Gap(16.h),
                  CustomTextField(
                    name: 'message',
                    label: 'Message *',
                    hint: 'Enter your message',
                    maxLines: 5,
                    validator: FormBuilderValidators.required(),
                  ),
                  Gap(32.h),

                  CustomButton(
                    text: 'Send Message',
                    onPressed: _sendMessage,
                    isLoading: _isLoading,
                    backgroundColor: AppColors.darkRed,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),

            Gap(48.h),

            // Contact Information
            _buildSectionHeader('Contact Information'),
            Gap(16.h),
            _buildInfoCard(
              context,
              icon: Icons.location_on,
              title: 'Headquarters',
              content: 'Sampa, Bono Region, Ghana',
            ),
            Gap(12.h),
            _buildInfoCard(
              context,
              icon: Icons.phone,
              title: 'Phone',
              content: '+233 XX XXX XXXX\n+233 XX XXX XXXX',
            ),
            Gap(12.h),
            _buildInfoCard(
              context,
              icon: Icons.email,
              title: 'Email',
              content: 'info@cqaag.org\nsupport@cqaag.org',
            ),
            Gap(12.h),
            _buildInfoCard(
              context,
              icon: Icons.access_time,
              title: 'Business Hours',
              content: 'Monday - Friday: 8:00 AM - 5:00 PM\nSaturday: 9:00 AM - 1:00 PM\nSunday: Closed',
            ),

            Gap(40.h),

            // Department Contacts
            _buildSectionHeader('Department Contacts'),
            Gap(16.h),
            _buildDepartmentContact(
              context,
              name: 'President Office',
              email: 'ceo@cqaag.org',
              phone: '+233 XX XXX XXXX',
            ),
            Gap(12.h),
            _buildDepartmentContact(
              context,
              name: 'Quality Assurance',
              email: 'quality@cqaag.org',
              phone: '+233 XX XXX XXXX',
            ),
            Gap(12.h),
            _buildDepartmentContact(
              context,
              name: 'Certification Services',
              email: 'certification@cqaag.org',
              phone: '+233 XX XXX XXXX',
            ),
            Gap(12.h),
            _buildDepartmentContact(
              context,
              name: 'Training & Development',
              email: 'training@cqaag.org',
              phone: '+233 XX XXX XXXX',
            ),

            Gap(40.h),

            // Why Contact CQAAG
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.lightOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.lightOrange.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    'Why Contact CQAAG?',
                    variant: TextVariant.headlineSmall,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkRed,
                  ),
                  Gap(12.h),
                  const CustomText(
                    'As the leading authority in cashew quality assurance in Ghana, we are committed to providing exceptional service to farmers, processors, exporters, and all stakeholders in the cashew value chain.',
                    variant: TextVariant.bodyMedium,
                  ),
                  Gap(12.h),
                  const CustomText(
                    'Our team of 156 certified analysts across 8 regions ensures rapid response times and comprehensive support for all your quality inspection and certification needs.',
                    variant: TextVariant.bodyMedium,
                  ),
                ],
              ),
            ),
            Gap(40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      children: [
        CustomText(
          title,
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBrown,
        ),
        Gap(8.h),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required String content}) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.lightOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.darkRed, size: 20.r),
          ),
          Gap(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(title, variant: TextVariant.bodySmall, fontWeight: FontWeight.bold),
                Gap(4.h),
                CustomText(content, variant: TextVariant.bodyMedium, color: Colors.black87),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentContact(BuildContext context, {required String name, required String email, required String phone}) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(name, variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
          Gap(8.h),
          Row(
            children: [
              Icon(Icons.email_outlined, size: 16.r, color: Colors.grey),
              Gap(8.w),
              Expanded(child: CustomText(email, variant: TextVariant.bodySmall)),
            ],
          ),
          Gap(4.h),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 16.r, color: Colors.grey),
              Gap(8.w),
              Expanded(child: CustomText(phone, variant: TextVariant.bodySmall)),
            ],
          ),
        ],
      ),
    );
  }
}
