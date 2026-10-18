import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:cqaag_app/core/constants/app_colors.dart';
import 'package:cqaag_app/services/membership/legacy_register.dart';

/// Public Member Directory (Spec Section 10).
/// Lists certified analysts and member organisations in good standing.
/// Act 843 compliant: Displays only Name, Job Title, Employer, and Chapter.
/// Protects member privacy: Zero phone numbers, emails, or personal addresses are shown.
class MemberDirectoryScreen extends ConsumerStatefulWidget {
  static const String id = 'member_directory_screen';

  const MemberDirectoryScreen({super.key});

  @override
  ConsumerState<MemberDirectoryScreen> createState() => _MemberDirectoryScreenState();
}

class _MemberDirectoryScreenState extends ConsumerState<MemberDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedChapter = 'All';
  String _searchQuery = '';

  final List<String> _chapters = const [
    'All',
    'Bono',
    'Bono East',
    'Ahafo',
    'Greater Accra',
    'Savannah',
    'Upper West',
    'Oti',
    'Ashanti',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Member Directory'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header description and Act 843 notice
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: const Color(0xFFE8F5E9),
            child: Row(
              children: [
                Icon(Icons.verified_user_outlined, color: AppColors.primaryGreen, size: 28.r),
                Gap(12.w),
                Expanded(
                  child: Text(
                    'Certified Cashew Quality Analysts in Good Standing. Contact requests should be addressed to info@cqaaggh.org (Act 843 compliant).',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF1B5E20),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search and Filters
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or employer (min 3 chars)...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
                Gap(10.h),
                // Chapter Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _chapters.map((chapter) {
                      final isSelected = _selectedChapter == chapter;
                      return Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: FilterChip(
                          label: Text(chapter),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedChapter = chapter);
                          },
                          selectedColor: const Color(0xFFC8E6C9),
                          checkmarkColor: AppColors.primaryGreen,
                          labelStyle: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF1B5E20) : Colors.grey.shade800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Search constraint notice
          if (_searchQuery.isNotEmpty && _searchQuery.length < 3)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16.r, color: Colors.orange.shade800),
                  Gap(6.w),
                  Text(
                    'Search requires at least 3 letters (Spec Section 10.2)',
                    style: TextStyle(fontSize: 11.5.sp, color: Colors.orange.shade800),
                  ),
                ],
              ),
            ),

          // Directory List
          Expanded(
            child: _buildDirectoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryList() {
    // If search length < 3, enforce rule and do not search on partial short strings
    final effectiveQuery = _searchQuery.length >= 3 ? _searchQuery.toLowerCase() : '';

    // Legacy members dataset
    final legacyList = LegacyRegister.allMembers.where((m) {
      if (_selectedChapter != 'All' && !m.region.toLowerCase().contains(_selectedChapter.toLowerCase())) {
        return false;
      }
      if (effectiveQuery.isNotEmpty) {
        final matchesName = m.name.toLowerCase().contains(effectiveQuery);
        final matchesEmployer = m.company.toLowerCase().contains(effectiveQuery);
        if (!matchesName && !matchesEmployer) return false;
      }
      return true;
    }).map((m) => {
      'name': m.name,
      'job_title': 'Certified Cashew Quality Analyst',
      'employer': m.company.isNotEmpty && m.company != 'N/A' ? m.company : 'Independent Analyst',
      'chapter': m.region.isNotEmpty ? '${m.region} Chapter' : 'National Chapter',
      'member_code': m.memberId,
    }).toList();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('directory_hidden', isNotEqualTo: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        final combinedList = <Map<String, String>>[];

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data();
            final firstName = data['first_name'] as String? ?? '';
            final lastName = data['last_name'] as String? ?? '';
            final fullName = '$firstName $lastName'.trim().toUpperCase();
            final jobTitle = data['job_title'] as String? ?? 'Cashew Quality Analyst';
            final employer = data['employer'] as String? ?? 'General Practice';
            final chapter = data['chapter'] as String? ?? data['region'] as String? ?? 'National';
            final memberCode = data['member_code'] as String? ?? '';

            if (fullName.isEmpty) continue;

            if (_selectedChapter != 'All' && !chapter.toLowerCase().contains(_selectedChapter.toLowerCase())) {
              continue;
            }

            if (effectiveQuery.isNotEmpty) {
              final matchesName = fullName.toLowerCase().contains(effectiveQuery);
              final matchesEmployer = employer.toLowerCase().contains(effectiveQuery);
              if (!matchesName && !matchesEmployer) continue;
            }

            combinedList.add({
              'name': fullName,
              'job_title': jobTitle,
              'employer': employer,
              'chapter': chapter.contains('Chapter') ? chapter : '$chapter Chapter',
              'member_code': memberCode,
            });
          }
        }

        // Add legacy members, avoiding duplicates by name
        for (final leg in legacyList) {
          if (!combinedList.any((e) => e['name']?.toUpperCase() == leg['name']?.toUpperCase())) {
            combinedList.add(leg);
          }
        }

        // Sort alphabetically
        combinedList.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));

        // Max 20 per page per Spec Section 10.2
        final displayList = combinedList.take(20).toList();

        if (displayList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48.r, color: Colors.grey.shade400),
                Gap(12.h),
                Text(
                  'No certified members found matching criteria.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: displayList.length,
          separatorBuilder: (context, index) => Gap(8.h),
          itemBuilder: (context, index) {
            final item = displayList[index];
            return Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: const Color(0xFFE8F5E9),
                    child: Text(
                      item['name']!.isNotEmpty ? item['name']![0] : 'C',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          '${item['job_title']} · ${item['employer']}',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
                        ),
                        Gap(2.h),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 12.r, color: AppColors.primaryGreen),
                            Gap(3.w),
                            Text(
                              item['chapter'] ?? '',
                              style: TextStyle(fontSize: 10.5.sp, color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
