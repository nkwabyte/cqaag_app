import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/tcda/tcda_party.dart';
import 'package:cqaag_app/services/cloudinary/cloudinary_service.dart';

class TcdaLicenceBlockedException implements Exception {
  final String message;
  final TcdaParty party;
  TcdaLicenceBlockedException(this.message, this.party);

  @override
  String toString() => message;
}

class TcdaLicenceService {
  final FirebaseFirestore? _firestore;
  final CloudinaryService? _cloudinary;

  TcdaLicenceService({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinary,
  })  : _firestore = firestore,
        _cloudinary = cloudinary;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;
  CloudinaryService get cloudinary => _cloudinary ?? CloudinaryService();

  CollectionReference<Map<String, dynamic>> get _partiesCollection =>
      firestore.collection('tcda_parties');

  /// Quick lookup or live verification of a TCDA licence number
  Future<TcdaParty?> checkLicence(String licenceNumber) async {
    final clean = licenceNumber.trim().toUpperCase();
    if (clean.isEmpty) return null;
    final snap = await _partiesCollection
        .where('tcda_licence_number', isEqualTo: clean)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      return TcdaParty(
        id: 'unregistered',
        name: 'Unverified Party ($clean)',
        partyType: 'commercial',
        tcdaLicenceNumber: clean,
        state: TcdaLicenceState.unverified,
        createdAt: DateTime.now(),
      );
    }
    return TcdaParty.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  /// Saves a party verifying Rule 26.4 Test 1:
  /// "A party cannot be saved without a licence number, an expiry date and a photograph of the licence."
  Future<TcdaParty> saveParty({
    required String name,
    required String partyType,
    required String tcdaLicenceNumber,
    DateTime? expiryDate,
    File? licencePhotoFile,
    String? existingPhotoUrl,
    bool isForeign = false,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Party name is mandatory.');
    }

    if (!isForeign) {
      if (tcdaLicenceNumber.trim().isEmpty) {
        throw ArgumentError('TCDA licence number is required for Ghanaian commercial parties.');
      }
      if (expiryDate == null) {
        throw ArgumentError('Licence expiry date is required.');
      }
      if (licencePhotoFile == null && (existingPhotoUrl == null || existingPhotoUrl.isEmpty)) {
        throw ArgumentError('A photograph of the official TCDA licence is mandatory.');
      }
    }

    String? photoUrl = existingPhotoUrl;
    if (licencePhotoFile != null) {
      photoUrl = await cloudinary.uploadPaymentEvidence(licencePhotoFile);
    }

    final docRef = _partiesCollection.doc();
    final party = TcdaParty(
      id: docRef.id,
      name: cleanName,
      partyType: partyType,
      tcdaLicenceNumber: isForeign ? 'Not applicable, outside Ghana' : tcdaLicenceNumber.trim().toUpperCase(),
      expiryDate: expiryDate,
      licencePhotoUrl: photoUrl,
      state: isForeign ? TcdaLicenceState.verified : TcdaLicenceState.unverified,
      isForeign: isForeign,
      createdAt: DateTime.now(),
    );

    await docRef.set(party.toMap());
    return party;
  }

  /// Validates party eligibility for transaction (Moisture Control, Arrival, Dispatch, Export)
  /// Section 26.4 Test 4: A party whose licence has expired or is blocked cannot be chosen as seller or buyer.
  void validatePartyForTransaction(TcdaParty party) {
    if (party.isForeign) return; // Foreign consignees are exempt

    final effective = party.effectiveState;
    if (effective == TcdaLicenceState.expired) {
      final expiryStr = party.expiryDate != null
          ? '${party.expiryDate!.day}/${party.expiryDate!.month}/${party.expiryDate!.year}'
          : 'Unknown';
      throw TcdaLicenceBlockedException(
        'Transaction Refused: The TCDA licence for "${party.name}" expired on $expiryStr. An expired party cannot participate in any transaction (Spec Section 23 & 26).',
        party,
      );
    }

    if (effective == TcdaLicenceState.blocked) {
      final reason = party.blockedReason ?? 'Unverified past 14 days or revoked by Secretariat';
      throw TcdaLicenceBlockedException(
        'Transaction Blocked: Party "${party.name}" is currently BLOCKED by the Secretariat ($reason). Spec Section 26 Rule 3.',
        party,
      );
    }
  }

  /// Stream of all active parties
  Stream<List<TcdaParty>> getPartiesStream({String? partyType}) {
    Query<Map<String, dynamic>> query = _partiesCollection.orderBy('created_at', descending: true);
    if (partyType != null && partyType != 'all') {
      query = query.where('party_type', isEqualTo: partyType);
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((d) => TcdaParty.fromMap(d.data(), d.id)).toList());
  }

  /// Secretariat action: verify an unverified party (Test 2.12)
  Future<void> verifyParty(String partyId, String verifierUserId) async {
    await _partiesCollection.doc(partyId).update({
      'state': TcdaLicenceState.verified.name,
      'verified_by': verifierUserId,
      'verified_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Secretariat action: mark party not valid / blocked (Test 2.3)
  Future<void> blockParty(String partyId, String reason, String blockedByUserId) async {
    await _partiesCollection.doc(partyId).update({
      'state': TcdaLicenceState.blocked.name,
      'blocked_reason': reason,
      'blocked_by': blockedByUserId,
      'blocked_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Lift block with compulsory dual-control approval (Test 2.20 & Section 88)
  Future<void> liftBlockWithTwoPersonApproval({
    required String partyId,
    required String reason,
    required String firstApproverId,
    required String secondApproverId,
  }) async {
    if (firstApproverId == secondApproverId) {
      throw ArgumentError('Dual-control violation: Second approver must be a distinct officer.');
    }

    final batch = firestore.batch();
    final partyRef = _partiesCollection.doc(partyId);

    batch.update(partyRef, {
      'state': TcdaLicenceState.verified.name,
      'blocked_reason': null,
      'blocked_at': null,
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Record statutory audit event
    final auditRef = firestore.collection('audit_events').doc();
    batch.set(auditRef, {
      'event_type': 'LIFT_TCDA_BLOCK',
      'party_id': partyId,
      'reason': reason,
      'initiator_id': firstApproverId,
      'secondary_approver_id': secondApproverId,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'APPROVED',
    });

    await batch.commit();
  }

  /// Auto-refund mechanism if a party becomes blocked after payment but before issue (Test 2.5)
  Future<void> refundIfBlocked({
    required String paymentId,
    required String partyId,
    required double amount,
  }) async {
    final partyDoc = await _partiesCollection.doc(partyId).get();
    if (!partyDoc.exists) return;

    final party = TcdaParty.fromMap(partyDoc.data()!, partyDoc.id);
    if (party.isBlockedOrExpired) {
      // Issue immediate full refund record
      await firestore.collection('refunds').add({
        'payment_id': paymentId,
        'party_id': partyId,
        'party_name': party.name,
        'amount': amount,
        'reason': 'Party became blocked before issuance (Spec Section 26.4 Test 5)',
        'status': 'REFUNDED_IN_FULL',
        'refunded_at': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Imports TCDA Active Register CSV (Test 2.12)
  /// Matched UNVERIFIED -> VERIFIED; missing -> CHECK (7 days) -> BLOCKED
  Future<Map<String, int>> importTcdaList(List<Map<String, dynamic>> records) async {
    int verifiedCount = 0;
    int flaggedCount = 0;

    final validLicences = <String, DateTime?>{};
    for (final r in records) {
      final lic = (r['licence_number'] ?? r['licence'] ?? '').toString().trim().toUpperCase();
      if (lic.isNotEmpty) {
        final expStr = r['expiry_date']?.toString();
        final exp = expStr != null ? DateTime.tryParse(expStr) : null;
        validLicences[lic] = exp;
      }
    }

    final allPartiesSnap = await _partiesCollection.get();
    final batch = firestore.batch();

    for (final doc in allPartiesSnap.docs) {
      final party = TcdaParty.fromMap(doc.data(), doc.id);
      if (party.isForeign) continue;

      final lic = party.tcdaLicenceNumber.toUpperCase();
      if (validLicences.containsKey(lic)) {
        if (party.state == TcdaLicenceState.unverified || party.state == TcdaLicenceState.check) {
          batch.update(doc.reference, {
            'state': TcdaLicenceState.verified.name,
            'expiry_date': validLicences[lic] != null ? Timestamp.fromDate(validLicences[lic]!) : null,
            'updated_at': FieldValue.serverTimestamp(),
          });
          verifiedCount++;
        }
      } else {
        // Party missing from TCDA active list
        if (party.state == TcdaLicenceState.verified) {
          batch.update(doc.reference, {
            'state': TcdaLicenceState.check.name,
            'updated_at': FieldValue.serverTimestamp(),
          });
          flaggedCount++;
        }
      }
    }

    await batch.commit();
    return {
      'verified': verifiedCount,
      'flagged_check': flaggedCount,
    };
  }
}
