import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/membership/membership_application.dart';
import 'package:cqaag_app/models/membership/membership_category.dart';
import 'package:cqaag_app/models/payment/payment_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'membership_service.g.dart';

/// Service for managing membership applications in Firestore
class MembershipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MembershipService();

  /// Collection reference for membership applications
  CollectionReference<Map<String, dynamic>> get _applicationsCollection => _firestore.collection('members');

  /// Submit a new membership application
  Future<void> submitApplication(MembershipApplication application) async {

    final updatedApplication = application.copyWith(
      status: ApplicationStatus.submitted,
      submittedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _applicationsCollection.doc(application.id).set(updatedApplication.toJson());
  }

  /// Update an existing application (for drafts)
  Future<void> updateApplication(MembershipApplication application) async {

    final updatedApplication = application.copyWith(
      updatedAt: DateTime.now(),
    );

    await _applicationsCollection.doc(application.id).update(updatedApplication.toJson());
  }

  /// Save application as draft
  Future<void> saveDraft(MembershipApplication application) async {

    final draftApplication = application.copyWith(
      status: ApplicationStatus.draft,
      createdAt: application.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _applicationsCollection.doc(application.id).set(draftApplication.toJson());
  }

  /// Get application by user ID
  Future<MembershipApplication?> getApplicationByUserId(String userId) async {
    final querySnapshot = await _applicationsCollection.where('user_id', isEqualTo: userId).limit(1).get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final data = querySnapshot.docs.first.data();
    return MembershipApplication.fromJson(data);
  }

  /// Get application by ID
  Future<MembershipApplication?> getApplicationById(String applicationId) async {
    final docSnapshot = await _applicationsCollection.doc(applicationId).get();

    if (!docSnapshot.exists || docSnapshot.data() == null) {
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
      final data = snapshot.docs.first.data();
      return MembershipApplication.fromJson(data);
    });
  }

  /// Stream application by ID
  Stream<MembershipApplication?> streamApplicationById(String applicationId) {
    return _applicationsCollection.doc(applicationId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return MembershipApplication.fromJson(snapshot.data()!);
    });
  }

  /// Delete application (only for drafts)
  Future<void> deleteApplication(String applicationId) async {
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

  /// Withdraw an unapproved application (submitted, under_review, draft, pending)
  Future<void> withdrawApplication(String applicationId, String userId) async {
    final application = await getApplicationById(applicationId);
    if (application == null) {
      throw Exception('Application not found');
    }

    if (application.status == ApplicationStatus.approved) {
      throw Exception('Approved memberships cannot be withdrawn');
    }

    await _applicationsCollection.doc(applicationId).delete();

    await _firestore.collection('users').doc(userId).update({
      'membership_status': 'Not a member',
    });
  }

  /// Get all applications (for admin use)
  Future<List<MembershipApplication>> getAllApplications() async {
    final querySnapshot = await _applicationsCollection.get();

    return querySnapshot.docs
        .map((doc) => MembershipApplication.fromJson(doc.data()))
        .toList();
  }

  /// Stream all applications (for admin use)
  Stream<List<MembershipApplication>> streamAllApplications() {
    return _applicationsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MembershipApplication.fromJson(doc.data()))
          .toList();
    });
  }

  /// Update application status (for admin/reviewer use)
  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
    String? reviewNotes,
    String? reviewerId,
  }) async {
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

    final application = await getApplicationById(applicationId);
    if (application != null) {
      String userMemStatus;
      switch (status) {
        case ApplicationStatus.approved:
          userMemStatus = 'verified';
          break;
        case ApplicationStatus.rejected:
          userMemStatus = 'Not a member';
          break;
        default:
          userMemStatus = 'applied';
      }

      await _firestore.collection('users').doc(application.userId).update({
        'membership_status': userMemStatus,
      });
    }
  }

  /// Records payment evidence uploaded by an applicant after initial registration.
  Future<void> submitPaymentEvidence({
    required String applicationId,
    required String evidenceUrl,
    String? reference,
    required PaymentSettings settings,
  }) async {
    final now = DateTime.now();
    await _applicationsCollection.doc(applicationId).update({
      'payment_method': PaymentMethod.momo.value,
      'payment_status': PaymentStatus.pendingVerification.value,
      'payment_amount': settings.registrationFee,
      'payment_currency': settings.currency,
      'payment_evidence_url': evidenceUrl,
      if (reference != null && reference.isNotEmpty) 'payment_reference': reference,
      'payment_momo_network': settings.network.value,
      'payment_momo_number': settings.momoNumber,
      'payment_submitted_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  /// Records an admin's verdict on an applicant's registration payment.
  ///
  /// Kept separate from [updateApplicationStatus] because verifying that money
  /// arrived and approving the membership are distinct decisions.
  Future<void> updatePaymentStatus({
    required String applicationId,
    required PaymentStatus status,
    required String verifiedBy,
  }) async {
    await _applicationsCollection.doc(applicationId).update({
      'payment_status': status.value,
      'payment_verified_at': DateTime.now().toIso8601String(),
      'payment_verified_by': verifiedBy,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

/// Provider for MembershipService
@Riverpod(keepAlive: true)
MembershipService membershipService(Ref ref) {
  return MembershipService();
}
