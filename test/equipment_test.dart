import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/equipment/equipment.dart';
import 'package:cqaag_app/services/equipment/equipment_service.dart';

void main() {
  group('Step 20: Register of Equipment & Meters Calibration (Tests 20.1 - 20.5)', () {
    test('Test 20.1: Equipment model initializes with calibrated status', () {
      final validMeter = Equipment(
        id: 'eq-01',
        equipmentCode: 'CQAAG-EQ-0001',
        equipmentType: EquipmentType.moistureMeter,
        brandModel: 'Dickey-John mini GAC plus',
        serialNumber: 'DJ-987654',
        assignedAnalystId: 'analyst-001',
        calibrationExpiryDate: DateTime.now().add(const Duration(days: 90)),
        createdAt: DateTime.now(),
      );

      expect(validMeter.isCalibrationExpired, isFalse);
      expect(validMeter.effectiveStatus, EquipmentStatus.calibrated);
    });

    test('Test 20.2: Expired equipment evaluates to EquipmentStatus.expired', () {
      final expiringMeter = Equipment(
        id: 'eq-02',
        equipmentCode: 'CQAAG-EQ-0002',
        equipmentType: EquipmentType.moistureMeter,
        brandModel: 'Draminski TwistGrain',
        serialNumber: 'DR-112233',
        assignedAnalystId: 'analyst-001',
        calibrationExpiryDate: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      );

      expect(expiringMeter.isCalibrationExpired, isTrue);
      expect(expiringMeter.effectiveStatus, EquipmentStatus.expired);
    });

    test('Test 20.3: Switching equipment check on requires two distinct approvers', () {
      final service = EquipmentService();
      expect(
        () => service.switchEquipmentCheckOn(
          firstApproverId: 'officer-01',
          secondApproverId: 'officer-01', // Identical
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
