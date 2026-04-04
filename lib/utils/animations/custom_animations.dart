import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cqaag_app/utils/animations/animation_configs.dart';

/// Reusable animation extensions for common animation patterns
extension AnimateExtensions on Widget {
  /// Fade in with slide up animation
  Widget fadeInSlideUp({Duration? delay, Duration? duration}) {
    return animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: duration ?? AnimationConfigs.normal, curve: AnimationConfigs.defaultCurve)
        .slideY(
          begin: AnimationConfigs.slideDistance,
          end: 0,
          duration: duration ?? AnimationConfigs.normal,
          curve: AnimationConfigs.defaultCurve,
        );
  }

  /// Fade in with slide down animation
  Widget fadeInSlideDown({Duration? delay, Duration? duration}) {
    return animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: duration ?? AnimationConfigs.normal, curve: AnimationConfigs.defaultCurve)
        .slideY(
          begin: -AnimationConfigs.slideDistance,
          end: 0,
          duration: duration ?? AnimationConfigs.normal,
          curve: AnimationConfigs.defaultCurve,
        );
  }

  /// Fade in with slide from right
  Widget fadeInSlideRight({Duration? delay, Duration? duration}) {
    return animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: duration ?? AnimationConfigs.normal, curve: AnimationConfigs.defaultCurve)
        .slideX(
          begin: AnimationConfigs.slideDistance,
          end: 0,
          duration: duration ?? AnimationConfigs.normal,
          curve: AnimationConfigs.defaultCurve,
        );
  }

  /// Fade in with slide from left
  Widget fadeInSlideLeft({Duration? delay, Duration? duration}) {
    return animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: duration ?? AnimationConfigs.normal, curve: AnimationConfigs.defaultCurve)
        .slideX(
          begin: -AnimationConfigs.slideDistance,
          end: 0,
          duration: duration ?? AnimationConfigs.normal,
          curve: AnimationConfigs.defaultCurve,
        );
  }

  /// Fade in with scale animation
  Widget fadeInScale({Duration? delay, Duration? duration}) {
    return animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: duration ?? AnimationConfigs.normal, curve: AnimationConfigs.defaultCurve)
        .scale(
          begin: const Offset(AnimationConfigs.scaleStart, AnimationConfigs.scaleStart),
          end: const Offset(AnimationConfigs.scaleEnd, AnimationConfigs.scaleEnd),
          duration: duration ?? AnimationConfigs.normal,
          curve: AnimationConfigs.defaultCurve,
        );
  }

  /// Staggered animation for list items
  Widget staggeredListItem(int index, {Duration? baseDelay}) {
    final delay = (baseDelay ?? Duration.zero) + (AnimationConfigs.staggerDelay * index);
    return animate(delay: delay)
        .fadeIn(duration: AnimationConfigs.normal, curve: AnimationConfigs.defaultCurve)
        .slideY(
          begin: AnimationConfigs.slideDistance,
          end: 0,
          duration: AnimationConfigs.normal,
          curve: AnimationConfigs.defaultCurve,
        );
  }

  /// Staggered animation for cards
  Widget staggeredCard(int index, {Duration? baseDelay}) {
    final delay = (baseDelay ?? Duration.zero) + (AnimationConfigs.cardDelay * index);
    return animate(delay: delay)
        .fadeIn(duration: AnimationConfigs.normal, curve: AnimationConfigs.defaultCurve)
        .scale(
          begin: const Offset(AnimationConfigs.scaleStart, AnimationConfigs.scaleStart),
          end: const Offset(AnimationConfigs.scaleEnd, AnimationConfigs.scaleEnd),
          duration: AnimationConfigs.normal,
          curve: AnimationConfigs.defaultCurve,
        );
  }

  /// Shimmer effect for badges or highlights
  Widget shimmer({Duration? duration, Duration? delay}) {
    return animate(delay: delay ?? Duration.zero).shimmer(
      duration: duration ?? AnimationConfigs.verySlow,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  /// Pulse animation for attention-grabbing elements
  Widget pulse({Duration? duration, Duration? delay}) {
    return animate(delay: delay ?? Duration.zero, onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: duration ?? const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1.0, 1.0),
          duration: duration ?? const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
  }

  /// Shake animation for errors
  Widget shake({Duration? delay}) {
    return animate(delay: delay ?? Duration.zero).shake(
      duration: const Duration(milliseconds: 500),
      hz: 4,
      curve: Curves.easeInOut,
    );
  }

  /// Bounce entrance animation
  Widget bounceIn({Duration? delay}) {
    return animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: AnimationConfigs.normal)
        .scale(
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          duration: AnimationConfigs.slow,
          curve: AnimationConfigs.bounceCurve,
        );
  }
}
