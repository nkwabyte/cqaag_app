import 'package:cloud_firestore/cloud_firestore.dart';

/// 6 TCDA Licence States per Spec Section 22 & Figure 12
enum TcdaLicenceState {
  unverified,
  verified,
  check,
  expiresSoon,
  expired,
  blocked;

  String get displayName {
    switch (this) {
      case TcdaLicenceState.unverified:
        return 'UNVERIFIED';
      case TcdaLicenceState.verified:
        return 'VERIFIED';
      case TcdaLicenceState.check:
        return 'CHECK';
      case TcdaLicenceState.expiresSoon:
        return 'EXPIRES SOON';
      case TcdaLicenceState.expired:
        return 'EXPIRED';
      case TcdaLicenceState.blocked:
        return 'BLOCKED';
    }
  }

  bool get isSelectable => this != TcdaLicenceState.expired && this != TcdaLicenceState.blocked;
}

/// A commercial party involved in cashew trading (Seller, Buyer, Aggregator, Shipper, Consignee)
/// Spec Section 21–26, Rules L1–L8, Figure 12–14
class TcdaParty {
  final String id;
  final String name;
  final String partyType; // seller, buyer, aggregator, shipper, consignee, farmer
  final String tcdaLicenceNumber;
  final DateTime? expiryDate;
  final String? licencePhotoUrl;
  final TcdaLicenceState state;
  final bool isForeign; // Foreign consignees: "Not applicable, outside Ghana"
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? blockedReason;
  final DateTime? blockedAt;
  final String? blockedBy;

  const TcdaParty({
    required this.id,
    required this.name,
    required this.partyType,
    required this.tcdaLicenceNumber,
    this.expiryDate,
    this.licencePhotoUrl,
    this.state = TcdaLicenceState.unverified,
    this.isForeign = false,
    required this.createdAt,
    this.updatedAt,
    this.verifiedBy,
    this.verifiedAt,
    this.blockedReason,
    this.blockedAt,
    this.blockedBy,
  });

  /// Evaluates effective state taking into account real-time expiry dates and 7/14 day rules
  TcdaLicenceState get effectiveState {
    if (isForeign) return TcdaLicenceState.verified;
    if (state == TcdaLicenceState.blocked) return TcdaLicenceState.blocked;

    final now = DateTime.now();

    // Check expiry
    if (expiryDate != null) {
      if (now.isAfter(expiryDate!)) {
        return TcdaLicenceState.expired;
      }
      final daysToExpiry = expiryDate!.difference(now).inDays;
      if (daysToExpiry <= 30) {
        return TcdaLicenceState.expiresSoon;
      }
    }

    // Check unverified aging (Spec Section 26.4 Test 6: day 15 blocked, day 8 red flag)
    if (state == TcdaLicenceState.unverified) {
      final daysSinceCreated = now.difference(createdAt).inDays;
      if (daysSinceCreated >= 14) {
        return TcdaLicenceState.blocked;
      }
    }

    return state;
  }

  bool get isBlockedOrExpired => effectiveState == TcdaLicenceState.blocked || effectiveState == TcdaLicenceState.expired;

  int get daysRemainingBeforeBlock {
    if (state != TcdaLicenceState.unverified) return 0;
    final days = 14 - DateTime.now().difference(createdAt).inDays;
    return days > 0 ? days : 0;
  }

  bool get isFlaggedRedWarning {
    if (state != TcdaLicenceState.unverified) return false;
    final days = DateTime.now().difference(createdAt).inDays;
    return days >= 7 && days < 14;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'party_type': partyType,
      'tcda_licence_number': isForeign ? 'Not applicable, outside Ghana' : tcdaLicenceNumber,
      'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'licence_photo_url': licencePhotoUrl,
      'state': state.name,
      'is_foreign': isForeign,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'blocked_reason': blockedReason,
      'blocked_at': blockedAt != null ? Timestamp.fromDate(blockedAt!) : null,
      'blocked_by': blockedBy,
    };
  }

  factory TcdaParty.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    TcdaLicenceState parseState(String? st) {
      if (st == null) return TcdaLicenceState.unverified;
      return TcdaLicenceState.values.firstWhere(
        (e) => e.name.toLowerCase() == st.toLowerCase(),
        orElse: () => TcdaLicenceState.unverified,
      );
    }

    return TcdaParty(
      id: docId,
      name: map['name'] as String? ?? '',
      partyType: map['party_type'] as String? ?? 'seller',
      tcdaLicenceNumber: map['tcda_licence_number'] as String? ?? '',
      expiryDate: parseDate(map['expiry_date']),
      licencePhotoUrl: map['licence_photo_url'] as String?,
      state: parseState(map['state'] as String?),
      isForeign: map['is_foreign'] as bool? ?? false,
      createdAt: parseDate(map['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(map['updated_at']),
      verifiedBy: map['verified_by'] as String?,
      verifiedAt: parseDate(map['verified_at']),
      blockedReason: map['blocked_reason'] as String?,
      blockedAt: parseDate(map['blocked_at']),
      blockedBy: map['blocked_by'] as String?,
    );
  }
}
