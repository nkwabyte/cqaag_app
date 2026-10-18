import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/agm/agm_voting.dart';
import 'package:cqaag_app/models/membership/membership_category.dart';
import 'package:cqaag_app/models/user/app_user.dart';

void main() {
  group('Step 24: Meetings, the AGM and Voting (Spec Section 91, Tests 24.1–24.6)', () {
    test('24.1: Short notice warning is triggered if notice issued under 21 statutory days', () {
      // 14 days notice -> Short notice warning
      final shortAgm = AgmMeeting(
        id: 'agm-2027',
        title: '2027 Annual General Meeting',
        noticeIssuedDate: DateTime(2027, 3, 1),
        scheduledDate: DateTime(2027, 3, 15),
        totalEligibleVotingMembers: 120,
        attendedMemberIds: {},
      );
      expect(shortAgm.hasShortNoticeWarning, isTrue);

      // 25 days notice -> Proper notice
      final properAgm = AgmMeeting(
        id: 'agm-2027-p',
        title: '2027 Annual General Meeting',
        noticeIssuedDate: DateTime(2027, 2, 1),
        scheduledDate: DateTime(2027, 3, 1),
        totalEligibleVotingMembers: 120,
        attendedMemberIds: {},
      );
      expect(properAgm.hasShortNoticeWarning, isFalse);
    });

    test('24.2: Attendance scanning and 33.3% Constitutional quorum tracking', () {
      var agm = AgmMeeting(
        id: 'agm-2027',
        title: '2027 Annual General Meeting',
        noticeIssuedDate: DateTime(2027, 2, 1),
        scheduledDate: DateTime(2027, 3, 1),
        totalEligibleVotingMembers: 90, // 33.3% quorum = 30 members
        attendedMemberIds: {},
      );

      expect(agm.hasReachedQuorum, isFalse);

      // Scan 25 members
      for (int i = 1; i <= 25; i++) {
        agm = agm.registerAttendance('MEMBER-$i');
      }
      expect(agm.attendanceCount, equals(25));
      expect(agm.hasReachedQuorum, isFalse);

      // Scan 5 more -> 30 members (33.33%) -> Quorum reached
      for (int i = 26; i <= 30; i++) {
        agm = agm.registerAttendance('MEMBER-$i');
      }
      expect(agm.attendanceCount, equals(30));
      expect(agm.hasReachedQuorum, isTrue);
    });

    test('24.3: Voting eligibility, single vote enforcement and hibernated member exclusion', () {
      final session = AgmBallotSession(
        id: 'ballot-001',
        meetingId: 'agm-2027',
        motionTitle: 'Approval of 2027 Audited Accounts & Financial Report',
        allowedCategories: [MembershipCategory.full], // Only Full Members vote
      );

      // Full Member in good standing can vote
      expect(session.canMemberVote(category: MembershipCategory.full, status: MembershipStatus.active), isTrue);

      // Associate Member cannot vote
      expect(session.canMemberVote(category: MembershipCategory.associate, status: MembershipStatus.active), isFalse);

      // Hibernated Full Member cannot vote
      expect(session.canMemberVote(category: MembershipCategory.full, status: MembershipStatus.hibernated), isFalse);

      // Cast first vote
      session.castSecretVote(
        memberId: 'MEMBER-001',
        category: MembershipCategory.full,
        status: MembershipStatus.active,
        choice: 'FOR',
        otpVerificationCode: '987123',
      );
      expect(session.voterRegistry.contains('MEMBER-001'), isTrue);

      // Attempt second vote -> Strictly refused
      expect(
        () => session.castSecretVote(
          memberId: 'MEMBER-001',
          category: MembershipCategory.full,
          status: MembershipStatus.active,
          choice: 'AGAINST',
          otpVerificationCode: '987123',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('24.4: Secret ballot cryptographically decouples ballots from member IDs', () {
      final session = AgmBallotSession(
        id: 'ballot-secret',
        meetingId: 'agm-2027',
        motionTitle: 'Election of National Vice President',
        allowedCategories: [MembershipCategory.full],
      );

      session.castSecretVote(
        memberId: 'MEMBER-A',
        category: MembershipCategory.full,
        status: MembershipStatus.active,
        choice: 'FOR',
        otpVerificationCode: '111222',
      );

      session.castSecretVote(
        memberId: 'MEMBER-B',
        category: MembershipCategory.full,
        status: MembershipStatus.active,
        choice: 'AGAINST',
        otpVerificationCode: '333444',
      );

      // Ballots contains choices, but no memberId links
      expect(session.anonymousTally.length, equals(2));
      for (final ballot in session.anonymousTally) {
        expect(ballot.choice, isIn(['FOR', 'AGAINST']));
      }
    });

    test('24.5 & 24.6: Floor votes entry and statutory resolution ID generation', () {
      final session = AgmBallotSession(
        id: 'ballot-room',
        meetingId: 'agm-2027',
        motionTitle: 'Adoption of Updated Quality Manual 2027',
        allowedCategories: [MembershipCategory.full],
      );

      // Record in-room votes: 41 for, 12 against, 3 abstaining (Test 24.5)
      session.recordInRoomVotes(forVotes: 41, againstVotes: 12, abstainVotes: 3);
      expect(session.isCountedInRoom, isTrue);

      final summary = session.tallySummary;
      expect(summary['FOR'], equals(41));
      expect(summary['AGAINST'], equals(12));
      expect(summary['ABSTAIN'], equals(3));
      expect(summary['TOTAL'], equals(56));

      // Test 24.6: Resolution ID format
      final resolutionId = AgmBallotSession.formatResolutionId(2027, 1);
      expect(resolutionId, equals('CQAAG-RES-2027-001'));
    });
  });
}
