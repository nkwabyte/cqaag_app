import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/index.dart';
import 'package:uuid/uuid.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Collection reference for newsletter subscriptions
  CollectionReference get _subscriptionsCollection => _firestore.collection('newsletter_subscriptions');

  /// Subscribe a new email to the newsletter
  /// Returns true if successful, throws exception on error
  Future<bool> subscribe(String email, {String source = 'guest_events_screen'}) async {
    try {
      // Check if email already exists
      final existingSubscription = await _subscriptionsCollection.where('email', isEqualTo: email.toLowerCase().trim()).limit(1).get();

      if (existingSubscription.docs.isNotEmpty) {
        // Email already subscribed
        final doc = existingSubscription.docs.first;
        final subscription = NewsletterSubscription.fromJson(
          doc.data() as Map<String, dynamic>,
        );

        // If inactive, reactivate it
        if (!subscription.isActive) {
          await doc.reference.update({
            'is_active': true,
            'updated_at': FieldValue.serverTimestamp(),
          });
          return true;
        }

        // Already active subscription
        throw Exception('This email is already subscribed');
      }

      // Create new subscription
      final subscription = NewsletterSubscription(
        id: _uuid.v4(),
        email: email.toLowerCase().trim(),
        subscribedAt: DateTime.now(),
        isActive: true,
        source: source,
      );

      await _subscriptionsCollection
          .doc(subscription.id)
          .set(
            subscription.toJson(),
          );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Unsubscribe an email from the newsletter
  Future<bool> unsubscribe(String email) async {
    try {
      final querySnapshot = await _subscriptionsCollection.where('email', isEqualTo: email.toLowerCase().trim()).limit(1).get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Email not found in subscriptions');
      }

      await querySnapshot.docs.first.reference.update({
        'is_active': false,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if an email is subscribed
  Future<bool> isSubscribed(String email) async {
    try {
      final querySnapshot = await _subscriptionsCollection.where('email', isEqualTo: email.toLowerCase().trim()).where('is_active', isEqualTo: true).limit(1).get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get all active subscriptions (admin only)
  Stream<List<NewsletterSubscription>> streamActiveSubscriptions() {
    return _subscriptionsCollection.where('is_active', isEqualTo: true).orderBy('subscribed_at', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return NewsletterSubscription.fromJson(
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }
}
