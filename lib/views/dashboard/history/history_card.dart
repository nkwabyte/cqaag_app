import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class HistoryCard extends StatelessWidget {
  final String title;
  final String? inspectionsCount;
  final String? communitiesCount;
  final String totalMT;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.title,
    this.inspectionsCount,
    this.communitiesCount,
    required this.totalMT,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: colorScheme.primary, size: 24.r),
                  Gap(12.w),
                  Expanded(
                    child: CustomText(title, variant: TextVariant.displaySmall),
                  ),
                  Icon(Icons.chevron_right, color: colorScheme.secondary),
                ],
              ),
              Gap(16.h),
              Row(
                children: [
                  if (inspectionsCount != null) ...[
                    Icon(Icons.assignment_outlined, size: 18.r, color: AppColors.deepGrayOrange),
                    Gap(6.w),
                    CustomText("$inspectionsCount inspections", color: AppColors.deepGrayOrange),
                    Gap(20.w),
                  ],
                  if (communitiesCount != null) ...[
                    Icon(Icons.share_location_outlined, size: 18.r, color: AppColors.deepGrayOrange),
                    Gap(6.w),
                    CustomText("$communitiesCount communities", color: AppColors.deepGrayOrange),
                  ],
                ],
              ),
              Gap(12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const CustomText(
                    "Total: ",
                    variant: TextVariant.bodyLarge,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomText(
                    "$totalMT MT",
                    variant: TextVariant.bodyLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ],
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
    padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 30.h),
    decoration: BoxDecoration(
      color: colorScheme.onSurface,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(50.r),
        bottomRight: Radius.circular(50.r),
      ),
    ),
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (showBack) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: <Widget>[
                  Icon(Icons.chevron_left, color: Colors.white, size: 20.r),
                  Gap(4.w),
                  const CustomText("Back", color: Colors.white),
                ],
              ),
            ),
            Gap(20.h),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomText(
                      title,
                      variant: TextVariant.bodyLarge,
                      color: Colors.white,
                    ),
                    Gap(8.h),
                    CustomText(sub, color: colorScheme.secondary),
                  ],
                ),
              ),
              Gap(8.0.w),
              CustomButton(
                text: "Export",
                width: 110.w,
                height: 45.h,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                leadingIcon: const Icon(Icons.file_download_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
