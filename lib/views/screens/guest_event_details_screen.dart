import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:cqaag_app/index.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class GuestEventDetailsScreen extends StatelessWidget {
  static const String id = 'guest_event_details_screen';
  final Event event;

  const GuestEventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const CustomText(
          'Event Details',
          variant: TextVariant.bodyLarge,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Hero Image
              _buildHeroImage(),

              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Category and Date
                    Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColors.lightOrange,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: CustomText(
                            event.category.label,
                            variant: TextVariant.bodySmall,
                            color: AppColors.darkBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Gap(12.w),
                        CustomText(
                          dateFormat.format(event.date),
                          variant: TextVariant.bodySmall,
                          color: colorScheme.secondary,
                        ),
                      ],
                    ),

                    Gap(16.h),

                    // Event Title
                    CustomText(
                      event.title,
                      variant: TextVariant.displaySmall,
                      fontWeight: FontWeight.bold,
                    ),

                    if (event.author != null) ...[
                      Gap(8.h),
                      CustomText(
                        'By ${event.author}',
                        variant: TextVariant.bodyMedium,
                        color: colorScheme.secondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ],

                    Gap(24.h),

                    // Event Content
                    _buildEventContent(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 250.h,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(event.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildEventContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MarkdownBody(
      data: event.content,
      styleSheet: MarkdownStyleSheet(
        h1: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBrown,
          height: 1.3,
        ),
        h2: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBrown,
          height: 1.3,
        ),
        h3: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.darkBrown,
          height: 1.3,
        ),
        p: TextStyle(
          fontSize: 14.sp,
          color: colorScheme.secondary,
          height: 1.6,
        ),
        listBullet: TextStyle(
          fontSize: 14.sp,
          color: AppColors.darkBrown,
        ),
        strong: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.darkBrown,
        ),
        blockSpacing: 16.h,
        listIndent: 24.w,
      ),
    );
  }
}
