import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/services/membership/legacy_register.dart';

void main() {
  group('LegacyRegister Tests', () {
    test('contains exactly 98 legacy members from the official register', () {
      expect(LegacyRegister.allMembers.length, 98);
    });

    test('member IDs follow standardized CQAAG-FM-XXX format', () {
      final first = LegacyRegister.allMembers.first;
      expect(first.number, 1);
      expect(first.memberId, 'CQAAG-FM-001');

      final last = LegacyRegister.allMembers.last;
      expect(last.number, 98);
      expect(last.memberId, 'CQAAG-FM-098');

      // Verify all member IDs are unique
      final ids = LegacyRegister.allMembers.map((m) => m.memberId).toSet();
      expect(ids.length, 98);
    });

    test('findByMemberId resolves correctly case-insensitively', () {
      final m1 = LegacyRegister.findByMemberId('CQAAG-FM-001');
      expect(m1, isNotNull);
      expect(m1?.fullName, 'AMANFO KWABENA EBENEZER');

      final m1Lower = LegacyRegister.findByMemberId('cqaag-fm-001');
      expect(m1Lower, isNotNull);
      expect(m1Lower?.fullName, 'AMANFO KWABENA EBENEZER');

      final m98 = LegacyRegister.findByMemberId('CQAAG-FM-098');
      expect(m98, isNotNull);
      expect(m98?.fullName, 'MASAWUDU SALIFU');

      final unknown = LegacyRegister.findByMemberId('CQAAG-FM-999');
      expect(unknown, isNull);
    });

    test('findByPhone resolves varying Ghanaian phone formats', () {
      // Find a member with known phone, e.g., entry #1: "0553330931"
      final m1 = LegacyRegister.findByPhone('0553330931');
      expect(m1, isNotNull);
      expect(m1?.number, 1);

      // Search with country code +233
      final m1Intl = LegacyRegister.findByPhone('+233553330931');
      expect(m1Intl, isNotNull);
      expect(m1Intl?.number, 1);

      // Search with spaces or dashes
      final m1Formatted = LegacyRegister.findByPhone('055 333-0931');
      expect(m1Formatted, isNotNull);
      expect(m1Formatted?.number, 1);
    });

    test('findByName finds members by full or partial name', () {
      final found = LegacyRegister.findByName('AMANFO KWABENA EBENEZER');
      expect(found, isNotNull);
      expect(found?.number, 1);

      final partial = LegacyRegister.findByName('KWABENA EBENEZER');
      expect(partial, isNotNull);
      expect(partial?.number, 1);
    });

    test('search filters across name, company, district, and region', () {
      // Search by region
      final bonoMembers = LegacyRegister.search('Bono');
      expect(bonoMembers.isNotEmpty, true);

      // Search by company keyword
      final unicomSearch = LegacyRegister.search('UNICOM');
      expect(unicomSearch.isNotEmpty, true);

      // Search by member ID
      final idSearch = LegacyRegister.search('FM-045');
      expect(idSearch.length, 1);
      expect(idSearch.first.number, 45);
    });

    test('toFirestoreMap generates valid Firestore document schema', () {
      final member = LegacyRegister.allMembers.first;
      final map = member.toFirestoreMap();

      expect(map['member_id'], 'CQAAG-FM-001');
      expect(map['membership_category'], 'full');
      expect(map['status'], 'approved');
      expect(map['is_legacy'], true);
      expect(map['is_claimed'], false);
      expect(map['first_name'], 'KWABENA EBENEZER');
      expect(map['last_name'], 'AMANFO');
      expect(map['phone_number_primary'], '0553330931');
      expect(map['card_status'], 'Card issued');
      expect(map['earlier_ghc60_paid'], true);
      expect(map['payment_registration_fee'], 200.0);
    });

    test('card status counts match the official Excel register', () {
      final issuedCount = LegacyRegister.allMembers.where((m) => m.hasCardIssued).length;
      final otherCount = LegacyRegister.allMembers.where((m) => !m.hasCardIssued).length;

      expect(issuedCount, 71);
      expect(otherCount, 27);
    });

    test('paid earlier count matches the 63/35 breakdown', () {
      final paidEarlierCount = LegacyRegister.allMembers.where((m) => m.earlierPaid).length;
      final notPaidEarlierCount = LegacyRegister.allMembers.where((m) => !m.earlierPaid).length;

      expect(paidEarlierCount, 63);
      expect(notPaidEarlierCount, 35);
    });
  });
}
