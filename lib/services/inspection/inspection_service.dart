import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

part 'inspection_service.g.dart';

class InspectionService {
  final Logger logger = Logger();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  InspectionService();

  CollectionReference<Map<String, dynamic>> get _inspectionsCollection => _firestore.collection('inspections');

  /// Create a new inspection
  Future<void> createInspection(Inspection inspection) async {
    await _inspectionsCollection.doc(inspection.id).set(inspection.toJson());
  }

  /// Update an existing inspection
  Future<void> updateInspection(Inspection inspection) async {
    await _inspectionsCollection.doc(inspection.id).update(inspection.toJson());
  }

  /// Get all inspections for a specific inspector
  Future<List<Inspection>> getInspections(String inspectorId) async {
    final snapshot = await _inspectionsCollection
        .where('inspector_id', isEqualTo: inspectorId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
  }

  /// Get recent inspections (limit 10)
  Future<List<Inspection>> getRecentInspections(String inspectorId, {int limit = 10}) async {
    final snapshot = await _inspectionsCollection
        .where('inspector_id', isEqualTo: inspectorId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
  }

  /// Stream user's inspections in real-time
  Stream<List<Inspection>> streamUserInspections(String inspectorId) {
    return _inspectionsCollection
        .where('inspector_id', isEqualTo: inspectorId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
        });
  }

  /// Get total count of all inspections (for ID generation)
  Future<int> getInspectionCount() async {
    final snapshot = await _inspectionsCollection.count().get();
    return snapshot.count ?? 0;
  }

  /// Stream recent inspections (limit 10)
  Stream<List<Inspection>> streamRecentInspections(String inspectorId, {int limit = 10}) {
    return _inspectionsCollection
        .where('inspector_id', isEqualTo: inspectorId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
        });
  }

  /// Get inspection by ID
  Future<Inspection?> getInspectionById(String inspectionId) async {
    final doc = await _inspectionsCollection.doc(inspectionId).get();

    if (!doc.exists) return null;
    return Inspection.fromJson(doc.data()!);
  }

  /// Update inspection status
  Future<void> updateInspectionStatus({
    required String inspectionId,
    required InspectionStatus status,
    DateTime? completedAt,
  }) async {

    final updateData = <String, dynamic>{
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (completedAt != null) {
      updateData['completed_at'] = completedAt.toIso8601String();
    }

    await _inspectionsCollection.doc(inspectionId).update(updateData);
  }

  // --- CQAAG approval desk (Export certificates) ---------------------------

  /// Export certificates waiting for approval, oldest request first, so the
  /// desk works through them in the order they arrived.
  Stream<List<Inspection>> streamPendingExportApprovals() {
    return _inspectionsCollection.where('approval_status', isEqualTo: CertificateApprovalStatus.pending.value).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).where((i) => i.isExport).toList();
      list.sort((a, b) {
        final aTime = a.approvalRequestedAtTime ?? a.createdAt ?? DateTime(2000);
        final bTime = b.approvalRequestedAtTime ?? b.createdAt ?? DateTime(2000);
        return aTime.compareTo(bTime);
      });
      return list;
    });
  }

  /// The signed seal (president's signature embedded) admins uploaded, shared
  /// with the website at `settings/export_approval`.
  Future<String?> getExportSealUrl() async {
    final doc = await _firestore.collection('settings').doc('export_approval').get();
    final url = doc.data()?['seal_url']?.toString() ?? '';
    return url.startsWith('http') ? url : null;
  }

  Stream<String?> streamExportSealUrl() {
    return _firestore.collection('settings').doc('export_approval').snapshots().map((doc) {
      final url = doc.data()?['seal_url']?.toString() ?? '';
      return url.startsWith('http') ? url : null;
    });
  }

  Future<void> setExportSealUrl({required String url, required String adminUid}) async {
    await _firestore.collection('settings').doc('export_approval').set({
      'seal_url': url,
      'seal_updated_at': DateTime.now().toUtc().toIso8601String(),
      'seal_updated_by': adminUid,
    }, SetOptions(merge: true));
  }

  /// Approves an Export certificate, stamping the seal and the date and time
  /// of approval on it, and tells the analyst in the app.
  ///
  /// [sealUrl] is the signed seal in force; when none has been uploaded the
  /// certificate carries the association seal without claiming a signature.
  Future<void> approveExport({
    required Inspection inspection,
    required String adminUid,
    required String adminName,
    String? sealUrl,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _inspectionsCollection.doc(inspection.id).update({
      'approval_status': CertificateApprovalStatus.approved.value,
      'status': 'completed',
      'completed_at': inspection.completedAt?.toIso8601String() ?? now,
      'approved_at': now,
      'approved_by_uid': adminUid,
      'approved_by_name': adminName,
      'approval_seal_url': sealUrl ?? '',
      'approval_seal_includes_signature': sealUrl != null,
      'declined_at': '',
      'decline_reason': '',
      'declined_by_uid': '',
      'declined_by_name': '',
      'updated_at': now,
    });
    await _notifyAnalyst(
      inspection,
      title: 'Export certificate approved',
      body: 'Export certificate ${inspection.inspectionId ?? inspection.id} was approved on ${_accraStamp(now)}. The certificate is now valid.',
      createdAt: now,
    );
  }

  Future<void> declineExport({
    required Inspection inspection,
    required String adminUid,
    required String adminName,
    required String reason,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _inspectionsCollection.doc(inspection.id).update({
      'approval_status': CertificateApprovalStatus.declined.value,
      'status': 'approval_declined',
      'approved_at': '',
      'approved_by_uid': '',
      'approved_by_name': '',
      'approval_seal_url': '',
      'approval_seal_includes_signature': false,
      'declined_at': now,
      'decline_reason': reason,
      'declined_by_uid': adminUid,
      'declined_by_name': adminName,
      'updated_at': now,
    });
    await _notifyAnalyst(
      inspection,
      title: 'Export certificate not approved',
      body: 'Export certificate ${inspection.inspectionId ?? inspection.id} was not approved. Reason: $reason',
      createdAt: now,
    );
  }

  /// Records an admin's check of the certificate fee evidence.
  Future<void> setReportFeeStatus({
    required String inspectionId,
    required PaymentStatus status,
    required String adminUid,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _inspectionsCollection.doc(inspectionId).update({
      'report_fee_status': status.value,
      'report_fee_verified_at': now,
      'report_fee_verified_by': adminUid,
      'updated_at': now,
    });
  }

  Future<void> _notifyAnalyst(Inspection inspection, {required String title, required String body, required String createdAt}) async {
    try {
      await _firestore.collection('notifications').add({
        'title': title,
        'body': body,
        'target': 'user:${inspection.inspectorId}',
        'created_at': createdAt,
      });
    } catch (e) {
      logger.w('Could not notify analyst of export decision: $e');
    }
  }

  static String _accraStamp(String iso) {
    final time = DateTime.tryParse(iso);
    return time == null ? iso : AgreementPdfService.formatSignedAt(time);
  }

  /// Get all completed inspections (for history screen - all users)
  Future<List<Inspection>> getAllCompletedInspections() async {
    final snapshot = await _inspectionsCollection
        .where('status', isEqualTo: 'completed')
        .orderBy('completed_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
  }

  /// Stream all completed inspections (for history screen - all users)
  Stream<List<Inspection>> streamAllCompletedInspections() {
    return _inspectionsCollection
        .where('status', isEqualTo: 'completed')
        .orderBy('completed_at', descending: true)
        .snapshots()
        .map((snapshot) {
          // _logger.i("Raw stream event received. Document count: ${snapshot.docs.length}");
          // for (final doc in snapshot.docs) {
          //   // _logger.d("Doc ID: ${doc.id}, Data: ${doc.data()}");
          //   _logger.d("Doc ID: ${doc.id}");
          // }
          return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
        });
  }

  /// Get user's uncompleted inspections (pending + in-progress)
  Future<List<Inspection>> getUserUncompletedInspections(String inspectorId) async {
    final snapshot = await _inspectionsCollection
        .where('inspector_id', isEqualTo: inspectorId)
        .where('status', whereIn: ['pending', 'in_progress'])
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
  }

  /// Stream user's uncompleted inspections
  Stream<List<Inspection>> streamUserUncompletedInspections(String inspectorId) {
    return _inspectionsCollection
        .where('inspector_id', isEqualTo: inspectorId)
        .where('status', whereIn: ['pending', 'in_progress'])
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
        });
  }

  /// Stream user's completed inspections (for home screen recent activity if no pending)
  Stream<List<Inspection>> streamUserCompletedInspections(String inspectorId, {int limit = 10}) {
    return _inspectionsCollection
        .where('inspector_id', isEqualTo: inspectorId)
        .where('status', isEqualTo: 'completed')
        .orderBy('completed_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
        });
  }
}

@Riverpod(keepAlive: true)
InspectionService inspectionService(Ref ref) {
  return InspectionService();
}
