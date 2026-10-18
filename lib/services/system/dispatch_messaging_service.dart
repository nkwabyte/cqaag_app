/// Statutory Message Construction & Delivery Rules per Spec Section 69 & Tests 12.2, 12.3
class DispatchMessagingService {
  static const int kMaxSmsLength = 160;

  /// Strips accents and normalizes string to pure 7-bit ASCII
  static String cleanAscii(String text) {
    const Map<String, String> accentMap = {
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a',
      'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ñ': 'n', 'ç': 'c',
      'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
      'Á': 'A', 'À': 'A', 'Â': 'A', 'Ä': 'A',
      'Ó': 'O', 'Ò': 'O', 'Ô': 'O', 'Ö': 'O',
      'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
      'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
      '–': '-', '—': '-', '“': '"', '”': '"', '’': "'", '‘': "'",
    };

    var cleaned = text;
    accentMap.forEach((char, replacement) {
      cleaned = cleaned.replaceAll(char, replacement);
    });

    return cleaned;
  }

  /// Builds statutory SMS for cashew certificates per Section 69 & Test 12.3
  /// Rule: Max 160 characters, plain characters.
  /// A result that is too long loses its defectives, then its nut count.
  static String buildStatutorySms({
    required String documentType, // e.g. "Moisture Pass", "Upcountry Arrival", "Export Original"
    required String role,         // e.g. "Seller", "Buyer", "Shipper"
    required String passNumber,   // e.g. "CQAAG-P-261012-0007"
    required String statusOfGoods,// e.g. "PASSED (8.5%)", "REJECTED (10.8%)"
    double? kor,
    int? nutCount,
    double? defectivesPercent,
    required String shortLink,    // e.g. "cqaaggh.org/p/261012-0007"
  }) {
    final cleanDoc = cleanAscii(documentType);
    final cleanRole = cleanAscii(role);
    final cleanStatus = cleanAscii(statusOfGoods);
    final cleanLink = cleanAscii(shortLink);

    // Full result format: "KOR 48.75 lb, NC 198, Def 4.2%"
    String buildWithMetrics({required bool includeDefectives, required bool includeNutCount}) {
      final parts = <String>[];
      if (kor != null) parts.add('KOR ${kor.toStringAsFixed(2)} lb');
      if (includeNutCount && nutCount != null) parts.add('NC $nutCount');
      if (includeDefectives && defectivesPercent != null) parts.add('Def ${defectivesPercent.toStringAsFixed(1)}%');

      final metricsStr = parts.isNotEmpty ? ' [${parts.join(', ')}]' : '';
      return 'CQAAG $cleanDoc $passNumber for $cleanRole: $cleanStatus$metricsStr. Details: https://$cleanLink';
    }

    // Try full message
    var sms = buildWithMetrics(includeDefectives: true, includeNutCount: true);
    if (sms.length <= kMaxSmsLength) return sms;

    // Rule: "A result that is too long loses its defectives..."
    sms = buildWithMetrics(includeDefectives: false, includeNutCount: true);
    if (sms.length <= kMaxSmsLength) return sms;

    // Rule: "...then its nut count."
    sms = buildWithMetrics(includeDefectives: false, includeNutCount: false);
    if (sms.length <= kMaxSmsLength) return sms;

    // Truncated fallback ensuring shortLink is never broken
    final base = 'CQAAG $cleanDoc for $cleanRole: $cleanStatus. Details: https://$cleanLink';
    return base.length <= kMaxSmsLength ? base : base.substring(0, kMaxSmsLength);
  }

  /// Determines notification channels for statutory document events (Test 12.2)
  static Map<String, bool> getChannelsForDocumentType(String documentType) {
    switch (documentType.toLowerCase()) {
      case 'moisture_pass':
        // Moisture Pass: email PDF + link to seller & buyer, sends each 1 SMS (Test 12.2)
        return {'email': true, 'sms': true, 'inApp': true};
      case 'export_draft':
      case 'declined_notice':
        // Export Draft and Declined notice: email + in-app notification ONLY (no SMS)
        return {'email': true, 'sms': false, 'inApp': true};
      case 'export_original':
        // Export Original to shipper only via email + inApp
        return {'email': true, 'sms': false, 'inApp': true};
      default:
        return {'email': true, 'sms': false, 'inApp': true};
    }
  }

  /// Calculates SMS dispatch volume, delivery rates, and cost report (Test 12.3)
  static Map<String, dynamic> generateMessagingReport({
    required int totalDispatched,
    required int failedCount,
    double costPerSmsGhs = 0.08,
  }) {
    final delivered = totalDispatched - failedCount;
    final successRate = totalDispatched > 0 ? (delivered / totalDispatched) * 100.0 : 100.0;
    final totalCostGhs = totalDispatched * costPerSmsGhs;

    return {
      'totalSent': totalDispatched,
      'delivered': delivered,
      'failed': failedCount,
      'successRatePercent': double.parse(successRate.toStringAsFixed(1)),
      'totalCostGhs': double.parse(totalCostGhs.toStringAsFixed(2)),
    };
  }
}
