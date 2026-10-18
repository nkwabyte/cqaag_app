import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/payment/fee_schedule.dart';

/// Lifecycle of a quality cutting kit order (Spec Section 80.5).
enum KitOrderStatus {
  pendingVerification('pending_verification', 'Awaiting payment check'),
  ordered('ordered', 'Ordered'),
  paid('paid', 'Paid — preparing'),
  packed('packed', 'Packed for dispatch'),
  shipped('shipped', 'Shipped with courier'),
  fulfilled('fulfilled', 'Delivered'),
  delivered('delivered', 'Delivered'),
  cancelled('cancelled', 'Cancelled'),
  refunded('refunded', 'Refunded'),
  rejected('rejected', 'Payment rejected');

  const KitOrderStatus(this.value, this.label);

  final String value;
  final String label;

  static KitOrderStatus fromValue(String? value) {
    if (value == null) return KitOrderStatus.pendingVerification;
    final clean = value.toLowerCase().trim();
    if (clean == 'delivered') return KitOrderStatus.delivered;
    if (clean == 'ordered') return KitOrderStatus.ordered;
    return KitOrderStatus.values.firstWhere(
      (s) => s.value == clean,
      orElse: () => KitOrderStatus.pendingVerification,
    );
  }
}

/// Audit log entry of kit order status transitions (Criterion 80.5: who changed them and when).
class KitOrderStatusHistoryEntry {
  const KitOrderStatusHistoryEntry({
    required this.status,
    required this.changedBy,
    required this.timestamp,
    this.reason,
  });

  final KitOrderStatus status;
  final String changedBy;
  final DateTime timestamp;
  final String? reason;

  factory KitOrderStatusHistoryEntry.fromJson(Map<String, dynamic> json) => KitOrderStatusHistoryEntry(
    status: KitOrderStatus.fromValue(json['status']?.toString()),
    changedBy: json['changed_by']?.toString() ?? '',
    timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    reason: json['reason']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'status': status.value,
    'changed_by': changedBy,
    'timestamp': timestamp.toIso8601String(),
    'reason': reason,
  };
}

/// A purchase of quality cutting kit items, by a guest or a member.
///
/// Stored in `kit_orders`. Items are priced from the fee schedule at the
/// moment of ordering and snapshotted, as membership quotes are.
class KitOrder {
  const KitOrder({
    required this.id,
    required this.buyerName,
    required this.phoneNumber,
    required this.items,
    required this.total,
    required this.currency,
    required this.createdAt,
    this.emailAddress,
    this.organisation,
    this.deliveryLocation,
    this.shippingZoneId,
    this.shippingFee = 0.0,
    this.statusHistory = const [],
    this.notes,
    this.buyerUserId,
    this.paymentEvidenceUrl,
    this.paymentReference,
    this.paymentMomoNetwork,
    this.paymentMomoNumber,
    this.status = KitOrderStatus.pendingVerification,
    this.updatedAt,
    this.handledBy,
  });

  final String id;
  final String buyerName;
  final String phoneNumber;
  final String? emailAddress;
  final String? organisation;
  final String? deliveryLocation;
  final String? shippingZoneId;
  final double shippingFee;
  final List<KitOrderStatusHistoryEntry> statusHistory;
  final String? notes;

  /// Signed-in buyer, or null for a guest.
  final String? buyerUserId;

  final List<SelectedFeeItem> items;
  final double total;
  final String currency;

  final String? paymentEvidenceUrl;
  final String? paymentReference;
  final String? paymentMomoNetwork;
  final String? paymentMomoNumber;

  final KitOrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// UID of the admin who last changed the status.
  final String? handledBy;

  /// Short reference for the buyer to quote.
  String get reference {
    final clean = id.replaceAll('-', '');
    if (clean.isEmpty) return 'KIT-ORDER';
    if (clean.length < 8) return clean.toUpperCase();
    return clean.substring(0, 8).toUpperCase();
  }

  String money(double amount) => '$currency ${amount.toStringAsFixed(2)}';

  bool get isGuest => buyerUserId == null;

  static DateTime _parseDate(dynamic val, {DateTime? fallback}) {
    if (val == null) return fallback ?? DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    final str = val.toString().trim();
    if (str.isEmpty) return fallback ?? DateTime.now();
    return DateTime.tryParse(str) ?? (fallback ?? DateTime.now());
  }

  factory KitOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['optional_items'] ?? json['payment_optional_items'];
    final total = json['total'] ?? json['amount'] ?? json['payment_amount'];
    return KitOrder(
      id: (json['id'] ?? json['doc_id'] ?? json['order_id'] ?? '').toString(),
      buyerName: (json['buyer_name'] ?? json['buyerName'] ?? json['full_name'] ?? json['fullName'] ?? json['name'] ?? '').toString(),
      phoneNumber: (json['phone_number'] ?? json['phoneNumber'] ?? json['phone'] ?? '').toString(),
      emailAddress: (json['email_address'] ?? json['emailAddress'] ?? json['email'])?.toString(),
      organisation: (json['organisation'] ?? json['organization'] ?? json['company'])?.toString(),
      deliveryLocation: (json['delivery_location'] ?? json['deliveryLocation'] ?? json['address'])?.toString(),
      shippingZoneId: (json['shipping_zone_id'] ?? json['shippingZoneId'] ?? json['zone_id'])?.toString(),
      shippingFee: (json['shipping_fee'] ?? json['shippingFee'] ?? 0.0) is num
          ? (json['shipping_fee'] ?? json['shippingFee'] ?? 0.0).toDouble()
          : 0.0,
      statusHistory: (json['status_history'] as List? ?? [])
          .whereType<Map>()
          .map((e) => KitOrderStatusHistoryEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      notes: (json['notes'] ?? json['note'])?.toString(),
      buyerUserId: (json['buyer_user_id'] ?? json['buyerUserId'] ?? json['user_id'] ?? json['userId'])?.toString(),
      items: rawItems is List
          ? rawItems.whereType<Map>().map((e) => SelectedFeeItem.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
      total: total is num ? total.toDouble() : 0,
      currency: (json['currency'] ?? json['payment_currency'] ?? 'GHS').toString(),
      paymentEvidenceUrl: (json['payment_evidence_url'] ?? json['paymentEvidenceUrl'] ?? json['receipt_url'])?.toString(),
      paymentReference: (json['payment_reference'] ?? json['paymentReference'])?.toString(),
      paymentMomoNetwork: (json['payment_momo_network'] ?? json['paymentMomoNetwork'] ?? json['network'])?.toString(),
      paymentMomoNumber: (json['payment_momo_number'] ?? json['paymentMomoNumber'])?.toString(),
      status: KitOrderStatus.fromValue((json['status'] ?? json['order_status'])?.toString()),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt'] ?? json['timestamp']),
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? _parseDate(json['updated_at'] ?? json['updatedAt'], fallback: null)
          : null,
      handledBy: (json['handled_by'] ?? json['handledBy'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'buyer_name': buyerName,
    'phone_number': phoneNumber,
    'email_address': emailAddress,
    'organisation': organisation,
    'delivery_location': deliveryLocation,
    'shipping_zone_id': shippingZoneId,
    'shipping_fee': shippingFee,
    'status_history': statusHistory.map((e) => e.toJson()).toList(),
    'notes': notes,
    'buyer_user_id': buyerUserId,
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'currency': currency,
    'payment_evidence_url': paymentEvidenceUrl,
    'payment_reference': paymentReference,
    'payment_momo_network': paymentMomoNetwork,
    'payment_momo_number': paymentMomoNumber,
    'status': status.value,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'handled_by': handledBy,
  };
}
