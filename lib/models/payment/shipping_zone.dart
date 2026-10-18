import 'package:cqaag_app/models/user/app_user.dart';

/// One of the 4 statutory delivery zones for quality cutting kit parcels (Spec Section 81).
class ShippingZone {
  const ShippingZone({
    required this.id,
    required this.name,
    required this.regions,
    this.fee,
    this.isClosed = true,
    this.history = const [],
  });

  final String id;
  final String name;
  final List<String> regions;

  /// Delivery fee in GHS. If null or 0, zone cannot be paid unless Secretariat sets fee.
  final double? fee;

  /// Whether the zone is closed for delivery.
  final bool isClosed;

  /// Audit history of fee changes: who changed it, when, and why (Criterion 81.4).
  final List<ShippingZoneFeeHistory> history;

  bool get canBePaid => !isClosed && fee != null && fee! > 0;

  ShippingZone copyWithNewFee({
    required double newFee,
    required String changedBy,
    required String reason,
    DateTime? timestamp,
  }) {
    final entry = ShippingZoneFeeHistory(
      fee: newFee,
      changedBy: changedBy,
      changedAt: timestamp ?? DateTime.now().toUtc(),
      reason: reason,
    );
    return ShippingZone(
      id: id,
      name: name,
      regions: regions,
      fee: newFee,
      isClosed: false,
      history: [...history, entry],
    );
  }

  factory ShippingZone.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'] as List? ?? [];
    return ShippingZone(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      regions: (json['regions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      fee: json['fee'] != null ? (json['fee'] as num).toDouble() : null,
      isClosed: json['is_closed'] ?? (json['fee'] == null || json['fee'] == 0),
      history: rawHistory
          .whereType<Map>()
          .map((e) => ShippingZoneFeeHistory.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'regions': regions,
    'fee': fee,
    'is_closed': isClosed,
    'history': history.map((e) => e.toJson()).toList(),
  };

  /// Initial state per Criterion 81.1: The four rows exist with no fee and are closed.
  static List<ShippingZone> initialStatutoryZones() {
    return const [
      ShippingZone(
        id: 'zone_1',
        name: 'Zone 1: Greater Accra',
        regions: ['Greater Accra'],
        fee: null,
        isClosed: true,
      ),
      ShippingZone(
        id: 'zone_2',
        name: 'Zone 2: Ashanti, Central & Western',
        regions: ['Ashanti', 'Central', 'Western', 'Western North'],
        fee: null,
        isClosed: true,
      ),
      ShippingZone(
        id: 'zone_3',
        name: 'Zone 3: Bono, Bono East & Ahafo',
        regions: ['Bono', 'Bono East', 'Ahafo'],
        fee: null,
        isClosed: true,
      ),
      ShippingZone(
        id: 'zone_4',
        name: 'Zone 4: Northern & Eastern Belts',
        regions: ['Northern', 'Savannah', 'North East', 'Upper East', 'Upper West', 'Volta', 'Oti', 'Eastern'],
        fee: null,
        isClosed: true,
      ),
    ];
  }
}

/// Audit history entry for Shipping Zone fee changes (Criterion 81.4).
class ShippingZoneFeeHistory {
  const ShippingZoneFeeHistory({
    required this.fee,
    required this.changedBy,
    required this.changedAt,
    required this.reason,
  });

  final double? fee;
  final String changedBy;
  final DateTime changedAt;
  final String reason;

  factory ShippingZoneFeeHistory.fromJson(Map<String, dynamic> json) => ShippingZoneFeeHistory(
    fee: json['fee'] != null ? (json['fee'] as num).toDouble() : null,
    changedBy: json['changed_by']?.toString() ?? '',
    changedAt: DateTime.tryParse(json['changed_at']?.toString() ?? '') ?? DateTime.now(),
    reason: json['reason']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'fee': fee,
    'changed_by': changedBy,
    'changed_at': changedAt.toIso8601String(),
    'reason': reason,
  };
}

/// Statutory Kit Order Rules Evaluator (Criteria 80.1–80.6 & 81.1–81.5).
class KitOrderStatutoryRules {
  /// Association statutory branding name for checkout screens (Criterion 80.3).
  static const String associationOfficialName = "Cashew Quality Assessors Association Ghana";

  /// P-J2: Active member or approved applicant paying for activation can order;
  /// a hibernated member cannot until arrears are paid.
  static bool canMemberOrderKit(MembershipStatus status) {
    if (status == MembershipStatus.hibernated || status == MembershipStatus.suspended || status == MembershipStatus.declined) {
      return false;
    }
    return status == MembershipStatus.active ||
        status == MembershipStatus.verified ||
        status == MembershipStatus.approvedPaymentPending;
  }

  /// Criterion 80.1: A member cannot pay with no item or no address.
  /// Criterion 80.6: An item without a price cannot be ordered.
  static String? validateOrderPrerequisites({
    required List<dynamic> items,
    required String? deliveryAddress,
    required ShippingZone? zone,
    required MembershipStatus membershipStatus,
  }) {
    if (!canMemberOrderKit(membershipStatus)) {
      return "Hibernated members cannot order kits until dues arrears are cleared (Rule P-J2).";
    }
    if (items.isEmpty) {
      return "An order must contain at least one item (Criterion 80.1).";
    }
    if (deliveryAddress == null || deliveryAddress.trim().isEmpty) {
      return "Delivery address is required to calculate shipping and dispatch (Criterion 80.1).";
    }
    if (zone != null && !zone.canBePaid) {
      return "Shipping to ${zone.name} is currently closed. Awaiting Secretariat tariff entry (Criterion 81.2).";
    }
    return null;
  }

  /// P-J1: Secretariat can cancel & refund an order at any time until it is SHIPPED;
  /// after SHIPPED only for a lost or damaged parcel.
  static bool canCancelAndRefund({
    required String currentStatus,
    bool isLostOrDamagedParcel = false,
  }) {
    final s = currentStatus.toLowerCase();
    if (s == 'delivered' || s == 'fulfilled') {
      return isLostOrDamagedParcel;
    }
    if (s == 'shipped') {
      return isLostOrDamagedParcel;
    }
    // Prior to shipped (ordered, paid, packed, pending_verification) can cancel & refund at any time
    return true;
  }
}
