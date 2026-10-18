import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/lot/lot_ledger.dart';

class LotValidationException implements Exception {
  final String message;
  final String? code;
  LotValidationException(this.message, {this.code});
  @override
  String toString() => message;
}

class LotLedgerService {
  final FirebaseFirestore? _firestore;

  LotLedgerService({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get lotsRef => firestore.collection('lots');
  CollectionReference<Map<String, dynamic>> get auditRef => firestore.collection('audit_events');

  /// 1. Weighbridge calculation & validation (Test 7.1)
  void validateWeighbridgeSlip({
    required double grossWeightKg,
    required double tareWeightKg,
    required double netWeightKg,
    required int bagCount,
    required String slipNumber,
    required String? slipPhotoUrl,
    required List<String> existingSlipNumbers,
  }) {
    if (slipPhotoUrl == null || slipPhotoUrl.trim().isEmpty) {
      throw LotValidationException(
        'Weighbridge slip photograph is mandatory.',
        code: 'PHOTO_REQUIRED',
      );
    }

    if (bagCount <= 0) {
      throw LotValidationException(
        'Number of bags must be greater than zero.',
        code: 'BAG_COUNT_REQUIRED',
      );
    }

    if (slipNumber.trim().isEmpty) {
      throw LotValidationException(
        'Weighbridge slip number is mandatory.',
        code: 'SLIP_NUMBER_REQUIRED',
      );
    }

    if (existingSlipNumbers.contains(slipNumber.trim())) {
      throw LotValidationException(
        'Weighbridge slip number "$slipNumber" has already been used.',
        code: 'DUPLICATE_SLIP',
      );
    }

    // Tare + Net must equal Gross (Test 7.1)
    final calculatedGross = tareWeightKg + netWeightKg;
    if ((calculatedGross - grossWeightKg).abs() > 0.01) {
      throw LotValidationException(
        'Tare ($tareWeightKg kg) plus Net ($netWeightKg kg) does not equal Gross ($grossWeightKg kg).',
        code: 'WEIGHT_MISMATCH',
      );
    }
  }

  /// 2. Purchase slip upload status and blocking rule (Test 7.2)
  bool canIssueCertificates(LotRecord lot) {
    if (lot.isPurchaseSlipBlockedDay3) {
      throw LotValidationException(
        'Dispatch, Packing and Export certificates are BLOCKED for Lot ${lot.lotCode}. Purchase slip was not uploaded within 72 hours (Day 3 rule). Upload purchase slip to lift block.',
        code: 'PURCHASE_SLIP_BLOCK_DAY3',
      );
    }
    return true;
  }

  /// 3. Drying calculation: moisture loss, pickings, balance & 24h parking (Test 7.5)
  Map<String, dynamic> calculateDryingRecord({
    required double netWeightKg,
    required double initialMoisture,
    required double driedMoisture,
    required int pickingsBags,
    double averageBagWeightKg = 65.0, // standard bag tare/net weight
  }) {
    if (driedMoisture >= initialMoisture) {
      throw LotValidationException(
        'Dried moisture ($driedMoisture%) must be less than initial moisture ($initialMoisture%).',
        code: 'INVALID_MOISTURE_RANGE',
      );
    }

    // Standard CQAAG statutory drying formula:
    // Loss = InitialNet * (M1 - M2) / (100 - M2)
    final moistureLossKg = netWeightKg * ((initialMoisture - driedMoisture) / (100.0 - driedMoisture));
    final pickingsKg = pickingsBags * averageBagWeightKg;
    final balanceKg = netWeightKg - moistureLossKg - pickingsKg;

    return {
      'moistureLossKg': double.parse(moistureLossKg.toStringAsFixed(1)),
      'pickingsKg': double.parse(pickingsKg.toStringAsFixed(1)),
      'estimatedBalanceKg': double.parse(balanceKg.toStringAsFixed(1)),
      'parkingDurationHours': 24, // 24-hour parking rule (Test 7.5)
    };
  }

  /// 4. Merge validation (Test 3.9 & 7.15)
  void validateLotMerge({
    required LotRecord lotA,
    required LotRecord lotB,
    required String? mergeReason,
  }) {
    // Two lots held at different registered facilities cannot be merged (Test 3.9)
    if (lotA.facilityId != lotB.facilityId) {
      throw LotValidationException(
        'Lots held at different registered facilities (${lotA.facilityId} vs ${lotB.facilityId}) cannot be merged.',
        code: 'DIFFERENT_FACILITY_MERGE_FORBIDDEN',
      );
    }

    if (mergeReason == null || mergeReason.trim().isEmpty) {
      throw LotValidationException(
        'A valid merge reason is mandatory.',
        code: 'MERGE_REASON_REQUIRED',
      );
    }
  }

  /// 5. Quality evolution along chain and drift check (Test 7.17)
  Map<String, dynamic> checkQualityDrift({
    required double arrivalKor,
    required double afterDryKor,
    required double exportKor,
  }) {
    final diff = (exportKor - afterDryKor).abs();
    bool isWarning = diff > 2.0;
    bool isFailure = diff > 4.0;

    return {
      'arrivalKor': arrivalKor,
      'afterDryKor': afterDryKor,
      'exportKor': exportKor,
      'korDifference': double.parse(diff.toStringAsFixed(2)),
      'isWarning': isWarning,
      'isFailure': isFailure,
      'status': isFailure ? 'FAILURE' : (isWarning ? 'WARNING' : 'COMPLIANT'),
    };
  }

  /// 6. Backward trace calculations (Test 7.19)
  List<Map<String, dynamic>> generateBackwardTrace(List<LotRecord> componentLots, double totalExportWeightKg) {
    return componentLots.map((lot) {
      final share = (lot.netWeightKg / totalExportWeightKg) * 100.0;
      return {
        'lotCode': lot.lotCode,
        'weightKg': lot.netWeightKg,
        'sharePercent': double.parse(share.toStringAsFixed(1)),
        'sellerTcda': lot.sellerTcda,
        'facilityId': lot.facilityId,
      };
    }).toList();
  }
}
