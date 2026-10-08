import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/core/constants/legal_documents.dart';
import 'package:cqaag_app/core/services/agreement_pdf_service.dart';
import 'package:cqaag_app/models/membership/membership_application.dart';
import 'package:cqaag_app/services/website/website_api_service.dart';
import 'package:cqaag_app/models/membership/membership_category.dart';
import 'package:cqaag_app/models/payment/fee_schedule.dart';
import 'package:cqaag_app/models/payment/payment_settings.dart';
import 'package:cqaag_app/utils/ghana_card.dart';
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

    await _applicationsCollection.doc(application.id).set(websiteFields(updatedApplication));
  }

  /// Submits an application together with the governing documents the
  /// applicant accepted.
  ///
  /// The accepted A4 copies are filed in the association's agreements database
  /// first, and the application is only written once that succeeds — exactly
  /// as the website does — so there is never a membership record without its
  /// signed documents.
  Future<void> submitSignedApplication({
    required MembershipApplication application,
    required List<SignedPacket> packets,
    required WebsiteApiService website,
  }) async {
    final filed = await website.storeAgreements(
      memberId: application.id,
      documents: packets.map((p) => p.toFiling()).toList(),
      fullName: application.fullName,
    );
    if (!filed.success) {
      throw Exception(filed.message ?? 'The agreements could not be filed. The application was not submitted.');
    }

    final now = DateTime.now();
    final submitted = application.copyWith(
      status: ApplicationStatus.submitted,
      submittedAt: now,
      updatedAt: now,
      createdAt: application.createdAt ?? now,
      signedDocuments: {for (final p in packets) p.type.shortKey: p.toPublicJson()},
      directoryConsent: true,
    );

    final termsAt = packets
        .where((p) => p.type == LegalDocumentType.termsOfService)
        .map((p) => p.signedAt.toUtc().toIso8601String())
        .firstOrNull;

    await _applicationsCollection.doc(application.id).set({
      ...websiteFields(submitted),
      'governing_documents_ack': {
        'terms_of_service_read_at': termsAt,
        'privacy_policy_read_at': termsAt,
      },
    });
  }

  /// The application as the website writes it: the app's own fields plus the
  /// website's names for the same data, so either client reads the record.
  static Map<String, dynamic> websiteFields(MembershipApplication application) {
    return {
      ...application.toJson(),
      'job_title': application.currentJobTitle,
      'education': {
        'level': application.highestEducationLevel,
        'level_other': application.educationLevelOther,
        'field_of_study': application.fieldOfStudy,
        'institution': application.institution,
        'year_obtained': int.tryParse(application.yearQualificationObtained ?? ''),
      },
    };
  }

  /// The signed-in applicant's application that was rejected, if any — a
  /// re-application revises that record in place rather than adding another.
  Future<MembershipApplication?> findRejectedApplication(String userId) async {
    final snapshot = await _applicationsCollection.where('user_id', isEqualTo: userId).get();
    for (final doc in snapshot.docs) {
      final application = MembershipApplication.fromJson(doc.data());
      if (application.status == ApplicationStatus.rejected) return application;
    }
    return null;
  }

  /// Notes that a generated sign-in password was emailed, as the website does.
  Future<void> markCredentialsIssued(String applicationId) async {
    await _applicationsCollection.doc(applicationId).update({
      'credentials_issued_at': DateTime.now().toUtc().toIso8601String(),
    });
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

  /// Get application by email or phone to check verification status for account registration
  Future<MembershipApplication?> getApplicationByEmailOrPhone(String identifier) async {
    final clean = identifier.trim().toLowerCase();
    final emailQuery = await _applicationsCollection.where('email_address', isEqualTo: clean).limit(1).get();
    if (emailQuery.docs.isNotEmpty) {
      return MembershipApplication.fromJson(emailQuery.docs.first.data());
    }

    final phoneQuery = await _applicationsCollection.where('phone_number_primary', isEqualTo: identifier.trim()).limit(1).get();
    if (phoneQuery.docs.isNotEmpty) {
      return MembershipApplication.fromJson(phoneQuery.docs.first.data());
    }

    return null;
  }

  /// Finds an existing application already registered against [ghanaCardNumber].
  ///
  /// One Ghana Card backs one membership: with card images no longer collected,
  /// the number is the only thing distinguishing one identity from another, so
  /// letting it repeat would let a single person hold several memberships.
  ///
  /// [excludingUserId] lets a member re-submit their own number without being
  /// told it is taken.
  Future<MembershipApplication?> findApplicationByGhanaCardNumber(
    String ghanaCardNumber, {
    String? excludingUserId,
  }) async {
    final normalised = GhanaCard.normalise(ghanaCardNumber);
    if (normalised == null) return null;

    final querySnapshot =
        await _applicationsCollection.where('ghana_card_number', isEqualTo: normalised).limit(5).get();

    for (final doc in querySnapshot.docs) {
      final application = MembershipApplication.fromJson(doc.data());
      if (excludingUserId != null && application.userId == excludingUserId) continue;
      return application;
    }

    return null;
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
  ///
  /// [quote] re-snapshots the itemised fee, because an applicant can change
  /// which optional kit items they are taking up to the moment they pay.
  Future<void> submitPaymentEvidence({
    required String applicationId,
    required String evidenceUrl,
    String? reference,
    required PaymentSettings settings,
    required FeeQuote quote,
  }) async {
    final now = DateTime.now();
    await _applicationsCollection.doc(applicationId).update({
      'payment_method': PaymentMethod.momo.value,
      'payment_status': PaymentStatus.pendingVerification.value,
      'payment_currency': settings.currency,
      'payment_evidence_url': evidenceUrl,
      if (reference != null && reference.isNotEmpty) 'payment_reference': reference,
      'payment_momo_network': settings.network.value,
      'payment_momo_number': settings.momoNumber,
      'payment_submitted_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      ...feeQuoteFields(quote),
    });
  }

  /// The itemised fee fields written onto a `members` document.
  ///
  /// Shared by the submission and the pay-later paths, and named exactly as the
  /// website writes them, so one record reads the same from either client.
  static Map<String, dynamic> feeQuoteFields(FeeQuote quote) {
    return {
      'payment_amount': quote.total,
      'payment_registration_fee': quote.registrationFee,
      'payment_annual_dues': quote.annualDues,
      'payment_optional_total': quote.optionalTotal,
      'payment_optional_items': quote.optionalItems.map((e) => e.toJson()).toList(),
      'payment_registration_components': quote.registrationComponents.map((e) => e.toJson()).toList(),
    };
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
