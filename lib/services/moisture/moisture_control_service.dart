import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/moisture/moisture_pass.dart';
import 'package:cqaag_app/models/equipment/equipment.dart';
import 'package:cqaag_app/models/user/app_user.dart';

class MoistureValidationException implements Exception {
  final String message;
  final String? code;
  MoistureValidationException(this.message, {this.code});
  @override
  String toString() => message;
}

class MoistureControlService {
  final FirebaseFirestore? _firestore;

  MoistureControlService({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _passesRef =>
      firestore.collection('moisture_passes');

  CollectionReference<Map<String, dynamic>> get _auditRef =>
      firestore.collection('audit_events');

  /// Computes a tamper-proof 8-character cryptographic signature hash
  static String computeSignatureHash(String passNumber, String lotCode, double moisture) {
    const salt = 'CQAAG_ACT772_MOISTURE_GATE_2026';
    final payload = '$passNumber|$lotCode|${moisture.toStringAsFixed(1)}|$salt';
    final bytes = utf8.encode(payload);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 8).toUpperCase();
  }

  /// Calculates max safe limit depending on inspection stage (Spec Section 43 / Test 4.9)
  static double getMaxSafeLimit(MoistureInspectionStage stage) {
    return switch (stage) {
      MoistureInspectionStage.upcountryArrival => 10.0,
      MoistureInspectionStage.dispatch => 10.0,
      MoistureInspectionStage.exportZone => 8.0,
    };
  }

  /// Format Pass Number according to CQAAG Rules
  static String formatPassNumber({
    required DateTime date,
    required int sequence,
    required bool isPassed,
  }) {
    final yy = (date.year % 100).toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final seq = sequence.toString().padLeft(4, '0');
    final prefix = isPassed ? 'CQAAG-P' : 'CQAAG-FP';
    return '$prefix-$yy$mm$dd-$seq';
  }

  /// Pre-check: Validates analyst status and equipment calibration before check can start (Test 4.8)
  void validateAnalystAndMeter({
    required AppUser analyst,
    required Equipment? equipment,
    required bool isCalibrationEnforced,
  }) {
    if (analyst.membershipStatus == MembershipStatus.hibernated) {
      throw MoistureValidationException(
        'Analyst is currently in HIBERNATION status. Suspended analysts cannot initiate quality inspections or sign passes.',
        code: 'ANALYST_HIBERNATED',
      );
    }

    if (equipment != null && isCalibrationEnforced) {
      if (equipment.isCalibrationExpired) {
        throw MoistureValidationException(
          'Moisture meter ${equipment.equipmentCode} (${equipment.brandModel}) has EXPIRED calibration. Metrology rules require active calibration.',
          code: 'CALIBRATION_EXPIRED',
        );
      }
      if (equipment.status == EquipmentStatus.expired || equipment.status == EquipmentStatus.unregistered) {
        throw MoistureValidationException(
          'Moisture meter ${equipment.equipmentCode} is ${equipment.status.displayName}. It cannot be used for inspection.',
          code: 'EQUIPMENT_UNAVAILABLE',
        );
      }
    }
  }

  /// Validates input data integrity before submission
  void validateMoistureInput({
    required String vehiclePlate,
    required bool isManualReading,
    required String? meterPhotoUrl,
    required String? meterPhoto2Url,
    required String? manualOverrideReason,
    required double moistureContent,
  }) {
    // Test 4.12: A check without a vehicle number cannot be saved, for any vehicle type
    if (vehiclePlate.trim().isEmpty) {
      throw MoistureValidationException(
        'Vehicle registration plate number is mandatory for all checks and cannot be empty.',
        code: 'VEHICLE_PLATE_REQUIRED',
      );
    }

    // Test 4.7: A typed reading without a second photo and a reason is refused
    if (isManualReading) {
      if (meterPhoto2Url == null || meterPhoto2Url.trim().isEmpty) {
        throw MoistureValidationException(
          'A typed/manual moisture reading requires a secondary verification photograph of the meter display.',
          code: 'SECOND_PHOTO_REQUIRED',
        );
      }
      if (manualOverrideReason == null || manualOverrideReason.trim().isEmpty) {
        throw MoistureValidationException(
          'A typed/manual moisture reading requires an explicit justification reason.',
          code: 'MANUAL_REASON_REQUIRED',
        );
      }
    } else {
      if (meterPhotoUrl == null || meterPhotoUrl.trim().isEmpty) {
        throw MoistureValidationException(
          'Primary photograph of the moisture meter display is required for AI verification.',
          code: 'PRIMARY_PHOTO_REQUIRED',
        );
      }
    }

    if (moistureContent <= 0.0 || moistureContent > 30.0) {
      throw MoistureValidationException(
        'Invalid moisture reading: ${moistureContent.toStringAsFixed(1)}%. Must be between 1.0% and 30.0%.',
        code: 'INVALID_MOISTURE_VALUE',
      );
    }
  }

  /// Creates a draft moisture check awaiting payment (Test 4.10, 4.12)
  Future<MoisturePass> createMoistureCheck({
    required String lotCode,
    required double moistureContent,
    required MoistureInspectionStage stage,
    required String sellerTcda,
    required String buyerTcda,
    required String vehiclePlate,
    required String facilityId,
    required String meterSerialNumber,
    required String analystId,
    required String analystTcda,
    String? meterPhotoUrl,
    String? meterPhoto2Url,
    String? manualOverrideReason,
    bool isManualReading = false,
    bool isLateSync = false,
  }) async {
    validateMoistureInput(
      vehiclePlate: vehiclePlate,
      isManualReading: isManualReading,
      meterPhotoUrl: meterPhotoUrl,
      meterPhoto2Url: meterPhoto2Url,
      manualOverrideReason: manualOverrideReason,
      moistureContent: moistureContent,
    );

    final maxLimit = getMaxSafeLimit(stage);
    final now = DateTime.now();
    final tempId = _passesRef.doc().id;

    // Temporary provisional pass awaiting payment (Test 4.1: before payment no official Pass number exists)
    final pass = MoisturePass(
      id: tempId,
      passNumber: 'PENDING-$tempId',
      lotCode: lotCode,
      moistureContent: moistureContent,
      maxSafeLimit: maxLimit,
      status: MoisturePassStatus.awaitingPayment,
      stage: stage,
      sellerTcda: sellerTcda,
      buyerTcda: buyerTcda,
      vehiclePlate: vehiclePlate.trim().toUpperCase(),
      facilityId: facilityId,
      meterSerialNumber: meterSerialNumber,
      meterPhotoUrl: meterPhotoUrl,
      meterPhoto2Url: meterPhoto2Url,
      manualOverrideReason: manualOverrideReason,
      isManualReading: isManualReading,
      analystId: analystId,
      analystTcda: analystTcda,
      timestamp: now,
      paymentConfirmed: false,
      signatureHash: '',
      isLateSync: isLateSync,
    );

    await _passesRef.doc(tempId).set(pass.toMap());
    return pass;
  }

  /// Confirms payment and issues official Pass or Failed Pass (Test 4.1, 4.2)
  Future<MoisturePass> confirmPaymentAndIssuePass({
    required String passId,
    required String paymentReference,
    int? customSequence,
  }) async {
    final doc = await _passesRef.doc(passId).get();
    if (!doc.exists) {
      throw MoistureValidationException('Moisture check record not found: $passId');
    }

    final current = MoisturePass.fromMap(doc.data()!, doc.id);
    if (current.paymentConfirmed && current.status != MoisturePassStatus.awaitingPayment) {
      return current; // Idempotent return
    }

    final isPassed = current.moistureContent <= current.maxSafeLimit;
    final now = DateTime.now();
    final seq = customSequence ?? (await _getNextPassSequence(now, isPassed));
    final passNumber = formatPassNumber(date: now, sequence: seq, isPassed: isPassed);
    final signatureHash = computeSignatureHash(passNumber, current.lotCode, current.moistureContent);
    final newStatus = isPassed ? MoisturePassStatus.valid : MoisturePassStatus.failed;

    final issued = current.copyWith(
      passNumber: passNumber,
      status: newStatus,
      paymentConfirmed: true,
      paymentReference: paymentReference,
      signatureHash: signatureHash,
      timestamp: now,
    );

    await _passesRef.doc(passId).set(issued.toMap(), SetOptions(merge: true));

    // Audit log
    await _auditRef.add({
      'action': isPassed ? 'ISSUE_MOISTURE_PASS' : 'ISSUE_FAILED_PASS',
      'passNumber': passNumber,
      'lotCode': current.lotCode,
      'moisture': current.moistureContent,
      'limit': current.maxSafeLimit,
      'vehiclePlate': current.vehiclePlate,
      'analystId': current.analystId,
      'paymentReference': paymentReference,
      'timestamp': now.toIso8601String(),
    });

    return issued;
  }

  /// Strict Gate for Arrival Cutting (Test 4.3, 4.4, 4.5, 4.6)
  /// Evaluates whether a Pass can unlock Arrival Cutting for a given lot
  Future<MoisturePass> validatePassForArrivalCutting({
    required String passNumber,
    required String currentLotCode,
  }) async {
    if (passNumber.trim().isEmpty) {
      throw MoistureValidationException(
        'Arrival Cutting cannot start without a Moisture Control Pass. Cut-test fields remain locked.',
        code: 'PASS_REQUIRED',
      );
    }

    final query = await _passesRef.where('passNumber', isEqualTo: passNumber.trim()).limit(1).get();
    if (query.docs.isEmpty) {
      throw MoistureValidationException(
        'Moisture Pass "$passNumber" not recognised. Valid official pass required.',
        code: 'PASS_NOT_FOUND',
      );
    }

    final pass = MoisturePass.fromMap(query.docs.first.data(), query.docs.first.id);

    // Test 4.4: Arrival Cutting with a Failed Pass is refused, even if typed by hand
    if (pass.status == MoisturePassStatus.failed || pass.passNumber.startsWith('CQAAG-FP')) {
      throw MoistureValidationException(
        'Refused: Moisture Pass "$passNumber" is a FAILED PASS (${pass.moistureContent}% > max safe limit ${pass.maxSafeLimit}%). Arrival cutting is strictly prohibited.',
        code: 'FAILED_PASS_REFUSED',
      );
    }

    // Test 4.5: Cancelled pass is refused
    if (pass.status == MoisturePassStatus.cancelled) {
      throw MoistureValidationException(
        'Refused: Moisture Pass "$passNumber" has been CANCELLED (${pass.cancellationReason ?? 'No reason stated'}).',
        code: 'PASS_CANCELLED',
      );
    }

    // Test 4.5: Same pass shows USED and is refused a second time
    if (pass.status == MoisturePassStatus.used) {
      throw MoistureValidationException(
        'Refused: Moisture Pass "$passNumber" has already been USED for Arrival Cutting in Lot ${pass.usedInArrivalCuttingLot ?? 'Unknown'}. Passes are single-use only.',
        code: 'PASS_ALREADY_USED',
      );
    }

    // Test 4.6: Pass from another lot is refused
    if (pass.lotCode.trim().toUpperCase() != currentLotCode.trim().toUpperCase()) {
      throw MoistureValidationException(
        'Refused: Moisture Pass "$passNumber" was issued for Lot ${pass.lotCode}, but current arrival is Lot $currentLotCode. Cross-lot pass usage is prohibited.',
        code: 'LOT_MISMATCH',
      );
    }

    // Unconfirmed payment
    if (!pass.paymentConfirmed || pass.status == MoisturePassStatus.awaitingPayment) {
      throw MoistureValidationException(
        'Refused: Moisture Pass payment has not been confirmed.',
        code: 'PAYMENT_PENDING',
      );
    }

    return pass;
  }

  /// Consumes a Pass when Arrival Cutting is saved (Test 4.5)
  Future<void> consumePassForArrivalCutting({
    required String passNumber,
    required String currentLotCode,
  }) async {
    final query = await _passesRef.where('passNumber', isEqualTo: passNumber.trim()).limit(1).get();
    if (query.docs.isEmpty) return;

    final docId = query.docs.first.id;
    final now = DateTime.now();

    await _passesRef.doc(docId).update({
      'status': MoisturePassStatus.used.code,
      'usedInArrivalCuttingLot': currentLotCode,
      'usedAt': now.toIso8601String(),
    });

    await _auditRef.add({
      'action': 'CONSUME_PASS_FOR_CUTTING',
      'passNumber': passNumber,
      'lotCode': currentLotCode,
      'timestamp': now.toIso8601String(),
    });
  }

  /// Verifies a QR security token (Test 4.11, Test 5.2)
  Future<MoisturePass?> verifyQrToken(String passNumber, String signatureHash) async {
    final query = await _passesRef.where('passNumber', isEqualTo: passNumber.trim()).limit(1).get();
    if (query.docs.isEmpty) return null;

    final pass = MoisturePass.fromMap(query.docs.first.data(), query.docs.first.id);

    // Test 4.11 / 5.2: Forged or altered QR code shows NOT RECOGNISED
    if (pass.signatureHash.toUpperCase() != signatureHash.trim().toUpperCase()) {
      return null;
    }

    return pass;
  }

  Future<int> _getNextPassSequence(DateTime date, bool isPassed) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final prefix = isPassed ? 'CQAAG-P' : 'CQAAG-FP';

    final snapshot = await _passesRef
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('timestamp', isLessThan: endOfDay.toIso8601String())
        .get();

    final count = snapshot.docs.where((d) {
      final pNum = d.data()['passNumber'] as String? ?? '';
      return pNum.startsWith(prefix);
    }).length;

    return count + 1;
  }
}
