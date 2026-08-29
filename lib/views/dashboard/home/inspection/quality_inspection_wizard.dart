import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';
import 'package:cqaag_app/views/dashboard/home/inspection/preview_and_confirm_step.dart';

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
    _docId = widget.existingInspection?.id ?? IdUtils.generateDocId();
    _customInspectionId = widget.existingInspection?.inspectionId ?? IdUtils.generateInspectionId();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitInspection();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _jumpToStep(int step) {
    if (step >= 0 && step <= 4) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

    final formData = _formKey.currentState!.value;
    final photos = formData['inspection_photos'] as Map<String, File?>?;

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

    if (mounted) {
      AppDialogs.showLoadingDialog(context, message: "Submitting Inspection...");
    }

    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final hasInternet = await ref.read(connectivityServiceProvider).hasInternetAccess();
      final cloudinary = ref.read(cloudinaryServiceProvider);
      List<String> uploadedImageUrls = [];

      Future<String> processPhoto(File file, String label) async {
        if (hasInternet) {
          final url = await cloudinary.uploadInspectionPhoto(file);
          if (url == null) {
            throw Exception("Failed to upload $label photo.");
          }
          return url;
        } else {
          return file.path;
        }
      }

      uploadedImageUrls.add(await processPhoto(photos['raw_nuts']!, "Raw Nuts"));
      uploadedImageUrls.add(await processPhoto(photos['packaging']!, "Packaging"));
      uploadedImageUrls.add(await processPhoto(photos['storage']!, "Storage"));

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

      final standaloneMoisture = parseDouble(formData['batch_moisture'] ?? formData['moisture'] ?? formData['c1_moisture']);

      final cutTests = <CutTest>[];
      for (var cutting = 1; cutting <= kMaxCutTests; cutting++) {
        final label = formData[cutTestField(cutting, 'label')] as String?;
        final cutMoisture = parseDouble(formData[cutTestField(cutting, 'moisture')]);

        final cut = CutTest(
          index: cutTests.length + 1,
          label: label,
          moistureContent: cutMoisture > 0 ? cutMoisture : standaloneMoisture,
          nutCount: parseInt(formData[cutTestField(cutting, 'nut_count')]),
          fullyDamagedNuts: parseDouble(formData[cutTestField(cutting, 'fully_damaged')]),
          voidNuts: parseDouble(formData[cutTestField(cutting, 'void')]),
          oilNuts: parseDouble(formData[cutTestField(cutting, 'oil')]),
          spottedNuts: parseDouble(formData[cutTestField(cutting, 'spotted')]),
          immatureNuts: parseDouble(formData[cutTestField(cutting, 'immature')]),
          goodKernels: parseDouble(formData[cutTestField(cutting, 'good_kernels')]),
          emptyShells: parseDouble(formData[cutTestField(cutting, 'empty_shells')]),
        );

        if (!cut.isEmpty) cutTests.add(cut);
      }

      if (cutTests.isEmpty) {
        throw Exception('Enter the measurements for at least one cut test.');
      }

      final rawQty = parseDouble(formData['quantity']);
      final rawGross = parseDouble(formData['gross_weight']);
      final rawNet = parseDouble(formData['net_weight']);
      final effectiveVolume = [rawQty, rawGross, rawNet].reduce((max, e) => e > max ? e : max);

      // Enforce Weight Rule: >=10,000kg requires minimum 2 cut tests
      if (effectiveVolume >= 10000 && cutTests.length < 2) {
        if (mounted) {
          try {
            Navigator.of(context, rootNavigator: true).pop();
          } catch (_) {}
          CustomSnackBar.error(
            context,
            message: 'For volume of 10,000kg and above, the 2nd cutting test is mandatory before the system can process.',
            title: '2nd Cutting Required',
          );
          _jumpToStep(2);
        }
        return;
      }

      final userProfile = ref.read(currentUserProfileProvider).value;
      final persistentQcCode = userProfile?.effectiveQcCode ?? IdUtils.getPermanentQcId(userId: user.uid);

      final isExport = (formData['analysis_type'] as String? ?? '').toLowerCase().contains('export');

      final inspection = Inspection(
        id: _docId,
        inspectionId: _customInspectionId,
        inspectorId: user.uid,
        qcCode: persistentQcCode,
        batchId: formData['batch_id'] as String?,
        farmerName: formData['farmer_name'] as String?,
        location: formData['location'] as String?,
        exactLocation: formData['exact_location'] as String?,
        capturedLocation: formData['captured_location'] as CapturedLocation?,
        town: formData['town'] as String?,
        chapter: formData['chapter'] as String?,
        truckNumber: formData['truck_number'] as String?,
        company: formData['company'] as String?,
        buyerName: formData['buyer_name'] as String?,
        waybillNumber: formData['waybill_number'] as String?,
        analysisType: formData['analysis_type'] as String?,

        // Export specifics
        blNumber: formData['bl_number'] as String?,
        shipperDetails: formData['shipper_details'] as String?,
        consigneeDetails: formData['consignee_details'] as String?,
        originCountry: formData['origin_country'] as String? ?? 'GHANA',
        destinationCountry: formData['destination_country'] as String?,
        transportDescription: formData['transport_description'] as String?,
        pod: formData['pod'] as String?,
        pol: formData['pol'] as String?,
        containerCountAndSizes: formData['container_count_and_sizes'] as String?,
        grossWeight: rawGross > 0 ? rawGross : rawQty,
        netWeight: rawNet > 0 ? rawNet : rawQty,
        packageDescription: formData['package_description'] as String?,
        samplePlaceAndDate: formData['sample_place_and_date'] as String?,
        cuttingTestPlaceAndDate: formData['cutting_test_place_and_date'] as String?,
        isAuthorized: formData['is_authorized'] as bool? ?? isExport,
        authorizedBy: isExport ? (userProfile != null ? '${userProfile.firstName} ${userProfile.lastName}' : user.uid) : null,

        quantity: rawQty > 0 ? rawQty : (rawNet > 0 ? rawNet : rawGross),
        quantityBags: parseInt(formData['quantity_bags']),

        cutTests: cutTests,

        moistureContent: standaloneMoisture > 0 ? standaloneMoisture : cutTests.averageMoisture,
        nutCount: cutTests.averageNutCount.round(),
        kor: cutTests.averageKor,

        goodKernels: cutTests.averageGoodKernels,
        fullyDamagedKernels: cutTests.averageFullyDamaged,
        spottedKernels: cutTests.averageSpotted,
        immatureKernels: cutTests.averageImmature,
        oilyKernels: cutTests.averageOilNuts,
        voidKernels: cutTests.averageVoidNuts,
        emptyShells: cutTests.averageEmptyShells,
        totalDefective: cutTests.averageTotalDamaged,
        totalSpotted: cutTests.averageTotalSpotted,

        imageUrls: uploadedImageUrls,
        cuttingImageUrls: uploadedImageUrls,
        notes: formData['notes'] as String?,
        status: hasInternet ? InspectionStatus.completed : InspectionStatus.pendingSync,
        createdAt: widget.existingInspection?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        completedAt: hasInternet ? DateTime.now() : null,
      );

      if (!mounted) {
        throw Exception('Widget was disposed during inspection save');
      }

      final controller = ref.read(inspectionControllerProvider.notifier);
      if (widget.existingInspection != null) {
        await controller.updateInspection(inspection);
      } else {
        await controller.createInspection(inspection);
      }

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      CustomSnackBar.success(
        context,
        message: 'Inspection completed and saved successfully!',
        title: 'Success',
      );

      context.pushReplacementNamed(
        QualityResultScreen.id,
        extra: inspection,
      );
    } catch (e) {
      if (!mounted) return;

      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}

      debugPrint('Error saving inspection: $e');

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
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (int index) => setState(() => _currentStep = index),
                    children: <Widget>[
                      BasicInfoStep(
                        key: ValueKey('step_0_$_docId'),
                        inspectionId: _customInspectionId,
                        footer: _buildBottomAction(colorScheme),
                      ).fadeInSlideUp(),
                      FarmLocationStep(
                        key: ValueKey('step_1_$_docId'),
                        footer: _buildBottomAction(colorScheme),
                      ).fadeInSlideUp(),
                      QualityMetricsStep(
                        key: ValueKey('step_2_$_docId'),
                        footer: _buildBottomAction(colorScheme),
                        initialCutTests: widget.existingInspection?.effectiveCutTests ?? const <CutTest>[],
                      ).fadeInSlideUp(),
                      PhotoDocumentationStep(
                        key: ValueKey('step_3_$_docId'),
                        footer: _buildBottomAction(colorScheme),
                      ).fadeInSlideUp(),
                      PreviewAndConfirmStep(
                        key: ValueKey('step_4_$_docId'),
                        formKey: _formKey,
                        onJumpToStep: _jumpToStep,
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
      backgroundColor: colorScheme.onSurface,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
          child: Icon(Icons.chevron_left, color: Colors.white, size: 20.r),
        ),
        onPressed: _previousStep,
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
            "Step ${_currentStep + 1} of 5",
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
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(height: 4.h, width: double.infinity, color: Colors.white10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4.h,
                width: (MediaQuery.of(context).size.width / 5) * (_currentStep + 1),
                color: colorScheme.primary,
              ),
            ],
          ),
          Gap(10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildStepLabel("Basic", 0),
                _buildStepLabel("Location", 1),
                _buildStepLabel("Metrics", 2),
                _buildStepLabel("Photos", 3),
                _buildStepLabel("Preview", 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String text, int stepIndex) {
    bool isActive = _currentStep == stepIndex;
    return GestureDetector(
      onTap: () => _jumpToStep(stepIndex),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: isActive ? const Border(bottom: BorderSide(color: Colors.white, width: 2)) : null,
        ),
        child: CustomText(
          text,
          variant: TextVariant.bodySmall,
          color: isActive ? Colors.white : Colors.white54,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBottomAction(ColorScheme colorScheme) {
    final isPreviewStep = _currentStep == 4;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: CustomButton(
                text: "Back",
                variant: ButtonVariant.outlined,
                onPressed: _isSubmitting ? () {} : _previousStep,
              ),
            ),
            Gap(12.w),
          ],
          Expanded(
            child: CustomButton(
              text: _isSubmitting
                  ? "Submitting..."
                  : (isPreviewStep ? "Submit Inspection" : "Continue"),
              leadingIcon: isPreviewStep && !_isSubmitting ? const Icon(Icons.check, color: Colors.white) : null,
              onPressed: _isSubmitting ? () {} : _nextStep,
            ),
          ),
        ],
      ).fadeInScale(duration: const Duration(milliseconds: 300)),
    );
  }
}
