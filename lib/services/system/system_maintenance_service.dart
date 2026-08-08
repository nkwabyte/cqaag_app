import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'system_maintenance_service.g.dart';

/// Service providing administrative tools to clear system caches,
/// delete specific entities, and perform full or selective database purges.
class SystemMaintenanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SystemMaintenanceService();

  /// Clears local image, network, and memory caches.
  Future<void> clearSystemCache() async {
    try {
      // Clear Flutter image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      debugPrint('Local system image cache cleared successfully.');
    } catch (e) {
      debugPrint('Error clearing local cache: $e');
      rethrow;
    }
  }

  /// Deletes a specific document from any Firestore collection.
  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    await _firestore.collection(collectionPath).doc(documentId).delete();
  }

  /// Delete a specific user from the `users` collection.
  /// First disables/inactivates the account record so registration email state is freed cleanly,
  /// then deletes the document from Firestore.
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'inactive',
        'is_active': false,
        'deleted_at': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Ignore if document was already deleted or missing
    }
    await deleteDocument(collectionPath: 'users', documentId: userId);
  }

  /// Delete a specific member application from the `members` collection.
  Future<void> deleteMember(String memberId) async {
    await deleteDocument(collectionPath: 'members', documentId: memberId);
  }

  /// Delete a specific inspection report from the `inspections` collection.
  Future<void> deleteReport(String reportId) async {
    await deleteDocument(collectionPath: 'inspections', documentId: reportId);
  }

  /// Delete a specific notification from the `notifications` collection.
  Future<void> deleteNotification(String notificationId) async {
    await deleteDocument(collectionPath: 'notifications', documentId: notificationId);
  }

  /// Delete a specific newsletter subscription from the `newsletter_subscriptions` collection.
  Future<void> deleteSubscription(String subscriptionId) async {
    await deleteDocument(collectionPath: 'newsletter_subscriptions', documentId: subscriptionId);
  }

  /// Purges an entire collection in Firestore using batched writes.
  /// If purging 'users', inactivates user accounts prior to deletion so re-registration works seamlessly.
  Future<int> purgeCollection(String collectionPath, {String? excludeDocId}) async {
    int deletedCount = 0;
    try {
      final collectionRef = _firestore.collection(collectionPath);
      final snapshot = await collectionRef.get();

      if (snapshot.docs.isEmpty) return 0;

      WriteBatch batch = _firestore.batch();
      int countInBatch = 0;

      for (final doc in snapshot.docs) {
        if (excludeDocId != null && doc.id == excludeDocId) {
          continue;
        }

        if (collectionPath == 'users') {
          batch.update(doc.reference, {
            'status': 'inactive',
            'is_active': false,
          });
        }

        batch.delete(doc.reference);
        deletedCount++;
        countInBatch++;

        // Firestore batches support maximum 500 operations
        if (countInBatch == 200) {
          await batch.commit();
          batch = _firestore.batch();
          countInBatch = 0;
        }
      }

      if (countInBatch > 0) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint("Warning during purge of collection '$collectionPath': $e");
    }

    return deletedCount;
  }

  /// Selective/Full Database Purge: Wipes requested data sections (members, inspections,
  /// notifications, subscriptions, users).
  /// Preserves the active admin document during collection purges so admin security rules
  /// remain active, deleting the admin document at the very end if requested.
  Future<Map<String, int>> purgeSelectedDatabase({
    required String currentAdminUid,
    bool purgeUsers = true,
    bool purgeMembers = true,
    bool purgeReports = true,
    bool purgeNotifications = true,
    bool purgeSubscriptions = true,
    bool deleteActiveAdmin = false,
  }) async {
    final Map<String, int> results = {};

    if (purgeMembers) {
      results['members'] = await purgeCollection('members');
    }
    if (purgeReports) {
      results['inspections'] = await purgeCollection('inspections');
    }
    if (purgeNotifications) {
      results['notifications'] = await purgeCollection('notifications');
    }
    if (purgeSubscriptions) {
      results['newsletter_subscriptions'] = await purgeCollection('newsletter_subscriptions');
    }

    if (purgeUsers) {
      // Always exclude current admin during bulk users purge to maintain active admin rights
      results['users'] = await purgeCollection('users', excludeDocId: currentAdminUid);

      // If active admin deletion was requested, delete active admin account at the final step
      if (deleteActiveAdmin) {
        await deleteUser(currentAdminUid);
        results['users'] = (results['users'] ?? 0) + 1;
      }
    }

    return results;
  }
}

@Riverpod(keepAlive: true)
SystemMaintenanceService systemMaintenanceService(Ref ref) {
  return SystemMaintenanceService();
}
