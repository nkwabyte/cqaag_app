import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';
import 'package:gap/gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FarmLocationStep extends StatefulWidget {
  static final String id = 'farm_location_step';
  const FarmLocationStep({super.key});

  @override
  State<FarmLocationStep> createState() => _FarmLocationStepState();
}

class _FarmLocationStepState extends State<FarmLocationStep> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Text
          const CustomText(
            "Farm Location",
            variant: TextVariant.displaySmall,
          ),
          Gap(8.h),
          CustomText(
            "Capture GPS coordinates for traceability",
            variant: TextVariant.bodyMedium,
            color: colorScheme.secondary,
          ),
          Gap(30.h),

          // Information Summary Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoField("Inspection ID", "new", colorScheme),
                Gap(16.h),
                Divider(color: colorScheme.secondary.withValues(alpha: 0.1)),
                Gap(16.h),
                _buildInfoField("Farmer", "Kwame Mensah", colorScheme),
                Gap(16.h),
                Divider(color: colorScheme.secondary.withValues(alpha: 0.1)),
                Gap(16.h),
                _buildInfoField(
                  "Location",
                  "Wenchi District, Bono Region",
                  colorScheme,
                ),
              ],
            ),
          ),

          Gap(40.h),

          // GPS Capture Button
          CustomButton(
            text: "Capture GPS Location",
            leadingIcon: Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 20.r,
            ),
            onPressed: () {
              // Logic to trigger geolocator package would go here
              _handleLocationCapture(context);
            },
          ),

          Gap(12.h),

          // Optional: Status Indicator for GPS
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14.r,
                  color: colorScheme.secondary.withValues(alpha: 0.6),
                ),
                Gap(6.w),
                CustomText(
                  "Accuracy: High (within 5 meters)",
                  variant: TextVariant.bodySmall,
                  color: colorScheme.secondary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build the label/value rows in the info card
  Widget _buildInfoField(String label, String value, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          variant: TextVariant.bodySmall,
          color: colorScheme.secondary,
        ),
        Gap(4.h),
        CustomText(
          value,
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface, // darkRed
        ),
      ],
    );
  }

  void _handleLocationCapture(BuildContext context) {
    // This is where you'd integrate the 'geolocator' or 'location' package.
    // For now, it provides visual feedback.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("GPS Coordinates Captured Successfully")),
    );
  }
}
