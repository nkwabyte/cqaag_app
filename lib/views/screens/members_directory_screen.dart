import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';
import 'package:cqaag_app/services/membership/legacy_register.dart';

/// The official CQAAG Members Directory / Register Screen.
/// Displays all 98 registered legacy Full Members with their unique IDs (CQAAG-FM-001..098),
/// cards status, and location, providing search, filters, and profile claiming for unlinked accounts.
class MembersDirectoryScreen extends ConsumerStatefulWidget {
  static const String id = 'members_directory_screen';

  const MembersDirectoryScreen({super.key});

  @override
  ConsumerState<MembersDirectoryScreen> createState() => _MembersDirectoryScreenState();
}

class _MembersDirectoryScreenState extends ConsumerState<MembersDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRegion = 'All';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    // Auto-seed legacy members to Firestore in background if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membershipServiceProvider).seedLegacyMembers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final membersAsync = ref.watch(membersDirectoryProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const CustomText(
          'Members Directory',
          variant: TextVariant.bodyLarge,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.darkRed,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: membersAsync.when(
        data: (members) {
          final filtered = members.where((m) {
            final name = (m['full_name'] ?? m['first_name'] ?? '').toString().toLowerCase();
            final memberId = (m['member_id'] ?? '').toString().toLowerCase();
            final phone = (m['phone_number_primary'] ?? '').toString().toLowerCase();
            final company = (m['employer_organization'] ?? '').toString().toLowerCase();
            final location = (m['region_district'] ?? m['residential_address'] ?? '').toString().toLowerCase();
            final q = _searchQuery.toLowerCase().trim();

            final matchesQuery = q.isEmpty ||
                name.contains(q) ||
                memberId.contains(q) ||
                phone.contains(q) ||
                company.contains(q) ||
                location.contains(q);

            if (!matchesQuery) return false;

            if (_selectedRegion != 'All') {
              if (!location.contains(_selectedRegion.toLowerCase())) {
                return false;
              }
            }

            if (_selectedStatus == 'Card Issued') {
              final card = (m['card_status'] ?? '').toString().toLowerCase();
              if (!card.contains('issued')) return false;
            } else if (_selectedStatus == 'Claimed') {
              final isClaimed = m['is_claimed'] == true;
              if (!isClaimed) return false;
            } else if (_selectedStatus == 'Pending Activation') {
              final isClaimed = m['is_claimed'] == true;
              if (isClaimed) return false;
            }

            return true;
          }).toList();

          return Column(
            children: [
              // Header Summary Banner
              _buildHeaderBanner(context, members),

              // Search & Filter controls
              _buildSearchBar(colorScheme),

              // Filter Chips
              _buildFilterChips(colorScheme),

              // Results Count Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      'Showing ${filtered.length} of ${members.length} members',
                      variant: TextVariant.bodySmall,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                    if (_searchQuery.isNotEmpty || _selectedRegion != 'All' || _selectedStatus != 'All')
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _selectedRegion = 'All';
                            _selectedStatus = 'All';
                          });
                        },
                        child: CustomText(
                          'Reset Filters',
                          variant: TextVariant.bodySmall,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              // Members List
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(colorScheme)
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => Gap(12.h),
                        itemBuilder: (context, index) {
                          final member = filtered[index];
                          return _buildMemberCard(context, member, colorScheme);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading directory: $err')),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, List<Map<String, dynamic>> members) {
    final issuedCount = members.where((m) => (m['card_status'] ?? '').toString().toLowerCase().contains('issued')).length;
    final regionsCount = members.map((m) {
      final loc = (m['region_district'] ?? m['region'] ?? '').toString();
      final parts = loc.split(',');
      return parts.length > 1 ? parts.last.trim() : loc.trim();
    }).where((r) => r.isNotEmpty).toSet().length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.darkRed,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.gold, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14.r, color: AppColors.gold),
                    Gap(4.w),
                    CustomText(
                      'OFFICIAL REGISTER',
                      variant: TextVariant.bodySmall,
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CustomText(
                'Full Members (Art. 2)',
                variant: TextVariant.bodySmall,
                color: Colors.white70,
              ),
            ],
          ),
          Gap(12.h),
          const CustomText(
            'Certified Cashew Quality Analysts',
            variant: TextVariant.headlineSmall,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          Gap(4.h),
          CustomText(
            'Members recognized on the Association Register with cards issued and voting rights.',
            variant: TextVariant.bodySmall,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          Gap(16.h),
          Row(
            children: [
              _buildStatChip('Total Register', '${members.length}', Icons.people_outline),
              Gap(12.w),
              _buildStatChip('Cards Issued', '$issuedCount', Icons.badge_outlined),
              Gap(12.w),
              _buildStatChip('Regions', '$regionsCount', Icons.map_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.r, color: Colors.white),
            Gap(8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  value,
                  variant: TextVariant.bodyMedium,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  label,
                  variant: TextVariant.bodySmall,
                  color: Colors.white70,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            isDense: true,
            hintText: "Search name, ID (e.g. CQAAG-FM-001), phone, district...",
            hintStyle: TextStyle(fontSize: 12.sp, color: Colors.black38),
            prefixIcon: Icon(Icons.search, size: 20.r, color: AppColors.primaryGreen),
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
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    final regions = ['All', 'Bono', 'Bono East', 'Savannah', 'Greater Accra', 'Western', 'Upper East'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        children: [
          ...regions.map((region) {
            final isSelected = _selectedRegion == region;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: ChoiceChip(
                label: Text(region, style: TextStyle(fontSize: 12.sp)),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primaryGreen : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
                ),
                onSelected: (val) {
                  setState(() {
                    _selectedRegion = region;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, Map<String, dynamic> member, ColorScheme colorScheme) {
    final memberId = (member['member_id'] ?? '').toString();
    final name = (member['full_name'] ?? '${member['first_name'] ?? ''} ${member['last_name'] ?? ''}').toString().trim();
    final location = (member['region_district'] ?? member['residential_address'] ?? 'Ghana').toString();
    final company = (member['employer_organization'] ?? '').toString();
    final phone = (member['phone_number_primary'] ?? '').toString();
    final cardStatus = (member['card_status'] ?? '').toString();
    final isClaimed = member['is_claimed'] == true;
    final hasCard = cardStatus.toLowerCase().contains('issued');

    return InkWell(
      onTap: () => _showMemberDetailsModal(context, member),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
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
            // Top Row: ID Badge + Status Badge
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.badge, size: 13.r, color: AppColors.primaryGreen),
                      Gap(4.w),
                      CustomText(
                        memberId.isNotEmpty ? memberId : 'MEMBER',
                        variant: TextVariant.bodySmall,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (hasCard)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 12.r, color: Colors.green.shade700),
                        Gap(4.w),
                        CustomText(
                          'Card Issued',
                          variant: TextVariant.bodySmall,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                Gap(6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isClaimed ? Colors.blue.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: CustomText(
                    isClaimed ? 'Active' : 'Unclaimed',
                    variant: TextVariant.bodySmall,
                    color: isClaimed ? Colors.blue.shade800 : Colors.amber.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Gap(10.h),

            // Member Name
            CustomText(
              name.isNotEmpty ? name : 'Full Member',
              variant: TextVariant.bodyLarge,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            Gap(6.h),

            // Company & Location
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14.r, color: Colors.grey.shade600),
                Gap(4.w),
                Expanded(
                  child: CustomText(
                    location,
                    variant: TextVariant.bodySmall,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            if (company.isNotEmpty && company != 'N/A') ...[
              Gap(4.h),
              Row(
                children: [
                  Icon(Icons.business_outlined, size: 14.r, color: Colors.grey.shade600),
                  Gap(4.w),
                  Expanded(
                    child: CustomText(
                      company,
                      variant: TextVariant.bodySmall,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            Gap(10.h),
            const Divider(height: 1),
            Gap(10.h),

            // Bottom Actions Row
            Row(
              children: [
                if (phone.isNotEmpty) ...[
                  Icon(Icons.phone_outlined, size: 13.r, color: Colors.grey.shade500),
                  Gap(4.w),
                  CustomText(
                    phone,
                    variant: TextVariant.bodySmall,
                    color: Colors.grey.shade600,
                  ),
                ],
                const Spacer(),
                if (!isClaimed)
                  InkWell(
                    onTap: () {
                      final legacyEntry = LegacyRegister.match(memberId) ?? LegacyRegister.findByName(name);
                      if (legacyEntry != null) {
                        context.pushNamed(RegisterScreen.id, extra: {'legacyMember': legacyEntry});
                      } else {
                        context.pushNamed(RegisterScreen.id);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add_alt_1, size: 13.r, color: Colors.white),
                          Gap(4.w),
                          const CustomText(
                            'Claim Profile',
                            variant: TextVariant.bodySmall,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.verified_user, size: 14.r, color: Colors.blue.shade700),
                      Gap(4.w),
                      CustomText(
                        'Verified Member',
                        variant: TextVariant.bodySmall,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberDetailsModal(BuildContext context, Map<String, dynamic> member) {
    final memberId = (member['member_id'] ?? '').toString();
    final name = (member['full_name'] ?? '${member['first_name'] ?? ''} ${member['last_name'] ?? ''}').toString();
    final location = (member['region_district'] ?? member['residential_address'] ?? 'Ghana').toString();
    final company = (member['employer_organization'] ?? '').toString();
    final phone = (member['phone_number_primary'] ?? '').toString();
    final cardStatus = (member['card_status'] ?? '').toString();
    final edu = (member['education'] is Map ? member['education']['level'] : '').toString();
    final isClaimed = member['is_claimed'] == true;
    final earlierPaid = member['earlier_ghc60_paid'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Gap(20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26.r,
                    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1) : 'M',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  Gap(16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: CustomText(
                            memberId,
                            variant: TextVariant.bodySmall,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Gap(4.h),
                        CustomText(
                          name,
                          variant: TextVariant.headlineSmall,
                          fontWeight: FontWeight.bold,
                        ),
                        CustomText(
                          'Full Member (Ghanaian Analyst)',
                          variant: TextVariant.bodySmall,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(20.h),
              const Divider(),
              Gap(12.h),

              _buildDetailRow('Location', location, Icons.location_on_outlined),
              if (company.isNotEmpty && company != 'N/A')
                _buildDetailRow('Company / Employer', company, Icons.business_outlined),
              if (phone.isNotEmpty)
                _buildDetailRow('Telephone', phone, Icons.phone_outlined),
              if (edu.isNotEmpty)
                _buildDetailRow('Education Qualification', edu, Icons.school_outlined),
              _buildDetailRow('Physical Card', cardStatus.isNotEmpty ? cardStatus : 'Pending', Icons.badge_outlined),
              _buildDetailRow(
                'Registration Tariff',
                earlierPaid ? 'GH₵ 200 (Earlier GH₵60 Credited)' : 'GH₵ 320 (Standard Full Rate)',
                Icons.payments_outlined,
              ),
              _buildDetailRow(
                'Annual Dues',
                'GH₵ 200 (60% Chapter / 40% National)',
                Icons.account_balance_wallet_outlined,
              ),
              _buildDetailRow(
                'Payable on Activation',
                earlierPaid ? 'GH₵ 400 Total' : 'GH₵ 520 Total',
                Icons.receipt_outlined,
              ),

              Gap(24.h),
              if (!isClaimed) ...[
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20.r),
                      Gap(10.w),
                      Expanded(
                        child: CustomText(
                          'This is your profile? Sign up or sign in to claim this record and link it to your account.',
                          variant: TextVariant.bodySmall,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(16.h),
                CustomButton(
                  text: 'Claim & Activate This Profile',
                  onPressed: () {
                    Navigator.pop(context);
                    final legacyEntry = LegacyRegister.match(memberId) ?? LegacyRegister.findByName(name);
                    context.pushNamed(RegisterScreen.id, extra: {'legacyMember': legacyEntry});
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.r, color: AppColors.primaryGreen),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label,
                  variant: TextVariant.bodySmall,
                  color: Colors.grey.shade600,
                ),
                CustomText(
                  value,
                  variant: TextVariant.bodyMedium,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 56.r, color: Colors.grey.shade400),
            Gap(12.h),
            const CustomText(
              'No Members Found',
              variant: TextVariant.headlineSmall,
              fontWeight: FontWeight.bold,
            ),
            Gap(6.h),
            CustomText(
              'No member records match "$_searchQuery" in the selected filters.',
              variant: TextVariant.bodySmall,
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
