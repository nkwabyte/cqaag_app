import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/moisture/moisture_pass.dart';
import 'package:cqaag_app/core/services/thermal_pos_service.dart';

void main() {
  group('Step 17 & Step 4: POS 58mm Thermal Printing (Tests 2.9, 2.10, 22.2)', () {
    late MoisturePass validPass;
    late MoisturePass failedPass;

    setUp(() {
      validPass = MoisturePass(
        id: 'p-valid',
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
        timestamp: DateTime(2026, 10, 18, 9, 30),
        paymentConfirmed: true,
        signatureHash: '5C21B7A0',
      );

      failedPass = MoisturePass(
        id: 'p-failed',
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
        timestamp: DateTime(2026, 10, 18, 10, 15),
        paymentConfirmed: true,
        signatureHash: '9A77E21D',
      );
    });

    test('Test 2.9 (Slip Text): Contains bold parties, vehicle plate, Pass title and 32 columns', () {
      final slip = ThermalPosService.generateSlipText(pass: validPass);

      // Verify essential fields
      expect(slip, contains('MOISTURE CONTROL PASS'));
      expect(slip, contains('CQAAG-P-261018-0001'));
      expect(slip, contains('AS 4521-24'));
      expect(slip, contains('TCDA/BR/2026/00142'));
      expect(slip, contains('TCDA/ER/2026/00088'));
      expect(slip, contains('9.4 %'));
      expect(slip, contains('PASSED (<= 10.0%)'));
      expect(slip, contains('VALID FOR ARRIVAL CUTTING'));
      expect(slip, contains('cqaaggh.org/p/'));
      expect(slip, contains('CQAAG-P-261018-0001'));
      expect(slip, contains('Token: 5C21B7A0'));

      // Check max column width
      for (final line in slip.split('\n')) {
        expect(line.length <= ThermalPosService.kColumns58mm + 2, isTrue,
            reason: 'Line exceeds 58mm width: "$line"');
      }
    });

    test('Test 2.9 (Failed Slip Text): Contains FAILED PASS and LOCKED reason', () {
      final slip = ThermalPosService.generateSlipText(pass: failedPass);

      expect(slip, contains('FAILED PASS - NOT VALID'));
      expect(slip, contains('CQAAG-FP-261018-0002'));
      expect(slip, contains('10.6 %'));
      expect(slip, contains('FAILED (> 10.0%)'));
      expect(slip, contains('CUT-TEST LOCKED'));
      expect(slip, contains('REASON: MOISTURE EXCEEDS LIMIT'));
    });

    test('Test 2.10: ESC/POS byte stream generated with QR code commands and init sequence', () {
      final bytes = ThermalPosService.generateEscPosBytes(pass: validPass);

      expect(bytes, isNotEmpty);
      // Starts with ESC @ (1B 40)
      expect(bytes[0], 0x1B);
      expect(bytes[1], 0x40);

      // Contains GS ( k QR code command (1D 28 6B)
      final byteList = bytes.toList();
      bool hasQrCommand = false;
      for (int i = 0; i < byteList.length - 2; i++) {
        if (byteList[i] == 0x1D && byteList[i + 1] == 0x28 && byteList[i + 2] == 0x6B) {
          hasQrCommand = true;
          break;
        }
      }
      expect(hasQrCommand, isTrue);

      // Contains pass number in byte stream
      final str = utf8.decode(bytes, allowMalformed: true);
      expect(str, contains('CQAAG-P-261018-0001'));
      expect(str, contains('TCDA/BR/2026/00142'));
    });

    test('Test 22.2 (Practice Mode): POS slip generates PRACTICE header and suppresses QR code', () {
      final practiceSlip = ThermalPosService.generateSlipText(
        pass: validPass,
        isPracticeMode: true,
      );

      expect(practiceSlip, contains('*** PRACTICE MODE ***'));
      expect(practiceSlip, contains('TRAINING ONLY - NO LEGAL VALUE'));
      expect(practiceSlip, contains('[ NO QR CODE - PRACTICE ]'));
      expect(practiceSlip, isNot(contains('https://cqaaggh.org/p/')));

      final practiceBytes = ThermalPosService.generateEscPosBytes(
        pass: validPass,
        isPracticeMode: true,
      );
      final byteList = practiceBytes.toList();
      bool hasQrCommand = false;
      for (int i = 0; i < byteList.length - 2; i++) {
        if (byteList[i] == 0x1D && byteList[i + 1] == 0x28 && byteList[i + 2] == 0x6B) {
          hasQrCommand = true;
          break;
        }
      }
      expect(hasQrCommand, isFalse);
    });
  });
}
