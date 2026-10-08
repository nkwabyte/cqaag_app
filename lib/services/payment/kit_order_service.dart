import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cqaag_app/models/payment/kit_order.dart';

part 'kit_order_service.g.dart';

/// Quality cutting kit orders, in `kit_orders`.
class KitOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders => _firestore.collection('kit_orders');

  Future<void> placeOrder(KitOrder order) async {
    await _orders.doc(order.id).set(order.toJson());
  }

  /// Every order, newest first (admins).
  Stream<List<KitOrder>> streamAllOrders() async* {
    try {
      await for (final snapshot in _orders.snapshots()) {
        final list = <KitOrder>[];
        for (final doc in snapshot.docs) {
          try {
            final data = Map<String, dynamic>.from(doc.data());
            if (data['id'] == null || (data['id'] is String && (data['id'] as String).isEmpty)) {
              data['id'] = doc.id;
            }
            list.add(KitOrder.fromJson(data));
          } catch (e, stack) {
            debugPrint('Error parsing kit order ${doc.id}: $e\n$stack');
          }
        }
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        yield list;
      }
    } catch (e, stack) {
      debugPrint('Error streaming kit_orders (handled gracefully): $e\n$stack');
      yield <KitOrder>[];
    }
  }

  Future<void> updateStatus({required String orderId, required KitOrderStatus status, required String adminUid}) async {
    final now = DateTime.now().toUtc().toIso8601String();
    try {
      final doc = await _orders.doc(orderId).get();
      if (doc.exists) {
        await _orders.doc(orderId).update({
          'status': status.value,
          'updated_at': now,
          'handled_by': adminUid,
        });
        return;
      }
    } catch (e) {
      debugPrint('Error updating kit_orders/$orderId: $e');
    }

    try {
      final memberRef = _firestore.collection('members').doc(orderId);
      final memberDoc = await memberRef.get();
      if (memberDoc.exists) {
        final paymentStatusStr = switch (status) {
          KitOrderStatus.paid => 'verified',
          KitOrderStatus.fulfilled => 'verified',
          KitOrderStatus.rejected => 'rejected',
          KitOrderStatus.pendingVerification => 'pending',
        };
        await memberRef.update({
          'payment_status': paymentStatusStr,
          'payment_verified_at': now,
          'payment_verified_by': adminUid,
          'updated_at': now,
        });
      }
    } catch (e) {
      debugPrint('Error updating members/$orderId for kit order: $e');
    }
  }
}

@Riverpod(keepAlive: true)
KitOrderService kitOrderService(Ref ref) => KitOrderService();
