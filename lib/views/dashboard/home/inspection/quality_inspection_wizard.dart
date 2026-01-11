import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class QualityInspectionWizard extends StatefulWidget {
  static const String id = 'quality_inspection_wizard';
  const QualityInspectionWizard({super.key});

  @override
  State<QualityInspectionWizard> createState() => _QualityInspectionWizardState();
}

class _QualityInspectionWizardState extends State<QualityInspectionWizard> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormBuilderState>();
  int _currentStep = 0;

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

  void _submitInspection() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      debugPrint(_formKey.currentState?.value.toString());
      // Show your custom Success Dialog here!
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildWizardAppBar(colorScheme),
      body: FormBuilder(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _buildProgressBar(colorScheme),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Force button navigation
                onPageChanged: (int index) => setState(() => _currentStep = index),
                children: const <Widget>[
                  BasicInfoStep(),
                  FarmLocationStep(),
                  QualityMetricsStep(),
                  PhotoDocumentationStep(),
                ],
              ),
            ),
            _buildBottomAction(colorScheme),
          ],
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
    bool isActive = endStep != null
        ? (_currentStep >= stepIndex && _currentStep <= endStep)
        : _currentStep == stepIndex;
    return CustomText(text, variant: TextVariant.bodySmall, color: isActive ? Colors.white : Colors.white24);
  }

  Widget _buildBottomAction(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: const BoxDecoration(color: Colors.white),
      child: CustomButton(
        text: _currentStep == 3 ? "Complete Inspection" : "Continue",
        leadingIcon: _currentStep == 3 ? const Icon(Icons.check, color: Colors.white) : null,
        onPressed: _nextStep,
      ),
    );
  }
}
