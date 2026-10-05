import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';

/// Asks the website to email the member their generated sign-in password,
/// confirming the current password first if Firebase wants a fresh sign-in.
///
/// Returns whether the password has been emailed (now or before).
Future<bool> requestSignInPassword(BuildContext context, WidgetRef ref, MembershipApplication application) async {
  final service = ref.read(memberCredentialsServiceProvider);
  AppDialogs.showLoadingDialog(context, message: 'Emailing your sign-in password...');
  var result = await service.requestForApplicant(application.id);
  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

  if (result.outcome == CredentialsOutcome.needsRecentSignIn && context.mounted) {
    final password = await _askCurrentPassword(context);
    if (password == null || !context.mounted) return false;
    try {
      AppDialogs.showLoadingDialog(context, message: 'Emailing your sign-in password...');
      await service.reauthenticate(password);
      result = await service.requestForApplicant(application.id);
    } on FirebaseAuthException catch (e) {
      result = CredentialsResult(CredentialsOutcome.failed, FirebaseErrorMapper.mapAuthError(e));
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  if (!context.mounted) return result.isDone;
  if (result.isDone) {
    CustomSnackBar.success(
      context,
      title: 'Password emailed',
      message: 'Your sign-in password was emailed to ${application.emailAddress}. Change it in your Profile after signing in.',
    );
  } else {
    CustomSnackBar.error(context, message: result.message ?? 'The password email could not be sent yet.');
  }
  return result.isDone;
}

Future<String?> _askCurrentPassword(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirm your password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('For your security, enter your current password so a new sign-in password can be emailed.'),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Current password', border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text), child: const Text('Confirm')),
      ],
    ),
  );
}
