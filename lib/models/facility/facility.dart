import 'package:cloud_firestore/cloud_firestore.dart';

enum FacilityType {
  warehouse,
  weighbridge;

  String get prefix => this == FacilityType.warehouse ? 'CQAAG-W' : 'CQAAG-WB';
  String get displayName => this == FacilityType.warehouse ? 'Warehouse' : 'Weighbridge';
}

enum FacilityStatus {
  provisional,
  active,
  suspended,
  closed;

  String get displayName => name.toUpperCase();
}

/// Register of Warehouses & Weighbridges per Spec Sections 27–34 & Figures 15–16
class Facility {
  final String id;
  final String facilityCode; // Server-issued CQAAG-W-nnnn or CQAAG-WB-nnnn
  final FacilityType facilityType;
  final String name;
  final String operatorName;
  final String operatorTcdaLicenceNumber;
  final double latitude; // Gate GPS
  final double longitude;
  final String photoGateUrl;
  final String photoFloorUrl;
  final String photoScaleUrl;
  final FacilityStatus status;
  final String district;
  final String region;
  final DateTime createdAt;
  final String registeredByUserId;
  final String? verifiedByUserId;
  final DateTime? verifiedAt;
  final Map<String, dynamic>? lastStorageChecklist; // 5-point checklist
  final DateTime? correctiveActionDeadline;

  const Facility({
    required this.id,
    required this.facilityCode,
    required this.facilityType,
    required this.name,
    required this.operatorName,
    required this.operatorTcdaLicenceNumber,
    required this.latitude,
    required this.longitude,
    required this.photoGateUrl,
    required this.photoFloorUrl,
    required this.photoScaleUrl,
    this.status = FacilityStatus.provisional,
    required this.district,
    required this.region,
    required this.createdAt,
    required this.registeredByUserId,
    this.verifiedByUserId,
    this.verifiedAt,
    this.lastStorageChecklist,
    this.correctiveActionDeadline,
  });

  bool get isOperational => status == FacilityStatus.provisional || status == FacilityStatus.active;

  bool get isFlaggedOlderThan7Days {
    if (status != FacilityStatus.provisional) return false;
    return DateTime.now().difference(createdAt).inDays >= 7;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facility_code': facilityCode,
      'facility_type': facilityType.name,
      'name': name,
      'operator_name': operatorName,
      'operator_tcda_licence_number': operatorTcdaLicenceNumber,
      'latitude': latitude,
      'longitude': longitude,
      'photo_gate_url': photoGateUrl,
      'photo_floor_url': photoFloorUrl,
      'photo_scale_url': photoScaleUrl,
      'status': status.name,
      'district': district,
      'region': region,
      'created_at': Timestamp.fromDate(createdAt),
      'registered_by_user_id': registeredByUserId,
      'verified_by_user_id': verifiedByUserId,
      'verified_at': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'last_storage_checklist': lastStorageChecklist,
      'corrective_action_deadline': correctiveActionDeadline != null ? Timestamp.fromDate(correctiveActionDeadline!) : null,
    };
  }

  factory Facility.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return Facility(
      id: docId,
      facilityCode: map['facility_code'] as String? ?? 'CQAAG-W-0001',
      facilityType: (map['facility_type'] as String?) == 'weighbridge'
          ? FacilityType.weighbridge
          : FacilityType.warehouse,
      name: map['name'] as String? ?? '',
      operatorName: map['operator_name'] as String? ?? '',
      operatorTcdaLicenceNumber: map['operator_tcda_licence_number'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      photoGateUrl: map['photo_gate_url'] as String? ?? '',
      photoFloorUrl: map['photo_floor_url'] as String? ?? '',
      photoScaleUrl: map['photo_scale_url'] as String? ?? '',
      status: FacilityStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == (map['status'] as String? ?? '').toLowerCase(),
        orElse: () => FacilityStatus.provisional,
      ),
      district: map['district'] as String? ?? '',
      region: map['region'] as String? ?? '',
      createdAt: parseDate(map['created_at']) ?? DateTime.now(),
      registeredByUserId: map['registered_by_user_id'] as String? ?? '',
      verifiedByUserId: map['verified_by_user_id'] as String?,
      verifiedAt: parseDate(map['verified_at']),
      lastStorageChecklist: map['last_storage_checklist'] as Map<String, dynamic>?,
      correctiveActionDeadline: parseDate(map['corrective_action_deadline']),
    );
  }
}
