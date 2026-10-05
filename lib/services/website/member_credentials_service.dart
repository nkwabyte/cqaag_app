import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cqaag_app/services/membership/membership_service.dart';
import 'package:cqaag_app/services/website/website_api_service.dart';

part 'member_credentials_service.g.dart';

enum CredentialsOutcome {
  /// A generated password was emailed to the application address just now.
  emailed,

  /// One was emailed before; nothing more to do.
  alreadyIssued,

  /// An admin asked; the applicant was emailed to sign in so the password can
  /// be issued on their own account.
  signInNoticeSent,

  /// Firebase wants a fresh sign-in before the password can change.
  needsRecentSignIn,

  failed,
}

class CredentialsResult {
  const CredentialsResult(this.outcome, [this.message]);

  final CredentialsOutcome outcome;
  final String? message;

  bool get isDone => outcome == CredentialsOutcome.emailed || outcome == CredentialsOutcome.alreadyIssued;
}

/// Emails an approved, paid-up member a generated sign-in password, linked
/// only to the email address on their application.
///
/// The password is generated and mailed by the website, which holds the SMTP
/// credentials; it is never written to Firestore. It can only be set on the
/// applicant's own account, so this runs while the applicant is signed in.
/// Same handshake as the website's member portal.
class MemberCredentialsService {
  MemberCredentialsService(this._website, this._membership);

  final WebsiteApiService _website;
  final MembershipService _membership;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Requests the password for [memberId] as the signed-in applicant.
  Future<CredentialsResult> requestForApplicant(String memberId) async {
    final result = await _website.issueCredentials(memberId);
    if (!result.success) return _failure(result);

    switch (result.status) {
      case 'link_required':
        return _attachAndConfirm(memberId, result);
      case 'emailed':
        await _recordIssued(memberId);
        return const CredentialsResult(CredentialsOutcome.emailed);
      case 'already_issued':
        await _membership.markCredentialsIssued(memberId).catchError((_) {});
        return const CredentialsResult(CredentialsOutcome.alreadyIssued);
      default:
        return CredentialsResult(CredentialsOutcome.failed, result.message);
    }
  }

  /// Asks the website to issue the password from an admin session. The
  /// website cannot set a password on someone else's account, so this emails
  /// the applicant to sign in, after which the app issues it.
  Future<CredentialsResult> requestAsAdmin(String memberId) async {
    final result = await _website.issueCredentials(memberId);
    if (!result.success) return _failure(result);
    return switch (result.status) {
      'emailed' || 'already_issued' => const CredentialsResult(CredentialsOutcome.alreadyIssued),
      'exists_notice' || 'notice_already_sent' => const CredentialsResult(CredentialsOutcome.signInNoticeSent),
      _ => CredentialsResult(CredentialsOutcome.failed, result.message),
    };
  }

  /// Re-confirms the applicant's identity with their current password, so a
  /// retry can change it.
  Future<void> reauthenticate(String currentPassword) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) throw Exception('Sign in is required.');
    await user.reauthenticateWithCredential(EmailAuthProvider.credential(email: email, password: currentPassword));
    await user.getIdToken(true);
  }

  /// The website generated the password but could not set it itself; set it on
  /// this account, then ask the website to email it.
  Future<CredentialsResult> _attachAndConfirm(String memberId, WebsiteApiResult issued) async {
    final password = issued.data['password']?.toString();
    final linkToken = issued.data['link_token']?.toString();
    final user = _auth.currentUser;
    final email = user?.email;
    if (password == null || linkToken == null || user == null || email == null) {
      return const CredentialsResult(CredentialsOutcome.failed, 'The sign-in password could not be prepared.');
    }

    try {
      await user.linkWithCredential(EmailAuthProvider.credential(email: email, password: password));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked' || e.code == 'email-already-in-use' || e.code == 'credential-already-in-use') {
        try {
          await user.updatePassword(password);
        } on FirebaseAuthException catch (updateError) {
          if (updateError.code == 'requires-recent-login') return _recentSignInNeeded();
          return const CredentialsResult(CredentialsOutcome.failed, 'The sign-in password could not be saved on this account.');
        }
      } else if (e.code == 'requires-recent-login') {
        return _recentSignInNeeded();
      } else {
        return const CredentialsResult(CredentialsOutcome.failed, 'The sign-in password could not be saved on this account.');
      }
    }

    final confirmed = await _website.confirmCredentials(memberId: memberId, linkToken: linkToken);
    if (!confirmed.success) return _failure(confirmed);
    if (confirmed.status == 'emailed') {
      await _recordIssued(memberId);
      return const CredentialsResult(CredentialsOutcome.emailed);
    }
    return CredentialsResult(CredentialsOutcome.failed, confirmed.message);
  }

  /// Notes the issue on the membership record, and flags the account so the
  /// member is asked to choose their own password after signing in.
  Future<void> _recordIssued(String memberId) async {
    await _membership.markCredentialsIssued(memberId).catchError((_) {});
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).update({'must_change_password': true}).catchError((_) {});
    }
  }

  CredentialsResult _recentSignInNeeded() {
    return const CredentialsResult(
      CredentialsOutcome.needsRecentSignIn,
      'Confirm your current password so a sign-in password can be emailed to your application address.',
    );
  }

  CredentialsResult _failure(WebsiteApiResult result) {
    if (result.code == 'credential_too_old') return _recentSignInNeeded();
    return CredentialsResult(CredentialsOutcome.failed, result.message ?? 'The password email could not be sent yet.');
  }
}

@Riverpod(keepAlive: true)
MemberCredentialsService memberCredentialsService(Ref ref) {
  return MemberCredentialsService(ref.watch(websiteApiServiceProvider), ref.watch(membershipServiceProvider));
}
