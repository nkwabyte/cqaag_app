import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cqaag_app/index.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  static const String id = 'edit_profile_screen';

  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _regionController;
  late TextEditingController _districtController;
  late TextEditingController _addressController;

  bool _isLoading = false;
  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProfileProvider).value;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _regionController = TextEditingController(text: user?.region ?? '');
    _districtController = TextEditingController(text: user?.district ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _regionController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      if (result.files.single.path != null) {
        setState(() {
          _newProfileImage = File(result.files.single.path!);
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProfileProvider).value;
      if (user == null) throw Exception("User not found");

      String? profileImageUrl = user.profilePicture;

      if (_newProfileImage != null) {
        final cloudinaryService = ref.read(cloudinaryServiceProvider);
        final url = await cloudinaryService.uploadAvatar(_newProfileImage!);
        if (url != null) {
          profileImageUrl = url;
        }
      }

      await ref.read(userServiceProvider).updateUserData(
        user.id,
        {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'region': _regionController.text.trim(),
          'district': _districtController.text.trim(),
          'address': _addressController.text.trim(),
          'profile_picture': profileImageUrl,
        },
      );

      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, message: "Failed to update profile: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(currentUserProfileProvider).value;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const CustomText('Edit Profile', variant: TextVariant.headlineMedium),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60.r,
                      backgroundColor: colorScheme.secondary.withValues(alpha: 0.1),
                      backgroundImage: _newProfileImage != null
                          ? FileImage(_newProfileImage!)
                          : (user?.profilePicture != null ? CachedNetworkImageProvider(user!.profilePicture) : null) as ImageProvider?,
                      child: (_newProfileImage == null && user?.profilePicture == null) ? Icon(Icons.person, size: 60.r) : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(30.h),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      name: 'firstName',
                      controller: _firstNameController,
                      label: "First Name",
                      hint: "Enter first name",
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: CustomTextField(
                      name: 'lastName',
                      controller: _lastNameController,
                      label: "Last Name",
                      hint: "Enter last name",
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              Gap(16.h),
              CustomTextField(
                name: 'phone',
                controller: _phoneController,
                label: "Phone Number",
                hint: "Enter phone number",
                keyboardType: TextInputType.phone,
              ),
              Gap(16.h),
              CustomTextField(
                name: 'region',
                controller: _regionController,
                label: "Region",
                hint: "Enter region",
              ),
              Gap(16.h),
              CustomTextField(
                name: 'district',
                controller: _districtController,
                label: "District",
                hint: "Enter district",
              ),
              Gap(16.h),
              CustomTextField(
                name: 'address',
                controller: _addressController,
                label: "Address",
                hint: "Enter address",
              ),
              Gap(40.h),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Save Changes",
                  onPressed: _saveProfile,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
