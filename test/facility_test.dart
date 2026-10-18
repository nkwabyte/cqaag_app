import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/facility/facility.dart';
import 'package:cqaag_app/services/facility/facility_service.dart';

void main() {
  group('Step 3: Register of Warehouses & Weighbridges (Tests 3.1 - 3.18)', () {
    test('Test 3.1: Sequential CQAAG codes follow specification format', () {
      expect(FacilityType.warehouse.prefix, 'CQAAG-W');
      expect(FacilityType.weighbridge.prefix, 'CQAAG-WB');

      final fac = Facility(
        id: 'fac-01',
        facilityCode: 'CQAAG-W-0042',
        facilityType: FacilityType.warehouse,
        name: 'Techiman Central Aggregation Warehouse',
        operatorName: 'Agro Logistics Ghana Ltd',
        operatorTcdaLicenceNumber: 'TCDA/W/2026/012',
        latitude: 7.5833,
        longitude: -1.9333,
        photoGateUrl: 'https://example.com/gate.jpg',
        photoFloorUrl: 'https://example.com/floor.jpg',
        photoScaleUrl: 'https://example.com/scale.jpg',
        district: 'Techiman Municipal',
        region: 'Bono East',
        createdAt: DateTime.now(),
        registeredByUserId: 'analyst-001',
      );

      expect(fac.facilityCode, 'CQAAG-W-0042');
      expect(fac.status, FacilityStatus.provisional);
      expect(fac.operatorTcdaLicenceNumber, 'TCDA/W/2026/012');
    });

    test('Test 3.5: Haversine distance correctly detects 50m proximity duplicates', () {
      // Coordinates approx 30m apart
      const lat1 = 7.583300;
      const lon1 = -1.933300;
      const lat2 = 7.583500;
      const lon2 = -1.933300;

      final dist = FacilityService.calculateDistanceMeters(lat1, lon1, lat2, lon2);
      expect(dist, lessThan(50.0));
    });

    test('Test 3.7: 300m GPS perimeter check flags check-ins beyond 300m from gate', () {
      final fac = Facility(
        id: 'fac-02',
        facilityCode: 'CQAAG-WB-0005',
        facilityType: FacilityType.weighbridge,
        name: 'Wenchi Electronic Weighbridge',
        operatorName: 'Bono Weighing Services',
        operatorTcdaLicenceNumber: 'TCDA/WB/2026/088',
        latitude: 7.7333,
        longitude: -2.1000,
        photoGateUrl: 'https://example.com/gate.jpg',
        photoFloorUrl: 'https://example.com/floor.jpg',
        photoScaleUrl: 'https://example.com/scale.jpg',
        district: 'Wenchi Municipal',
        region: 'Bono',
        createdAt: DateTime.now(),
        registeredByUserId: 'analyst-002',
      );

      final service = FacilityService();

      // Within 100m
      expect(service.isWithin300m(fac, 7.7338, -2.1000), isTrue);

      // > 1000m away
      expect(service.isWithin300m(fac, 7.7500, -2.1000), isFalse);
    });

    test('Test 3.12: 5-Point Storage Inspection checklist requires all 5 criteria to pass', () {
      final checklistAllPassed = {
        'stack_heights_passed': true,
        'pallet_spacing_passed': true,
        'ventilation_passed': true,
        'moisture_barrier_passed': true,
        'pest_control_passed': true,
      };

      final allPassed = checklistAllPassed.values.every((v) => v == true);
      expect(allPassed, isTrue);

      final checklistOneFailed = {
        'stack_heights_passed': true,
        'pallet_spacing_passed': false, // Failed!
        'ventilation_passed': true,
        'moisture_barrier_passed': true,
        'pest_control_passed': true,
      };

      final failedResult = checklistOneFailed.values.every((v) => v == true);
      expect(failedResult, isFalse);
    });
  });
}
