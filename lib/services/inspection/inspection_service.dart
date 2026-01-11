import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/inspection/inspection.dart';
import 'package:cqaag_app/services/connectivity/connectivity_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspection_service.g.dart';

class InspectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService;

  InspectionService(this._connectivityService);

  CollectionReference<Map<String, dynamic>> get _inspectionsCollection => _firestore.collection('inspections');

  Future<void> createInspection(Inspection inspection) async {
    await _connectivityService.ensureConnected();
    await _inspectionsCollection.doc(inspection.id).set(inspection.toJson());
  }

  Future<void> updateInspection(Inspection inspection) async {
    await _connectivityService.ensureConnected();
    await _inspectionsCollection.doc(inspection.id).update(inspection.toJson());
  }

  Future<List<Inspection>> getInspections(String inspectorId) async {
    await _connectivityService.ensureConnected();
    final snapshot = await _inspectionsCollection.where('inspector_id', isEqualTo: inspectorId).orderBy('date', descending: true).get();

    return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
  }
}

@Riverpod(keepAlive: true)
InspectionService inspectionService(Ref ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return InspectionService(connectivityService);
}
