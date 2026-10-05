import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';

/// Lets a member replace their password — in particular the generated one
/// emailed when their membership was activated.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  static const String id = 'change_password_screen';

  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final values = _formKey.currentState!.value;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null) return;

    setState(() => _isSaving = true);
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: values['current_password'] as String),
      );
      await user.updatePassword(values['new_password'] as String);
      await ref.read(userServiceProvider).updateUserData(user.uid, {'must_change_password': false});

      if (!mounted) return;
      CustomSnackBar.success(context, message: 'Your password has been changed.');
      context.pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, message: FirebaseErrorMapper.mapAuthError(e));
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, message: 'Could not change your password: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mustChange = ref.watch(currentUserProfileProvider).value?.mustChangePassword ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const CustomText("Change Password", variant: TextVariant.headlineMedium, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mustChange) ...[
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.4)),
                    ),
                    child: const CustomText(
                      "You are signed in with the password the Secretariat emailed you. Choose your own now.",
                      variant: TextVariant.bodySmall,
                    ),
                  ),
                  Gap(20.h),
                ],
                CustomTextField(
                  name: 'current_password',
                  label: "Current Password",
                  hint: "The emailed password, or your current one",
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: FormBuilderValidators.required(),
                ),
                Gap(16.h),
                CustomTextField(
                  name: 'new_password',
                  label: "New Password",
                  hint: "At least 8 characters",
                  obscureText: true,
                  prefixIcon: Icons.lock_reset_outlined,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(8, errorText: 'Use at least 8 characters'),
                  ]),
                ),
                Gap(16.h),
                CustomTextField(
                  name: 'confirm_password',
                  label: "Confirm New Password",
                  hint: "Type it again",
                  obscureText: true,
                  prefixIcon: Icons.lock_reset_outlined,
                  validator: (value) =>
                      value != _formKey.currentState?.fields['new_password']?.value ? 'The passwords do not match' : null,
                ),
                Gap(32.h),
                CustomButton(text: "Change Password", isLoading: _isSaving, onPressed: _isSaving ? null : _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
