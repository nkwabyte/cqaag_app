import 'dart:math';

class IdUtils {
  /// Generate Q.C ID in format: INSP-XXX
  /// where XXX is the inspection count + 1
  static String generateQcId(int inspectionCount) {
    final nextNumber = inspectionCount + 1;
    return 'INSP-$nextNumber';
  }

  /// Generate Batch ID in format: BATCH-GH-{COMPANY_INITIALS}-XXX
  /// where XXX is the inspection count + 1
  static String generateBatchId(String company, int inspectionCount) {
    final initials = _getCompanyInitials(company);
    final nextNumber = inspectionCount + 1;
    return 'BATCH-GH-$initials-$nextNumber';
  }

  /// Extract company initials from company name
  /// Examples:
  /// - "Olam Ghana Ltd" -> "OLAM"
  /// - "Ghana Cashew Board" -> "GCB"
  /// - "ABC" -> "ABC"
  static String _getCompanyInitials(String company) {
    if (company.isEmpty) return 'UNKNOWN';

    final trimmed = company.trim();

    // If company name is already short (3 chars or less), use it as-is
    if (trimmed.length <= 5) {
      return trimmed.toUpperCase();
    }

    // Split by spaces and take first letter of each word
    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length > 1) {
      // Multi-word company: take first letter of each word (max 4 letters)
      final initials = words.take(4).map((word) => word.isNotEmpty ? word[0].toUpperCase() : '').where((char) => char.isNotEmpty).join();
      return initials.isNotEmpty ? initials : trimmed.substring(0, 3).toUpperCase();
    }

    // Single word company: take first 4 uppercase letters
    return trimmed.substring(0, trimmed.length > 4 ? 4 : trimmed.length).toUpperCase();
  }

  /// Legacy method for backward compatibility
  /// Generates a unique inspection ID with timestamp
  static String generateInspectionId() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    // Generate 4 random uppercase letters/numbers
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final randomStr = List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();

    return 'INS-$year$month$day-$randomStr';
  }

  /// Generate a unique Document ID (similar to Firestore auto-id)
  static String generateDocId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(20, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
