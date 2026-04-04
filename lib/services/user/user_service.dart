import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/user/app_user.dart';
import 'package:cqaag_app/services/connectivity/connectivity_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_service.g.dart';

@Riverpod(keepAlive: true)
UserService userService(Ref ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return UserService(connectivityService);
}

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService;

  UserService(this._connectivityService);

  CollectionReference<Map<String, dynamic>> get _usersCollection => _firestore.collection('users');

  /// Stream all users for admin dashboard
  Stream<List<AppUser>> streamAllUsers() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList();
    });
  }

  /// Update user status (e.g. suspend, ban, active)
  Future<void> updateUserStatus(String userId, AppUserStatus status) async {
    await _connectivityService.ensureConnected();
    await _usersCollection.doc(userId).update({'status': status.value});
  }

  /// Get user by ID
  Future<AppUser?> getUserById(String userId) async {
    await _connectivityService.ensureConnected(); // Restoring this too just in case
    final doc = await _usersCollection.doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromJson(doc.data()!);
    }
    return null;
  }

  /// Update generic user data
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _connectivityService.ensureConnected();
      await _usersCollection.doc(userId).update(data);
    } catch (e) {
      // Re-throw to be handled by caller
      rethrow;
    }
  }

  /// Stream user by ID
  Stream<AppUser?> streamUser(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return AppUser.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  /// Update user profile
  Future<void> updateUser(AppUser user) async {
    await _connectivityService.ensureConnected();
    await _usersCollection.doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }
}
