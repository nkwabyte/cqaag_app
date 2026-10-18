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

          // 3. Regulatory & Audit Compliance (Rules R9 & R11)
          _buildAuditComplianceCard(colorScheme),
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
          "Record Correction & Audit",
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        Gap(4.h),
        CustomText(
          "In accordance with Rule R9, records are append-only. Corrections emit an immutable CANCEL event with mandatory justification.",
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
            label: const Text("Certificates"),
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
              icon: Icon(Icons.cancel_outlined, color: Colors.amber.shade800),
              tooltip: "Record CANCEL Event",
              onPressed: () => _confirmCancelEntity(
                title: "Cancel User Record",
                targetType: "User",
                targetIdentifier: "${user.firstName} ${user.lastName}",
                collectionPath: 'users',
                documentId: user.id,
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
                  icon: Icon(Icons.cancel_outlined, color: Colors.amber.shade800),
                  tooltip: "Record CANCEL Event",
                  onPressed: () => _confirmCancelEntity(
                    title: "Cancel Member Application",
                    targetType: "Member Application",
                    targetIdentifier: "${app.firstName} ${app.lastName}",
                    collectionPath: 'members',
                    documentId: app.id,
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
      return _buildEmptyState("No quality certificates found");
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
            title: CustomText("Certificate #$displayId", fontWeight: FontWeight.bold),
            subtitle: CustomText("KOR: ${report.kor.toStringAsFixed(1)} lbs/80kg • $displayLoc", variant: TextVariant.bodySmall, color: colorScheme.secondary),
            trailing: IconButton(
              icon: Icon(Icons.cancel_outlined, color: Colors.amber.shade800),
              tooltip: "Record CANCEL Event",
              onPressed: () => _confirmCancelEntity(
                title: "Cancel Quality Certificate",
                targetType: "Certificate",
                targetIdentifier: "#$displayId",
                collectionPath: 'inspections',
                documentId: report.id,
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

  Widget _buildAuditComplianceCard(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF143D2B).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF143D2B).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, color: const Color(0xFF143D2B), size: 28.r),
              Gap(12.w),
              Expanded(
                child: const CustomText(
                  "Regulatory & Audit Compliance (Rules R9 & R11)",
                  variant: TextVariant.headlineMedium,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF143D2B),
                ),
              ),
            ],
          ),
          Gap(12.h),
          const CustomText(
            "Destructive purges are permanently disabled. The CQAAG ledger is strictly append-only. All certificates, lots, inspections, and member histories are statutory evidence for the Tree Crops Development Authority (TCDA), the Ghana Standards Authority (GSA), and the Board, retained for a minimum of 7 years. Any administrative corrections must be issued as traceable event logs (CANCEL) preserving the original record.",
            variant: TextVariant.bodySmall,
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

  void _confirmCancelEntity({
    required String title,
    required String targetType,
    required String targetIdentifier,
    required String collectionPath,
    required String documentId,
  }) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.history_edu, color: Colors.amber.shade900),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rule R9 Compliance: This $targetType ($targetIdentifier) will not be deleted. An immutable CANCEL event will be appended to the statutory audit ledger.",
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Text(
              "Reason for Cancellation (Required):",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: "Enter regulatory reason for correction...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Keep Intact")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900),
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                CustomSnackBar.error(context, message: "A justification reason is required per Rule R9.");
                return;
              }
              Navigator.pop(ctx);
              final currentAdmin = ref.read(authServiceProvider).currentUser;
              try {
                await ref.read(systemMaintenanceServiceProvider).cancelRecord(
                  collectionPath: collectionPath,
                  documentId: documentId,
                  reason: reason,
                  officerId: currentAdmin?.uid,
                );
                if (mounted) {
                  CustomSnackBar.success(context, message: "Cancellation event appended to audit ledger.");
                }
              } catch (e) {
                if (mounted) {
                  CustomSnackBar.error(context, message: "Failed to record cancellation: $e");
                }
              }
            },
            child: const Text("Record CANCEL Event", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
