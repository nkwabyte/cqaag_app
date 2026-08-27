import 'dart:math';

class IdUtils {
  /// QC ID number should be unique for every QC and MUST NOT change per report.
  /// Generates or resolves the fixed QC ID from the user's ID or QC Code.
  static String getPermanentQcId({String? existingQcCode, String? userId}) {
    if (existingQcCode != null && existingQcCode.trim().isNotEmpty) {
      return existingQcCode.trim().toUpperCase();
    }
    if (userId != null && userId.trim().isNotEmpty) {
      final shortId = userId.length >= 6 ? userId.substring(0, 6).toUpperCase() : userId.toUpperCase();
      return 'CQAAG-QC-$shortId';
    }
    return 'CQAAG-QC-001';
  }

  /// Generate unique Ticket Code: TCK-YYYYMMDD-XXXX
  static String generateTicketCode() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final randomStr = List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();

    return 'TCK-$year$month$day-$randomStr';
  }

  /// Legacy method for backward compatibility
  static String generateQcId(int inspectionCount) {
    final nextNumber = inspectionCount + 1;
    return 'CQAAG-QC-${nextNumber.toString().padLeft(3, '0')}';
  }

  /// Generate Batch ID in format: BATCH-GH-{COMPANY_INITIALS}-XXX
  /// where XXX is the inspection count + 1
  static String generateBatchId(String company, int inspectionCount) {
    final initials = _getCompanyInitials(company);
    final nextNumber = inspectionCount + 1;
    return 'BATCH-GH-$initials-$nextNumber';
  }

  /// Extract company initials from company name
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
      final initials = words.take(4).map((word) => word.isNotEmpty ? word[0].toUpperCase() : '').where((char) => char.isNotEmpty).join();
      return initials.isNotEmpty ? initials : trimmed.substring(0, 3).toUpperCase();
    }

    return trimmed.substring(0, trimmed.length > 4 ? 4 : trimmed.length).toUpperCase();
  }

  /// Generates a unique inspection ID with timestamp
  static String generateInspectionId() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

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
