import 'package:cqaag_app/models/membership/membership_category.dart';
import 'package:cqaag_app/models/payment/fee_schedule.dart';
import 'package:cqaag_app/utils/ghana_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeeSchedule defaults match the Board fee schedule', () {
    final schedule = FeeSchedule.defaults;

    test('Registration Fee is 250 for every fee-paying category', () {
      for (final category in FeeCategory.values) {
        if (category.isExempt) continue;
        expect(schedule.registrationFeeFor(category), 250, reason: category.label);
      }
      expect(schedule.registrationFeeFor(FeeCategory.honorary), 0);
    });

    test('Annual Dues follow Art. 2 as amended', () {
      expect(schedule.annualDuesFor(FeeCategory.full), 200);
      // Half of Full Membership dues.
      expect(schedule.annualDuesFor(FeeCategory.nationalAssociate), 100);
      expect(schedule.annualDuesFor(FeeCategory.corporate), 100);
      // Board-determined special rate, overriding the half-dues rule.
      expect(schedule.annualDuesFor(FeeCategory.foreignAssociate), 1000);
      expect(schedule.annualDuesFor(FeeCategory.honorary), 0);
    });

    test('Grand Totals reproduce the schedule spreadsheet', () {
      expect(schedule.grandTotalFor(FeeCategory.full), 520);
      expect(schedule.grandTotalFor(FeeCategory.nationalAssociate), 420);
      expect(schedule.grandTotalFor(FeeCategory.foreignAssociate), 1320);
      expect(schedule.grandTotalFor(FeeCategory.corporate), 350);
      expect(schedule.grandTotalFor(FeeCategory.honorary), 0);
    });

    test('only priced optional items are offered', () {
      // Gloves are the one kit item the Board has priced so far.
      expect(
        schedule.optionalItemsFor(FeeCategory.full).map((e) => e.key),
        ['gloves'],
      );
      // Corporate members are priced at zero for gloves, so nothing is offered.
      expect(schedule.optionalItemsFor(FeeCategory.corporate), isEmpty);
      expect(schedule.optionalItemsFor(FeeCategory.honorary), isEmpty);

      // The unpriced items are surfaced separately, not silently dropped.
      expect(schedule.unpricedOptionalItemsFor(FeeCategory.full).length, 7);
    });
  });

  group('FeeQuote charges only what was chosen', () {
    final schedule = FeeSchedule.defaults;

    test('declining every optional item leaves the mandatory total', () {
      final quote = schedule.quote(FeeCategory.full);
      expect(quote.optionalTotal, 0);
      expect(quote.total, 450); // 250 registration + 200 dues
    });

    test('taking an optional item adds exactly its price', () {
      final gloves = schedule.optionalItemsFor(FeeCategory.full).single;
      final quote = schedule.quote(
        FeeCategory.full,
        selectedOptionalItems: [
          SelectedFeeItem(key: gloves.key, label: gloves.label, amount: gloves.amountFor(FeeCategory.full)!),
        ],
      );
      expect(quote.optionalTotal, 70);
      expect(quote.total, 520);
    });

    test('Honorary Members are never charged, even for a chosen item', () {
      final quote = schedule.quote(
        FeeCategory.honorary,
        selectedOptionalItems: const [SelectedFeeItem(key: 'gloves', label: 'gloves', amount: 70)],
      );
      expect(quote.total, 0);
      expect(quote.optionalItems, isEmpty);
    });
  });

  group('membership categories map onto the right schedule column', () {
    test('mapping follows the amended Constitution', () {
      expect(FeeCategory.fromMembership(MembershipCategory.full), FeeCategory.full);
      expect(FeeCategory.fromMembership(MembershipCategory.associate), FeeCategory.nationalAssociate);
      expect(FeeCategory.fromMembership(MembershipCategory.fullForeign), FeeCategory.foreignAssociate);
      expect(FeeCategory.fromMembership(MembershipCategory.corporate), FeeCategory.corporate);
      expect(FeeCategory.fromMembership(MembershipCategory.honorary), FeeCategory.honorary);
    });

    test('only Full Members vote; foreign associates are still TCDA-eligible', () {
      expect(MembershipCategory.full.hasVotingRights, isTrue);
      expect(MembershipCategory.fullForeign.hasVotingRights, isFalse);
      expect(MembershipCategory.fullForeign.isTcdaLicensingEligible, isTrue);
      expect(MembershipCategory.associate.isTcdaLicensingEligible, isFalse);
    });
  });

  group('FeeSchedule survives a Firestore round trip', () {
    test('an edited schedule reads back identically', () {
      final edited = FeeSchedule.defaults.copyWith(
        annualDues: {...FeeSchedule.defaults.annualDues, 'full': 275},
      );
      final restored = FeeSchedule.fromJson(edited.toJson());

      expect(restored.annualDuesFor(FeeCategory.full), 275);
      expect(restored.registrationFeeFor(FeeCategory.full), 250);
      expect(restored.grandTotalFor(FeeCategory.full), 595);
    });

    test('an unpriced item stays unpriced rather than becoming free', () {
      final restored = FeeSchedule.fromJson(FeeSchedule.defaults.toJson());
      final boot = restored.optionalItems.firstWhere((e) => e.key == 'safety_boot');

      expect(boot.amountFor(FeeCategory.full), isNull);
      expect(boot.isAvailableTo(FeeCategory.full), isFalse);
      expect(boot.requiresSize, isTrue);
    });

    test('a partial document falls back to the Board defaults', () {
      final restored = FeeSchedule.fromJson({});
      expect(restored.grandTotalFor(FeeCategory.full), 520);
    });
  });

  group('GhanaCard', () {
    test('accepts only the GHA-#########-# structure', () {
      expect(GhanaCard.isValid('GHA-123456789-0'), isTrue);
      expect(GhanaCard.isValid('GHA-12345678-0'), isFalse); // eight digits
      expect(GhanaCard.isValid('GHA-1234567890'), isFalse); // no second hyphen
      expect(GhanaCard.isValid('GH-123456789-0'), isFalse); // wrong prefix
      expect(GhanaCard.isValid('GHA-12345678A-0'), isFalse); // letter in body
      expect(GhanaCard.isValid(null), isFalse);
      expect(GhanaCard.isValid(''), isFalse);
    });

    test('normalises loose input so the same card matches itself', () {
      const canonical = 'GHA-123456789-0';
      expect(GhanaCard.normalise('gha-123456789-0'), canonical);
      expect(GhanaCard.normalise('GHA1234567890'), canonical);
      expect(GhanaCard.normalise(' GHA-123456789-0 '), canonical);
      expect(GhanaCard.normalise('1234567890'), canonical);
      // Too few or too many digits cannot be repaired into a real number.
      expect(GhanaCard.normalise('GHA-12345-0'), isNull);
      expect(GhanaCard.normalise('GHA-12345678901-0'), isNull);
    });

    test('reports a blank number differently when it is optional', () {
      expect(GhanaCard.validationError('GHA-'), isNotNull);
      expect(GhanaCard.validationError('GHA-', required: false), isNull);
      expect(GhanaCard.validationError('GHA-123456789-0'), isNull);
      expect(GhanaCard.validationError('GHA-123-0'), isNotNull);
    });
  });
}
