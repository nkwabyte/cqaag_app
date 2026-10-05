import 'package:cloud_firestore/cloud_firestore.dart';
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
  Stream<List<KitOrder>> streamAllOrders() {
    return _orders.orderBy('created_at', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => KitOrder.fromJson(doc.data())).toList(),
    );
  }

  Future<void> updateStatus({required String orderId, required KitOrderStatus status, required String adminUid}) async {
    await _orders.doc(orderId).update({
      'status': status.value,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
      'handled_by': adminUid,
    });
  }
}

@Riverpod(keepAlive: true)
KitOrderService kitOrderService(Ref ref) => KitOrderService();
