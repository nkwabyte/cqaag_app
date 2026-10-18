
enum OutboxItemType {
  moistureControl,
  weighingSlip,
  plantReport,
  arrivalCutting,
  storageChecklist,
}

enum OutboxItemStatus {
  waitingToSend,
  syncing,
  sent,
  needsAttention,
  late,
  conflict,
  failed,
}

extension OutboxItemStatusExtension on OutboxItemStatus {
  String get label => switch (this) {
    OutboxItemStatus.waitingToSend => 'Waiting to send',
    OutboxItemStatus.syncing => 'Synchronizing...',
    OutboxItemStatus.sent => 'Sent',
    OutboxItemStatus.needsAttention => 'Needs Attention',
    OutboxItemStatus.late => 'Late (>3 days)',
    OutboxItemStatus.conflict => 'Allocation Conflict',
    OutboxItemStatus.failed => 'Sync Failed',
  };
}

/// Model representing a queued offline transaction in the CQAAG Shared Outbox
/// (Spec Section 72–79, Figure 18)
class OutboxItem {
  final String id;
  final OutboxItemType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final OutboxItemStatus status;
  final int attempts;
  final String? errorMessage;
  final String? serverRecordId;
  final bool isFlaggedLate;
  final String? conflictDetails;
  final String analystId;

  const OutboxItem({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.status = OutboxItemStatus.waitingToSend,
    this.attempts = 0,
    this.errorMessage,
    this.serverRecordId,
    this.isFlaggedLate = false,
    this.conflictDetails,
    required this.analystId,
  });

  /// Duration item has been queued locally
  Duration get age => DateTime.now().difference(createdAt);

  /// 49 hours amber warning threshold (Spec Section 73 / Test 17.3)
  bool get isStaleAmber => age.inHours >= 49 && age.inHours < 73;

  /// 73 hours (>3 days) critical staleness threshold (Spec Section 73 / Test 17.3)
  bool get isLate73h => age.inHours >= 73;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'attempts': attempts,
      'errorMessage': errorMessage,
      'serverRecordId': serverRecordId,
      'isFlaggedLate': isFlaggedLate,
      'conflictDetails': conflictDetails,
      'analystId': analystId,
    };
  }

  factory OutboxItem.fromMap(Map<String, dynamic> map, [String? id]) {
    return OutboxItem(
      id: id ?? map['id'] ?? '',
      type: OutboxItemType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => OutboxItemType.moistureControl,
      ),
      payload: Map<String, dynamic>.from(map['payload'] ?? {}),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      status: OutboxItemStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => OutboxItemStatus.waitingToSend,
      ),
      attempts: map['attempts'] is int ? map['attempts'] : 0,
      errorMessage: map['errorMessage'],
      serverRecordId: map['serverRecordId'],
      isFlaggedLate: map['isFlaggedLate'] == true,
      conflictDetails: map['conflictDetails'],
      analystId: map['analystId'] ?? '',
    );
  }

  OutboxItem copyWith({
    String? id,
    OutboxItemType? type,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    OutboxItemStatus? status,
    int? attempts,
    String? errorMessage,
    String? serverRecordId,
    bool? isFlaggedLate,
    String? conflictDetails,
    String? analystId,
  }) {
    return OutboxItem(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      errorMessage: errorMessage ?? this.errorMessage,
      serverRecordId: serverRecordId ?? this.serverRecordId,
      isFlaggedLate: isFlaggedLate ?? this.isFlaggedLate,
      conflictDetails: conflictDetails ?? this.conflictDetails,
      analystId: analystId ?? this.analystId,
    );
  }
}
