import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class MembershipManagementTab extends ConsumerStatefulWidget {
  const MembershipManagementTab({super.key});

  @override
  ConsumerState<MembershipManagementTab> createState() => _MembershipManagementTabState();
}

class _MembershipManagementTabState extends ConsumerState<MembershipManagementTab> {
  final TextEditingController _searchController = TextEditingController();
  // Simple local state for demo, can be moved to provider if needed strictly
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch all applications
    final applicationsAsync = ref.watch(allMembershipApplicationsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Search & Filter Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: 'search_members',
                  label: 'Search Applications',
                  hint: "Search applications...",
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value ?? '';
                    });
                  },
                ),
              ),
              Gap(10.w),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(Icons.filter_list, color: colorScheme.primary),
                  onPressed: () {
                    // Open filter modal
                  },
                ),
              ),
            ],
          ),
        ),

        // Applications List
        Expanded(
          child: applicationsAsync.when(
            data: (applications) {
              final filteredApps = applications.where((app) {
                if (_searchQuery.isEmpty) return true;
                // Add robust search logic here based on fields
                return true;
              }).toList();

              if (filteredApps.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_late_outlined, size: 48.r, color: colorScheme.secondary),
                      Gap(10.h),
                      CustomText(
                        "No applications found",
                        variant: TextVariant.bodyMedium,
                        color: colorScheme.secondary,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: filteredApps.length,
                separatorBuilder: (context, index) => Gap(12.h),
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  return _buildApplicationCard(app, colorScheme);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationCard(MembershipApplication app, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12.r),
        leading: Container(
          width: 50.r,
          height: 50.r,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Icon(Icons.assignment_ind, color: colorScheme.primary),
          ),
        ),
        title: CustomText(
          app.firstName.isNotEmpty ? "${app.firstName} ${app.lastName}" : "Unknown Applicant",
          variant: TextVariant.bodyLarge,
          fontWeight: FontWeight.bold,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(4.h),
            Row(
              children: [
                Icon(Icons.category_outlined, size: 14.r, color: colorScheme.secondary),
                Gap(4.w),
                CustomText(
                  app.membershipCategory.displayName,
                  variant: TextVariant.bodySmall,
                  color: colorScheme.secondary,
                ),
              ],
            ),
            Gap(6.h),
            _buildStatusChip(app.status, colorScheme),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to details
          context.pushNamed(AdminMemberDetailScreen.id, extra: app);
        },
      ),
    );
  }

  Widget _buildStatusChip(ApplicationStatus status, ColorScheme colorScheme) {
    Color color;
    switch (status) {
      case ApplicationStatus.approved:
        color = Colors.green;
        break;
      case ApplicationStatus.rejected:
        color = Colors.red;
        break;
      case ApplicationStatus.submitted:
      case ApplicationStatus.underReview:
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
