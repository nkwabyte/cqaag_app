import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class VerificationUploadScreen extends ConsumerStatefulWidget {
  static const String id = 'verification_upload_screen';
  const VerificationUploadScreen({super.key});

  @override
  ConsumerState<VerificationUploadScreen> createState() => _VerificationUploadScreenState();
}

class _VerificationUploadScreenState extends ConsumerState<VerificationUploadScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  File? _idFrontFile;
  File? _idBackFile;
  File? _selfieFile;
  bool _isLoading = false;

  Future<void> _pickDocument(void Function(File) onPick) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null) {
          setState(() {
            onPick(File(path));
          });
        }
      }
    } catch (e) {
      if (mounted) CustomSnackBar.error(context, message: 'Error picking document: $e');
    }
  }

  Future<void> _takeSelfie(void Function(File) onPick) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        setState(() {
          onPick(File(image.path));
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) CustomSnackBar.error(context, message: 'Error taking selfie: $e');
    }
  }

  Future<void> _submitVerification() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      if (_idFrontFile == null) {
        CustomSnackBar.error(context, message: 'Please upload the front of your Ghana Card.');
        return;
      }
      if (_idBackFile == null) {
        CustomSnackBar.error(context, message: 'Please upload the back of your Ghana Card.');
        return;
      }
      if (_selfieFile == null) {
        CustomSnackBar.error(context, message: 'Please take a selfie.');
        return;
      }

      setState(() => _isLoading = true);
      AppDialogs.showLoadingDialog(context, message: "Uploading Verification Documents");

      try {
        final cloudinary = ref.read(cloudinaryServiceProvider);

        // Upload images
        final frontUrl = await cloudinary.uploadIdentityDocument(_idFrontFile!);
        final backUrl = await cloudinary.uploadIdentityDocument(_idBackFile!);
        final selfieUrl = await cloudinary.uploadIdentityDocument(_selfieFile!);

        if (frontUrl == null || backUrl == null || selfieUrl == null) {
          throw Exception("Failed to upload one or more images.");
        }

        final formData = _formKey.currentState!.value;
        final ghanaCardNumber = formData['ghana_card_number'] as String;

        final verificationData = VerificationData(
          idCardFrontUrl: frontUrl,
          idCardBackUrl: backUrl,
          idCardNumber: ghanaCardNumber,
          selfieUrl: selfieUrl,
        );

        final currentUser = ref.read(authServiceProvider).currentUser;
        if (currentUser != null) {
          await ref.read(userServiceProvider).updateUserData(
            currentUser.uid,
            {
              'verification': verificationData.toJson(),
              'verification_status': VerificationStatus.pending.name,
            },
          );

          if (mounted) {
            if (_isLoading) {
              Navigator.of(context, rootNavigator: true).pop();
              setState(() => _isLoading = false);
            }
            CustomSnackBar.success(context, message: 'Verification submitted successfully!');
            if (mounted) {
              context.go('/${DashboardScreen.id}');
            }
            ref.invalidate(currentUserProfileProvider);
          }
        } else {
          throw Exception("User profile not found. Please log in again.");
        }
      } catch (e) {
        debugPrint('Submission error: $e');
        if (mounted) {
          if (_isLoading) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() => _isLoading = false);
          }
          CustomSnackBar.error(context, message: 'Submission failed: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          "Identity Verification",
          variant: TextVariant.displayMedium,
        ),
        backgroundColor: theme.colorScheme.onSurface,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomText(
                  "Verify Your Identity",
                  variant: TextVariant.headlineMedium,
                  fontWeight: FontWeight.bold,
                ),
                Gap(8.h),
                CustomText(
                  "Please provide your Ghana Card details and a selfie to verify your account.",
                  variant: TextVariant.bodyMedium,
                ),
                Gap(32.h),

                // Ghana Card Front
                _buildImageUploadCard(
                  title: "Ghana Card (Front)",
                  description: "Upload the front view of your Ghana Card.",
                  file: _idFrontFile,
                  onTap: () => _pickDocument((file) => _idFrontFile = file),
                ),
                Gap(16.h),

                // Ghana Card Back
                _buildImageUploadCard(
                  title: "Ghana Card (Back)",
                  description: "Upload the back view of your Ghana Card.",
                  file: _idBackFile,
                  onTap: () => _pickDocument((file) => _idBackFile = file),
                ),
                Gap(24.h),

                // Ghana Card Number Field
                CustomTextField(
                  name: 'ghana_card_number',
                  label: 'Ghana Card Number',
                  hint: 'GHA-000000000-0',
                  initialValue: 'GHA-',
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(15, errorText: "Invalid Ghana Card Number"),
                    FormBuilderValidators.maxLength(15, errorText: "Invalid Ghana Card Number"),
                  ]),
                  inputFormatters: [
                    GhanaCardFormatter(),
                  ],
                ),
                Gap(24.h),

                // Selfie
                _buildImageUploadCard(
                  title: "Selfie",
                  description: "Take a selfie to verify your identity.",
                  file: _selfieFile,
                  onTap: () => _takeSelfie((file) => _selfieFile = file),
                  icon: Icons.camera_alt_outlined,
                ),
                Gap(40.h),

                CustomButton(
                  text: "Submit Verification",
                  onPressed: _submitVerification,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadCard({
    required String title,
    required String description,
    File? file,
    required VoidCallback onTap,
    IconData icon = Icons.credit_card,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                image: file != null ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : null,
              ),
              child: file == null ? Icon(icon, color: Theme.of(context).primaryColor, size: 30.r) : null,
            ),
            Gap(16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(title, variant: TextVariant.labelLarge, fontWeight: FontWeight.bold),
                  Gap(4.h),
                  CustomText(description, variant: TextVariant.bodySmall, color: Colors.grey),
                ],
              ),
            ),
            Icon(
              file != null ? Icons.check_circle : Icons.upload_file,
              color: file != null ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class GhanaCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Ensure it starts with GHA-
    if (!text.startsWith('GHA-')) {
      // If user tries to delete prefix, keep it
      if (oldValue.text.startsWith('GHA-') && text.length < 4) {
        return oldValue;
      }
      // Or prepend it if completely cleared
      if (text.isEmpty) {
        return const TextEditingValue(
          text: 'GHA-',
          selection: TextSelection.collapsed(offset: 4),
        );
      }
      return const TextEditingValue(
        text: 'GHA-',
        selection: TextSelection.collapsed(offset: 4),
      );
    }

    // Logic for hyphens
    // GHA- => 4 chars
    // digits => 9
    // auto add -

    // Clean text to just digits after 'GHA-'
    String cleanText = text.substring(4).replaceAll(RegExp(r'[^0-9]'), '');

    String newText = 'GHA-';

    if (cleanText.isNotEmpty) {
      if (cleanText.length > 9) {
        newText +=
            '${cleanText.substring(0, 9)}-${cleanText.substring(9, cleanText.length > 10 ? 10 : cleanText.length)}';
      } else {
        newText += cleanText;
        // Auto-add hyphen if 9 digits entered and user is adding text (not deleting)
        if (cleanText.length == 9 && newValue.text.length > oldValue.text.length) {
          newText += '-';
        }
      }
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
