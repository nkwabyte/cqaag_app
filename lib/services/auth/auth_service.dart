import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/user/app_user.dart';
import 'package:cqaag_app/services/connectivity/connectivity_service.dart';
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

  Stream<User?> get authStateChanges => _auth.authStateChanges();

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

    final newUser = AppUser(
      id: credential.user!.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      district: district,
      region: region,
      isAdmin: isAdmin,
      verificationStatus: VerificationStatus.unverified,
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
