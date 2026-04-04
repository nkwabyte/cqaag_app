import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';
import 'package:gap/gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FarmLocationStep extends ConsumerStatefulWidget {
  static final String id = 'farm_location_step';
  final Widget? footer;
  const FarmLocationStep({super.key, this.footer});

  @override
  ConsumerState<FarmLocationStep> createState() => _FarmLocationStepState();
}

class _FarmLocationStepState extends ConsumerState<FarmLocationStep> {
  CapturedLocation? _capturedLocation;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Dismiss keyboard when entering this step since there are no input fields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProfileProvider).value;

    final inspectorName = user != null ? '${user.firstName} ${user.lastName}' : 'Unknown Inspector';
    final location = user != null ? '${user.district}, ${user.region}' : 'Unknown Location';

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
                _buildInfoField("Inspector", inspectorName, colorScheme),
                Gap(16.h),
                Divider(color: colorScheme.secondary.withValues(alpha: 0.1)),
                Gap(16.h),
                _buildInfoField(
                  "Location",
                  location,
                  colorScheme,
                ),
              ],
            ),
          ),

          Gap(40.h),

          // Hidden form field to store captured location
          FormBuilderField<CapturedLocation>(
            name: 'captured_location',
            builder: (field) => const SizedBox.shrink(),
          ),

          // GPS Capture Button
          CustomButton(
            text: _isCapturing ? "Capturing Location..." : (_capturedLocation != null ? "Recapture GPS Location" : "Capture GPS Location"),
            leadingIcon: _isCapturing
                ? SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    _capturedLocation != null ? Icons.refresh : Icons.location_on_outlined,
                    color: Colors.white,
                    size: 20.r,
                  ),
            onPressed: _isCapturing
                ? () {} // Disabled state
                : () => _handleLocationCapture(context),
          ),

          // Show captured location details
          if (_capturedLocation != null) ...[
            Gap(24.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20.r),
                      Gap(8.w),
                      const CustomText(
                        "Location Captured",
                        variant: TextVariant.bodyLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  Gap(12.h),
                  _buildLocationDetail("Latitude", _capturedLocation!.latitude.toStringAsFixed(6)),
                  Gap(8.h),
                  _buildLocationDetail("Longitude", _capturedLocation!.longitude.toStringAsFixed(6)),
                  Gap(8.h),
                  _buildLocationDetail("Accuracy", "${_capturedLocation!.accuracy.toStringAsFixed(1)}m"),
                  if (_capturedLocation!.altitude != null) ...[
                    Gap(8.h),
                    _buildLocationDetail("Altitude", "${_capturedLocation!.altitude!.toStringAsFixed(1)}m"),
                  ],
                ],
              ),
            ),
          ],

          // Show error message if any
          if (_errorMessage != null && _capturedLocation == null) ...[
            Gap(16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20.r),
                  Gap(8.w),
                  Expanded(
                    child: CustomText(
                      _errorMessage!,
                      variant: TextVariant.bodySmall,
                      color: Colors.red.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (widget.footer != null) ...[
            Gap(40.h),
            widget.footer!,
          ],

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

  // Helper to build location detail rows
  Widget _buildLocationDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          label,
          variant: TextVariant.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        CustomText(
          value,
          variant: TextVariant.bodySmall,
          fontWeight: FontWeight.normal,
        ),
      ],
    );
  }

  Future<void> _handleLocationCapture(BuildContext context) async {
    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final capturedLocation = await locationService.getCapturedLocation();

      if (!mounted) return;

      setState(() {
        _capturedLocation = capturedLocation;
        _isCapturing = false;
      });

      // Store the captured location in the form state
      // Use the State's context instead of the parameter context
      final formState = FormBuilder.of(this.context);
      if (formState != null) {
        formState.fields['captured_location']?.didChange(capturedLocation);
      }

      if (!mounted) return;
      CustomSnackBar.success(
        this.context,
        message: "GPS Coordinates Captured Successfully",
        title: "Success",
      );
    } on LocationServiceDisabledException catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _errorMessage = e.toString();
      });

      if (!mounted) return;
      _showLocationServiceDialog(this.context);
    } on LocationPermissionDeniedException catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _errorMessage = e.toString();
      });

      if (!mounted) return;
      _showPermissionDialog(this.context);
    } on LocationCaptureException catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _errorMessage = e.toString();
      });

      if (!mounted) return;
      CustomSnackBar.error(
        this.context,
        message: e.toString(),
        title: "Location Capture Failed",
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _errorMessage = "An unexpected error occurred: ${e.toString()}";
      });

      if (!mounted) return;
      CustomSnackBar.error(
        this.context,
        message: "Failed to capture location. Please try again.",
        title: "Error",
      );
    }
  }

  void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(
          "Location Services Disabled",
          variant: TextVariant.headlineSmall,
        ),
        content: const CustomText(
          "Please enable location services in your device settings to capture GPS coordinates.",
          variant: TextVariant.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText("Cancel", variant: TextVariant.bodyMedium),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(locationServiceProvider).openLocationSettings();
            },
            child: const CustomText(
              "Open Settings",
              variant: TextVariant.bodyMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(
          "Location Permission Required",
          variant: TextVariant.headlineSmall,
        ),
        content: const CustomText(
          "This app needs location permission to capture GPS coordinates for inspection reports. Please grant location access in app settings.",
          variant: TextVariant.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText("Cancel", variant: TextVariant.bodyMedium),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(locationServiceProvider).openAppSettings();
            },
            child: const CustomText(
              "Open Settings",
              variant: TextVariant.bodyMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
