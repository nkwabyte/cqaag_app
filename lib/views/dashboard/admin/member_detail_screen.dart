import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class AdminMemberDetailScreen extends ConsumerWidget {
  static const String id = 'admin_member_detail_screen';
  final MembershipApplication application;

  const AdminMemberDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = ref.read(membershipControllerProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const CustomText("Application Details", variant: TextVariant.headlineMedium),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            // Header Status
            Container(
              padding: EdgeInsets.all(16.r),
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getStatusColor(application.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _getStatusColor(application.status).withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  CustomText(
                    "Status: ${application.status.displayName}",
                    variant: TextVariant.headlineMedium,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(application.status),
                  ),
                  if (application.submittedAt != null) ...[
                    Gap(4.h),
                    CustomText(
                      "Submitted on ${application.submittedAt.toString().split(' ')[0]}",
                      variant: TextVariant.bodySmall,
                      color: colorScheme.secondary,
                    ),
                  ],
                ],
              ),
            ),

            Gap(20.h),

            _buildInfoCard(
              context,
              title: "Applicant Info",
              children: [
                _buildInfoRow("Name", "${application.firstName} ${application.lastName}"),
                _buildInfoRow("Category", application.membershipCategory.displayName),
                _buildInfoRow("Email", application.emailAddress),
                _buildInfoRow("Phone", application.phoneNumberPrimary),
                if (application.phoneNumberSecondary != null) _buildInfoRow("Alt Phone", application.phoneNumberSecondary!),
                _buildInfoRow("Address", application.residentialAddress),
                _buildInfoRow("Date of Birth", application.dateOfBirth.split('T')[0]),
                _buildInfoRow("Region/District", application.regionDistrict),
              ],
            ),

            Gap(16.h),

            _buildInfoCard(
              context,
              title: "Professional Details",
              children: [
                _buildInfoRow("Employer", application.employerOrganization),
                _buildInfoRow("Job Title", application.currentJobTitle),
              ],
            ),

            Gap(40.h),

            // Admin Actions
            if (application.status == ApplicationStatus.submitted || application.status == ApplicationStatus.underReview) ...[
              CustomText(
                "Review Actions",
                variant: TextVariant.headlineMedium,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              Gap(16.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Reject",
                      backgroundColor: Colors.red,
                      onPressed: () async {
                        final updatedApp = application.copyWith(status: ApplicationStatus.rejected, reviewedAt: DateTime.now());
                        await controller.updateApplication(updatedApp);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: CustomButton(
                      text: "Approve",
                      backgroundColor: Colors.green,
                      onPressed: () async {
                        final updatedApp = application.copyWith(status: ApplicationStatus.approved, reviewedAt: DateTime.now());
                        await controller.updateApplication(updatedApp);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.submitted:
      case ApplicationStatus.underReview:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(title, variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: CustomText(label, variant: TextVariant.bodyMedium, color: Colors.grey[600]),
          ),
          Expanded(
            child: CustomText(value, variant: TextVariant.bodyMedium, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
