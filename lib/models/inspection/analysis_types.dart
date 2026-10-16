/// The kinds of quality analysis a certificate can be issued for, and the
/// rules that hang off each under the CQAAG Certificates Design Specification
/// and the CQAAG Certificate Fees and Payment Timing Specification.
class CertificateTypeInfo {
  const CertificateTypeInfo({
    required this.code,
    required this.key,
    required this.englishTitle,
    required this.frenchSubtitle,
    this.frenchSubtitlePage2,
    required this.maxMoisture,
    required this.fixedCuttings,
    required this.requiresApproval,
    required this.requiresSeparateFee,
    required this.feeDescription,
  });

  /// 3-letter code: UAC, DQC, ARB, EZA, EXQ
  final String code;

  /// Internal key / type name
  final String key;

  final String englishTitle;
  final String frenchSubtitle;
  final String? frenchSubtitlePage2;

  /// Moisture threshold: 8.0% for export, 10.0% for upcountry/dispatch/arrival/arbitration
  final double maxMoisture;

  /// Fixed number of cuttings if specified (3 for EXQ), or null if weight-dependent (1 up to 10 t, 2 above)
  final int? fixedCuttings;

  /// Whether the certificate requires approval from National President or General Secretary
  final bool requiresApproval;

  /// Whether a separate certificate fee is charged
  final bool requiresSeparateFee;

  final String feeDescription;

  int cuttingsFor(double quantityTons) {
    if (fixedCuttings != null) return fixedCuttings!;
    return quantityTons > 10.0 ? 2 : 1;
  }
}

class AnalysisTypes {
  AnalysisTypes._();

  // Canonical type keys matching the 5 certificate specifications
  static const String upcountryArrival = 'Upcountry RCN Arrival';
  static const String dispatchQuality = 'RCN Dispatch Quality';
  static const String arbitration = 'RCN Arbitration';
  static const String exportZoneArrival = 'Export Zone RCN Arrival';
  static const String exportQuality = 'RCN Export Quality';

  // Legacy aliases for backward compatibility with existing records
  static const String arrivalUpcountry = 'Arrival Upcountry Warehouse';
  static const String moistureControl = 'Moisture Control';
  static const String dispatch = 'Dispatch';
  static const String arrivalPort = 'Arrival Port Warehouse';
  static const String export = 'Export';

  /// Default/fallback certificate fee in Ghana Cedis
  static const double reportFeeCedis = 100.0;

  /// Types whose certificate was traditionally marked as paid
  static const Set<String> paid = {
    export,
    moistureControl,
    dispatch,
    arbitration,
    dispatchQuality,
    exportQuality,
  };

  /// Standard list offered on the inspection form
  static const List<String> all = [
    upcountryArrival,
    dispatchQuality,
    arbitration,
    exportZoneArrival,
    exportQuality,
    moistureControl,
  ];

  static const CertificateTypeInfo uac = CertificateTypeInfo(
    code: 'UAC',
    key: upcountryArrival,
    englishTitle: 'UPCOUNTRY RCN ARRIVAL CERTIFICATE',
    frenchSubtitle: 'Certificat de qualité à l’arrivée – entrepôt de l’intérieur',
    maxMoisture: 10.0,
    fixedCuttings: null, // 1 up to 10 t; 2 above
    requiresApproval: false,
    requiresSeparateFee: false,
    feeDescription: 'Covered by Moisture Pass fee (no separate certificate fee)',
  );

  static const CertificateTypeInfo dqc = CertificateTypeInfo(
    code: 'DQC',
    key: dispatchQuality,
    englishTitle: 'RCN DISPATCH QUALITY CERTIFICATE',
    frenchSubtitle: 'Certificat de qualité à l’expédition',
    maxMoisture: 10.0,
    fixedCuttings: null, // 1 up to 10 t; 2 above
    requiresApproval: false,
    requiresSeparateFee: true,
    feeDescription: 'GH₵300 per truck of 45 t (due when moisture ≤ 10.0%)',
  );

  static const CertificateTypeInfo arb = CertificateTypeInfo(
    code: 'ARB',
    key: arbitration,
    englishTitle: 'RCN ARBITRATION CERTIFICATE',
    frenchSubtitle: 'Certificat d’arbitrage de qualité',
    frenchSubtitlePage2: 'Certificat d’arbitrage de qualité – procédure et règlement',
    maxMoisture: 10.0,
    fixedCuttings: null, // 1 up to 10 t; 2 above
    requiresApproval: false,
    requiresSeparateFee: true,
    feeDescription: 'GH₵300 per dossier (paid by claimant at request)',
  );

  static const CertificateTypeInfo eza = CertificateTypeInfo(
    code: 'EZA',
    key: exportZoneArrival,
    englishTitle: 'EXPORT ZONE RCN ARRIVAL CERTIFICATE',
    frenchSubtitle: 'Certificat de qualité à l’arrivée – zone d’exportation',
    maxMoisture: 10.0,
    fixedCuttings: null, // 1 up to 10 t; 2 above
    requiresApproval: false,
    requiresSeparateFee: false,
    feeDescription: 'No separate fee (included with dispatch reading)',
  );

  static const CertificateTypeInfo exq = CertificateTypeInfo(
    code: 'EXQ',
    key: exportQuality,
    englishTitle: 'RCN EXPORT QUALITY CERTIFICATE',
    frenchSubtitle: 'Certificat de qualité à l’exportation – noix de cajou brutes',
    frenchSubtitlePage2: 'Certificat de qualité à l’exportation – suite',
    maxMoisture: 8.0,
    fixedCuttings: 3, // Exactly 3 cuttings
    requiresApproval: true,
    requiresSeparateFee: true,
    feeDescription: 'GH₵10 per tonne of net weight (Draft D1 is free)',
  );

  /// Resolves any analysis type string (including legacy ones) to its specification info.
  static CertificateTypeInfo resolve(String? type) {
    if (type == null) return uac;
    final normalized = type.trim().toLowerCase();

    if (normalized.contains('eza') ||
        normalized.contains('zone') ||
        (normalized.contains('arrival') && normalized.contains('port')) ||
        (normalized.contains('export') && normalized.contains('arrival'))) {
      return eza;
    }
    if (normalized.contains('exq') || normalized.contains('export')) {
      return exq;
    }
    if (normalized.contains('dqc') || normalized.contains('dispatch')) {
      return dqc;
    }
    if (normalized.contains('arb') || normalized.contains('arbitrat')) {
      return arb;
    }
    return uac;
  }

  /// 3-letter code for the certificate (UAC, DQC, ARB, EZA, EXQ)
  static String code(String? type) => resolve(type).code;

  static String englishTitle(String? type) => resolve(type).englishTitle;

  static String frenchSubtitle(String? type, {int page = 1}) {
    final info = resolve(type);
    if (page > 1 && info.frenchSubtitlePage2 != null) {
      return info.frenchSubtitlePage2!;
    }
    return info.frenchSubtitle;
  }

  static double maxMoisture(String? type) => resolve(type).maxMoisture;

  static int requiredCuttings(String? type, {double quantityTons = 0}) {
    return resolve(type).cuttingsFor(quantityTons);
  }

  /// Calculates certificate fee according to `CQAAG_Certificate_Fees_and_Payment_Timing.pdf`:
  /// - DQC: GH₵ 300.0 (flat per truck of 45 t)
  /// - ARB: GH₵ 300.0 (flat per dossier)
  /// - EXQ: GH₵ 10.0 per tonne on net weight (draft D1 is free)
  /// - UAC / EZA: GH₵ 0.0
  static double feeFor(String? type, {double quantityTons = 0, double netWeightKg = 0}) {
    if (type != null && type.trim().toLowerCase().contains('moisture')) {
      return 100.0;
    }
    final info = resolve(type);
    if (!info.requiresSeparateFee) return 0.0;

    if (info.code == 'DQC') {
      return 300.0;
    }
    if (info.code == 'ARB') {
      return 300.0;
    }
    if (info.code == 'EXQ') {
      final tons = quantityTons > 0
          ? quantityTons
          : (netWeightKg > 0 ? (netWeightKg / 1000.0) : 25.0);
      return double.parse((tons * 10.0).toStringAsFixed(2));
    }
    return 0.0;
  }

  static bool isExport(String? type) => resolve(type).code == 'EXQ';

  static bool requiresPayment(String? type) {
    if (type == null) return false;
    final normalized = type.trim().toLowerCase();
    if (normalized.contains('moisture')) return true;
    return resolve(type).requiresSeparateFee;
  }

  /// Only Export certificates go to the CQAAG approval desk for the
  /// National President / General Secretary official navy stamp and signature.
  static bool requiresApproval(String? type) => resolve(type).requiresApproval;

  /// Generates a standardized certificate number conforming to
  /// `CQAAG-{type}-{year}-{six digits}` (e.g. `CQAAG-UAC-2026-000123`).
  static String formatCertificateNumber(
    String? type, {
    int? year,
    required int sequence,
    bool isDraft = false,
    int draftIndex = 1,
  }) {
    final typeCode = code(type);
    final y = year ?? DateTime.now().year;
    final padded = sequence.toString().padLeft(6, '0');
    final base = 'CQAAG-$typeCode-$y-$padded';
    if (isDraft && typeCode == 'EXQ') {
      return '$base-D$draftIndex';
    }
    return base;
  }

  /// QR verification URL format:
  /// `https://cqaaggh.org/c/{number}?s={hash}`
  static String verificationUrl(String certificateNumber, {String? hash}) {
    final shortHash = (hash != null && hash.isNotEmpty)
        ? (hash.length > 8 ? hash.substring(0, 8) : hash)
        : '00000000';
    return 'https://cqaaggh.org/c/$certificateNumber?s=$shortHash';
  }
}
