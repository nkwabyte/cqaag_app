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
                    text: _isSubmitting ? "Submitting..." : "Accept and Submit Application",
                    onPressed: _isSubmitting ? () {} : _handleFinalSubmission,
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
    // Navigate back to profile screen
    context.goNamed(ProfileScreen.id);
  }

  Future<void> _handleFinalSubmission() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current user
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Parse form data and create MembershipApplication
      final formData = widget.applicationData;

      // Parse title
      final titleStr = (formData['title'] as String?)?.toLowerCase() ?? 'mr';
      final title = membership_models.Title.values.firstWhere(
        (t) => t.name == titleStr,
        orElse: () => membership_models.Title.mr,
      );

      // Parse gender from form
      final genderStr = formData['gender'] as String?;
      final gender = _parseGender(genderStr);

      // Parse membership category
      final categoryStr = formData['membership_category'] as String?;
      final category = _parseMembershipCategory(categoryStr);

      // Parse date of birth
      final dobDateTime = formData['dob'] as DateTime?;
      final dateOfBirth = dobDateTime?.toIso8601String() ?? DateTime.now().toIso8601String();

      // Create the membership application
      final application = MembershipApplication(
        id: const uuid_pkg.Uuid().v4(),
        userId: user.uid,
        title: title,
        firstName: formData['first_name'] as String? ?? '',
        lastName: formData['last_name'] as String? ?? '',
        dateOfBirth: dateOfBirth,
        gender: gender,
        nationality: formData['nationality'] as String? ?? 'Ghanaian',
        phoneNumberPrimary: formData['phone'] as String? ?? '',
        emailAddress: user.email ?? '',
        residentialAddress: formData['address'] as String? ?? '',
        regionDistrict: formData['region'] as String? ?? '',
        currentJobTitle: formData['job_title'] as String? ?? '',
        employerOrganization: formData['employer'] as String? ?? '',
        membershipCategory: category,
        status: ApplicationStatus.submitted,
        createdAt: DateTime.now(),
        submittedAt: DateTime.now(),
      );

      // Submit the application using the controller
      final controller = ref.read(membershipControllerProvider.notifier);
      await controller.submitApplication(application);

      // Check if widget is still mounted before using context
      if (!mounted) return;

      // Show success snackBar
      CustomSnackBar.success(
        context,
        message: 'Your membership application has been submitted successfully!',
        title: 'Application Submitted',
      );

      // Navigate back to profile screen
      context.goNamed(ProfileScreen.id);
    } catch (e) {
      if (!mounted) return;

      // Show error snackBar
      CustomSnackBar.error(
        context,
        message: 'Failed to submit application: ${e.toString()}',
        title: 'Submission Failed',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  MembershipCategory _parseMembershipCategory(String? categoryStr) {
    if (categoryStr == null) return MembershipCategory.full;

    switch (categoryStr.toLowerCase()) {
      case 'full member':
        return MembershipCategory.full;
      case 'associate member':
        return MembershipCategory.associate;
      case 'corporate member':
        return MembershipCategory.corporate;
      case 'honorary member':
        return MembershipCategory.honorary;
      default:
        return MembershipCategory.full;
    }
  }

  membership_models.Gender _parseGender(String? genderStr) {
    if (genderStr == null) return membership_models.Gender.male;

    switch (genderStr.toLowerCase()) {
      case 'male':
        return membership_models.Gender.male;
      case 'female':
        return membership_models.Gender.female;
      case 'prefer not to say':
        return membership_models.Gender.preferNotToSay;
      default:
        return membership_models.Gender.male;
    }
  }
}
