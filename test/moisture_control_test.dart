import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/moisture/moisture_pass.dart';
import 'package:cqaag_app/models/equipment/equipment.dart';
import 'package:cqaag_app/models/user/app_user.dart';
import 'package:cqaag_app/services/moisture/moisture_control_service.dart';

void main() {
  group('Step 4: Moisture Control Engine (Tests 4.1 - 4.12)', () {
    late MoistureControlService service;

    setUp(() {
      service = MoistureControlService();
    });

    test('Test 4.1: Lot at 9.4% evaluates as PASS with limit 10.0%', () {
      final pass = MoisturePass(
        id: 'p-1',
        passNumber: 'CQAAG-P-261018-0001',
        lotCode: 'CQAAG-L-261018-0001',
        moistureContent: 9.4,
        maxSafeLimit: 10.0,
        status: MoisturePassStatus.valid,
        sellerTcda: 'TCDA/BR/2026/00142',
        buyerTcda: 'TCDA/ER/2026/00088',
        vehiclePlate: 'AS 4521-24',
        facilityId: 'CQAAG-W-0042',
        meterSerialNumber: 'DJ-GAC2500-8812',
        analystId: 'user-01',
        analystTcda: 'TCDA/AN/2026/00012',
        timestamp: DateTime.now(),
        paymentConfirmed: true,
        signatureHash: '5C21B7A0',
      );

      expect(pass.isPass, isTrue);
      expect(pass.isFailed, isFalse);
      expect(pass.status, MoisturePassStatus.valid);
      expect(pass.verificationUrl, contains('https://cqaaggh.org/p/CQAAG-P-261018-0001?s=5C21B7A0'));
    });

    test('Test 4.2: Lot at 10.6% evaluates as FAILED PASS (> 10.0%)', () {
      final failedPass = MoisturePass(
        id: 'p-2',
        passNumber: 'CQAAG-FP-261018-0002',
        lotCode: 'CQAAG-L-261018-0002',
        moistureContent: 10.6,
        maxSafeLimit: 10.0,
        status: MoisturePassStatus.failed,
        sellerTcda: 'TCDA/AR/2026/00049',
        buyerTcda: 'TCDA/ER/2026/00088',
        vehiclePlate: 'BA 1289-23',
        facilityId: 'CQAAG-W-0042',
        meterSerialNumber: 'DJ-GAC2500-8812',
        analystId: 'user-01',
        analystTcda: 'TCDA/AN/2026/00012',
        timestamp: DateTime.now(),
        paymentConfirmed: true,
        signatureHash: '9A77E21D',
      );

      expect(failedPass.isPass, isFalse);
      expect(failedPass.isFailed, isTrue);
      expect(failedPass.status, MoisturePassStatus.failed);
      expect(failedPass.passNumber.startsWith('CQAAG-FP'), isTrue);
    });

    test('Test 4.7: Manual typed reading requires second photo and reason', () {
      // Missing photo 2
      expect(
        () => service.validateMoistureInput(
          vehiclePlate: 'AS 1234-24',
          isManualReading: true,
          meterPhotoUrl: 'photo1.jpg',
          meterPhoto2Url: null,
          manualOverrideReason: 'Glare on digital screen',
          moistureContent: 9.2,
        ),
        throwsA(isA<MoistureValidationException>().having(
          (e) => e.code,
          'code',
          'SECOND_PHOTO_REQUIRED',
        )),
      );

      // Missing reason
      expect(
        () => service.validateMoistureInput(
          vehiclePlate: 'AS 1234-24',
          isManualReading: true,
          meterPhotoUrl: 'photo1.jpg',
          meterPhoto2Url: 'photo2.jpg',
          manualOverrideReason: '',
          moistureContent: 9.2,
        ),
        throwsA(isA<MoistureValidationException>().having(
          (e) => e.code,
          'code',
          'MANUAL_REASON_REQUIRED',
        )),
      );

      // Valid manual input passes validation
      expect(
        () => service.validateMoistureInput(
          vehiclePlate: 'AS 1234-24',
          isManualReading: true,
          meterPhotoUrl: 'photo1.jpg',
          meterPhoto2Url: 'photo2.jpg',
          manualOverrideReason: 'Sun glare prevented OCR capture',
          moistureContent: 9.2,
        ),
        returnsNormally,
      );
    });

    test('Test 4.8: Meter with expired calibration or hibernated analyst cannot start check', () {
      final hibernatedAnalyst = AppUser(
        id: 'u-hibernated',
        firstName: 'Suspended',
        lastName: 'Analyst',
        email: 'hibernated@cqaaggh.org',
        membershipStatus: MembershipStatus.hibernated,
      );

      final activeAnalyst = AppUser(
        id: 'u-active',
        firstName: 'Active',
        lastName: 'Analyst',
        email: 'analyst@cqaaggh.org',
        membershipStatus: MembershipStatus.active,
      );

      final expiredMeter = Equipment(
        id: 'eq-exp',
        equipmentCode: 'CQAAG-EQ-0001',
        brandModel: 'Dickey-John GAC2500',
        serialNumber: 'DJ-9912',
        equipmentType: EquipmentType.moistureMeter,
        assignedAnalystId: 'u-active',
        calibrationExpiryDate: DateTime.now().subtract(const Duration(days: 10)),
        status: EquipmentStatus.calibrated,
        createdAt: DateTime.now().subtract(const Duration(days: 400)),
      );

      // 1. Hibernated analyst rejected
      expect(
        () => service.validateAnalystAndMeter(
          analyst: hibernatedAnalyst,
          equipment: null,
          isCalibrationEnforced: false,
        ),
        throwsA(isA<MoistureValidationException>().having(
          (e) => e.code,
          'code',
          'ANALYST_HIBERNATED',
        )),
      );

      // 2. Expired meter rejected when calibration is enforced
      expect(
        () => service.validateAnalystAndMeter(
          analyst: activeAnalyst,
          equipment: expiredMeter,
          isCalibrationEnforced: true,
        ),
        throwsA(isA<MoistureValidationException>().having(
          (e) => e.code,
          'code',
          'CALIBRATION_EXPIRED',
        )),
      );

      // 3. Expired meter allowed when calibration enforcement switch is OFF (default)
      expect(
        () => service.validateAnalystAndMeter(
          analyst: activeAnalyst,
          equipment: expiredMeter,
          isCalibrationEnforced: false,
        ),
        returnsNormally,
      );
    });

    test('Test 4.9: Stage thresholds: Dispatch 10.4% fails & 9.7% passes; Export 8.6% fails & 7.9% passes', () {
      final dispatchLimit = MoistureControlService.getMaxSafeLimit(MoistureInspectionStage.dispatch);
      final exportLimit = MoistureControlService.getMaxSafeLimit(MoistureInspectionStage.exportZone);

      expect(dispatchLimit, 10.0);
      expect(exportLimit, 8.0);

      // Dispatch: 10.4% fails, 9.7% passes
      expect(10.4 <= dispatchLimit, isFalse);
      expect(9.7 <= dispatchLimit, isTrue);

      // Export Zone: 8.6% fails, 7.9% passes
      expect(8.6 <= exportLimit, isFalse);
      expect(7.9 <= exportLimit, isTrue);
    });

    test('Test 4.11: Cryptographic signature hash is tamper-evident', () {
      final sig1 = MoistureControlService.computeSignatureHash(
        'CQAAG-P-261018-0001',
        'CQAAG-L-261018-0001',
        9.4,
      );
      final sigAlteredMoisture = MoistureControlService.computeSignatureHash(
        'CQAAG-P-261018-0001',
        'CQAAG-L-261018-0001',
        9.5,
      );
      final sigAlteredLot = MoistureControlService.computeSignatureHash(
        'CQAAG-P-261018-0001',
        'CQAAG-L-261018-0002',
        9.4,
      );

      expect(sig1.length, 8);
      expect(sig1, isNot(equals(sigAlteredMoisture)));
      expect(sig1, isNot(equals(sigAlteredLot)));
    });

    test('Test 4.12: Check without vehicle registration plate cannot be saved', () {
      expect(
        () => service.validateMoistureInput(
          vehiclePlate: '',
          isManualReading: false,
          meterPhotoUrl: 'photo.jpg',
          meterPhoto2Url: null,
          manualOverrideReason: null,
          moistureContent: 9.4,
        ),
        throwsA(isA<MoistureValidationException>().having(
          (e) => e.code,
          'code',
          'VEHICLE_PLATE_REQUIRED',
        )),
      );
    });
  });
}
