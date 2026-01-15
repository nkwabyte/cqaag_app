import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';

class QualityInspectionWizard extends ConsumerStatefulWidget {
  static const String id = 'quality_inspection_wizard';
  final Inspection? existingInspection; // For resuming pending inspections

  const QualityInspectionWizard({super.key, this.existingInspection});

  @override
  ConsumerState<QualityInspectionWizard> createState() => _QualityInspectionWizardState();
}

class _QualityInspectionWizardState extends ConsumerState<QualityInspectionWizard> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormBuilderState>();
  int _currentStep = 0;
  bool _isSubmitting = false;

  late String _docId; // Firebase Document ID
  late String _customInspectionId; // Custom Readable ID (INS-...)

  @override
  void initState() {
    super.initState();
    // If editing, use existing IDs. If new, generate new ones.
    _docId = widget.existingInspection?.id ?? IdUtils.generateDocId();
    _customInspectionId = widget.existingInspection?.inspectionId ?? IdUtils.generateInspectionId();

    // Pre-populate form if resuming existing inspection
    if (widget.existingInspection != null) {
      // Form will be pre-populated in the individual step widgets
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitInspection();
    }
  }

  Future<void> _submitInspection() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      CustomSnackBar.warning(
        context,
        message: 'Please fill in all required fields',
        title: 'Incomplete Form',
      );
      return;
    }

    // Check for photos
    final formData = _formKey.currentState!.value;
    final photos = formData['inspection_photos'] as Map<String, File?>?;

    // Explicitly check for each required photo
    if (photos == null || photos['raw_nuts'] == null || photos['packaging'] == null || photos['storage'] == null) {
      CustomSnackBar.error(
        context,
        message: 'Please capture all 3 required photos (Raw Nuts, Packaging, Storage).',
        title: 'Missing Photos',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Show single loading dialog for the entire process
    if (mounted) {
      AppDialogs.showLoadingDialog(context, message: "Submitting Inspection...");
    }

    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final cloudinary = ref.read(cloudinaryServiceProvider);
      List<String> uploadedImageUrls = [];

      // Helper function to upload
      Future<String> uploadPhoto(File file, String label) async {
        final url = await cloudinary.uploadInspectionPhoto(file);
        if (url == null) {
          throw Exception("Failed to upload $label photo.");
        }
        return url;
      }

      // Upload Raw Nuts
      uploadedImageUrls.add(await uploadPhoto(photos['raw_nuts']!, "Raw Nuts"));

      // Upload Packaging
      uploadedImageUrls.add(await uploadPhoto(photos['packaging']!, "Packaging"));

      // Upload Storage
      uploadedImageUrls.add(await uploadPhoto(photos['storage']!, "Storage"));

      // Safe Parsing Helpers
      double parseDouble(dynamic value) {
        if (value is String) {
          return double.tryParse(value) ?? 0.0;
        } else if (value is num) {
          return value.toDouble();
        }
        return 0.0;
      }

      int parseInt(dynamic value) {
        if (value is String) {
          return int.tryParse(value) ?? 0;
        } else if (value is num) {
          return value.toInt();
        }
        return 0;
      }

      // Create inspection object from form data
      final inspection = Inspection(
        id: _docId,
        inspectionId: _customInspectionId,
        inspectorId: user.uid,
        batchId: formData['batch_id'] as String?,
        farmerName: formData['farmer_name'] as String?,
        location: formData['location'] as String?,
        capturedLocation: formData['captured_location'] as CapturedLocation?,
        town: formData['town'] as String?,
        chapter: formData['chapter'] as String?,
        truckNumber: formData['truck_number'] as String?,
        company: formData['company'] as String?,

        quantity: parseDouble(formData['quantity']),
        quantityBags: parseInt(formData['quantity_bags']),

        moistureContent: parseDouble(formData['moisture']),
        nutCount: parseInt(formData['nut_count']),
        kor: parseDouble(formData['kor']),

        goodKernels: parseDouble(formData['good_kernels']),
        spottedKernels: parseDouble(formData['spotted_kernels']),
        immatureKernels: parseDouble(formData['immature_kernels']),
        oilyKernels: parseDouble(formData['oily_kernels']),
        voidKernels: parseDouble(formData['void_kernels']),
        totalDefective: parseDouble(formData['total_defective']),
        totalSpotted: parseDouble(formData['total_spotted']),

        imageUrls: uploadedImageUrls,
        notes: formData['notes'] as String?,
        status: InspectionStatus.completed,
        createdAt: widget.existingInspection?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      // Check if widget is still mounted before using it
      if (!mounted) {
        throw Exception('Widget was disposed during inspection save');
      }

      // Save to Firebase
      final controller = ref.read(inspectionControllerProvider.notifier);
      if (widget.existingInspection != null) {
        await controller.updateInspection(inspection);
      } else {
        await controller.createInspection(inspection);
      }

      if (!mounted) return;

      // Hide loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Show success SnackBar
      CustomSnackBar.success(
        context,
        message: 'Inspection completed and saved successfully!',
        title: 'Success',
      );

      // Navigate to Quality Result Screen (Replacement to avoid going back to wizard)
      context.pushReplacementNamed(
        QualityResultScreen.id,
        extra: inspection,
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog if open
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}

      debugPrint('Error saving inspection: $e');

      // Show error snackBar
      CustomSnackBar.error(
        context,
        message: 'Failed to save inspection: ${e.toString()}',
        title: 'Error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Keep the controller alive while this screen is active to prevent disposal during async operations
    ref.watch(inspectionControllerProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: _buildWizardAppBar(colorScheme),
        body: SafeArea(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _buildProgressBar(colorScheme),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Force button navigation
                    onPageChanged: (int index) => setState(() => _currentStep = index),
                    children: <Widget>[
                      BasicInfoStep(
                        key: ValueKey('step_0_$_docId'),
                        inspectionId: _customInspectionId, // Pass custom ID for display
                        footer: _buildBottomAction(colorScheme),
                      ).fadeInSlideUp(),
                      FarmLocationStep(
                        key: ValueKey('step_1_$_docId'),
                        footer: _buildBottomAction(colorScheme),
                      ).fadeInSlideUp(),
                      QualityMetricsStep(
                        key: ValueKey('step_2_$_docId'),
                        footer: _buildBottomAction(colorScheme),
                      ).fadeInSlideUp(),
                      PhotoDocumentationStep(
                        key: ValueKey('step_3_$_docId'),
                        footer: _buildBottomAction(colorScheme),
                      ).fadeInSlideUp(),
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

  PreferredSizeWidget _buildWizardAppBar(ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.onSurface, // darkRed
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
          child: Icon(Icons.chevron_left, color: Colors.white, size: 20.r),
        ),
        onPressed: () => _currentStep == 0
            ? Navigator.pop(context)
            : _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
      ),
      centerTitle: true,
      title: Column(
        children: <Widget>[
          const CustomText(
            "Quality Inspection",
            variant: TextVariant.headlineMedium,
            color: Colors.white,
          ),
          CustomText(
            "Step ${_currentStep + 1} of 4",
            variant: TextVariant.bodySmall,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.onSurface,
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(height: 4.h, width: double.infinity, color: Colors.white10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4.h,
                width: (MediaQuery.of(context).size.width / 4) * (_currentStep + 1),
                color: colorScheme.primary, // darkBrown
              ),
            ],
          ),
          Gap(12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildStepLabel("Location", 0),
                _buildStepLabel("Metrics", 1, 2), // Spans steps
                _buildStepLabel("Photos", 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String text, int stepIndex, [int? endStep]) {
    bool isActive = endStep != null ? (_currentStep >= stepIndex && _currentStep <= endStep) : _currentStep == stepIndex;
    return CustomText(text, variant: TextVariant.bodySmall, color: isActive ? Colors.white : Colors.white24);
  }

  Widget _buildBottomAction(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0.h),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: CustomButton(
        text: _isSubmitting ? "Saving..." : (_currentStep == 3 ? "Complete Inspection" : "Continue"),
        leadingIcon: _currentStep == 3 && !_isSubmitting ? const Icon(Icons.check, color: Colors.white) : null,
        onPressed: _isSubmitting ? () {} : _nextStep,
      ).fadeInScale(duration: const Duration(milliseconds: 300)),
    );
  }
}
