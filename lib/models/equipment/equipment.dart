import 'package:cloud_firestore/cloud_firestore.dart';

enum EquipmentType {
  moistureMeter,
  scale,
  caliper;

  String get displayName {
    switch (this) {
      case EquipmentType.moistureMeter:
        return 'Moisture Meter';
      case EquipmentType.scale:
        return 'Weighing Scale';
      case EquipmentType.caliper:
        return 'Vernier Caliper';
    }
  }
}

enum EquipmentStatus {
  calibrated,
  warningGrace,
  expired,
  unregistered;

  String get displayName => name.toUpperCase();
}

/// Register of Equipment and Meters per Spec Section 36 & Figure 17
class Equipment {
  final String id;
  final String equipmentCode; // CQAAG-EQ-nnnn
  final EquipmentType equipmentType;
  final String brandModel;
  final String serialNumber;
  final String assignedAnalystId;
  final DateTime calibrationExpiryDate;
  final String? certificateUrl;
  final EquipmentStatus status;
  final DateTime createdAt;

  const Equipment({
    required this.id,
    required this.equipmentCode,
    required this.equipmentType,
    required this.brandModel,
    required this.serialNumber,
    required this.assignedAnalystId,
    required this.calibrationExpiryDate,
    this.certificateUrl,
    this.status = EquipmentStatus.calibrated,
    required this.createdAt,
  });

  bool get isCalibrationExpired => DateTime.now().isAfter(calibrationExpiryDate);

  EquipmentStatus get effectiveStatus {
    if (isCalibrationExpired) return EquipmentStatus.expired;
    return status;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipment_code': equipmentCode,
      'equipment_type': equipmentType.name,
      'brand_model': brandModel,
      'serial_number': serialNumber,
      'assigned_analyst_id': assignedAnalystId,
      'calibration_expiry_date': Timestamp.fromDate(calibrationExpiryDate),
      'certificate_url': certificateUrl,
      'status': status.name,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory Equipment.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return Equipment(
      id: docId,
      equipmentCode: map['equipment_code'] as String? ?? 'CQAAG-EQ-0001',
      equipmentType: EquipmentType.values.firstWhere(
        (e) => e.name.toLowerCase() == (map['equipment_type'] as String? ?? '').toLowerCase(),
        orElse: () => EquipmentType.moistureMeter,
      ),
      brandModel: map['brand_model'] as String? ?? '',
      serialNumber: map['serial_number'] as String? ?? '',
      assignedAnalystId: map['assigned_analyst_id'] as String? ?? '',
      calibrationExpiryDate: parseDate(map['calibration_expiry_date']) ?? DateTime.now(),
      certificateUrl: map['certificate_url'] as String?,
      status: EquipmentStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == (map['status'] as String? ?? '').toLowerCase(),
        orElse: () => EquipmentStatus.calibrated,
      ),
      createdAt: parseDate(map['created_at']) ?? DateTime.now(),
    );
  }
}
