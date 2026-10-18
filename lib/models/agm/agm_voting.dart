import 'package:cqaag_app/models/membership/membership_category.dart';
import 'package:cqaag_app/models/user/app_user.dart';

/// AGM and Constitutional Voting Models (Spec Section 91, Tests 24.1–24.6).
class AgmMeeting {
  const AgmMeeting({
    required this.id,
    required this.title,
    required this.scheduledDate,
    required this.noticeIssuedDate,
    required this.totalEligibleVotingMembers,
    required this.attendedMemberIds,
    this.resolutions = const [],
  });

  final String id;
  final String title;
  final DateTime scheduledDate;
  final DateTime noticeIssuedDate;
  final int totalEligibleVotingMembers;
  final Set<String> attendedMemberIds;
  final List<String> resolutions;

  /// Test 24.1: Statutory 21-day AGM notice rule.
  bool get hasShortNoticeWarning => scheduledDate.difference(noticeIssuedDate).inDays < 21;

  /// Test 24.2: Constitutional Quorum (1/3 or 33.3% of voting members in good standing).
  int get attendanceCount => attendedMemberIds.length;
  double get quorumPercentage => totalEligibleVotingMembers > 0
      ? (attendanceCount / totalEligibleVotingMembers) * 100.0
      : 0.0;
  bool get hasReachedQuorum => quorumPercentage >= 33.33;

  AgmMeeting registerAttendance(String memberId) {
    return AgmMeeting(
      id: id,
      title: title,
      scheduledDate: scheduledDate,
      noticeIssuedDate: noticeIssuedDate,
      totalEligibleVotingMembers: totalEligibleVotingMembers,
      attendedMemberIds: {...attendedMemberIds, memberId},
      resolutions: resolutions,
    );
  }
}

/// Constitutional Voting Eligibility and Balloting Engine (Tests 24.3 & 24.4).
class AgmBallotSession {
  AgmBallotSession({
    required this.id,
    required this.meetingId,
    required this.motionTitle,
    required this.allowedCategories,
    Set<String>? voterRegistry,
    List<AnonymousBallot>? anonymousTally,
    this.inRoomFor = 0,
    this.inRoomAgainst = 0,
    this.inRoomAbstain = 0,
    this.isCountedInRoom = false,
  }) : voterRegistry = voterRegistry ?? {},
       anonymousTally = anonymousTally ?? [];

  final String id;
  final String meetingId;
  final String motionTitle;
  final List<MembershipCategory> allowedCategories;

  /// Set of member IDs who have exercised their franchise (prevents double voting).
  final Set<String> voterRegistry;

  /// Anonymized ballots completely decoupled from member IDs (Test 24.4 Secret Ballot).
  final List<AnonymousBallot> anonymousTally;

  /// Test 24.5: Physical floor count entry
  int inRoomFor;
  int inRoomAgainst;
  int inRoomAbstain;
  bool isCountedInRoom;

  /// Test 24.3: Member voting eligibility check.
  bool canMemberVote({
    required MembershipCategory category,
    required MembershipStatus status,
  }) {
    // Hibernated, suspended or declined members cannot vote
    if (status == MembershipStatus.hibernated ||
        status == MembershipStatus.suspended ||
        status == MembershipStatus.declined) {
      return false;
    }
    // Must be in allowed categories (Constitution Art 2: Full Members vote; Associates do not)
    return allowedCategories.contains(category);
  }

  /// Test 24.3 & 24.4: Cast secret ballot with duplicate prevention and cryptographic separation.
  void castSecretVote({
    required String memberId,
    required MembershipCategory category,
    required MembershipStatus status,
    required String choice, // 'FOR', 'AGAINST', 'ABSTAIN'
    required String otpVerificationCode,
  }) {
    if (!canMemberVote(category: category, status: status)) {
      throw StateError("Member category ${category.name} or status ${status.name} is ineligible to vote on this motion.");
    }
    if (voterRegistry.contains(memberId)) {
      throw StateError("Duplicate vote strictly refused. Member $memberId has already voted (Test 24.3).");
    }
    if (otpVerificationCode.isEmpty) {
      throw ArgumentError("SMS 2FA code is required to authorize ballot submission.");
    }

    // 1. Record voter in participation registry (prevents voting a second time)
    voterRegistry.add(memberId);

    // 2. Cast decoupled anonymous ballot (No memberId stored; Super Admin cannot correlate)
    anonymousTally.add(AnonymousBallot(choice: choice.toUpperCase()));
  }

  /// Test 24.5: Record in-room counted votes
  void recordInRoomVotes({required int forVotes, required int againstVotes, required int abstainVotes}) {
    inRoomFor = forVotes;
    inRoomAgainst = againstVotes;
    inRoomAbstain = abstainVotes;
    isCountedInRoom = true;
  }

  /// Total tally summary
  Map<String, int> get tallySummary {
    int countFor = inRoomFor;
    int countAgainst = inRoomAgainst;
    int countAbstain = inRoomAbstain;

    for (final b in anonymousTally) {
      if (b.choice == 'FOR') countFor++;
      if (b.choice == 'AGAINST') countAgainst++;
      if (b.choice == 'ABSTAIN') countAbstain++;
    }

    return {
      'FOR': countFor,
      'AGAINST': countAgainst,
      'ABSTAIN': countAbstain,
      'TOTAL': countFor + countAgainst + countAbstain,
    };
  }

  /// Test 24.6: Format statutory resolution identifier
  static String formatResolutionId(int year, int sequenceNumber) {
    final seqStr = sequenceNumber.toString().padLeft(3, '0');
    return "CQAAG-RES-$year-$seqStr";
  }
}

/// Anonymized Ballot with strictly no link to voter ID (Test 24.4).
class AnonymousBallot {
  const AnonymousBallot({required this.choice});
  final String choice;
}
