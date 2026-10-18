import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/equipment/equipment.dart';

class EquipmentBlockedException implements Exception {
  final String message;
  EquipmentBlockedException(this.message);

  @override
  String toString() => message;
}

class EquipmentValidationResult {
  final bool canProceed;
  final String? warningMessage;
  final bool isStrictBlock;

  const EquipmentValidationResult({
    required this.canProceed,
    this.warningMessage,
    this.isStrictBlock = false,
  });

  static const valid = EquipmentValidationResult(canProceed: true);
}

class EquipmentService {
  final FirebaseFirestore? _firestore;

  EquipmentService({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _equipmentCollection =>
      firestore.collection('equipment');

  DocumentReference<Map<String, dynamic>> get _settingsDoc =>
      firestore.collection('system_settings').doc('equipment_settings');

  /// Checks if equipment validation switch is ON (Spec Section 36.4 Test 1)
  /// Default: false (switch OFF)
  Future<bool> isEquipmentCheckEnabled() async {
    final doc = await _settingsDoc.get();
    if (!doc.exists) return false;
    return doc.data()?['is_enabled'] as bool? ?? false;
  }

  /// Switches equipment check ON with compulsory two-person approval (Test 20.2 & Section 88)
  Future<void> switchEquipmentCheckOn({
    required String firstApproverId,
    required String secondApproverId,
  }) async {
    if (firstApproverId == secondApproverId) {
      throw ArgumentError('Two distinct officers required to switch on equipment validation.');
    }

    final batch = firestore.batch();
    batch.set(_settingsDoc, {
      'is_enabled': true,
      'switched_on_at': FieldValue.serverTimestamp(),
      'first_approver_id': firstApproverId,
      'second_approver_id': secondApproverId,
    }, SetOptions(merge: true));

    // Audit event log
    final auditRef = firestore.collection('audit_events').doc();
    batch.set(auditRef, {
      'event_type': 'SWITCH_EQUIPMENT_CHECK_ON',
      'initiator_id': firstApproverId,
      'second_approver_id': secondApproverId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Switches equipment check OFF
  Future<void> switchEquipmentCheckOff({required String adminId}) async {
    await _settingsDoc.set({
      'is_enabled': false,
      'switched_off_at': FieldValue.serverTimestamp(),
      'switched_off_by': adminId,
    }, SetOptions(merge: true));
  }

  /// Validates equipment for inspection check (Spec Section 36.4 Tests 1, 2, 3)
  Future<EquipmentValidationResult> validateEquipmentForCheck({
    Equipment? equipment,
    required String currentAnalystId,
  }) async {
    final isEnabled = await isEquipmentCheckEnabled();
    // Test 20.1: With switch OFF, checks save with no equipment asked and no warning
    if (!isEnabled) {
      return EquipmentValidationResult.valid;
    }

    // Switch is ON
    if (equipment == null) {
      return const EquipmentValidationResult(
        canProceed: false,
        isStrictBlock: true,
        warningMessage: 'Equipment validation is active: an official registered moisture meter must be selected.',
      );
    }

    // Test 20.3: A meter assigned to another analyst gives a warning, not a block
    String? warning;
    if (equipment.assignedAnalystId != currentAnalystId) {
      warning = 'Warning: This meter is assigned to another analyst on the Equipment Register.';
    }

    // Test 20.2: 30-day grace period check
    final settingsSnap = await _settingsDoc.get();
    final switchedOnAt = (settingsSnap.data()?['switched_on_at'] as Timestamp?)?.toDate() ?? DateTime.now();
    final daysSinceEnabled = DateTime.now().difference(switchedOnAt).inDays;

    if (equipment.isCalibrationExpired) {
      if (daysSinceEnabled <= 30) {
        // Within 30 days: warning only, check can still be saved
        return EquipmentValidationResult(
          canProceed: true,
          warningMessage: '${warning != null ? "$warning\n" : ""}Calibration Notice: This meter\'s calibration ended on ${equipment.calibrationExpiryDate.toLocal().toString().split(" ")[0]}. Day $daysSinceEnabled of 30-day grace period.',
        );
      } else {
        // Day 31+: Strict block
        return EquipmentValidationResult(
          canProceed: false,
          isStrictBlock: true,
          warningMessage: 'Inspection Blocked: Calibration expired on ${equipment.calibrationExpiryDate.toLocal().toString().split(" ")[0]}. The 30-day grace period has elapsed. Recalibration required (Spec Section 36).',
        );
      }
    }

    return EquipmentValidationResult(
      canProceed: true,
      warningMessage: warning,
    );
  }

  Stream<List<Equipment>> getEquipmentStream({String? analystId}) {
    Query<Map<String, dynamic>> q = _equipmentCollection.orderBy('created_at', descending: true);
    if (analystId != null) {
      q = q.where('assigned_analyst_id', isEqualTo: analystId);
    }
    return q.snapshots().map(
        (snap) => snap.docs.map((d) => Equipment.fromMap(d.data(), d.id)).toList());
  }
}
