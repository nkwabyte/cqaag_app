import 'package:flutter/material.dart';

/// Centralized animation configuration for consistent timing and curves
class AnimationConfigs {
  // Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 600);

  // Delays for staggered animations
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration cardDelay = Duration(milliseconds: 100);
  static const Duration itemDelay = Duration(milliseconds: 80);

  // Curves
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve sharpCurve = Curves.easeOutExpo;
  static const Curve smoothCurve = Curves.easeInOutCubic;

  // Slide distances
  static const double slideDistance = 0.2;
  static const double slideDistanceLarge = 0.3;

  // Scale values
  static const double scaleStart = 0.8;
  static const double scaleEnd = 1.0;
  static const double buttonScaleDown = 0.95;
}
