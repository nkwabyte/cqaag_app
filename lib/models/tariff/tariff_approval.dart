enum TariffApprovalStatus {
  waitingApproval,
  approved,
  rejected,
  lapsed,
}

/// Represents a requested change to statutory association tariffs
/// (Spec Section 88.4 / Tests 18.1 - 18.3)
class TariffChangeRequest {
  final String id;
  final String itemKey;
  final String itemName;
  final double oldAmountGhs;
  final double newAmountGhs;
  final DateTime effectiveDate;
  final String reason;
  final String initiatorUserId;
  final String initiatorRole; // e.g. 'Admin'
  final TariffApprovalStatus status;
  final String? approvedByUserId;
  final String? approvedByRole; // e.g. 'Treasurer'
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime? reminderSentAt;
  final DateTime? lapsedAt;
  final List<String> notifiedRoles; // ['President', 'GeneralSecretary']

  const TariffChangeRequest({
    required this.id,
    required this.itemKey,
    required this.itemName,
    required this.oldAmountGhs,
    required this.newAmountGhs,
    required this.effectiveDate,
    required this.reason,
    required this.initiatorUserId,
    required this.initiatorRole,
    this.status = TariffApprovalStatus.waitingApproval,
    this.approvedByUserId,
    this.approvedByRole,
    this.approvedAt,
    required this.createdAt,
    this.reminderSentAt,
    this.lapsedAt,
    this.notifiedRoles = const ['President', 'GeneralSecretary'],
  });

  bool get isWaiting => status == TariffApprovalStatus.waitingApproval;
  bool get isApproved => status == TariffApprovalStatus.approved;
  bool get isLapsed => status == TariffApprovalStatus.lapsed;

  TariffChangeRequest copyWith({
    String? id,
    String? itemKey,
    String? itemName,
    double? oldAmountGhs,
    double? newAmountGhs,
    DateTime? effectiveDate,
    String? reason,
    String? initiatorUserId,
    String? initiatorRole,
    TariffApprovalStatus? status,
    String? approvedByUserId,
    String? approvedByRole,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? reminderSentAt,
    DateTime? lapsedAt,
    List<String>? notifiedRoles,
  }) {
    return TariffChangeRequest(
      id: id ?? this.id,
      itemKey: itemKey ?? this.itemKey,
      itemName: itemName ?? this.itemName,
      oldAmountGhs: oldAmountGhs ?? this.oldAmountGhs,
      newAmountGhs: newAmountGhs ?? this.newAmountGhs,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      reason: reason ?? this.reason,
      initiatorUserId: initiatorUserId ?? this.initiatorUserId,
      initiatorRole: initiatorRole ?? this.initiatorRole,
      status: status ?? this.status,
      approvedByUserId: approvedByUserId ?? this.approvedByUserId,
      approvedByRole: approvedByRole ?? this.approvedByRole,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      reminderSentAt: reminderSentAt ?? this.reminderSentAt,
      lapsedAt: lapsedAt ?? this.lapsedAt,
      notifiedRoles: notifiedRoles ?? this.notifiedRoles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemKey': itemKey,
      'itemName': itemName,
      'oldAmountGhs': oldAmountGhs,
      'newAmountGhs': newAmountGhs,
      'effectiveDate': effectiveDate.toIso8601String(),
      'reason': reason,
      'initiatorUserId': initiatorUserId,
      'initiatorRole': initiatorRole,
      'status': status.name,
      'approvedByUserId': approvedByUserId,
      'approvedByRole': approvedByRole,
      'approvedAt': approvedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'reminderSentAt': reminderSentAt?.toIso8601String(),
      'lapsedAt': lapsedAt?.toIso8601String(),
      'notifiedRoles': notifiedRoles,
    };
  }

  factory TariffChangeRequest.fromJson(Map<String, dynamic> json) {
    return TariffChangeRequest(
      id: json['id'] as String,
      itemKey: json['itemKey'] as String,
      itemName: json['itemName'] as String,
      oldAmountGhs: (json['oldAmountGhs'] as num).toDouble(),
      newAmountGhs: (json['newAmountGhs'] as num).toDouble(),
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      reason: json['reason'] as String,
      initiatorUserId: json['initiatorUserId'] as String,
      initiatorRole: json['initiatorRole'] as String,
      status: TariffApprovalStatus.values.byName(json['status'] as String),
      approvedByUserId: json['approvedByUserId'] as String?,
      approvedByRole: json['approvedByRole'] as String?,
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reminderSentAt: json['reminderSentAt'] != null ? DateTime.parse(json['reminderSentAt'] as String) : null,
      lapsedAt: json['lapsedAt'] != null ? DateTime.parse(json['lapsedAt'] as String) : null,
      notifiedRoles: (json['notifiedRoles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['President', 'GeneralSecretary'],
    );
  }
}

/// Represents a hand refund request (Section 88.4 Test 18.4 & Section 89.3 Test 18.10)
class HandRefundRequest {
  final String id;
  final String receiptOrPassNumber;
  final double amountGhs;
  final String reason;
  final String initiatorUserId;
  final bool isApproved;
  final String? approvedByUserId;
  final DateTime? approvedAt;
  final bool isRefunded;
  final DateTime createdAt;

  const HandRefundRequest({
    required this.id,
    required this.receiptOrPassNumber,
    required this.amountGhs,
    required this.reason,
    required this.initiatorUserId,
    this.isApproved = false,
    this.approvedByUserId,
    this.approvedAt,
    this.isRefunded = false,
    required this.createdAt,
  });

  HandRefundRequest copyWith({
    bool? isApproved,
    String? approvedByUserId,
    DateTime? approvedAt,
    bool? isRefunded,
  }) {
    return HandRefundRequest(
      id: id,
      receiptOrPassNumber: receiptOrPassNumber,
      amountGhs: amountGhs,
      reason: reason,
      initiatorUserId: initiatorUserId,
      isApproved: isApproved ?? this.isApproved,
      approvedByUserId: approvedByUserId ?? this.approvedByUserId,
      approvedAt: approvedAt ?? this.approvedAt,
      isRefunded: isRefunded ?? this.isRefunded,
      createdAt: createdAt,
    );
  }
}

/// Month-end dues reconciliation with 60 / 40 split (Section 89.3 Test 18.11)
class MonthEndDuesSummary {
  final double totalDuesCollectedGhs;
  final double nationalSplitGhs; // 60%
  final double chapterSplitGhs;  // 40%
  final double bankReportedAmountGhs;
  final double differenceGhs;

  MonthEndDuesSummary({
    required this.totalDuesCollectedGhs,
    required this.bankReportedAmountGhs,
  })  : nationalSplitGhs = double.parse((totalDuesCollectedGhs * 0.60).toStringAsFixed(2)),
        chapterSplitGhs = double.parse((totalDuesCollectedGhs * 0.40).toStringAsFixed(2)),
        differenceGhs = double.parse((bankReportedAmountGhs - totalDuesCollectedGhs).toStringAsFixed(2));
}
