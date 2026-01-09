import 'package:cqaag_app/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class BoardingScreen extends StatefulWidget {
  static final String id = 'boarding_screen';

  const BoardingScreen({super.key});

  @override
  State<BoardingScreen> createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<BoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<BoardingData> _boardingContent = [
    BoardingData(
      title: "Welcome to CQAAG",
      description: "Your mobile companion for cashew quality inspection and certification across Ghana.",
      icon: Icons.shield_outlined,
    ),
    BoardingData(
      title: "Mobile Inspection",
      description: "Conduct field inspections with photo documentation, GPS tracking, and offline support.",
      icon: Icons.camera_alt_outlined,
    ),
    BoardingData(
      title: "Real-Time Tracking",
      description: "Track batch traceability from farm to export with complete supply chain visibility.",
      icon: Icons.location_on_outlined,
    ),
    BoardingData(
      title: "Digital Certification",
      description: "Generate instant quality certificates with QR codes for verification.",
      icon: Icons.verified_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _boardingContent.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to Login Screen
      context.goNamed(LoginScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button at the top
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                child: GestureDetector(
                  onTap: () {
                    context.goNamed(LoginScreen.id);
                  },
                  child: CustomText(
                    "Skip",
                    variant: TextVariant.bodyMedium,
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Swipeable content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _boardingContent.length,
                itemBuilder: (context, index) {
                  final data = _boardingContent[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Circle
                        Container(
                          width: 140.r,
                          height: 140.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.secondary.withValues(alpha: 0.15),
                          ),
                          child: Icon(
                            data.icon,
                            size: 60.r,
                            color: colorScheme.onSurface, // darkRed
                          ),
                        ),
                        Gap(60.h),
                        CustomText(
                          data.title,
                          variant: TextVariant.displaySmall,
                          textAlign: TextAlign.center,
                          color: colorScheme.onSurface,
                        ),
                        Gap(20.h),
                        CustomText(
                          data.description,
                          variant: TextVariant.bodyLarge,
                          textAlign: TextAlign.center,
                          color: colorScheme.secondary,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicators and Button Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              child: Column(
                children: [
                  // Progress Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _boardingContent.length,
                      (index) => _buildIndicator(index == _currentPage, colorScheme),
                    ),
                  ),
                  Gap(40.h),

                  // Main Action Button
                  CustomButton(
                    text: _currentPage == _boardingContent.length - 1 ? "Get Started" : "Next",
                    trailingIcon: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 20.r,
                    ),
                    onPressed: _onNextPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive, ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: isActive ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: isActive ? colorScheme.onSurface : colorScheme.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
