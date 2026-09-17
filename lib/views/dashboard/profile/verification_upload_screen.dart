import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';

/// Ghana Card verification (KYC).
///
/// Current Ghanaian law limits what the Association may collect to the Ghana
/// Card *number*. No photograph of the card and no selfie is captured, so this
/// screen takes one field and validates it hard: the number is the only piece
/// of identity evidence an admin will have to verify against, which makes its
/// structural correctness and uniqueness the whole of the check.
class VerificationUploadScreen extends ConsumerStatefulWidget {
  static const String id = 'verification_upload_screen';

  /// Set when this is a step of the membership application flow, in which case
  /// the number is carried forward rather than written on its own.
  final Map<String, dynamic>? applicationData;

  const VerificationUploadScreen({super.key, this.applicationData});

  @override
  ConsumerState<VerificationUploadScreen> createState() => _VerificationUploadScreenState();
}

class _VerificationUploadScreenState extends ConsumerState<VerificationUploadScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  /// Live preview of whether what has been typed so far is a valid number.
  bool _isNumberValid = false;

  bool get _isApplicationStep => widget.applicationData != null;

  Future<void> _submitVerification() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    final raw = _formKey.currentState!.value['ghana_card_number'] as String?;
    final ghanaCardNumber = GhanaCard.normalise(raw);

    // saveAndValidate already ran the same check, so this only guards against
    // a number that formats but does not normalise.
    if (ghanaCardNumber == null) {
      CustomSnackBar.error(context, message: 'Enter a valid Ghana Card number in the form ${GhanaCard.placeholder}.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(authServiceProvider).currentUser;

      // One Ghana Card may only back one membership. Checked here so the
      // applicant is told immediately rather than being rejected at review.
      final takenBy = await ref.read(membershipServiceProvider).findApplicationByGhanaCardNumber(
        ghanaCardNumber,
        excludingUserId: currentUser?.uid,
      );

      if (takenBy != null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        CustomSnackBar.error(
          context,
          title: 'Ghana Card already registered',
          message: 'This Ghana Card number is already on a CQAAG membership record. '
              'Please check the number, or contact the Secretariat if you believe this is an error.',
        );
        return;
      }

      // Part of the application flow: hand the number to the next step.
      if (_isApplicationStep) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        final combinedData = Map<String, dynamic>.from(widget.applicationData!);
        combinedData['ghana_card_number'] = ghanaCardNumber;

        context.pushNamed(MembershipAgreementScreen.id, extra: combinedData);
        return;
      }

      // Standalone verification from the profile screen.
      if (currentUser == null) {
        throw Exception('User profile not found. Please log in again.');
      }

      await ref.read(userServiceProvider).updateUserData(
        currentUser.uid,
        {
          'verification': VerificationData(idCardNumber: ghanaCardNumber).toJson(),
          'verification_status': VerificationStatus.pending.value,
        },
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ref.invalidate(currentUserProfileProvider);
      CustomSnackBar.success(context, message: 'Ghana Card number submitted for verification.');

      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed(DashboardScreen.id);
      }
    } catch (e) {
      debugPrint('Ghana Card verification error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackBar.error(context, message: 'Submission failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          "Ghana Card Verification",
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
                const CustomText(
                  "Verify Your Identity",
                  variant: TextVariant.headlineMedium,
                  fontWeight: FontWeight.bold,
                ),
                Gap(8.h),
                CustomText(
                  "Enter the personal ID number printed on the front of your Ghana Card. "
                  "The Secretariat verifies this number against the National Identification Register.",
                  variant: TextVariant.bodyMedium,
                  color: colorScheme.secondary,
                ),
                Gap(24.h),

                _buildPrivacyNotice(colorScheme),
                Gap(24.h),

                CustomTextField(
                  name: 'ghana_card_number',
                  label: 'Ghana Card Number',
                  hint: GhanaCard.placeholder,
                  initialValue: GhanaCard.prefix,
                  keyboardType: TextInputType.number,
                  validator: (value) => GhanaCard.validationError(value),
                  inputFormatters: [GhanaCardFormatter()],
                  onChanged: (value) {
                    final valid = GhanaCard.isValid(value);
                    if (valid != _isNumberValid) {
                      setState(() => _isNumberValid = valid);
                    }
                  },
                ),
                Gap(8.h),
                _buildFormatHint(colorScheme),

                Gap(32.h),
                CustomButton(
                  text: _isApplicationStep ? "Continue to Membership Agreement" : "Submit for Verification",
                  isLoading: _isLoading,
                  onPressed: _isLoading ? () {} : _submitVerification,
                ),
                Gap(24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// States plainly that no card images are taken. Applicants who went through
  /// the old flow, or who expect to be asked for photographs, would otherwise
  /// assume the step is unfinished.
  Widget _buildPrivacyNotice(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.privacy_tip_outlined, color: AppColors.primaryGreen, size: 22.r),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  "We no longer collect card images",
                  variant: TextVariant.bodyMedium,
                  fontWeight: FontWeight.bold,
                ),
                Gap(4.h),
                CustomText(
                  "In line with current Ghanaian identity law, CQAAG records your Ghana Card "
                  "number only. Do not send photographs of your card to anyone claiming to "
                  "act for the Association.",
                  variant: TextVariant.bodySmall,
                  color: colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Confirms the structure as it is typed, so a mistyped number is caught
  /// before submission rather than at review.
  Widget _buildFormatHint(ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          _isNumberValid ? Icons.check_circle : Icons.info_outline,
          size: 16.r,
          color: _isNumberValid ? AppColors.primaryGreen : colorScheme.secondary,
        ),
        Gap(6.w),
        Expanded(
          child: CustomText(
            _isNumberValid
                ? "Valid Ghana Card number format."
                : "Format: ${GhanaCard.placeholder} — nine digits followed by a single check digit.",
            variant: TextVariant.bodySmall,
            color: _isNumberValid ? AppColors.primaryGreen : colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
