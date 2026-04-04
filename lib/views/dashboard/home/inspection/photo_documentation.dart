import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class PhotoDocumentationStep extends StatefulWidget {
  static final String id = 'photo_documentation_step';
  final Widget? footer;
  const PhotoDocumentationStep({super.key, this.footer});

  @override
  State<PhotoDocumentationStep> createState() => _PhotoDocumentationStepState();
}

class _PhotoDocumentationStepState extends State<PhotoDocumentationStep> {
  final Map<String, File?> _photos = {
    'raw_nuts': null,
    'packaging': null,
    'storage': null,
  };

  @override
  void initState() {
    super.initState();
    // Dismiss keyboard when entering this step since there are no input fields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  Future<void> _pickImage(String key) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _photos[key] = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        CustomSnackBar.error(context, message: 'Failed to capture image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CustomText(
            "Photo Documentation",
            variant: TextVariant.displaySmall,
          ),
          CustomText(
            "Capture evidence photos (3 required)",
            variant: TextVariant.bodyMedium,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Gap(24.h),
          FormBuilderField<Map<String, File?>>(
            name: 'inspection_photos',
            initialValue: _photos,
            builder: (FormFieldState<Map<String, File?>> field) {
              return Column(
                children: [
                  _buildPhotoPicker(
                    context,
                    key: 'raw_nuts',
                    label: "Raw Cashew Nuts Sample",
                    file: _photos['raw_nuts'],
                    onTap: () async {
                      await _pickImage('raw_nuts');
                      field.didChange(_photos);
                    },
                  ),
                  Gap(20.h),
                  _buildPhotoPicker(
                    context,
                    key: 'packaging',
                    label: "Packaging & Sacks",
                    file: _photos['packaging'],
                    onTap: () async {
                      await _pickImage('packaging');
                      field.didChange(_photos);
                    },
                  ),
                  Gap(20.h),
                  _buildPhotoPicker(
                    context,
                    key: 'storage',
                    label: "Storage Conditions",
                    file: _photos['storage'],
                    onTap: () async {
                      await _pickImage('storage');
                      field.didChange(_photos);
                    },
                  ),
                ],
              );
            },
          ),
          if (widget.footer != null) ...[
            Gap(40.h),
            widget.footer!,
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoPicker(
    BuildContext context, {
    required String key,
    required String label,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Gap(12.w),
              CustomText(
                label,
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.bold,
              ),
              const Spacer(),
              if (file != null) const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          Gap(16.h),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              height: 180.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  style: BorderStyle.solid,
                ),
                image: file != null
                    ? DecorationImage(
                        image: FileImage(file),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: file == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 30.r,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Gap(8.h),
                        const CustomText(
                          "Tap to Capture",
                          variant: TextVariant.bodySmall,
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                          right: 8.r,
                          bottom: 8.r,
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
