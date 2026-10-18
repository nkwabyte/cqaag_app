import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/services/inspection/cutting_calculation_service.dart';
import 'package:cqaag_app/models/user/app_user.dart';
import 'package:cqaag_app/models/tcda/tcda_party.dart';

void main() {
  group('Phase 4: Step 6 - Arrival Cutting & Certificate Issuance Rules', () {
    test('Test 6.2: Single-cut and multi-cut statutory KOR, defectives and averages calculation', () {
      // Cut 1: 1000g sample, 200 nuts, 250g good, 20g spotted, 10g immature, 15g insect, 5g void, 10g diseased, 5g oily
      // usable = 250 + 0.5*20 + 0.5*10 = 265g
      // KOR = 265 * (80 / 453.59237) / 1.0 = 265 * 0.1763698 = 46.74 lbs
      // defective = 15 + 5 + 10 + 5 = 35g -> 3.50%
      final cut1 = CuttingCalculationService.calculateSingleCut(
        sampleWeightGrams: 1000.0,
        nutCount: 200,
        goodKernelsGrams: 250.0,
        spottedKernelsGrams: 20.0,
        immatureKernelsGrams: 10.0,
        oilyKernelsGrams: 5.0,
        insectDamagedGrams: 15.0,
        voidNutsGrams: 5.0,
        diseasedNutsGrams: 10.0,
      );

      expect(cut1['usableKernelWeightGrams'], equals(265.0));
      expect(cut1['kor'], equals(46.74));
      expect(cut1['defectivesPercent'], equals(3.50));
      expect(cut1['nutCount'], equals(200.0));

      // Cut 2
      final cut2 = CuttingCalculationService.calculateSingleCut(
        sampleWeightGrams: 1000.0,
        nutCount: 202,
        goodKernelsGrams: 260.0,
        spottedKernelsGrams: 10.0,
        immatureKernelsGrams: 10.0,
        oilyKernelsGrams: 4.0,
        insectDamagedGrams: 10.0,
        voidNutsGrams: 6.0,
        diseasedNutsGrams: 5.0,
      );

      final averages = CuttingCalculationService.calculateCuttingAverages([cut1, cut2]);
      expect(averages['count'], equals(2));
      expect(averages['averageNutCount'], equals(201));
      expect(averages['averageKor'], isNotNull);
      expect(averages['averageDefectives'], isNotNull);
    });

    test('Test 6.9: Member in hibernation cannot sign a certificate', () {
      final hibernatedAnalyst = AppUser(
        id: 'user_hibernated',
        firstName: 'Kwame',
        lastName: 'Mensah',
        email: 'kwame@cqaaggh.org',
        role: 'analyst',
        membershipStatus: MembershipStatus.hibernated,
      );

      final validParty = TcdaParty(
        id: 'tcda_1',
        name: 'Cashew Traders Ltd',
        partyType: 'seller',
        tcdaLicenceNumber: 'TCDA/CS/2026/001',
        isForeign: false,
        state: TcdaLicenceState.verified,
        createdAt: DateTime.now(),
      );

      expect(
        () => CuttingCalculationService.validateCertificateIssuance(
          analyst: hibernatedAnalyst,
          vehiclePlate: 'AS 4452-24',
          seller: validParty,
          buyer: validParty,
        ),
        throwsA(isA<CuttingCalculationException>().having(
          (e) => e.code,
          'code',
          'ANALYST_HIBERNATED',
        )),
      );
    });

    test('Test 6.10: Vehicle number is mandatory on every certificate and cannot be empty', () {
      final activeAnalyst = AppUser(
        id: 'user_active',
        firstName: 'Kwame',
        lastName: 'Mensah',
        email: 'kwame@cqaaggh.org',
        role: 'analyst',
        membershipStatus: MembershipStatus.active,
      );

      final validParty = TcdaParty(
        id: 'tcda_1',
        name: 'Cashew Traders Ltd',
        partyType: 'seller',
        tcdaLicenceNumber: 'TCDA/CS/2026/001',
        isForeign: false,
        state: TcdaLicenceState.verified,
        createdAt: DateTime.now(),
      );

      expect(
        () => CuttingCalculationService.validateCertificateIssuance(
          analyst: activeAnalyst,
          vehiclePlate: '   ',
          seller: validParty,
          buyer: validParty,
        ),
        throwsA(isA<CuttingCalculationException>().having(
          (e) => e.code,
          'code',
          'VEHICLE_PLATE_REQUIRED',
        )),
      );
    });

    test('Test 6.5: Ghanaian party with EXPIRED or BLOCKED licence stops certificate issue', () {
      final activeAnalyst = AppUser(
        id: 'user_active',
        firstName: 'Kwame',
        lastName: 'Mensah',
        email: 'kwame@cqaaggh.org',
        role: 'analyst',
        membershipStatus: MembershipStatus.active,
      );

      final validParty = TcdaParty(
        id: 'tcda_1',
        name: 'Cashew Traders Ltd',
        partyType: 'seller',
        tcdaLicenceNumber: 'TCDA/CS/2026/001',
        isForeign: false,
        state: TcdaLicenceState.verified,
        createdAt: DateTime.now(),
      );

      final expiredParty = TcdaParty(
        id: 'tcda_2',
        name: 'Old Export Co',
        partyType: 'exporter',
        tcdaLicenceNumber: 'TCDA/EX/2023/044',
        isForeign: false,
        state: TcdaLicenceState.expired,
        createdAt: DateTime.now(),
      );

      // Blocked seller
      expect(
        () => CuttingCalculationService.validateCertificateIssuance(
          analyst: activeAnalyst,
          vehiclePlate: 'NR 1209-23',
          seller: expiredParty,
          buyer: validParty,
        ),
        throwsA(isA<CuttingCalculationException>().having(
          (e) => e.code,
          'code',
          'SELLER_TCDA_BLOCKED',
        )),
      );

      // Foreign party with no TCDA licence does NOT block
      final foreignParty = TcdaParty(
        id: 'tcda_foreign',
        name: 'Vietnam Kernel Processors Inc',
        partyType: 'exporter',
        tcdaLicenceNumber: 'VN-IMPORT-88',
        isForeign: true,
        state: TcdaLicenceState.verified,
        createdAt: DateTime.now(),
      );

      expect(
        () => CuttingCalculationService.validateCertificateIssuance(
          analyst: activeAnalyst,
          vehiclePlate: 'NR 1209-23',
          seller: validParty,
          buyer: foreignParty,
        ),
        returnsNormally,
      );
    });

    test('Test 6.16: Certificate color palette mapping', () {
      expect(CuttingCalculationService.getCertificateColorHex('UAC'), equals('1D4ED8')); // Blue
      expect(CuttingCalculationService.getCertificateColorHex('DQC'), equals('7C3AED')); // Purple
      expect(CuttingCalculationService.getCertificateColorHex('ARB'), equals('92400E')); // Brown
      expect(CuttingCalculationService.getCertificateColorHex('EZA'), equals('EA580C')); // Orange
      expect(CuttingCalculationService.getCertificateColorHex('EXQ'), equals('059669')); // Sea Green
    });
  });
}
