import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cqaag_app/index.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

final userNotificationsStreamProvider = StreamProvider<List<SystemNotification>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  final user = ref.watch(currentUserProfileProvider).value;
  return service.getNotificationsStream(user: user);
});

final readNotificationIdsProvider = NotifierProvider<ReadNotificationsNotifier, Set<String>>(ReadNotificationsNotifier.new);

class ReadNotificationsNotifier extends Notifier<Set<String>> {
  static const String _storageKey = 'cqaag_read_notifications';

  @override
  Set<String> build() {
    _loadReadIds();
    return {};
  }

  Future<void> _loadReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_storageKey) ?? [];
    state = ids.toSet();
  }

  Future<void> markAsRead(String id) async {
    if (state.contains(id)) return;
    final updated = {...state, id};
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, updated.toList());
  }

  Future<void> markAllAsRead(List<String> ids) async {
    final updated = {...state, ...ids};
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, updated.toList());
  }
}

class NotificationService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  NotificationService({
    required this.firestore,
    required this.auth,
  });

  Stream<List<SystemNotification>> getNotificationsStream({AppUser? user}) {
    return firestore.collection('notifications').snapshots().map((snapshot) {
      final String userUid = auth.currentUser?.uid ?? '';
      final String userEmail = auth.currentUser?.email ?? '';
      final String membershipCategory = (user?.membershipStatus.toString() ?? 'none').toLowerCase();

      final list = snapshot.docs.map((doc) => SystemNotification.fromFirestore(doc)).where((notif) {
        final targetStr = notif.target.toString().toLowerCase().trim();

        if (targetStr == 'all') return true;
        if (targetStr == 'category:$membershipCategory') return true;
        if (targetStr == 'user:$userUid' || targetStr == 'user:$userEmail') return true;

        return false;
      }).toList();

      list.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      return list;
    });
  }
}
