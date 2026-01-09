import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        context.goNamed(BoardingScreen.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Accessing theme data
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Uses the background color defined in AppTheme
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(flex: 3),

            // Logo Image (SVG)
            SvgPicture.asset(
                  Assets.svgLogoWhite,
                  width: 180.w,
                )
                .animate()
                .fade(duration: 800.ms)
                .scale(
                  delay: 200.ms,
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),

            Gap(40.h),

            // Slogan using the CustomText widget
            CustomText(
                  "Guardians of Ghana's\nCashew Quality",
                  variant: TextVariant.bodyLarge,
                  color: colorScheme.secondary.withValues(alpha: 0.9),
                  textAlign: TextAlign.center,
                  fontStyle: FontStyle.italic,
                )
                .animate()
                .fade(delay: 600.ms, duration: 800.ms)
                .moveY(begin: 20, end: 0, delay: 600.ms, curve: Curves.easeOut),

            const Spacer(flex: 2),

            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildDot(delay: 0),
                Gap(8.w),
                _buildDot(delay: 300),
                Gap(8.w),
                _buildDot(delay: 600),
              ],
            ),

            Gap(60.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required int delay}) {
    final colorScheme = Theme.of(context).colorScheme;
    final inactiveColor = colorScheme.onSurface.withValues(alpha: 0.2);
    final activeColor = colorScheme.secondary;

    return Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: inactiveColor,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          delay: delay.ms,
          duration: 600.ms,
          begin: const Offset(1, 1),
          end: const Offset(1.5, 1.5),
        )
        .tint(
          color: activeColor,
          delay: delay.ms,
          duration: 600.ms,
        );
  }
}
