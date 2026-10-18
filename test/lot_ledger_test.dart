import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/lot/lot_ledger.dart';
import 'package:cqaag_app/services/lot/lot_ledger_service.dart';

void main() {
  group('Phase 4: Step 7 - Lot Ledger & Lifecycle Rules', () {
    late LotLedgerService service;

    setUp(() {
      service = LotLedgerService();
    });

    test('Test 7.1: Weighbridge tare + net must equal gross, photo and bag count mandatory', () {
      // 1. Missing photo throws
      expect(
        () => service.validateWeighbridgeSlip(
          grossWeightKg: 42000.0,
          tareWeightKg: 14488.0,
          netWeightKg: 27512.0,
          bagCount: 342,
          slipNumber: 'WB-261012-001',
          slipPhotoUrl: null,
          existingSlipNumbers: [],
        ),
        throwsA(isA<LotValidationException>().having((e) => e.code, 'code', 'PHOTO_REQUIRED')),
      );

      // 2. Duplicate slip number throws
      expect(
        () => service.validateWeighbridgeSlip(
          grossWeightKg: 42000.0,
          tareWeightKg: 14488.0,
          netWeightKg: 27512.0,
          bagCount: 342,
          slipNumber: 'WB-261012-001',
          slipPhotoUrl: 'https://res.cloudinary.com/cqaag/image/upload/slip.jpg',
          existingSlipNumbers: ['WB-261012-001'],
        ),
        throwsA(isA<LotValidationException>().having((e) => e.code, 'code', 'DUPLICATE_SLIP')),
      );

      // 3. Tare + net != gross throws
      expect(
        () => service.validateWeighbridgeSlip(
          grossWeightKg: 45000.0, // Incorrect gross
          tareWeightKg: 14488.0,
          netWeightKg: 27512.0,
          bagCount: 342,
          slipNumber: 'WB-261012-002',
          slipPhotoUrl: 'https://res.cloudinary.com/cqaag/image/upload/slip.jpg',
          existingSlipNumbers: [],
        ),
        throwsA(isA<LotValidationException>().having((e) => e.code, 'code', 'WEIGHT_MISMATCH')),
      );

      // 4. Valid weighbridge slip passes
      expect(
        () => service.validateWeighbridgeSlip(
          grossWeightKg: 42000.0,
          tareWeightKg: 14488.0,
          netWeightKg: 27512.0,
          bagCount: 342,
          slipNumber: 'WB-261012-003',
          slipPhotoUrl: 'https://res.cloudinary.com/cqaag/image/upload/slip.jpg',
          existingSlipNumbers: ['WB-261012-001'],
        ),
        returnsNormally,
      );
    });

    test('Test 7.2: Purchase slip Day 3 rule blocks certificate issuance', () {
      final now = DateTime.now();

      // Lot created 74 hours ago without purchase slip
      final overdueLot = LotRecord(
        lotCode: 'CQAAG-L-261012-0007',
        facilityId: 'CQAAG-W-0001',
        sellerTcda: 'TCDA/CS/2026/001',
        buyerTcda: 'TCDA/EX/2026/010',
        vehiclePlate: 'AS 2301-24',
        createdAt: now.subtract(const Duration(hours: 74)),
        purchaseSlipPhotoUrl: null,
      );

      expect(overdueLot.isPurchaseSlipOverdue48h, isTrue);
      expect(overdueLot.isPurchaseSlipBlockedDay3, isTrue);
      expect(
        () => service.canIssueCertificates(overdueLot),
        throwsA(isA<LotValidationException>().having(
          (e) => e.code,
          'code',
          'PURCHASE_SLIP_BLOCK_DAY3',
        )),
      );

      // Uploading purchase slip unblocks issuance
      final unblockedLot = LotRecord(
        lotCode: 'CQAAG-L-261012-0007',
        facilityId: 'CQAAG-W-0001',
        sellerTcda: 'TCDA/CS/2026/001',
        buyerTcda: 'TCDA/EX/2026/010',
        vehiclePlate: 'AS 2301-24',
        createdAt: now.subtract(const Duration(hours: 74)),
        purchaseSlipPhotoUrl: 'https://res.cloudinary.com/cqaag/image/upload/purchase_slip.jpg',
        purchaseSlipUploadedAt: now,
      );

      expect(unblockedLot.isPurchaseSlipBlockedDay3, isFalse);
      expect(service.canIssueCertificates(unblockedLot), isTrue);
    });

    test('Test 7.5: Drying record calculation and 24-hour parking initiation', () {
      // Lot 0007: Net accepted 12,480 kg, 9.5% to 9.0%, 2 bags pickings (65kg/bag = 130kg)
      // Loss = 12480 * (9.5 - 9.0) / (100 - 9.0) = 12480 * 0.5 / 91.0 = 68.571 -> 68.6 kg
      // Pickings = 2 * 65 = 130.0 kg
      // Balance = 12480 - 68.57 - 130 = 12,281.43 -> 12,281.4 kg
      final dryingResult = service.calculateDryingRecord(
        netWeightKg: 12480.0,
        initialMoisture: 9.5,
        driedMoisture: 9.0,
        pickingsBags: 2,
        averageBagWeightKg: 65.0,
      );

      expect(dryingResult['moistureLossKg'], equals(68.6));
      expect(dryingResult['pickingsKg'], equals(130.0));
      expect(dryingResult['estimatedBalanceKg'], equals(12281.4));
      expect(dryingResult['parkingDurationHours'], equals(24));
    });

    test('Test 7.15 & 3.9: Merge refused for lots held at different facilities', () {
      final now = DateTime.now();
      final lotA = LotRecord(
        lotCode: 'CQAAG-L-261012-0007',
        facilityId: 'CQAAG-W-0001', // Facility 1
        sellerTcda: 'TCDA/CS/2026/001',
        buyerTcda: 'TCDA/EX/2026/010',
        vehiclePlate: 'AS 2301-24',
        createdAt: now,
      );

      final lotB = LotRecord(
        lotCode: 'CQAAG-L-261012-0008',
        facilityId: 'CQAAG-W-0002', // Facility 2
        sellerTcda: 'TCDA/CS/2026/002',
        buyerTcda: 'TCDA/EX/2026/010',
        vehiclePlate: 'NR 5511-23',
        createdAt: now,
      );

      expect(
        () => service.validateLotMerge(
          lotA: lotA,
          lotB: lotB,
          mergeReason: 'Fill a truck',
        ),
        throwsA(isA<LotValidationException>().having(
          (e) => e.code,
          'code',
          'DIFFERENT_FACILITY_MERGE_FORBIDDEN',
        )),
      );
    });

    test('Test 7.17: Quality drift check flags warning at >2.0 lb and failure at >4.0 lb', () {
      // Normal drift (diff 1.55 lb)
      final normal = service.checkQualityDrift(arrivalKor: 48.75, afterDryKor: 48.35, exportKor: 49.90);
      expect(normal['isWarning'], isFalse);
      expect(normal['isFailure'], isFalse);
      expect(normal['status'], equals('COMPLIANT'));

      // Warning (> 2.0 lb)
      final warning = service.checkQualityDrift(arrivalKor: 48.75, afterDryKor: 48.00, exportKor: 50.50);
      expect(warning['isWarning'], isTrue);
      expect(warning['isFailure'], isFalse);
      expect(warning['status'], equals('WARNING'));

      // Failure (> 4.0 lb)
      final failure = service.checkQualityDrift(arrivalKor: 48.75, afterDryKor: 46.00, exportKor: 50.50);
      expect(failure['isFailure'], isTrue);
      expect(failure['status'], equals('FAILURE'));
    });

    test('Test 7.19: Backward trace calculates component lot shares', () {
      final now = DateTime.now();
      final lot1 = LotRecord(
        lotCode: 'CQAAG-L-261012-0007',
        facilityId: 'CQAAG-W-0001',
        sellerTcda: 'TCDA/CS/2026/001',
        buyerTcda: 'TCDA/EX/2026/010',
        vehiclePlate: 'AS 2301-24',
        netWeightKg: 12014.0,
        createdAt: now,
      );
      final lot2 = LotRecord(
        lotCode: 'CQAAG-L-261012-0008',
        facilityId: 'CQAAG-W-0001',
        sellerTcda: 'TCDA/CS/2026/002',
        buyerTcda: 'TCDA/EX/2026/010',
        vehiclePlate: 'AS 2301-24',
        netWeightKg: 17339.0,
        createdAt: now,
      );
      final lot3 = LotRecord(
        lotCode: 'CQAAG-L-261012-0009',
        facilityId: 'CQAAG-W-0001',
        sellerTcda: 'TCDA/CS/2026/003',
        buyerTcda: 'TCDA/EX/2026/010',
        vehiclePlate: 'AS 2301-24',
        netWeightKg: 20537.0,
        createdAt: now,
      );

      final totalExportKg = 49890.0;
      final trace = service.generateBackwardTrace([lot1, lot2, lot3], totalExportKg);

      expect(trace.length, equals(3));
      expect(trace[0]['sharePercent'], equals(24.1));
      expect(trace[1]['sharePercent'], equals(34.8));
      expect(trace[2]['sharePercent'], equals(41.2));
    });
  });
}
