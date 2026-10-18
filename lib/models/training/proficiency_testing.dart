import 'package:cqaag_app/models/membership/membership_category.dart';

/// Training Course Model (Spec Section 18–19, Tests 22.1–22.3).
class TrainingCourse {
  const TrainingCourse({
    required this.id,
    required this.title,
    required this.targetCategories,
    required this.capacity,
    required this.confirmedSeats,
    required this.waitingList,
    required this.fee,
    this.isOpenToPublic = false,
  });

  final String id;
  final String title;

  /// Target membership categories. Empty means open to all.
  final List<MembershipCategory> targetCategories;
  final int capacity;
  final List<String> confirmedSeats;
  final List<WaitingListEntry> waitingList;
  final double fee;
  final bool isOpenToPublic;

  bool get isFull => confirmedSeats.length >= capacity;

  /// Test 22.1: Course visibility filtering based on membership category.
  bool isVisibleTo({MembershipCategory? userCategory, bool isGuest = false}) {
    if (isGuest && isOpenToPublic) return true;
    if (isOpenToPublic) return true;
    if (userCategory == null) return false;
    if (targetCategories.isEmpty) return true;
    return targetCategories.contains(userCategory);
  }

  /// Test 22.2: Enroll applicant or put on waiting list if full without charge.
  TrainingCourse enroll({required String applicantId, required bool paymentConfirmed}) {
    if (isFull) {
      // Put on waiting list without charging
      final entry = WaitingListEntry(applicantId: applicantId, addedAt: DateTime.now().toUtc());
      return TrainingCourse(
        id: id,
        title: title,
        targetCategories: targetCategories,
        capacity: capacity,
        confirmedSeats: confirmedSeats,
        waitingList: [...waitingList, entry],
        fee: fee,
        isOpenToPublic: isOpenToPublic,
      );
    }

    if (!paymentConfirmed) {
      // Unconfirmed payment does not receive a confirmed seat
      return this;
    }

    return TrainingCourse(
      id: id,
      title: title,
      targetCategories: targetCategories,
      capacity: capacity,
      confirmedSeats: [...confirmedSeats, applicantId],
      waitingList: waitingList,
      fee: fee,
      isOpenToPublic: isOpenToPublic,
    );
  }
}

class WaitingListEntry {
  const WaitingListEntry({
    required this.applicantId,
    required this.addedAt,
    this.offerExpiresAt,
  });

  final String applicantId;
  final DateTime addedAt;
  final DateTime? offerExpiresAt;
}

/// Proficiency Test Round Model (Spec Section 11, Tests 22.4–22.5).
class ProficiencyRound {
  const ProficiencyRound({
    required this.id,
    required this.roundNumber,
    required this.sampleBatchCode,
    required this.isOpen,
    this.referenceMoisture,
    this.moistureTolerance,
    this.referenceKor,
    this.korTolerance,
    this.referenceNutCount,
    this.nutCountTolerance,
    this.submissions = const {},
  });

  final String id;
  final int roundNumber;
  final String sampleBatchCode;
  final bool isOpen;

  final double? referenceMoisture;
  final double? moistureTolerance;

  final double? referenceKor;
  final double? korTolerance;

  final int? referenceNutCount;
  final int? nutCountTolerance;

  /// Map of analyst ID -> Submission
  final Map<String, ProficiencySubmission> submissions;

  /// Test 22.4: Analyst enters result once; second entry is strictly refused.
  ProficiencyRound submitResult({
    required String analystId,
    required double moisture,
    required double kor,
    required int nutCount,
    DateTime? timestamp,
  }) {
    if (submissions.containsKey(analystId)) {
      throw StateError("A second entry is refused. An analyst may only submit once per round (Test 22.4).");
    }

    final sub = ProficiencySubmission(
      analystId: analystId,
      moisture: moisture,
      kor: kor,
      nutCount: nutCount,
      submittedAt: timestamp ?? DateTime.now().toUtc(),
    );

    return ProficiencyRound(
      id: id,
      roundNumber: roundNumber,
      sampleBatchCode: sampleBatchCode,
      isOpen: isOpen,
      referenceMoisture: referenceMoisture,
      moistureTolerance: moistureTolerance,
      referenceKor: referenceKor,
      korTolerance: korTolerance,
      referenceNutCount: referenceNutCount,
      nutCountTolerance: nutCountTolerance,
      submissions: {...submissions, analystId: sub},
    );
  }

  /// Test 22.5: Evaluate result for a specific analyst with strict peer isolation.
  ProficiencyEvaluation evaluateForAnalyst(String analystId) {
    final sub = submissions[analystId];
    if (sub == null) {
      throw ArgumentError("No submission found for analyst $analystId");
    }

    if (referenceMoisture == null || moistureTolerance == null ||
        referenceKor == null || korTolerance == null ||
        referenceNutCount == null || nutCountTolerance == null) {
      return ProficiencyEvaluation(
        analystSubmission: sub,
        status: "PENDING_REFERENCE",
        isPass: false,
      );
    }

    final moistureDiff = (sub.moisture - referenceMoisture!).abs();
    final korDiff = (sub.kor - referenceKor!).abs();
    final nutCountDiff = (sub.nutCount - referenceNutCount!).abs();

    final isPass = (moistureDiff <= moistureTolerance!) &&
        (korDiff <= korTolerance!) &&
        (nutCountDiff <= nutCountTolerance!);

    // Calculate median across all submissions
    final allMoistures = submissions.values.map((s) => s.moisture).toList()..sort();
    final medianMoisture = allMoistures[allMoistures.length ~/ 2];

    final allKors = submissions.values.map((s) => s.kor).toList()..sort();
    final medianKor = allKors[allKors.length ~/ 2];

    final allNutCounts = submissions.values.map((s) => s.nutCount).toList()..sort();
    final medianNutCount = allNutCounts[allNutCounts.length ~/ 2];

    return ProficiencyEvaluation(
      analystSubmission: sub,
      status: isPass ? "PROFICIENT" : "TO RETRAIN",
      isPass: isPass,
      referenceMoisture: referenceMoisture,
      referenceKor: referenceKor,
      referenceNutCount: referenceNutCount,
      medianMoisture: medianMoisture,
      medianKor: medianKor,
      medianNutCount: medianNutCount,
    );
  }
}

class ProficiencySubmission {
  const ProficiencySubmission({
    required this.analystId,
    required this.moisture,
    required this.kor,
    required this.nutCount,
    required this.submittedAt,
  });

  final String analystId;
  final double moisture;
  final double kor;
  final int nutCount;
  final DateTime submittedAt;
}

class ProficiencyEvaluation {
  const ProficiencyEvaluation({
    required this.analystSubmission,
    required this.status,
    required this.isPass,
    this.referenceMoisture,
    this.referenceKor,
    this.referenceNutCount,
    this.medianMoisture,
    this.medianKor,
    this.medianNutCount,
  });

  final ProficiencySubmission analystSubmission;
  final String status; // "PROFICIENT" or "TO RETRAIN"
  final bool isPass;
  final double? referenceMoisture;
  final double? referenceKor;
  final int? referenceNutCount;
  final double? medianMoisture;
  final double? medianKor;
  final int? medianNutCount;
}

/// Yearly Quality Inspection Renewal State Evaluator (Test 22.6).
class YearlyRenewalEvaluator {
  /// Test 22.6: 31 December deadline, 90-day grace banner, locked after day 90.
  static RenewalStatus evaluateStatus({
    required DateTime lastRenewalYearEnd,
    required DateTime currentDate,
    required bool committeeRenewalRecorded,
  }) {
    if (committeeRenewalRecorded) {
      return RenewalStatus.active;
    }

    final yearEnd = DateTime(lastRenewalYearEnd.year, 12, 31, 23, 59, 59);
    if (currentDate.isBefore(yearEnd)) {
      return RenewalStatus.active;
    }

    final graceEnd = yearEnd.add(const Duration(days: 90));
    if (currentDate.isBefore(graceEnd)) {
      return RenewalStatus.gracePeriodWarning; // Amber banner: Renewal required within 90 days
    }

    return RenewalStatus.locked; // Features locked: Quality Inspection locked unrenewed
  }
}

enum RenewalStatus {
  active,
  gracePeriodWarning,
  locked,
}

/// Practice Sandbox Mode Evaluator (Spec Section 20, Tests 22.8–22.10).
class PracticeModeEvaluator {
  /// Test 22.8: A practice Moisture Control prints POS with line PRACTICE and NO QR code.
  /// No fee is asked, and no SMS or email is sent.
  static Map<String, dynamic> generatePracticePassReceipt({
    required String lotCode,
    required double moisture,
  }) {
    return {
      'header': 'CASHEW QUALITY ASSESSORS ASSOCIATION GHANA',
      'watermark': 'PRACTICE',
      'lot_code': 'PRACTICE-$lotCode',
      'moisture': moisture,
      'has_qr_code': false, // Strictly NO QR code on practice POS (Test 22.8)
      'fee_amount': 0.0,    // No fee asked
      'dispatch_sms': false, // No SMS sent
      'dispatch_email': false, // No email sent
      'is_practice': true,
      'auto_delete_days': 30, // Purged after 30 days (Test 22.9)
    };
  }

  /// Test 22.9: Practice checks appear in no dashboard, report, rating, or lot chain.
  static bool shouldIncludeInOfficialLedger(bool isPractice) => !isPractice;
}
