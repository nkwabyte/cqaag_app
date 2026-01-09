import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class MembershipAgreementScreen extends StatefulWidget {
  static const String id = 'membership_agreement_screen';
  final Map<String, dynamic> applicationData;

  const MembershipAgreementScreen({super.key, required this.applicationData});

  @override
  State<MembershipAgreementScreen> createState() => _MembershipAgreementScreenState();
}

class _MembershipAgreementScreenState extends State<MembershipAgreementScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // 1. Curved Focused Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: colorScheme.onSurface, // darkRed
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50.r),
                bottomRight: Radius.circular(50.r),
              ),
            ),
            child: Column(
              children: [
                Gap(80.h),
                const CustomText(
                  "Membership Agreement",
                  variant: TextVariant.displaySmall,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
                Gap(12.h),
                CustomText(
                  "Effective Date: January 05, 2026",
                  variant: TextVariant.bodySmall,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                Gap(40.h),
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

          // 3. Sticky Acceptance Footer
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
            child: CustomButton(
              text: "Accept and Submit Application",
              onPressed: () {
                // Logic to submit applicationData and declaration
                _handleFinalSubmission(context);
              },
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

  void _handleFinalSubmission(BuildContext context) {
    // Implement your final API call or success dialog here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Membership Application Submitted Successfully")),
    );
  }
}
