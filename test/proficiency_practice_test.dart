import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/membership/membership_category.dart';
import 'package:cqaag_app/models/training/proficiency_testing.dart';

void main() {
  group('Step 22: Training, Proficiency Testing, Tour & Practice Mode (Spec Section 18–20)', () {
    test('22.1: Course visibility is filtered by membership category and public status', () {
      final associateCourse = TrainingCourse(
        id: 'c-assoc-01',
        title: 'National Associate Upcountry QC Fundamentals',
        targetCategories: [MembershipCategory.associate],
        capacity: 20,
        confirmedSeats: [],
        waitingList: [],
        fee: 300.0,
        isOpenToPublic: false,
      );

      final publicCourse = TrainingCourse(
        id: 'c-pub-01',
        title: 'Cashew Post-Harvest & Drying Best Practices',
        targetCategories: [],
        capacity: 50,
        confirmedSeats: [],
        waitingList: [],
        fee: 150.0,
        isOpenToPublic: true,
      );

      // Public course is visible to guest and members
      expect(publicCourse.isVisibleTo(isGuest: true), isTrue);
      expect(publicCourse.isVisibleTo(userCategory: MembershipCategory.full), isTrue);

      // Associate course is visible to Associate, but hidden from Full Member
      expect(associateCourse.isVisibleTo(userCategory: MembershipCategory.associate), isTrue);
      expect(associateCourse.isVisibleTo(userCategory: MembershipCategory.full), isFalse);
      expect(associateCourse.isVisibleTo(isGuest: true), isFalse);
    });

    test('22.2: When course capacity is full, next applicant goes to waiting list without paying', () {
      var course = TrainingCourse(
        id: 'c-01',
        title: 'Moisture Calibration Lab Workshop',
        targetCategories: [MembershipCategory.full],
        capacity: 2,
        confirmedSeats: ['MEMBER-1', 'MEMBER-2'],
        waitingList: [],
        fee: 250.0,
      );

      expect(course.isFull, isTrue);

      // Next applicant tries to enroll
      course = course.enroll(applicantId: 'MEMBER-3', paymentConfirmed: false);
      expect(course.confirmedSeats.length, equals(2));
      expect(course.waitingList.length, equals(1));
      expect(course.waitingList.first.applicantId, equals('MEMBER-3'));
    });

    test('22.4: Analyst can enter proficiency result once; second submission is refused', () {
      var round = const ProficiencyRound(
        id: 'rnd-2026-01',
        roundNumber: 1,
        sampleBatchCode: 'PT-RCN-2026-A',
        isOpen: true,
      );

      round = round.submitResult(
        analystId: 'ANALYST-007',
        moisture: 9.1,
        kor: 48.5,
        nutCount: 185,
      );

      expect(round.submissions.containsKey('ANALYST-007'), isTrue);

      // Attempting second submission throws StateError
      expect(
        () => round.submitResult(
          analystId: 'ANALYST-007',
          moisture: 9.2,
          kor: 48.6,
          nutCount: 184,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('22.5: Proficiency evaluation checks tolerances, returns TO RETRAIN with peer isolation', () {
      var round = const ProficiencyRound(
        id: 'rnd-2026-02',
        roundNumber: 2,
        sampleBatchCode: 'PT-RCN-2026-B',
        isOpen: true,
        referenceMoisture: 8.5,
        moistureTolerance: 0.5, // 8.0 - 9.0
        referenceKor: 49.0,
        korTolerance: 1.0,     // 48.0 - 50.0
        referenceNutCount: 180,
        nutCountTolerance: 10, // 170 - 190
      );

      // Analyst 1: Within tolerance (Pass / PROFICIENT)
      round = round.submitResult(analystId: 'A1', moisture: 8.7, kor: 49.2, nutCount: 178);

      // Analyst 2: Moisture outside tolerance (9.4 > 9.0 -> TO RETRAIN)
      round = round.submitResult(analystId: 'A2', moisture: 9.4, kor: 49.0, nutCount: 180);

      // Analyst 3: Within tolerance
      round = round.submitResult(analystId: 'A3', moisture: 8.4, kor: 48.5, nutCount: 182);

      final eval1 = round.evaluateForAnalyst('A1');
      expect(eval1.isPass, isTrue);
      expect(eval1.status, equals('PROFICIENT'));

      final eval2 = round.evaluateForAnalyst('A2');
      expect(eval2.isPass, isFalse);
      expect(eval2.status, equals('TO RETRAIN'));
      expect(eval2.referenceMoisture, equals(8.5));
      expect(eval2.medianMoisture, equals(8.7));
    });

    test('22.6: Yearly renewal passes 31 Dec: 90-day grace banner, locked after day 90', () {
      final year2026 = DateTime(2026, 1, 1);

      // Before 31 Dec: Active
      final statusDec20 = YearlyRenewalEvaluator.evaluateStatus(
        lastRenewalYearEnd: year2026,
        currentDate: DateTime(2026, 12, 20),
        committeeRenewalRecorded: false,
      );
      expect(statusDec20, equals(RenewalStatus.active));

      // In 90-day grace period (e.g. 15 February 2027): Grace period warning
      final statusFeb15 = YearlyRenewalEvaluator.evaluateStatus(
        lastRenewalYearEnd: year2026,
        currentDate: DateTime(2027, 2, 15),
        committeeRenewalRecorded: false,
      );
      expect(statusFeb15, equals(RenewalStatus.gracePeriodWarning));

      // After 90 days (e.g. 5 April 2027): Locked
      final statusApr5 = YearlyRenewalEvaluator.evaluateStatus(
        lastRenewalYearEnd: year2026,
        currentDate: DateTime(2027, 4, 5),
        committeeRenewalRecorded: false,
      );
      expect(statusApr5, equals(RenewalStatus.locked));

      // When Committee records renewal: Reopens immediately
      final statusRenewed = YearlyRenewalEvaluator.evaluateStatus(
        lastRenewalYearEnd: year2026,
        currentDate: DateTime(2027, 4, 5),
        committeeRenewalRecorded: true,
      );
      expect(statusRenewed, equals(RenewalStatus.active));
    });

    test('22.8 & 22.9: Practice mode POS receipt has PRACTICE, no QR code, no fee, and is isolated', () {
      final receipt = PracticeModeEvaluator.generatePracticePassReceipt(
        lotCode: '261018-0001',
        moisture: 8.6,
      );

      expect(receipt['watermark'], equals('PRACTICE'));
      expect(receipt['has_qr_code'], isFalse); // No QR code
      expect(receipt['fee_amount'], equals(0.0)); // No fee
      expect(receipt['dispatch_sms'], isFalse); // No SMS
      expect(receipt['dispatch_email'], isFalse); // No email
      expect(receipt['auto_delete_days'], equals(30)); // 30-day purge

      // Test 22.9: Excluded from official lot chain & dashboard
      expect(PracticeModeEvaluator.shouldIncludeInOfficialLedger(true), isFalse);
      expect(PracticeModeEvaluator.shouldIncludeInOfficialLedger(false), isTrue);
    });
  });
}
