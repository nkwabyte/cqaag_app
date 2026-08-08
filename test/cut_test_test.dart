import 'package:flutter_test/flutter_test.dart';

import 'package:cqaag_app/models/inspection/cut_test.dart';

/// Figures taken from the association's RCN Quality Report spreadsheet
/// (Benphila Company Limited, certificate 002) so the app's arithmetic is
/// checked against a sheet the analysts already trust.
const sawla = CutTest(
  index: 1,
  label: 'Sawla',
  moistureContent: 8,
  nutCount: 182,
  fullyDamagedNuts: 55,
  voidNuts: 14,
  oilNuts: 0,
  spottedNuts: 14,
  immatureNuts: 6,
  goodKernels: 272,
  emptyShells: 636,
);

const sampa = CutTest(
  index: 2,
  label: 'Sampa',
  moistureContent: 10,
  nutCount: 161,
  fullyDamagedNuts: 67,
  voidNuts: 6,
  oilNuts: 0,
  spottedNuts: 13,
  immatureNuts: 3,
  goodKernels: 269,
  emptyShells: 640,
);

const drobo = CutTest(
  index: 3,
  label: 'Drobo',
  moistureContent: 10,
  nutCount: 170,
  fullyDamagedNuts: 69,
  voidNuts: 2,
  oilNuts: 4,
  spottedNuts: 16,
  immatureNuts: 12,
  goodKernels: 262,
  emptyShells: 632,
);

void main() {
  group('CutTest derived figures match the reference sheet', () {
    test('Sawla column', () {
      expect(sawla.totalDamaged, 69);
      expect(sawla.totalSpotted, 20);
      expect(sawla.halfTotalSpotted, 10);
      expect(sawla.totalYield, 282);
      expect(sawla.total, 997);
      expect(sawla.kor, closeTo(49.632, 0.001));
    });

    test('Sampa column', () {
      expect(sampa.totalDamaged, 73);
      expect(sampa.totalSpotted, 16);
      expect(sampa.totalYield, 277);
      expect(sampa.total, 998);
      expect(sampa.kor, closeTo(48.752, 0.001));
    });

    test('Drobo column', () {
      expect(drobo.totalDamaged, 75);
      expect(drobo.totalSpotted, 28);
      expect(drobo.totalYield, 276);
      expect(drobo.total, 997);
      expect(drobo.kor, closeTo(48.576, 0.001));
    });
  });

  group('AVERAGE column', () {
    final all = [sawla, sampa, drobo];

    test('averages the three cut tests as the sheet does', () {
      expect(all.averageMoisture, closeTo(9.33, 0.01));
      expect(all.averageNutCount, closeTo(171.00, 0.01));
      expect(all.averageFullyDamaged, closeTo(63.67, 0.01));
      expect(all.averageVoidNuts, closeTo(7.33, 0.01));
      expect(all.averageOilNuts, closeTo(1.33, 0.01));
      expect(all.averageTotalDamaged, closeTo(72.33, 0.01));
      expect(all.averageSpotted, closeTo(14.33, 0.01));
      expect(all.averageImmature, closeTo(7.00, 0.01));
      expect(all.averageTotalSpotted, closeTo(21.33, 0.01));
      expect(all.averageHalfTotalSpotted, closeTo(10.67, 0.01));
      expect(all.averageGoodKernels, closeTo(267.67, 0.01));
      expect(all.averageTotalYield, closeTo(278.33, 0.01));
      expect(all.averageEmptyShells, closeTo(636.00, 0.01));
      expect(all.averageTotal, closeTo(997.33, 0.01));
      expect(all.averageKor, closeTo(48.99, 0.01));
    });

    test('a single cut test averages to itself', () {
      final one = [sawla];
      expect(one.averageTotalYield, sawla.totalYield);
      expect(one.averageKor, sawla.kor);
      expect(one.averageMoisture, sawla.moistureContent);
    });

    test('two cut tests average only those two', () {
      final two = [sawla, sampa];
      expect(two.averageTotalYield, closeTo((282 + 277) / 2, 0.001));
      expect(two.averageKor, closeTo((49.632 + 48.752) / 2, 0.001));
    });

    test('no cut tests yields zero rather than throwing', () {
      expect(<CutTest>[].averageKor, 0);
      expect(<CutTest>[].averageTotalYield, 0);
    });
  });

  // Rules as stated by the association, checked against the EAK EBAKOP
  // certificate. Its printed OUTTURN of 46.2 lbs is an independent check: that
  // figure is only reachable from a TOTAL YIELD of 262.5, which is why the
  // 254.0 printed on that certificate was wrong.
  group('report arithmetic rules', () {
    const eak = CutTest(
      index: 1,
      moistureContent: 15,
      nutCount: 148,
      fullyDamagedNuts: 49,
      voidNuts: 14,
      oilNuts: 0,
      spottedNuts: 12,
      immatureNuts: 5,
      goodKernels: 254,
      emptyShells: 666,
    );

    test('first TOTAL = fully damaged + void + oil', () {
      expect(eak.totalDamaged, 63);
      expect(eak.totalDamaged, eak.fullyDamagedNuts + eak.voidNuts + eak.oilNuts);
    });

    test('second TOTAL = spotted + immature', () {
      expect(eak.totalSpotted, 17);
      expect(eak.totalSpotted, eak.spottedNuts + eak.immatureNuts);
    });

    test('50% of above TOTAL is half of spotted + immature', () {
      expect(eak.halfTotalSpotted, 8.5);
      expect(eak.halfTotalSpotted, (eak.spottedNuts + eak.immatureNuts) / 2);
    });

    test('TOTAL YIELD = good kernels + half of spotted + immature', () {
      expect(eak.totalYield, 262.5);
      expect(eak.totalYield, eak.goodKernels + eak.halfTotalSpotted);
      // Guards the bug where total yield was printed as good kernels alone.
      expect(eak.totalYield, isNot(eak.goodKernels));
    });

    test('OUTTURN matches the figure printed on the certificate', () {
      expect(eak.kor, closeTo(46.2, 0.05));
    });

    test('final TOTAL = empty shells + good + void + fully damaged + oil + spotted + immature', () {
      expect(eak.total, 1000);
      expect(
        eak.total,
        eak.emptyShells +
            eak.goodKernels +
            eak.voidNuts +
            eak.fullyDamagedNuts +
            eak.oilNuts +
            eak.spottedNuts +
            eak.immatureNuts,
      );
    });

    test('empty shells is carried through rather than dropped', () {
      const withoutShells = CutTest(index: 1, goodKernels: 254);
      expect(withoutShells.total, 254);
      expect(eak.total - withoutShells.total, 746);
    });
  });

  group('labels', () {
    test('falls back to ordinal naming when no location is given', () {
      expect(const CutTest(index: 1).displayLabel, '1st Cutting');
      expect(const CutTest(index: 2).displayLabel, '2nd Cutting');
      expect(const CutTest(index: 3).displayLabel, '3rd Cutting');
    });

    test('prefers the sample location when supplied', () {
      expect(sawla.displayLabel, 'Sawla');
    });

    test('treats a whitespace-only label as absent', () {
      expect(const CutTest(index: 1, label: '   ').displayLabel, '1st Cutting');
    });
  });

  group('isEmpty', () {
    test('is true for an untouched cut test so it can be dropped', () {
      expect(const CutTest(index: 3).isEmpty, isTrue);
    });

    test('is false once any measurement is entered', () {
      expect(const CutTest(index: 3, goodKernels: 1).isEmpty, isFalse);
    });
  });
}
