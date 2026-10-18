import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/tcda/tcda_party.dart';
import 'package:cqaag_app/services/tcda/tcda_licence_service.dart';

void main() {
  group('Step 2: TCDA Licence Verification Engine (Tests 2.1 - 2.20)', () {
    test('Test 2.1: 6 TCDA licence states defined with correct display names', () {
      expect(TcdaLicenceState.unverified.displayName, 'UNVERIFIED');
      expect(TcdaLicenceState.verified.displayName, 'VERIFIED');
      expect(TcdaLicenceState.check.displayName, 'CHECK');
      expect(TcdaLicenceState.expiresSoon.displayName, 'EXPIRES SOON');
      expect(TcdaLicenceState.expired.displayName, 'EXPIRED');
      expect(TcdaLicenceState.blocked.displayName, 'BLOCKED');
    });

    test('Test 2.2: isSelectable is false strictly for expired and blocked parties', () {
      expect(TcdaLicenceState.verified.isSelectable, isTrue);
      expect(TcdaLicenceState.check.isSelectable, isTrue);
      expect(TcdaLicenceState.expiresSoon.isSelectable, isTrue);
      expect(TcdaLicenceState.unverified.isSelectable, isTrue);
      expect(TcdaLicenceState.expired.isSelectable, isFalse);
      expect(TcdaLicenceState.blocked.isSelectable, isFalse);
    });

    test('Test 2.3: Party dynamically evaluates to expired when expiryDate is past', () {
      final pastParty = TcdaParty(
        id: 'party-01',
        name: 'Past Trader Ltd',
        partyType: 'buyer',
        tcdaLicenceNumber: 'TCDA/BUY/2025/001',
        expiryDate: DateTime.now().subtract(const Duration(days: 5)),
        state: TcdaLicenceState.verified,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      );

      expect(pastParty.effectiveState, TcdaLicenceState.expired);
      expect(pastParty.isBlockedOrExpired, isTrue);
    });

    test('Test 2.4: Party evaluates to expiresSoon when expiry is within 30 days', () {
      final soonParty = TcdaParty(
        id: 'party-02',
        name: 'Soon Trader Ltd',
        partyType: 'seller',
        tcdaLicenceNumber: 'TCDA/SEL/2026/045',
        expiryDate: DateTime.now().add(const Duration(days: 15)),
        state: TcdaLicenceState.verified,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      );

      expect(soonParty.effectiveState, TcdaLicenceState.expiresSoon);
      expect(soonParty.isBlockedOrExpired, isFalse);
    });

    test('Test 2.5: Foreign Consignee is marked "Not applicable, outside Ghana" and exempt from TCDA', () {
      final foreignConsignee = TcdaParty(
        id: 'party-03',
        name: 'Vietnam Cashew Processors JSC',
        partyType: 'consignee',
        tcdaLicenceNumber: 'Not applicable, outside Ghana',
        isForeign: true,
        state: TcdaLicenceState.verified,
        createdAt: DateTime.now(),
      );

      expect(foreignConsignee.isForeign, isTrue);
      expect(foreignConsignee.isBlockedOrExpired, isFalse);

      final service = TcdaLicenceService();
      // Should not throw exception
      expect(() => service.validatePartyForTransaction(foreignConsignee), returnsNormally);
    });

    test('Test 2.6: Transaction validation throws TcdaLicenceBlockedException for expired/blocked parties', () {
      final blockedParty = TcdaParty(
        id: 'party-04',
        name: 'Suspended Aggregator Ltd',
        partyType: 'aggregator',
        tcdaLicenceNumber: 'TCDA/AGG/2026/099',
        state: TcdaLicenceState.blocked,
        blockedReason: 'Revoked by TCDA directive',
        createdAt: DateTime.now(),
      );

      final service = TcdaLicenceService();
      expect(
        () => service.validatePartyForTransaction(blockedParty),
        throwsA(isA<TcdaLicenceBlockedException>()),
      );
    });

    test('Test 2.20: Dual-control block lift strictly requires two distinct approvers', () async {
      final service = TcdaLicenceService();
      expect(
        () => service.liftBlockWithTwoPersonApproval(
          partyId: 'party-04',
          reason: 'Review complete',
          firstApproverId: 'officer-01',
          secondApproverId: 'officer-01', // Identical!
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
