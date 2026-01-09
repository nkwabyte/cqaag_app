import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/user/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  return AuthService();
}

@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(authServiceProvider).authStateChanges;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Stream<AppUser?> get currentUserProfile {
    return authStateChanges.switchMap((user) {
      if (user == null) return Stream.value(null);
      return _firestore.collection('users').doc(user.uid).snapshots().map((snapshot) => snapshot.exists ? AppUser.fromJson(snapshot.data()!) : null);
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? role, // Optionally used if needed immediately, though not in AppUser yet
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (credential.user == null) return;

    final newUser = AppUser(
      id: credential.user!.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
    );

    await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
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
