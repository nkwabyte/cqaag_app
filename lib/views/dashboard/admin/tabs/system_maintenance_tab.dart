import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:cqaag_app/index.dart';

enum MaintenanceCategory { users, members, reports }

class SystemMaintenanceTab extends ConsumerStatefulWidget {
  const SystemMaintenanceTab({super.key});

  @override
  ConsumerState<SystemMaintenanceTab> createState() => _SystemMaintenanceTabState();
}

class _SystemMaintenanceTabState extends ConsumerState<SystemMaintenanceTab> {
  MaintenanceCategory _selectedCategory = MaintenanceCategory.users;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isClearingCache = false;
  bool _isPurging = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const CustomText(
            "System Maintenance",
            variant: TextVariant.headlineMedium,
            fontWeight: FontWeight.bold,
          ),
          Gap(4.h),
          CustomText(
            "Tools for managing app cache, deleting specific records, and performing database purges.",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
          Gap(24.h),

          // 1. System Cache Management Card
          _buildCacheControlCard(colorScheme),

          Gap(24.h),
          const Divider(),
          Gap(24.h),

          // 2. Selective Record Management
          _buildSelectiveDeleteHeader(colorScheme),
          Gap(16.h),
          _buildCategoryFilterChips(colorScheme),
          Gap(16.h),
          _buildSearchBar(colorScheme),
          Gap(16.h),
          _buildEntityList(colorScheme),

          Gap(32.h),
          const Divider(),
          Gap(24.h),

          // 3. Danger Zone: Database Purge
          _buildDangerZoneCard(colorScheme),
          Gap(40.h),
        ],
      ),
    );
  }

  Widget _buildCacheControlCard(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cleaning_services_outlined, color: colorScheme.primary, size: 24.r),
              Gap(12.w),
              Expanded(
                child: const CustomText(
                  "System & Image Cache",
                  variant: TextVariant.headlineMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Gap(8.h),
          CustomText(
            "Clear cached network images, memory buffers, and refresh system data providers across the app.",
            variant: TextVariant.bodySmall,
            color: colorScheme.secondary,
          ),
          Gap(16.h),
          CustomButton(
            text: _isClearingCache ? "Clearing Cache..." : "Clear System Cache",
            isLoading: _isClearingCache,
            backgroundColor: colorScheme.primary,
            textColor: Colors.white,
            onPressed: _isClearingCache ? () {} : _handleClearCache,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectiveDeleteHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          "Delete Specific Records",
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        Gap(4.h),
        CustomText(
          "Inspect and delete individual users, members, or quality reports.",
          variant: TextVariant.bodySmall,
          color: colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildCategoryFilterChips(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text("Users"),
            selected: _selectedCategory == MaintenanceCategory.users,
            onSelected: (val) {
              if (val) setState(() => _selectedCategory = MaintenanceCategory.users);
            },
            selectedColor: colorScheme.primary,
            labelStyle: TextStyle(
              color: _selectedCategory == MaintenanceCategory.users ? Colors.white : colorScheme.onSurface,
              fontWeight: _selectedCategory == MaintenanceCategory.users ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Gap(8.w),
          ChoiceChip(
            label: const Text("Members"),
            selected: _selectedCategory == MaintenanceCategory.members,
            onSelected: (val) {
              if (val) setState(() => _selectedCategory = MaintenanceCategory.members);
            },
            selectedColor: colorScheme.primary,
            labelStyle: TextStyle(
              color: _selectedCategory == MaintenanceCategory.members ? Colors.white : colorScheme.onSurface,
              fontWeight: _selectedCategory == MaintenanceCategory.members ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Gap(8.w),
          ChoiceChip(
            label: const Text("Reports"),
            selected: _selectedCategory == MaintenanceCategory.reports,
            onSelected: (val) {
              if (val) setState(() => _selectedCategory = MaintenanceCategory.reports);
            },
            selectedColor: colorScheme.primary,
            labelStyle: TextStyle(
              color: _selectedCategory == MaintenanceCategory.reports ? Colors.white : colorScheme.onSurface,
              fontWeight: _selectedCategory == MaintenanceCategory.reports ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return CustomTextField(
      name: 'maintenance_search',
      label: 'Search',
      hint: 'Filter by name, email, or ID...',
      prefixIcon: Icons.search,
      onChanged: (val) => setState(() => _searchQuery = val?.toLowerCase() ?? ''),
    );
  }

  Widget _buildEntityList(ColorScheme colorScheme) {
    switch (_selectedCategory) {
      case MaintenanceCategory.users:
        return _buildUsersList(colorScheme);
      case MaintenanceCategory.members:
        return _buildMembersList(colorScheme);
      case MaintenanceCategory.reports:
        return _buildReportsList(colorScheme);
    }
  }

  Widget _buildUsersList(ColorScheme colorScheme) {
    final usersAsync = ref.watch(filteredUsersProvider);
    final users = usersAsync.where((u) {
      if (_searchQuery.isEmpty) return true;
      return u.firstName.toLowerCase().contains(_searchQuery) ||
          u.lastName.toLowerCase().contains(_searchQuery) ||
          u.email.toLowerCase().contains(_searchQuery);
    }).toList();

    if (users.isEmpty) {
      return _buildEmptyState("No users found");
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (ctx, idx) => Gap(8.h),
      itemBuilder: (context, index) {
        final user = users[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          child: ListTile(
            leading: CircleAvatar(
              radius: 20.r,
              backgroundImage: NetworkImage(user.profilePicture),
              onBackgroundImageError: (exception, stackTrace) {},
              child: Text(user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?'),
            ),
            title: CustomText("${user.firstName} ${user.lastName}", fontWeight: FontWeight.bold),
            subtitle: CustomText(user.email, variant: TextVariant.bodySmall, color: colorScheme.secondary),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteEntity(
                title: "Delete User",
                message: "Are you sure you want to delete user ${user.firstName} ${user.lastName}? This action cannot be undone.",
                successMessage: "User deleted",
                onConfirm: () => ref.read(systemMaintenanceServiceProvider).deleteUser(user.id),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMembersList(ColorScheme colorScheme) {
    final appsAsync = ref.watch(allMembershipApplicationsProvider);
    return appsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => CustomText("Error: $err", color: Colors.red),
      data: (apps) {
        final filtered = apps.where((app) {
          if (_searchQuery.isEmpty) return true;
          return app.firstName.toLowerCase().contains(_searchQuery) ||
              app.lastName.toLowerCase().contains(_searchQuery) ||
              app.emailAddress.toLowerCase().contains(_searchQuery);
        }).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState("No member applications found");
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (ctx, idx) => Gap(8.h),
          itemBuilder: (context, index) {
            final app = filtered[index];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              child: ListTile(
                leading: Icon(Icons.badge_outlined, color: colorScheme.primary, size: 28.r),
                title: CustomText("${app.firstName} ${app.lastName}", fontWeight: FontWeight.bold),
                subtitle: CustomText("${app.membershipCategory.displayName} • ${app.status.value}", variant: TextVariant.bodySmall, color: colorScheme.secondary),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDeleteEntity(
                    title: "Delete Member Application",
                    message: "Are you sure you want to delete application for ${app.firstName} ${app.lastName}?",
                    successMessage: "Application deleted",
                    onConfirm: () => ref.read(systemMaintenanceServiceProvider).deleteMember(app.id),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportsList(ColorScheme colorScheme) {
    final inspectionState = ref.watch(inspectionControllerProvider).value;
    final reports = inspectionState?.allCompletedInspections ?? [];

    final filtered = reports.where((r) {
      if (_searchQuery.isEmpty) return true;
      final batch = r.batchId?.toLowerCase() ?? '';
      final farmer = r.farmerName?.toLowerCase() ?? '';
      final loc = r.location?.toLowerCase() ?? '';
      return batch.contains(_searchQuery) || farmer.contains(_searchQuery) || loc.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState("No quality reports found");
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (ctx, idx) => Gap(8.h),
      itemBuilder: (context, index) {
        final report = filtered[index];
        final displayId = report.inspectionId ?? report.id;
        final displayLoc = report.location ?? 'Ghana';

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          child: ListTile(
            leading: Icon(Icons.analytics_outlined, color: colorScheme.primary, size: 28.r),
            title: CustomText("Report #$displayId", fontWeight: FontWeight.bold),
            subtitle: CustomText("KOR: ${report.kor.toStringAsFixed(1)} lbs/80kg • $displayLoc", variant: TextVariant.bodySmall, color: colorScheme.secondary),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteEntity(
                title: "Delete Inspection Report",
                message: "Are you sure you want to delete inspection report #$displayId?",
                successMessage: "Report deleted",
                onConfirm: () => ref.read(systemMaintenanceServiceProvider).deleteReport(report.id),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: CustomText(message, color: Colors.grey),
      ),
    );
  }

  Widget _buildDangerZoneCard(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28.r),
              Gap(12.w),
              Expanded(
                child: const CustomText(
                  "Danger Zone: Purge Database",
                  variant: TextVariant.headlineMedium,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          Gap(12.h),
          const CustomText(
            "Caution: Purging database collections permanently deletes data from Firestore. "
            "This operation cannot be reversed.",
            variant: TextVariant.bodySmall,
          ),
          Gap(20.h),

          // Collection specific purges
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              OutlinedButton.icon(
                onPressed: () => _handlePurgeCollection('members', 'Members & Applications'),
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                label: const Text("Purge Members"),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
              OutlinedButton.icon(
                onPressed: () => _handlePurgeCollection('inspections', 'Inspection Reports'),
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                label: const Text("Purge Reports"),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
              OutlinedButton.icon(
                onPressed: () => _handlePurgeCollection('notifications', 'Notifications'),
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                label: const Text("Purge Notifications"),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
          Gap(20.h),
          const Divider(color: Colors.redAccent),
          Gap(16.h),

          // Full Database Purge Button
          CustomButton(
            text: _isPurging ? "Purging Database..." : "EMERGENCY FULL DATABASE PURGE",
            backgroundColor: Colors.red,
            leadingIcon: const Icon(Icons.no_crash, color: Colors.white),
            isLoading: _isPurging,
            onPressed: _isPurging ? () {} : _showFullPurgeModal,
          ),
        ],
      ),
    );
  }

  Future<void> _handleClearCache() async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cleaning_services_outlined, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text("Clear System Cache?")),
          ],
        ),
        content: const Text(
          "Are you sure you want to clear local image and memory caches? App data streams will be refreshed.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Clear Cache",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isClearingCache = true);
    try {
      await ref.read(systemMaintenanceServiceProvider).clearSystemCache();
      if (!mounted) return;
      CustomSnackBar.success(context, message: "System image & memory cache cleared successfully.");
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, message: "Failed to clear cache: $e");
    } finally {
      if (mounted) setState(() => _isClearingCache = false);
    }
  }

  void _confirmDeleteEntity({
    required String title,
    required String message,
    required String successMessage,
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await onConfirm();
              if (mounted) {
                CustomSnackBar.success(context, message: successMessage);
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurgeCollection(String collectionPath, String collectionTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Purge $collectionTitle?"),
        content: Text("Are you sure you want to delete ALL documents in '$collectionPath'? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Purge Collection"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isPurging = true);
    try {
      final count = await ref.read(systemMaintenanceServiceProvider).purgeCollection(collectionPath);
      if (!mounted) return;
      CustomSnackBar.success(context, message: "Purged $count items from $collectionTitle.");
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, message: "Purge failed: $e");
    } finally {
      if (mounted) setState(() => _isPurging = false);
    }
  }

  void _showFullPurgeModal() {
    final confirmationController = TextEditingController();
    bool canConfirmText = false;

    bool purgeUsers = true;
    bool purgeMembers = true;
    bool purgeReports = true;
    bool purgeNotifications = true;
    bool purgeSubscriptions = true;
    bool deleteActiveAdmin = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final hasSelection = purgeUsers || purgeMembers || purgeReports || purgeNotifications || purgeSubscriptions;
          final isButtonEnabled = canConfirmText && hasSelection;

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text("Emergency System Data Purge"),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select the specific data sections you want to purge from Firestore:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 12),

                    // Sections Selection Checklist
                    Material(
                      color: Colors.grey.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            dense: true,
                            title: const Text("User Accounts", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text("All user profile records in 'users'", style: TextStyle(fontSize: 11)),
                            value: purgeUsers,
                            activeColor: Colors.red,
                            onChanged: (val) {
                              setModalState(() {
                                purgeUsers = val ?? false;
                                if (!purgeUsers) deleteActiveAdmin = false;
                              });
                            },
                          ),
                          if (purgeUsers)
                            Padding(
                              padding: EdgeInsets.only(left: 16.w, right: 8.w, bottom: 8.h),
                              child: Material(
                                color: Colors.red.withValues(alpha: 0.08),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  side: BorderSide(color: Colors.red.withValues(alpha: 0.25)),
                                ),
                                child: CheckboxListTile(
                                  dense: true,
                                  title: const Text(
                                    "Delete my active admin account as well",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red),
                                  ),
                                  subtitle: const Text(
                                    "If checked, your account will be inactivated & deleted, and you will be signed out immediately.",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  value: deleteActiveAdmin,
                                  activeColor: Colors.red,
                                  onChanged: (val) {
                                    setModalState(() => deleteActiveAdmin = val ?? false);
                                  },
                                ),
                              ),
                            ),
                          const Divider(height: 1),
                          CheckboxListTile(
                            dense: true,
                            title: const Text("Members & Applications", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text("All member records in 'members'", style: TextStyle(fontSize: 11)),
                            value: purgeMembers,
                            activeColor: Colors.red,
                            onChanged: (val) => setModalState(() => purgeMembers = val ?? false),
                          ),
                          const Divider(height: 1),
                          CheckboxListTile(
                            dense: true,
                            title: const Text("Quality Inspection Reports", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text("All inspection reports in 'inspections'", style: TextStyle(fontSize: 11)),
                            value: purgeReports,
                            activeColor: Colors.red,
                            onChanged: (val) => setModalState(() => purgeReports = val ?? false),
                          ),
                          const Divider(height: 1),
                          CheckboxListTile(
                            dense: true,
                            title: const Text("Notifications & Bulletins", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text("All alerts in 'notifications'", style: TextStyle(fontSize: 11)),
                            value: purgeNotifications,
                            activeColor: Colors.red,
                            onChanged: (val) => setModalState(() => purgeNotifications = val ?? false),
                          ),
                          const Divider(height: 1),
                          CheckboxListTile(
                            dense: true,
                            title: const Text("Newsletter Subscriptions", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text("All subscriptions in 'newsletter_subscriptions'", style: TextStyle(fontSize: 11)),
                            value: purgeSubscriptions,
                            activeColor: Colors.red,
                            onChanged: (val) => setModalState(() => purgeSubscriptions = val ?? false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("To confirm, type 'PURGE DATABASE' below:"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: confirmationController,
                      decoration: const InputDecoration(
                        hintText: "PURGE DATABASE",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          canConfirmText = val.trim() == "PURGE DATABASE";
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: isButtonEnabled
                    ? () async {
                        Navigator.pop(ctx);
                        _executeFullDatabasePurge(
                          purgeUsers: purgeUsers,
                          purgeMembers: purgeMembers,
                          purgeReports: purgeReports,
                          purgeNotifications: purgeNotifications,
                          purgeSubscriptions: purgeSubscriptions,
                          deleteActiveAdmin: deleteActiveAdmin,
                        );
                      }
                    : null,
                child: const Text("CONFIRM PURGE"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _executeFullDatabasePurge({
    required bool purgeUsers,
    required bool purgeMembers,
    required bool purgeReports,
    required bool purgeNotifications,
    required bool purgeSubscriptions,
    required bool deleteActiveAdmin,
  }) async {
    setState(() => _isPurging = true);
    try {
      final admin = ref.read(authServiceProvider).currentUser;
      if (admin == null) throw Exception("Not authenticated as admin");

      final results = await ref.read(systemMaintenanceServiceProvider).purgeSelectedDatabase(
        currentAdminUid: admin.uid,
        purgeUsers: purgeUsers,
        purgeMembers: purgeMembers,
        purgeReports: purgeReports,
        purgeNotifications: purgeNotifications,
        purgeSubscriptions: purgeSubscriptions,
        deleteActiveAdmin: deleteActiveAdmin,
      );

      if (!mounted) return;
      final summary = results.entries.map((e) => "${e.key}: ${e.value}").join(", ");

      if (deleteActiveAdmin) {
        CustomSnackBar.success(context, message: "Selected Purge Complete including Admin Account. Signing out...");
        await ref.read(authControllerProvider.notifier).signOut();
      } else {
        CustomSnackBar.success(context, message: "Purge Complete! ($summary)");
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, message: "Failed to purge database: $e");
    } finally {
      if (mounted) setState(() => _isPurging = false);
    }
  }
}
