import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class UserManagementTab extends ConsumerStatefulWidget {
  const UserManagementTab({super.key});

  @override
  ConsumerState<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends ConsumerState<UserManagementTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch filtered users
    final usersAsync = ref.watch(filteredUsersProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: <Widget>[
        // Search Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: CustomTextField(
            name: 'search_users',
            label: 'Search Users',
            hint: "Search users by name, email...",
            prefixIcon: Icons.search,
            onChanged: (value) {
              ref.read(userFilterProvider.notifier).setFilter(value ?? '');
            },
          ),
        ),

        // Users List
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 10.0.h),
            child: usersAsync.when(
              data: (List<AppUser> users) {
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.person_off_outlined,
                          size: 48.r,
                          color: colorScheme.secondary,
                        ),
                        Gap(10.h),
                        CustomText(
                          "No users found",
                          variant: TextVariant.bodyMedium,
                          color: colorScheme.secondary,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (BuildContext context, int index) => Divider(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final user = users[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 24.r,
                        backgroundImage: NetworkImage(user.profilePicture),
                        // Fallback if image fails or is essential to handle effectively
                        onBackgroundImageError: (ctx, err) {},
                        child: Text(user.firstName[0].toUpperCase()),
                      ),
                      title: CustomText(
                        "${user.firstName} ${user.lastName}",
                        variant: TextVariant.bodyLarge,
                        fontWeight: FontWeight.w600,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CustomText(
                            user.email,
                            variant: TextVariant.bodySmall,
                            color: colorScheme.secondary,
                          ),
                          Gap(4.h),
                          _buildStatusBadge(user.status, colorScheme),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to details
                        context.pushNamed(AdminUserDetailScreen.id, extra: user);
                      },
                    );
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

  Widget _buildStatusBadge(AppUserStatus status, ColorScheme colorScheme) {
    Color color;
    switch (status) {
      case AppUserStatus.active:
        color = Colors.green;
        break;
      case AppUserStatus.suspended:
        color = Colors.orange;
        break;
      case AppUserStatus.banned:
        color = Colors.red;
        break;
      case AppUserStatus.inactive:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.value.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
