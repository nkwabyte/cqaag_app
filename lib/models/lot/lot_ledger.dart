enum LotStage {
  arrivalCutting,
  drying,
  parking24h,
  inStock,
  dispatched,
  exportZoneArrival,
  exported,
}

/// Data model representing an RCN Lot across its entire lifecycle
/// (Spec Section 51–57, Figures 26–31, 35–37)
class LotRecord {
  final String lotCode; // CQAAG-L-yymmdd-nnnn
  final String facilityId; // CQAAG-W-nnnn or CQAAG-WB-nnnn
  final LotStage stage;
  final String sellerTcda;
  final String buyerTcda;
  final String vehiclePlate;

  // Weighing & Bag inventory
  final double grossWeightKg;
  final double tareWeightKg;
  final double netWeightKg;
  final int totalBags;
  final int remainingBags;
  final String? weighbridgeSlipNumber;
  final String? weighbridgeSlipPhotoUrl;
  final DateTime? weighingTimestamp;

  // Purchase Slip & 48h / Day 3 rule (Test 7.2)
  final String? purchaseSlipPhotoUrl;
  final DateTime? purchaseSlipUploadedAt;
  final DateTime createdAt;

  // Drying & Moisture Parameters
  final double currentMoisture;
  final double? initialMoisture;
  final double? driedMoisture;
  final double? moistureLossKg;
  final double? pickingsKg;
  final int? pickingsBags;
  final DateTime? dryingStartedAt;
  final DateTime? dryingEndedAt;
  final DateTime? parkingExpiresAt; // 24-hour parking state (Test 7.5)

  // Quality Metrics Snapshot
  final double? kor;
  final int? nutCount;
  final double? defectivesPercent;

  // Traceability & Lineage (Tests 7.17, 7.19)
  final List<String> parentLotCodes; // If merged
  final List<String> childLotCodes; // If split
  final String? mergeReason;
  final String? tcdaConveyanceNumber; // For Dispatch (Step 8)
  final String? containerNumber; // For Export (Step 9 & 10)

  const LotRecord({
    required this.lotCode,
    required this.facilityId,
    this.stage = LotStage.arrivalCutting,
    required this.sellerTcda,
    required this.buyerTcda,
    required this.vehiclePlate,
    this.grossWeightKg = 0.0,
    this.tareWeightKg = 0.0,
    this.netWeightKg = 0.0,
    this.totalBags = 0,
    this.remainingBags = 0,
    this.weighbridgeSlipNumber,
    this.weighbridgeSlipPhotoUrl,
    this.weighingTimestamp,
    this.purchaseSlipPhotoUrl,
    this.purchaseSlipUploadedAt,
    required this.createdAt,
    this.currentMoisture = 9.5,
    this.initialMoisture,
    this.driedMoisture,
    this.moistureLossKg,
    this.pickingsKg,
    this.pickingsBags,
    this.dryingStartedAt,
    this.dryingEndedAt,
    this.parkingExpiresAt,
    this.kor,
    this.nutCount,
    this.defectivesPercent,
    this.parentLotCodes = const [],
    this.childLotCodes = const [],
    this.mergeReason,
    this.tcdaConveyanceNumber,
    this.containerNumber,
  });

  /// Check if 48 hours have passed without purchase slip (Test 7.2)
  bool get isPurchaseSlipOverdue48h {
    if (purchaseSlipPhotoUrl != null && purchaseSlipPhotoUrl!.isNotEmpty) return false;
    final age = DateTime.now().difference(createdAt);
    return age.inHours >= 48;
  }

  /// Check if Day 3 (72 hours) has passed without purchase slip -> Hard Block (Test 7.2)
  bool get isPurchaseSlipBlockedDay3 {
    if (purchaseSlipPhotoUrl != null && purchaseSlipPhotoUrl!.isNotEmpty) return false;
    final age = DateTime.now().difference(createdAt);
    return age.inHours >= 72;
  }

  /// Check if lot is currently in 24-hour parking (Test 7.5)
  bool get isParkingActive {
    if (parkingExpiresAt == null) return false;
    return DateTime.now().isBefore(parkingExpiresAt!);
  }

  Map<String, dynamic> toMap() {
    return {
      'lotCode': lotCode,
      'facilityId': facilityId,
      'stage': stage.name,
      'sellerTcda': sellerTcda,
      'buyerTcda': buyerTcda,
      'vehiclePlate': vehiclePlate,
      'grossWeightKg': grossWeightKg,
      'tareWeightKg': tareWeightKg,
      'netWeightKg': netWeightKg,
      'totalBags': totalBags,
      'remainingBags': remainingBags,
      'weighbridgeSlipNumber': weighbridgeSlipNumber,
      'weighbridgeSlipPhotoUrl': weighbridgeSlipPhotoUrl,
      'weighingTimestamp': weighingTimestamp?.toIso8601String(),
      'purchaseSlipPhotoUrl': purchaseSlipPhotoUrl,
      'purchaseSlipUploadedAt': purchaseSlipUploadedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'currentMoisture': currentMoisture,
      'initialMoisture': initialMoisture,
      'driedMoisture': driedMoisture,
      'moistureLossKg': moistureLossKg,
      'pickingsKg': pickingsKg,
      'pickingsBags': pickingsBags,
      'dryingStartedAt': dryingStartedAt?.toIso8601String(),
      'dryingEndedAt': dryingEndedAt?.toIso8601String(),
      'parkingExpiresAt': parkingExpiresAt?.toIso8601String(),
      'kor': kor,
      'nutCount': nutCount,
      'defectivesPercent': defectivesPercent,
      'parentLotCodes': parentLotCodes,
      'childLotCodes': childLotCodes,
      'mergeReason': mergeReason,
      'tcdaConveyanceNumber': tcdaConveyanceNumber,
      'containerNumber': containerNumber,
    };
  }

  factory LotRecord.fromMap(Map<String, dynamic> map, [String? code]) {
    return LotRecord(
      lotCode: code ?? map['lotCode'] ?? '',
      facilityId: map['facilityId'] ?? '',
      stage: LotStage.values.firstWhere(
        (s) => s.name == map['stage'],
        orElse: () => LotStage.arrivalCutting,
      ),
      sellerTcda: map['sellerTcda'] ?? '',
      buyerTcda: map['buyerTcda'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      grossWeightKg: (map['grossWeightKg'] is num) ? (map['grossWeightKg'] as num).toDouble() : 0.0,
      tareWeightKg: (map['tareWeightKg'] is num) ? (map['tareWeightKg'] as num).toDouble() : 0.0,
      netWeightKg: (map['netWeightKg'] is num) ? (map['netWeightKg'] as num).toDouble() : 0.0,
      totalBags: map['totalBags'] is int ? map['totalBags'] : 0,
      remainingBags: map['remainingBags'] is int ? map['remainingBags'] : 0,
      weighbridgeSlipNumber: map['weighbridgeSlipNumber'],
      weighbridgeSlipPhotoUrl: map['weighbridgeSlipPhotoUrl'],
      weighingTimestamp: map['weighingTimestamp'] != null ? DateTime.tryParse(map['weighingTimestamp']) : null,
      purchaseSlipPhotoUrl: map['purchaseSlipPhotoUrl'],
      purchaseSlipUploadedAt: map['purchaseSlipUploadedAt'] != null ? DateTime.tryParse(map['purchaseSlipUploadedAt']) : null,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) ?? DateTime.now() : DateTime.now(),
      currentMoisture: (map['currentMoisture'] is num) ? (map['currentMoisture'] as num).toDouble() : 9.5,
      initialMoisture: (map['initialMoisture'] is num) ? (map['initialMoisture'] as num).toDouble() : null,
      driedMoisture: (map['driedMoisture'] is num) ? (map['driedMoisture'] as num).toDouble() : null,
      moistureLossKg: (map['moistureLossKg'] is num) ? (map['moistureLossKg'] as num).toDouble() : null,
      pickingsKg: (map['pickingsKg'] is num) ? (map['pickingsKg'] as num).toDouble() : null,
      pickingsBags: map['pickingsBags'] is int ? map['pickingsBags'] : null,
      dryingStartedAt: map['dryingStartedAt'] != null ? DateTime.tryParse(map['dryingStartedAt']) : null,
      dryingEndedAt: map['dryingEndedAt'] != null ? DateTime.tryParse(map['dryingEndedAt']) : null,
      parkingExpiresAt: map['parkingExpiresAt'] != null ? DateTime.tryParse(map['parkingExpiresAt']) : null,
      kor: (map['kor'] is num) ? (map['kor'] as num).toDouble() : null,
      nutCount: map['nutCount'] is int ? map['nutCount'] : null,
      defectivesPercent: (map['defectivesPercent'] is num) ? (map['defectivesPercent'] as num).toDouble() : null,
      parentLotCodes: List<String>.from(map['parentLotCodes'] ?? []),
      childLotCodes: List<String>.from(map['childLotCodes'] ?? []),
      mergeReason: map['mergeReason'],
      tcdaConveyanceNumber: map['tcdaConveyanceNumber'],
      containerNumber: map['containerNumber'],
    );
  }

  LotRecord copyWith({
    String? lotCode,
    String? facilityId,
    LotStage? stage,
    String? sellerTcda,
    String? buyerTcda,
    String? vehiclePlate,
    double? grossWeightKg,
    double? tareWeightKg,
    double? netWeightKg,
    int? totalBags,
    int? remainingBags,
    String? weighbridgeSlipNumber,
    String? weighbridgeSlipPhotoUrl,
    DateTime? weighingTimestamp,
    String? purchaseSlipPhotoUrl,
    DateTime? purchaseSlipUploadedAt,
    DateTime? createdAt,
    double? currentMoisture,
    double? initialMoisture,
    double? driedMoisture,
    double? moistureLossKg,
    double? pickingsKg,
    int? pickingsBags,
    DateTime? dryingStartedAt,
    DateTime? dryingEndedAt,
    DateTime? parkingExpiresAt,
    double? kor,
    int? nutCount,
    double? defectivesPercent,
    List<String>? parentLotCodes,
    List<String>? childLotCodes,
    String? mergeReason,
    String? tcdaConveyanceNumber,
    String? containerNumber,
  }) {
    return LotRecord(
      lotCode: lotCode ?? this.lotCode,
      facilityId: facilityId ?? this.facilityId,
      stage: stage ?? this.stage,
      sellerTcda: sellerTcda ?? this.sellerTcda,
      buyerTcda: buyerTcda ?? this.buyerTcda,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      grossWeightKg: grossWeightKg ?? this.grossWeightKg,
      tareWeightKg: tareWeightKg ?? this.tareWeightKg,
      netWeightKg: netWeightKg ?? this.netWeightKg,
      totalBags: totalBags ?? this.totalBags,
      remainingBags: remainingBags ?? this.remainingBags,
      weighbridgeSlipNumber: weighbridgeSlipNumber ?? this.weighbridgeSlipNumber,
      weighbridgeSlipPhotoUrl: weighbridgeSlipPhotoUrl ?? this.weighbridgeSlipPhotoUrl,
      weighingTimestamp: weighingTimestamp ?? this.weighingTimestamp,
      purchaseSlipPhotoUrl: purchaseSlipPhotoUrl ?? this.purchaseSlipPhotoUrl,
      purchaseSlipUploadedAt: purchaseSlipUploadedAt ?? this.purchaseSlipUploadedAt,
      createdAt: createdAt ?? this.createdAt,
      currentMoisture: currentMoisture ?? this.currentMoisture,
      initialMoisture: initialMoisture ?? this.initialMoisture,
      driedMoisture: driedMoisture ?? this.driedMoisture,
      moistureLossKg: moistureLossKg ?? this.moistureLossKg,
      pickingsKg: pickingsKg ?? this.pickingsKg,
      pickingsBags: pickingsBags ?? this.pickingsBags,
      dryingStartedAt: dryingStartedAt ?? this.dryingStartedAt,
      dryingEndedAt: dryingEndedAt ?? this.dryingEndedAt,
      parkingExpiresAt: parkingExpiresAt ?? this.parkingExpiresAt,
      kor: kor ?? this.kor,
      nutCount: nutCount ?? this.nutCount,
      defectivesPercent: defectivesPercent ?? this.defectivesPercent,
      parentLotCodes: parentLotCodes ?? this.parentLotCodes,
      childLotCodes: childLotCodes ?? this.childLotCodes,
      mergeReason: mergeReason ?? this.mergeReason,
      tcdaConveyanceNumber: tcdaConveyanceNumber ?? this.tcdaConveyanceNumber,
      containerNumber: containerNumber ?? this.containerNumber,
    );
  }
}
