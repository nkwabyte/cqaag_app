import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';
import 'package:cqaag_app/services/membership/legacy_register.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static final String id = "register_screen";
  final LegacyMemberEntry? initialLegacyMember;

  const RegisterScreen({super.key, this.initialLegacyMember});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isRegisteringAsAdmin = false;
  LegacyMemberEntry? _recognizedLegacyMember;

  @override
  void initState() {
    super.initState();
    _recognizedLegacyMember = widget.initialLegacyMember;
    if (_recognizedLegacyMember != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateFromLegacy(_recognizedLegacyMember!);
      });
    }
  }

  void _populateFromLegacy(LegacyMemberEntry entry) {
    _formKey.currentState?.patchValue({
      'first_name': entry.firstName,
      'last_name': entry.lastName,
      'phone': entry.phone ?? '',
      'region': entry.region,
      'district': entry.district,
      'address': entry.district.isNotEmpty ? '${entry.district}, ${entry.region}' : entry.region,
    });
  }

  void _onPhoneChanged(String? val) {
    if (_recognizedLegacyMember != null) return;
    if (val != null && val.replaceAll(RegExp(r'[^0-9]'), '').length >= 9) {
      final match = LegacyRegister.findByPhone(val);
      if (match != null) {
        setState(() {
          _recognizedLegacyMember = match;
        });
        _populateFromLegacy(match);
      }
    }
  }

  void _showLegacyLookupModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return _LegacyLookupBottomSheet(
          onSelect: (entry) {
            Navigator.pop(context);
            setState(() {
              _recognizedLegacyMember = entry;
            });
            _populateFromLegacy(entry);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Header Section
              _buildHeader(colorScheme, context),

              // Form Section
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Legacy Recognition Card or Quick Lookup Bar
                      if (_recognizedLegacyMember != null)
                        _buildRecognitionCard(colorScheme)
                      else
                        _buildLookupPromptBar(),

                      Gap(20.h),

                      Row(
                        children: <Widget>[
                          Expanded(
                            child: const CustomTextField(
                              name: 'first_name',
                              label: "First Name",
                              hint: "First Name",
                              prefixIcon: Icons.person_outline,
                            ),
                          ),
                          Gap(16.w),
                          Expanded(
                            child: const CustomTextField(
                              name: 'last_name',
                              label: "Last Name",
                              hint: "Last Name",
                              prefixIcon: Icons.person_outline,
                            ),
                          ),
                        ],
                      ),
                      Gap(20.h),
                      const CustomTextField(
                        name: 'email',
                        label: "Email Address",
                        hint: "Enter your email",
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),
                      Gap(20.h),
                      CustomTextField(
                        name: 'phone',
                        label: "Phone Number",
                        hint: "Enter your phone number",
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        onChanged: _onPhoneChanged,
                      ),
                      Gap(20.h),

                      _buildAdminCheckbox(colorScheme),

                      Gap(20.h),
                      const CustomTextField(
                        name: 'password',
                        label: "Password",
                        hint: "Create a password",
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                      ),
                      Gap(4.h),
                      CustomText(
                        "Must be at least 8 characters",
                        variant: TextVariant.bodySmall,
                        color: colorScheme.secondary.withValues(alpha: 0.8),
                      ),

                      Gap(20.h),
                      const CustomTextField(
                        name: 'confirm_password',
                        label: "Confirm Password",
                        hint: "Confirm your password",
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                      ),

                      Gap(30.h),

                      // Location Section
                      const CustomText(
                        "Location Information",
                        variant: TextVariant.headlineMedium,
                        fontWeight: FontWeight.bold,
                      ),
                      Gap(16.h),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: const CustomTextField(
                              name: 'region',
                              label: "Region",
                              hint: "Region",
                              prefixIcon: Icons.location_on_outlined,
                            ),
                          ),
                          Gap(16.w),
                          Expanded(
                            child: const CustomTextField(
                              name: 'district',
                              label: "District",
                              hint: "District",
                              prefixIcon: Icons.location_city_outlined,
                            ),
                          ),
                        ],
                      ),
                      Gap(20.h),
                      const CustomTextField(
                        name: 'address',
                        label: "Address",
                        hint: "Residential Address",
                        prefixIcon: Icons.home_outlined,
                      ),

                      Gap(30.h),
                      CustomButton(
                        text: _recognizedLegacyMember != null ? "Activate Account" : "Create Account",
                        onPressed: () async {
                          UIHelpers.dismissKeyboard(context);
                          if (_formKey.currentState?.saveAndValidate() ?? false) {
                            final values = _formKey.currentState?.value;
                            final email = values?['email'] as String?;
                            final password = values?['password'] as String?;
                            final confirmPassword = values?['confirm_password'] as String?;
                            final firstName = values?['first_name'] as String?;
                            final lastName = values?['last_name'] as String?;
                            final phone = values?['phone'] as String?;

                            // Location fields
                            final region = values?['region'] as String?;
                            final district = values?['district'] as String?;
                            final address = values?['address'] as String?;

                            if (password != confirmPassword) {
                              CustomSnackBar.warning(
                                context,
                                message: "Passwords do not match. Please try again.",
                              );
                              return;
                            }

                            if (email != null && password != null && firstName != null && lastName != null && phone != null) {
                              AppDialogs.showLoadingDialog(context, message: "Setting up your account...");
                              try {
                                final authService = ref.read(authServiceProvider);
                                await authService.signUpWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                  firstName: firstName,
                                  lastName: lastName,
                                  phoneNumber: phone,
                                  address: address,
                                  district: district,
                                  region: region,
                                  isAdmin: _isRegisteringAsAdmin,
                                );

                                // If legacy member recognized, also claim in Firestore explicitly
                                if (_recognizedLegacyMember != null) {
                                  final currentUser = authService.currentUser;
                                  if (currentUser != null) {
                                    final membershipService = ref.read(membershipServiceProvider);
                                    await membershipService.claimLegacyMember(
                                      entry: _recognizedLegacyMember!,
                                      userId: currentUser.uid,
                                      email: email,
                                      address: address,
                                    );
                                  }
                                }

                                ref.invalidate(currentUserProfileProvider);
                                ref.invalidate(authStateProvider);

                                if (context.mounted) {
                                  Navigator.of(context, rootNavigator: true).pop();
                                  CustomSnackBar.success(
                                    context,
                                    message: _recognizedLegacyMember != null
                                        ? "Welcome back! Your CQAAG membership record is linked."
                                        : "Account created successfully!",
                                  );
                                  context.goNamed(TermsAndConditionsScreen.id, extra: {'fromRegister': true});
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  try {
                                    Navigator.of(context, rootNavigator: true).pop();
                                  } catch (_) {}
                                  if (e is NoInternetException) {
                                    CustomSnackBar.info(context, message: e.message);
                                  } else {
                                    CustomSnackBar.error(
                                      context,
                                      message: FirebaseErrorMapper.getErrorMessage(e),
                                    );
                                  }
                                }
                              }
                            }
                          }
                        },
                      ),
                      Gap(20.h),
                      // Process Info Banner
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            CustomText(
                              "Membership Process",
                              variant: TextVariant.bodyMedium,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                            Gap(4.h),
                            CustomText(
                              _recognizedLegacyMember != null
                                  ? "Your membership is verified on the earlier register with cards issued. After activating your login credentials, sign the digital agreements in your profile to complete your digital record."
                                  : "Create your account first, then submit your membership application and sign the association agreements from your profile.",
                              variant: TextVariant.bodySmall,
                              textAlign: TextAlign.center,
                              color: Colors.green.shade800,
                            ),
                          ],
                        ),
                      ),
                      Gap(24.h),
                      _buildFooter(colorScheme, context),
                      Gap(20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLookupPromptBar() {
    return InkWell(
      onTap: _showLegacyLookupModal,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.badge_outlined, color: AppColors.primaryGreen, size: 20.r),
            Gap(10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Already on the CQAAG Register?',
                    style: TextStyle(fontSize: 13.sp, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                  Gap(2.h),
                  Text(
                    'Tap here to find your name or phone number and fast-track your registration.',
                    style: TextStyle(fontSize: 11.sp, color: Colors.black87),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.primaryGreen, size: 20.r),
          ],
        ),
      ),
    );
  }

  Widget _buildRecognitionCard(ColorScheme colorScheme) {
    final entry = _recognizedLegacyMember!;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: Colors.green.shade800, size: 20.r),
              Gap(8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  entry.memberId,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              Gap(8.w),
              Expanded(
                child: Text(
                  'Recognized Member',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _recognizedLegacyMember = null;
                    _formKey.currentState?.reset();
                  });
                },
              ),
            ],
          ),
          Gap(8.h),
          Text(
            entry.name,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          Gap(4.h),
          Text(
            '${entry.company.isNotEmpty && entry.company != "N/A" ? "${entry.company} · " : ""}${entry.locationSummary} · Card Issued',
            style: TextStyle(fontSize: 12.sp, color: Colors.green.shade900),
          ),
          Gap(6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              entry.earlierPaid
                  ? 'Earlier GH₵60 paid · Discounted Registration Fee of GH₵ 200 applied.'
                  : 'Full Member Register · Registration Fee is GH₵ 320 at activation.',
              style: TextStyle(fontSize: 11.sp, color: Colors.green.shade900, fontWeight: FontWeight.w600),
            ),
          ),
          Gap(6.h),
          Text(
            'We auto-filled your personal details above. Only your email and a password are required to create your login.',
            style: TextStyle(fontSize: 11.sp, fontStyle: FontStyle.italic, color: Colors.green.shade800),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildAdminCheckbox(ColorScheme colorScheme) {
    return Row(
      children: <Widget>[
        SizedBox(
          height: 24.h,
          width: 24.w,
          child: Checkbox(
            value: _isRegisteringAsAdmin,
            onChanged: (value) {
              setState(() {
                _isRegisteringAsAdmin = value ?? false;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            side: BorderSide(
              color: colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
        Gap(8.w),
        CustomText(
          "Register as Admin",
          variant: TextVariant.bodyMedium,
          color: colorScheme.onSurface,
        ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme colorScheme, BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomText(
            "Already have an account? ",
            color: colorScheme.secondary,
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CustomText(
              "Sign In",
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: colorScheme.onSurface, // darkRed
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(60.r),
          bottomRight: Radius.circular(60.r),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Gap(40.h),
            // Back Button
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20.r,
                  ),
                  Gap(8.w),
                  const CustomText(
                    "Back",
                    variant: TextVariant.bodyMedium,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Gap(20.h),
            CustomText(
              _recognizedLegacyMember != null ? "Activate Account" : "Create Account",
              variant: TextVariant.displaySmall,
              color: Colors.white,
            ),
            Gap(8.h),
            CustomText(
              _recognizedLegacyMember != null
                  ? "Welcome, ${_recognizedLegacyMember!.firstName}! Activate your official CQAAG credentials."
                  : "Join the C.Q.A.A.G quality control team",
              variant: TextVariant.bodyMedium,
              color: colorScheme.secondary.withValues(alpha: 0.9),
            ),
            Gap(30.h),
          ],
        ),
      ),
    );
  }
}

class _LegacyLookupBottomSheet extends StatefulWidget {
  final ValueChanged<LegacyMemberEntry> onSelect;

  const _LegacyLookupBottomSheet({required this.onSelect});

  @override
  State<_LegacyLookupBottomSheet> createState() => _LegacyLookupBottomSheetState();
}

class _LegacyLookupBottomSheetState extends State<_LegacyLookupBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<LegacyMemberEntry> _results = LegacyRegister.allEntries;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _results = LegacyRegister.search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Gap(16.h),
              Text(
                'Find Your CQAAG Record',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Gap(4.h),
              Text(
                'Search by your name, telephone, company, or Member ID (e.g. CQAAG-FM-001).',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
              Gap(12.h),
              TextField(
                controller: _searchController,
                onChanged: _onSearch,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Type your name or phone number...',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              Gap(12.h),
              Text(
                'Found ${_results.length} matching members',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
              Gap(8.h),
              Expanded(
                child: _results.isEmpty
                    ? Center(
                        child: Text(
                          'No member found matching "${_searchController.text}".',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: _results.length,
                        separatorBuilder: (_, _) => Gap(8.h),
                        itemBuilder: (context, index) {
                          final entry = _results[index];
                          return InkWell(
                            onTap: () => widget.onSelect(entry),
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18.r,
                                    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.12),
                                    child: Text(
                                      entry.number.toString(),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                  Gap(12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              entry.memberId,
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryGreen,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (entry.phone != null && entry.phone!.isNotEmpty)
                                              Text(
                                                entry.phone!,
                                                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                                              ),
                                          ],
                                        ),
                                        Gap(2.h),
                                        Text(
                                          entry.name,
                                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                                        ),
                                        Gap(2.h),
                                        Text(
                                          '${entry.company.isNotEmpty && entry.company != "N/A" ? "${entry.company} · " : ""}${entry.locationSummary}',
                                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, size: 18.r, color: Colors.grey.shade400),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
