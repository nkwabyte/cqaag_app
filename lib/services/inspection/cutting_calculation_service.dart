import 'package:cqaag_app/models/user/app_user.dart';
import 'package:cqaag_app/models/tcda/tcda_party.dart';

class CuttingCalculationException implements Exception {
  final String message;
  final String? code;
  CuttingCalculationException(this.message, {this.code});
  @override
  String toString() => message;
}

/// Service implementing CQAAG Statutory 100-Nut Cutting Calculations & Certificate Gates
/// (Spec Section 63.4 & Section 71 / Tests 6.1 - 6.16)
class CuttingCalculationService {
  // Constant factor for 80kg bag in lbs: 80 / 0.45359237 = 176.3698
  // When sample is 1000g: KOR = (W_usable_g / 1000) * (80 / 0.45359237) = W_usable_g * 0.1763698
  static const double kKorFactor = 80.0 / 453.59237;

  /// Calculates KOR, Defectives %, and Nut Count for a single cut-test (Section 63.4)
  static Map<String, double> calculateSingleCut({
    required double sampleWeightGrams,
    required int nutCount,
    required double goodKernelsGrams,
    required double spottedKernelsGrams,
    required double immatureKernelsGrams,
    required double oilyKernelsGrams,
    required double insectDamagedGrams,
    required double voidNutsGrams,
    required double diseasedNutsGrams,
  }) {
    if (sampleWeightGrams <= 0) {
      throw CuttingCalculationException('Sample weight must be greater than zero.', code: 'INVALID_SAMPLE_WEIGHT');
    }

    // Usable kernel weight: Good + 50% Spotted + 50% Immature
    final usableKernelWeight = goodKernelsGrams + (0.5 * spottedKernelsGrams) + (0.5 * immatureKernelsGrams);

    // KOR formula to 2 decimal places: W_usable * 80 / 453.59237 / (sampleWeight / 1000)
    final rawKor = (usableKernelWeight * kKorFactor) / (sampleWeightGrams / 1000.0);
    final kor = double.parse(rawKor.toStringAsFixed(2));

    // Defective nuts weight: Insect damaged + Void + Diseased + Oily
    final defectiveWeight = insectDamagedGrams + voidNutsGrams + diseasedNutsGrams + oilyKernelsGrams;
    final rawDefectives = (defectiveWeight / sampleWeightGrams) * 100.0;
    final defectivesPercent = double.parse(rawDefectives.toStringAsFixed(2));

    return {
      'usableKernelWeightGrams': double.parse(usableKernelWeight.toStringAsFixed(2)),
      'kor': kor,
      'defectivesPercent': defectivesPercent,
      'nutCount': nutCount.toDouble(),
    };
  }

  /// Calculates average metrics across multiple cut-tests (Test 6.2)
  static Map<String, dynamic> calculateCuttingAverages(List<Map<String, double>> cuttings) {
    if (cuttings.isEmpty) {
      return {'averageKor': 0.0, 'averageDefectives': 0.0, 'averageNutCount': 0, 'count': 0};
    }

    double totalKor = 0.0;
    double totalDefectives = 0.0;
    double totalNutCount = 0.0;

    for (final cut in cuttings) {
      totalKor += cut['kor'] ?? 0.0;
      totalDefectives += cut['defectivesPercent'] ?? 0.0;
      totalNutCount += cut['nutCount'] ?? 0.0;
    }

    final n = cuttings.length;
    final avgKor = double.parse((totalKor / n).toStringAsFixed(2));
    final avgDefectives = double.parse((totalDefectives / n).toStringAsFixed(2));
    final avgNutCount = (totalNutCount / n).round();

    return {
      'averageKor': avgKor,
      'averageDefectives': avgDefectives,
      'averageNutCount': avgNutCount,
      'count': n,
    };
  }

  /// Validates statutory requirements before certificate issuance (Tests 6.5, 6.9, 6.10)
  static void validateCertificateIssuance({
    required AppUser analyst,
    required String vehiclePlate,
    required TcdaParty seller,
    required TcdaParty buyer,
  }) {
    // Test 6.9: A member in hibernation cannot sign a certificate
    if (analyst.membershipStatus == MembershipStatus.hibernated) {
      throw CuttingCalculationException(
        'Analyst is currently in HIBERNATION status and cannot sign certificates.',
        code: 'ANALYST_HIBERNATED',
      );
    }

    // Test 6.10: The vehicle number is present on every certificate and cannot be left empty
    if (vehiclePlate.trim().isEmpty) {
      throw CuttingCalculationException(
        'Vehicle registration number is mandatory on all certificates and cannot be empty.',
        code: 'VEHICLE_PLATE_REQUIRED',
      );
    }

    // Test 6.5: Every certificate shows TCDA licence; Ghanaian party EXPIRED or BLOCKED stops issue
    if (!seller.isForeign && seller.isBlockedOrExpired) {
      throw CuttingCalculationException(
        'Seller party ${seller.name} has ${seller.effectiveState.name.toUpperCase()} TCDA licence. Certificate issue is stopped.',
        code: 'SELLER_TCDA_BLOCKED',
      );
    }

    if (!buyer.isForeign && buyer.isBlockedOrExpired) {
      throw CuttingCalculationException(
        'Buyer party ${buyer.name} has ${buyer.effectiveState.name.toUpperCase()} TCDA licence. Certificate issue is stopped.',
        code: 'BUYER_TCDA_BLOCKED',
      );
    }
  }

  /// Color branding definitions per Spec Section 63.7 & Test 6.16
  static String getCertificateColorHex(String code) {
    return switch (code.toUpperCase()) {
      'UAC' => '1D4ED8', // Upcountry Arrival: Blue
      'DQC' => '7C3AED', // Dispatch Quality: Purple
      'ARB' => '92400E', // Arbitration: Brown
      'EZA' => 'EA580C', // Export Zone Arrival: Orange
      'EXQ' => '059669', // Export Quality: Sea Green
      _ => '134E32',     // Default CQAAG Green
    };
  }
}
