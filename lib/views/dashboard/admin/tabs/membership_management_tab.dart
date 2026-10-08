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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Search & Filter Bar
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: TextStyle(fontSize: 13.sp),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Search applications...",
                      hintStyle: TextStyle(fontSize: 12.sp, color: Colors.black38),
                      prefixIcon: Icon(Icons.search, size: 20.r, color: colorScheme.primary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.cancel, size: 18.r, color: Colors.black38),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                  ),
                ),
              ),
              Gap(10.w),
              InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () {
                  // Open filter modal
                },
                child: Container(
                  height: 44.h,
                  width: 44.h,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.filter_list,
                      color: colorScheme.primary,
                      size: 20.r,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Applications List
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: applicationsAsync.when(
              data: (applications) {
                final filteredApps = applications.where((app) {
                  if (_searchQuery.isEmpty) return true;

                  final query = _searchQuery.toLowerCase();
                  final fullName = '${app.firstName} ${app.lastName}'.toLowerCase();
                  final category = app.membershipCategory.displayName.toLowerCase();
                  final status = app.status.displayName.toLowerCase();

                  return fullName.contains(query) || category.contains(query) || status.contains(query);
                }).toList();

                if (filteredApps.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
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
                  separatorBuilder: (BuildContext context, int index) => Gap(12.h),
                  itemBuilder: (BuildContext context, int index) {
                    final app = filteredApps[index];
                    return _buildApplicationCard(app, colorScheme);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationCard(MembershipApplication app, ColorScheme colorScheme) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: EdgeInsets.all(12.r),
        leading: Consumer(
          builder: (context, ref, child) {
            final userState = ref.watch(userControllerProvider).value;
            final user = userState?.allUsers.where((u) => u.id == app.userId).firstOrNull;

            return AppAvatar(
              profilePicture: user?.profilePicture,
              selfieUrl: user?.verification?.selfieUrl,
              name: app.firstName,
              radius: 25,
            );
          },
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
