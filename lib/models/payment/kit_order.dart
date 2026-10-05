import 'package:cqaag_app/models/payment/fee_schedule.dart';

/// Lifecycle of a quality cutting kit order.
enum KitOrderStatus {
  pendingVerification('pending_verification', 'Awaiting payment check'),
  paid('paid', 'Paid — preparing'),
  fulfilled('fulfilled', 'Delivered'),
  rejected('rejected', 'Payment rejected');

  const KitOrderStatus(this.value, this.label);

  final String value;
  final String label;

  static KitOrderStatus fromValue(String? value) {
    return KitOrderStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => KitOrderStatus.pendingVerification,
    );
  }
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
  String get reference => id.replaceAll('-', '').substring(0, 8).toUpperCase();

  String money(double amount) => '$currency ${amount.toStringAsFixed(2)}';

  bool get isGuest => buyerUserId == null;

  factory KitOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final total = json['total'];
    return KitOrder(
      id: json['id']?.toString() ?? '',
      buyerName: json['buyer_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      emailAddress: json['email_address']?.toString(),
      organisation: json['organisation']?.toString(),
      deliveryLocation: json['delivery_location']?.toString(),
      notes: json['notes']?.toString(),
      buyerUserId: json['buyer_user_id']?.toString(),
      items: rawItems is List
          ? rawItems.whereType<Map>().map((e) => SelectedFeeItem.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
      total: total is num ? total.toDouble() : 0,
      currency: json['currency']?.toString() ?? 'GHS',
      paymentEvidenceUrl: json['payment_evidence_url']?.toString(),
      paymentReference: json['payment_reference']?.toString(),
      paymentMomoNetwork: json['payment_momo_network']?.toString(),
      paymentMomoNumber: json['payment_momo_number']?.toString(),
      status: KitOrderStatus.fromValue(json['status']?.toString()),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      handledBy: json['handled_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'buyer_name': buyerName,
    'phone_number': phoneNumber,
    'email_address': emailAddress,
    'organisation': organisation,
    'delivery_location': deliveryLocation,
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
