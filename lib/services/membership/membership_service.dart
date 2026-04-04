import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/membership/membership_application.dart';
import 'package:cqaag_app/models/membership/membership_category.dart';
import 'package:cqaag_app/services/connectivity/connectivity_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'membership_service.g.dart';

/// Service for managing membership applications in Firestore
class MembershipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService;

  MembershipService(this._connectivityService);

  /// Collection reference for membership applications
  CollectionReference<Map<String, dynamic>> get _applicationsCollection => _firestore.collection('members');

  /// Submit a new membership application
  Future<void> submitApplication(MembershipApplication application) async {
    await _connectivityService.ensureConnected();

    final updatedApplication = application.copyWith(
      status: ApplicationStatus.submitted,
      submittedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _applicationsCollection.doc(application.id).set(updatedApplication.toJson());
  }

  /// Update an existing application (for drafts)
  Future<void> updateApplication(MembershipApplication application) async {
    await _connectivityService.ensureConnected();

    final updatedApplication = application.copyWith(
      updatedAt: DateTime.now(),
    );

    await _applicationsCollection.doc(application.id).update(updatedApplication.toJson());
  }

  /// Save application as draft
  Future<void> saveDraft(MembershipApplication application) async {
    await _connectivityService.ensureConnected();

    final draftApplication = application.copyWith(
      status: ApplicationStatus.draft,
      createdAt: application.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _applicationsCollection.doc(application.id).set(draftApplication.toJson());
  }

  /// Get application by user ID
  Future<MembershipApplication?> getApplicationByUserId(String userId) async {
    await _connectivityService.ensureConnected();

    final querySnapshot = await _applicationsCollection.where('user_id', isEqualTo: userId).limit(1).get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return MembershipApplication.fromJson(querySnapshot.docs.first.data());
  }

  /// Get application by ID
  Future<MembershipApplication?> getApplicationById(String applicationId) async {
    await _connectivityService.ensureConnected();

    final docSnapshot = await _applicationsCollection.doc(applicationId).get();

    if (!docSnapshot.exists) {
      return null;
    }

    return MembershipApplication.fromJson(docSnapshot.data()!);
  }

  /// Stream user's membership application
  Stream<MembershipApplication?> streamUserApplication(String userId) {
    return _applicationsCollection.where('user_id', isEqualTo: userId).limit(1).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return MembershipApplication.fromJson(snapshot.docs.first.data());
    });
  }

  /// Stream application by ID
  Stream<MembershipApplication?> streamApplicationById(String applicationId) {
    return _applicationsCollection.doc(applicationId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return MembershipApplication.fromJson(snapshot.data()!);
    });
  }

  /// Delete application (only for drafts)
  Future<void> deleteApplication(String applicationId) async {
    await _connectivityService.ensureConnected();

    // First check if it's a draft
    final application = await getApplicationById(applicationId);
    if (application == null) {
      throw Exception('Application not found');
    }

    if (application.status != ApplicationStatus.draft) {
      throw Exception('Only draft applications can be deleted');
    }

    await _applicationsCollection.doc(applicationId).delete();
  }

  /// Get all applications (for admin use)
  Future<List<MembershipApplication>> getAllApplications() async {
    await _connectivityService.ensureConnected();

    final querySnapshot = await _applicationsCollection.get();

    return querySnapshot.docs.map((doc) => MembershipApplication.fromJson(doc.data())).toList();
  }

  /// Stream all applications (for admin use)
  Stream<List<MembershipApplication>> streamAllApplications() {
    return _applicationsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MembershipApplication.fromJson(doc.data())).toList();
    });
  }

  /// Update application status (for admin/reviewer use)
  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
    String? reviewNotes,
    String? reviewerId,
  }) async {
    await _connectivityService.ensureConnected();

    final updateData = <String, dynamic>{
      'status': status.value,
      'reviewed_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (reviewNotes != null) {
      updateData['review_notes'] = reviewNotes;
    }

    if (reviewerId != null) {
      updateData['reviewer_id'] = reviewerId;
    }

    await _applicationsCollection.doc(applicationId).update(updateData);
  }
}

/// Provider for MembershipService
@Riverpod(keepAlive: true)
MembershipService membershipService(Ref ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return MembershipService(connectivityService);
}
