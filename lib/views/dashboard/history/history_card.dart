import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class HistoryCard extends StatelessWidget {
  final String title;
  final String? inspectionsCount;
  final String? communitiesCount;
  final String totalKg;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.title,
    this.inspectionsCount,
    this.communitiesCount,
    required this.totalKg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.12), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(18.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.mintLight,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primaryGreen,
                        size: 20.r,
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            title,
                            variant: TextVariant.headlineSmall,
                            fontWeight: FontWeight.bold,
                          ),
                          Gap(2.h),
                          Text(
                            "Verified District Zone",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.lightOrange,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: AppColors.primaryGreen,
                        size: 18.r,
                      ),
                    ),
                  ],
                ),
                Gap(14.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 6.h,
                  children: [
                    if (inspectionsCount != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: AppColors.mintLight.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.tcdaAccentGreen.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 14.r,
                              color: AppColors.primaryGreen,
                            ),
                            Gap(6.w),
                            Text(
                              "$inspectionsCount certificates",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (communitiesCount != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.holiday_village_outlined,
                              size: 14.r,
                              color: Colors.black54,
                            ),
                            Gap(6.w),
                            Text(
                              "$communitiesCount communities",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Gap(12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.lightOrangeCard,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          Icon(
                            Icons.scale_outlined,
                            size: 16.r,
                            color: AppColors.primaryGreen,
                          ),
                          Gap(6.w),
                          Text(
                            "Total Verified Weight",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkRed,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "$totalKg KG",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildHistoryHeader(
  BuildContext context,
  String title,
  String sub,
  ColorScheme colorScheme, {
  bool showBack = false,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.darkRed,
          Color(0xFF073814),
        ],
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(28.r),
        bottomRight: Radius.circular(28.r),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (showBack) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14.r),
                    Gap(6.w),
                    const CustomText("Back", color: Colors.white, fontWeight: FontWeight.w600),
                  ],
                ),
              ),
            ),
            Gap(16.h),
          ],
          CustomText(
            title,
            variant: TextVariant.headlineMedium,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          Gap(6.h),
          CustomText(
            sub,
            color: AppColors.mintLight.withValues(alpha: 0.95),
            variant: TextVariant.bodyMedium,
          ),
        ],
      ),
    ),
  );
}
