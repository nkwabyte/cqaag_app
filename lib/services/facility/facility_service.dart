import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/facility/facility.dart';
import 'package:cqaag_app/services/cloudinary/cloudinary_service.dart';

class FacilityDuplicateWarningException implements Exception {
  final String message;
  final Facility existingFacility;
  FacilityDuplicateWarningException(this.message, this.existingFacility);

  @override
  String toString() => message;
}

class FacilityProximityResult {
  final bool isWithin300m;
  final double distanceMeters;
  final Facility? facility;
  const FacilityProximityResult({
    required this.isWithin300m,
    required this.distanceMeters,
    this.facility,
  });
}

class FacilityService {
  final FirebaseFirestore? _firestore;
  final CloudinaryService? _cloudinary;

  FacilityService({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinary,
  })  : _firestore = firestore,
        _cloudinary = cloudinary;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;
  CloudinaryService get cloudinary => _cloudinary ?? CloudinaryService();

  CollectionReference<Map<String, dynamic>> get _facilitiesCollection =>
      firestore.collection('facilities');

  Future<List<Facility>> getFacilities({FacilityType? type}) async {
    Query<Map<String, dynamic>> q = _facilitiesCollection.orderBy('created_at', descending: true);
    if (type != null) {
      q = q.where('facility_type', isEqualTo: type.name);
    }
    final snap = await q.get();
    return snap.docs.map((d) => Facility.fromMap(d.data(), d.id)).toList();
  }

  Future<FacilityProximityResult> checkProximityToFacility(String facilityId, double lat, double lng) async {
    final doc = await _facilitiesCollection.doc(facilityId).get();
    if (!doc.exists) {
      return const FacilityProximityResult(isWithin300m: true, distanceMeters: 0.0);
    }
    final fac = Facility.fromMap(doc.data()!, doc.id);
    final dist = calculateDistanceMeters(fac.latitude, fac.longitude, lat, lng);
    return FacilityProximityResult(
      isWithin300m: dist <= 300.0,
      distanceMeters: dist,
      facility: fac,
    );
  }

  /// Registers a Warehouse or Weighbridge (Step 3, Test 3.1 & 3.2)
  /// Enforces: Gate GPS, 3 Live Photos, and Valid Operator TCDA Licence.
  Future<Facility> registerFacility({
    required FacilityType type,
    required String name,
    required String operatorName,
    required String operatorTcdaLicenceNumber,
    required double latitude,
    required double longitude,
    required File photoGate,
    required File photoFloor,
    required File photoScale,
    required String district,
    required String region,
    required String registeringUserId,
    bool forceDuplicateOverride = false,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) throw ArgumentError('Facility name is mandatory.');
    if (operatorTcdaLicenceNumber.trim().isEmpty) {
      throw ArgumentError('Operator TCDA licence number is mandatory (Test 3.1).');
    }
    if (latitude == 0.0 && longitude == 0.0) {
      throw ArgumentError('Gate GPS coordinates are mandatory (Test 3.1).');
    }

    // Check 50-meter duplicate proximity rule (Test 3.5)
    final existingSnap = await _facilitiesCollection.get();
    final allFacilities = existingSnap.docs.map((d) => Facility.fromMap(d.data(), d.id)).toList();

    for (final existing in allFacilities) {
      final distMeters = calculateDistanceMeters(latitude, longitude, existing.latitude, existing.longitude);
      final sameLicence = existing.operatorTcdaLicenceNumber.toUpperCase() == operatorTcdaLicenceNumber.trim().toUpperCase();
      final similarName = existing.name.toLowerCase().contains(cleanName.toLowerCase()) ||
          cleanName.toLowerCase().contains(existing.name.toLowerCase());

      if (distMeters <= 50 && (sameLicence || similarName) && !forceDuplicateOverride) {
        throw FacilityDuplicateWarningException(
          'Duplicate Warning: Registered facility "${existing.name}" (${existing.facilityCode}) is located within ${distMeters.toStringAsFixed(1)}m with matching parameters. Please confirm merge or override.',
          existing,
        );
      }
    }

    // Upload 3 live photos
    final gateUrl = await cloudinary.uploadPaymentEvidence(photoGate);
    final floorUrl = await cloudinary.uploadPaymentEvidence(photoFloor);
    final scaleUrl = await cloudinary.uploadPaymentEvidence(photoScale);

    // Generate sequential server number (Test 3.2)
    final count = allFacilities.where((f) => f.facilityType == type).length + 1;
    final prefix = type == FacilityType.warehouse ? 'CQAAG-W' : 'CQAAG-WB';
    final facilityCode = '$prefix-${count.toString().padLeft(4, '0')}';

    final docRef = _facilitiesCollection.doc();
    final facility = Facility(
      id: docRef.id,
      facilityCode: facilityCode,
      facilityType: type,
      name: cleanName,
      operatorName: operatorName.trim(),
      operatorTcdaLicenceNumber: operatorTcdaLicenceNumber.trim().toUpperCase(),
      latitude: latitude,
      longitude: longitude,
      photoGateUrl: gateUrl ?? '',
      photoFloorUrl: floorUrl ?? '',
      photoScaleUrl: scaleUrl ?? '',
      status: FacilityStatus.provisional, // Test 3.2: PROVISIONAL at creation
      district: district,
      region: region,
      createdAt: DateTime.now(),
      registeredByUserId: registeringUserId,
    );

    await docRef.set(facility.toMap());
    return facility;
  }

  /// Verifies facility to ACTIVE (Test 3.3: agent who entered cannot verify it)
  Future<void> verifyFacility({
    required String facilityId,
    required String verifierUserId,
  }) async {
    final doc = await _facilitiesCollection.doc(facilityId).get();
    if (!doc.exists) throw ArgumentError('Facility not found.');

    final facility = Facility.fromMap(doc.data()!, doc.id);
    if (facility.registeredByUserId == verifierUserId) {
      throw StateError('Rule 34.5 Test 3: The agent who registered the facility cannot verify it. Verification requires a supervisor or Secretariat.');
    }

    await _facilitiesCollection.doc(facilityId).update({
      'status': FacilityStatus.active.name,
      'verified_by_user_id': verifierUserId,
      'verified_at': FieldValue.serverTimestamp(),
    });
  }

  /// 300m GPS gate proximity check (Spec Section 34.5 Test 7)
  bool isWithin300m(Facility facility, double checkLat, double checkLng) {
    if (facility.latitude == 0.0 || checkLat == 0.0) return true;
    final dist = calculateDistanceMeters(facility.latitude, facility.longitude, checkLat, checkLng);
    return dist <= 300.0;
  }

  /// Haversine distance formula between two GPS coordinates in meters
  static double calculateDistanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a)); // 2 * R * 1000m
  }

  /// Records 5-Point Storage Inspection (Spec Figure 16)
  Future<void> recordStorageVisit({
    required String facilityId,
    required bool stackHeightsPassed,
    required bool palletSpacingPassed,
    required bool ventilationPassed,
    required bool moistureBarrierPassed,
    required bool pestControlPassed,
    required String inspectedByUserId,
    String? remarks,
  }) async {
    final allPassed = stackHeightsPassed &&
        palletSpacingPassed &&
        ventilationPassed &&
        moistureBarrierPassed &&
        pestControlPassed;

    final correctiveDeadline = allPassed ? null : DateTime.now().add(const Duration(days: 14));

    final checklist = {
      'stack_heights_passed': stackHeightsPassed,
      'pallet_spacing_passed': palletSpacingPassed,
      'ventilation_passed': ventilationPassed,
      'moisture_barrier_passed': moistureBarrierPassed,
      'pest_control_passed': pestControlPassed,
      'all_passed': allPassed,
      'inspected_by': inspectedByUserId,
      'inspected_at': Timestamp.now(),
      'remarks': remarks ?? '',
    };

    await _facilitiesCollection.doc(facilityId).update({
      'last_storage_checklist': checklist,
      'corrective_action_deadline': correctiveDeadline != null ? Timestamp.fromDate(correctiveDeadline) : null,
    });
  }

  Stream<List<Facility>> getFacilitiesStream({FacilityType? type}) {
    Query<Map<String, dynamic>> q = _facilitiesCollection.orderBy('created_at', descending: true);
    if (type != null) {
      q = q.where('facility_type', isEqualTo: type.name);
    }
    return q.snapshots().map(
        (snap) => snap.docs.map((d) => Facility.fromMap(d.data(), d.id)).toList());
  }
}
