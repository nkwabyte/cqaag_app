import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/user/app_user.dart';
import 'package:cqaag_app/services/connectivity/connectivity_service.dart';
import 'package:cqaag_app/services/membership/legacy_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return AuthService(connectivityService);
}

@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(authServiceProvider).authStateChanges;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService;

  AuthService(this._connectivityService);

  Stream<User?> get authStateChanges => _auth.userChanges();

  User? get currentUser => _auth.currentUser;

  Stream<AppUser?> get currentUserProfile {
    return authStateChanges.switchMap((user) {
      if (user == null) return Stream.value(null);
      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) => snapshot.exists ? AppUser.fromJson(snapshot.data()!) : null);
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _connectivityService.ensureConnected();
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? address,
    String? district,
    String? region,
    bool isAdmin = false,
  }) async {
    await _connectivityService.ensureConnected();
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (credential.user == null) return;

    final cleanEmail = email.trim().toLowerCase();

    // Check if there is an existing membership application filed with this email or phone
    MembershipStatus initialMembershipStatus = MembershipStatus.notAMember;
    VerificationStatus initialVerificationStatus = VerificationStatus.unverified;

    try {
      final membersRef = _firestore.collection('members');
      final emailQuery = await membersRef.where('email_address', isEqualTo: cleanEmail).limit(1).get();
      QueryDocumentSnapshot<Map<String, dynamic>>? matchedDoc;

      if (emailQuery.docs.isNotEmpty) {
        matchedDoc = emailQuery.docs.first;
      } else {
        final phoneQuery = await membersRef.where('phone_number_primary', isEqualTo: phoneNumber.trim()).limit(1).get();
        if (phoneQuery.docs.isNotEmpty) {
          matchedDoc = phoneQuery.docs.first;
        }
      }

      if (matchedDoc != null) {
        final appData = matchedDoc.data();
        final statusStr = appData['status'] as String?;
        if (statusStr == 'approved' || (appData['is_payment_verified'] == true)) {
          initialMembershipStatus = MembershipStatus.verified;
          initialVerificationStatus = VerificationStatus.verified;
        } else if (statusStr == 'submitted' || statusStr == 'underReview' || statusStr == 'pendingReview') {
          initialMembershipStatus = MembershipStatus.applied;
          initialVerificationStatus = VerificationStatus.pending;
        }
        // Link the membership record to the newly created user ID
        await matchedDoc.reference.update({
          'user_id': credential.user!.uid,
          'email_address': cleanEmail,
          'is_claimed': true,
          'claimed_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Check legacy register by phone or name
        final legacyMatch = LegacyRegister.findByPhone(phoneNumber) ??
            LegacyRegister.findByName('$firstName $lastName') ??
            LegacyRegister.findByName('$lastName $firstName');
        if (legacyMatch != null) {
          initialMembershipStatus = MembershipStatus.verified;
          initialVerificationStatus = VerificationStatus.verified;
          // Seed & claim in Firestore members collection
          await membersRef.doc(legacyMatch.firestoreDocId).set({
            ...legacyMatch.toFirestoreMap(userId: credential.user!.uid, email: cleanEmail),
            'is_claimed': true,
            'claimed_at': DateTime.now().toIso8601String(),
            if (address != null && address.isNotEmpty) 'residential_address': address,
          }, SetOptions(merge: true));
        }
      }
    } catch (_) {
      // Continue even if linking encounters a non-critical error
    }

    final newUser = AppUser(
      id: credential.user!.uid,
      firstName: firstName,
      lastName: lastName,
      email: cleanEmail,
      phoneNumber: phoneNumber,
      address: address,
      district: district,
      region: region,
      isAdmin: isAdmin,
      membershipStatus: initialMembershipStatus,
      verificationStatus: initialVerificationStatus,
    );

    await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());

    // Automatically send email verification link upon registration
    try {
      await credential.user!.sendEmailVerification();
    } catch (_) {
      // Handled silently if rate-limited or transient failure
    }
  }

  Future<void> sendEmailVerification() async {
    await _connectivityService.ensureConnected();
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> updateUser(AppUser user) async {
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Mark as inactive in Firestore
    await _firestore.collection('users').doc(user.uid).update({'status': AppUserStatus.inactive.value});

    // Check if re-authentication is needed before delete (usually required for sensitive ops)
    // For now, attempting direct delete
    await user.delete();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
