import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspection_service.g.dart';

class InspectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService;

  InspectionService(this._connectivityService);

  CollectionReference<Map<String, dynamic>> get _inspectionsCollection => _firestore.collection('inspections');

  /// Create a new inspection
  Future<void> createInspection(Inspection inspection) async {
    await _connectivityService.ensureConnected();
    await _inspectionsCollection.doc(inspection.id).set(inspection.toJson());
  }

  /// Update an existing inspection
  Future<void> updateInspection(Inspection inspection) async {
    await _connectivityService.ensureConnected();
    await _inspectionsCollection.doc(inspection.id).update(inspection.toJson());
  }

  /// Get all inspections for a specific inspector
  Future<List<Inspection>> getInspections(String inspectorId) async {
    await _connectivityService.ensureConnected();
    final snapshot = await _inspectionsCollection.where('inspector_id', isEqualTo: inspectorId).orderBy('created_at', descending: true).get();

    return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
  }

  /// Get recent inspections (limit 10)
  Future<List<Inspection>> getRecentInspections(String inspectorId, {int limit = 10}) async {
    await _connectivityService.ensureConnected();
    final snapshot = await _inspectionsCollection.where('inspector_id', isEqualTo: inspectorId).orderBy('created_at', descending: true).limit(limit).get();

    return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
  }

  /// Stream user's inspections in real-time
  Stream<List<Inspection>> streamUserInspections(String inspectorId) {
    return _inspectionsCollection.where('inspector_id', isEqualTo: inspectorId).orderBy('created_at', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
    });
  }

  /// Get total count of all inspections (for ID generation)
  Future<int> getInspectionCount() async {
    await _connectivityService.ensureConnected();
    final snapshot = await _inspectionsCollection.count().get();
    return snapshot.count ?? 0;
  }

  /// Stream recent inspections (limit 10)
  Stream<List<Inspection>> streamRecentInspections(String inspectorId, {int limit = 10}) {
    return _inspectionsCollection.where('inspector_id', isEqualTo: inspectorId).orderBy('created_at', descending: true).limit(limit).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
    });
  }

  /// Get inspection by ID
  Future<Inspection?> getInspectionById(String inspectionId) async {
    await _connectivityService.ensureConnected();
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
    await _connectivityService.ensureConnected();

    final updateData = <String, dynamic>{
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (completedAt != null) {
      updateData['completed_at'] = completedAt.toIso8601String();
    }

    await _inspectionsCollection.doc(inspectionId).update(updateData);
  }

  /// Get all completed inspections (for history screen - all users)
  Future<List<Inspection>> getAllCompletedInspections() async {
    await _connectivityService.ensureConnected();
    final snapshot = await _inspectionsCollection.where('status', isEqualTo: 'completed').orderBy('completed_at', descending: true).get();

    return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
  }

  /// Stream all completed inspections (for history screen - all users)
  Stream<List<Inspection>> streamAllCompletedInspections() {
    return _inspectionsCollection.where('status', isEqualTo: 'completed').orderBy('completed_at', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
    });
  }

  /// Get user's uncompleted inspections (pending + in-progress)
  Future<List<Inspection>> getUserUncompletedInspections(String inspectorId) async {
    await _connectivityService.ensureConnected();
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
}

@Riverpod(keepAlive: true)
InspectionService inspectionService(Ref ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return InspectionService(connectivityService);
}
