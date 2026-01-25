import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:cqaag_app/index.dart';
import 'package:intl/intl.dart';

class GuestEventsScreen extends StatelessWidget {
  static const String id = 'guest_events_screen';

  const GuestEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = Event.getMockEvents();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Hero Section
          _buildHeroSection(context),

          Gap(40.h),

          // Events Grid
          _buildEventsGrid(context, events),

          Gap(40.h),

          // Newsletter Section
          _buildNewsletterSection(context),

          Gap(20.h),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBrown,
            AppColors.darkRed,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: <Widget>[
          const CustomText(
            'Updates & Events',
            variant: TextVariant.displaySmall,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          Gap(12.h),
          const CustomText(
            'Latest updates, announcements, and industry insights from C.Q.A.A.G',
            variant: TextVariant.bodyMedium,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsGrid(BuildContext context, List<Event> events) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 20.h,
          childAspectRatio: 0.75, // Adjusted for mobile to give more height
        ),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return _buildEventCard(context, events[index]);
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Event Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
            child: Container(
              height: 180.h,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(event.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Category Badge
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

                  Gap(12.h),

                  // Event Title
                  CustomText(
                    event.title,
                    variant: TextVariant.headlineSmall,
                    fontWeight: FontWeight.bold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Gap(8.h),

                  // Event Description
                  Expanded(
                    child: CustomText(
                      event.description,
                      variant: TextVariant.bodySmall,
                      color: colorScheme.secondary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  Gap(12.h),

                  // Date and Read More Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CustomText(
                        dateFormat.format(event.date),
                        variant: TextVariant.bodySmall,
                        color: colorScheme.secondary,
                      ),
                      CustomButton(
                        text: 'Read More',
                        backgroundColor: AppColors.darkBrown,
                        onPressed: () {
                          context.pushNamed(
                            GuestEventDetailsScreen.id,
                            extra: event,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsletterSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBrown,
            AppColors.darkRed,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: <Widget>[
          const CustomText(
            'Stay Updated',
            variant: TextVariant.displaySmall,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          Gap(12.h),
          const CustomText(
            'Subscribe to our newsletter for the latest news and updates from C.Q.A.A.G',
            variant: TextVariant.bodyMedium,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          Gap(24.h),
          // Mobile-optimized Column layout
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomTextField(
                name: 'email',
                label: '',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              Gap(12.h),
              CustomButton(
                text: 'Subscribe',
                backgroundColor: AppColors.grayOrange,
                onPressed: () {
                  // TODO: Implement newsletter subscription
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
