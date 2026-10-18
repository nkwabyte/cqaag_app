
/// Status of a Moisture Control Pass per CQAAG Rules R5 & Spec Section 37–43
enum MoisturePassStatus {
  awaitingPayment,
  valid,
  failed,
  used,
  cancelled,
}

extension MoisturePassStatusExtension on MoisturePassStatus {
  String get code => switch (this) {
    MoisturePassStatus.awaitingPayment => 'AWAITING_PAYMENT',
    MoisturePassStatus.valid => 'VALID',
    MoisturePassStatus.failed => 'FAILED',
    MoisturePassStatus.used => 'USED',
    MoisturePassStatus.cancelled => 'CANCELLED',
  };

  String get label => switch (this) {
    MoisturePassStatus.awaitingPayment => 'Awaiting Payment',
    MoisturePassStatus.valid => 'Valid Pass (Passed)',
    MoisturePassStatus.failed => 'Failed Pass (Not Valid)',
    MoisturePassStatus.used => 'Used (Arrival Cutting Done)',
    MoisturePassStatus.cancelled => 'Cancelled',
  };

  static MoisturePassStatus fromString(String? val) {
    if (val == null) return MoisturePassStatus.awaitingPayment;
    final upper = val.toUpperCase().replaceAll(' ', '_');
    for (final status in MoisturePassStatus.values) {
      if (status.code == upper || status.name.toUpperCase() == upper) {
        return status;
      }
    }
    return MoisturePassStatus.awaitingPayment;
  }
}

/// Type of check context for moisture thresholds (Spec Section 43 / Test 4.9)
enum MoistureInspectionStage {
  upcountryArrival, // Max 10.0%
  dispatch,         // Max 10.0% (e.g. 10.4% fails, 9.7% passes)
  exportZone,       // Max 8.0%  (e.g. 8.6% fails, 7.9% passes)
}

/// Data model representing a CQAAG Moisture Control Pass / Failed Pass
/// (Spec Sections 37–43, Specimen B1 & B2, Figures 19–25)
class MoisturePass {
  final String id;
  final String passNumber; // CQAAG-P-yymmdd-nnnn or CQAAG-FP-yymmdd-nnnn
  final String lotCode;    // CQAAG-L-yymmdd-nnnn
  final double moistureContent;
  final double maxSafeLimit; // 10.0 for Upcountry/Dispatch; 8.0 for Export
  final MoisturePassStatus status;
  final MoistureInspectionStage stage;
  final String sellerTcda;
  final String buyerTcda;
  final String vehiclePlate;
  final String facilityId;
  final String meterSerialNumber;
  final String? meterPhotoUrl;
  final String? meterPhoto2Url;
  final String? manualOverrideReason;
  final bool isManualReading;
  final String analystId;
  final String analystTcda;
  final DateTime timestamp;
  final bool paymentConfirmed;
  final String? paymentReference;
  final String signatureHash; // Security token for QR verification
  final String? usedInArrivalCuttingLot;
  final DateTime? usedAt;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final bool isLateSync;

  const MoisturePass({
    required this.id,
    required this.passNumber,
    required this.lotCode,
    required this.moistureContent,
    this.maxSafeLimit = 10.0,
    required this.status,
    this.stage = MoistureInspectionStage.upcountryArrival,
    required this.sellerTcda,
    required this.buyerTcda,
    required this.vehiclePlate,
    required this.facilityId,
    required this.meterSerialNumber,
    this.meterPhotoUrl,
    this.meterPhoto2Url,
    this.manualOverrideReason,
    this.isManualReading = false,
    required this.analystId,
    required this.analystTcda,
    required this.timestamp,
    this.paymentConfirmed = false,
    this.paymentReference,
    required this.signatureHash,
    this.usedInArrivalCuttingLot,
    this.usedAt,
    this.cancellationReason,
    this.cancelledAt,
    this.isLateSync = false,
  });

  bool get isPass => moistureContent <= maxSafeLimit;
  bool get isFailed => moistureContent > maxSafeLimit;

  String get verificationUrl =>
      'https://cqaaggh.org/p/$passNumber?s=$signatureHash';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'passNumber': passNumber,
      'lotCode': lotCode,
      'moistureContent': moistureContent,
      'maxSafeLimit': maxSafeLimit,
      'status': status.code,
      'stage': stage.name,
      'sellerTcda': sellerTcda,
      'buyerTcda': buyerTcda,
      'vehiclePlate': vehiclePlate,
      'facilityId': facilityId,
      'meterSerialNumber': meterSerialNumber,
      'meterPhotoUrl': meterPhotoUrl,
      'meterPhoto2Url': meterPhoto2Url,
      'manualOverrideReason': manualOverrideReason,
      'isManualReading': isManualReading,
      'analystId': analystId,
      'analystTcda': analystTcda,
      'timestamp': timestamp.toIso8601String(),
      'paymentConfirmed': paymentConfirmed,
      'paymentReference': paymentReference,
      'signatureHash': signatureHash,
      'usedInArrivalCuttingLot': usedInArrivalCuttingLot,
      'usedAt': usedAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'isLateSync': isLateSync,
    };
  }

  factory MoisturePass.fromMap(Map<String, dynamic> map, [String? docId]) {
    return MoisturePass(
      id: docId ?? map['id'] ?? '',
      passNumber: map['passNumber'] ?? '',
      lotCode: map['lotCode'] ?? '',
      moistureContent: (map['moistureContent'] is num)
          ? (map['moistureContent'] as num).toDouble()
          : 0.0,
      maxSafeLimit: (map['maxSafeLimit'] is num)
          ? (map['maxSafeLimit'] as num).toDouble()
          : 10.0,
      status: MoisturePassStatusExtension.fromString(map['status']),
      stage: MoistureInspectionStage.values.firstWhere(
        (s) => s.name == map['stage'],
        orElse: () => MoistureInspectionStage.upcountryArrival,
      ),
      sellerTcda: map['sellerTcda'] ?? '',
      buyerTcda: map['buyerTcda'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      facilityId: map['facilityId'] ?? '',
      meterSerialNumber: map['meterSerialNumber'] ?? '',
      meterPhotoUrl: map['meterPhotoUrl'],
      meterPhoto2Url: map['meterPhoto2Url'],
      manualOverrideReason: map['manualOverrideReason'],
      isManualReading: map['isManualReading'] == true,
      analystId: map['analystId'] ?? '',
      analystTcda: map['analystTcda'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      paymentConfirmed: map['paymentConfirmed'] == true,
      paymentReference: map['paymentReference'],
      signatureHash: map['signatureHash'] ?? '',
      usedInArrivalCuttingLot: map['usedInArrivalCuttingLot'],
      usedAt: map['usedAt'] != null ? DateTime.tryParse(map['usedAt']) : null,
      cancellationReason: map['cancellationReason'],
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.tryParse(map['cancelledAt'])
          : null,
      isLateSync: map['isLateSync'] == true,
    );
  }

  MoisturePass copyWith({
    String? id,
    String? passNumber,
    String? lotCode,
    double? moistureContent,
    double? maxSafeLimit,
    MoisturePassStatus? status,
    MoistureInspectionStage? stage,
    String? sellerTcda,
    String? buyerTcda,
    String? vehiclePlate,
    String? facilityId,
    String? meterSerialNumber,
    String? meterPhotoUrl,
    String? meterPhoto2Url,
    String? manualOverrideReason,
    bool? isManualReading,
    String? analystId,
    String? analystTcda,
    DateTime? timestamp,
    bool? paymentConfirmed,
    String? paymentReference,
    String? signatureHash,
    String? usedInArrivalCuttingLot,
    DateTime? usedAt,
    String? cancellationReason,
    DateTime? cancelledAt,
    bool? isLateSync,
  }) {
    return MoisturePass(
      id: id ?? this.id,
      passNumber: passNumber ?? this.passNumber,
      lotCode: lotCode ?? this.lotCode,
      moistureContent: moistureContent ?? this.moistureContent,
      maxSafeLimit: maxSafeLimit ?? this.maxSafeLimit,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      sellerTcda: sellerTcda ?? this.sellerTcda,
      buyerTcda: buyerTcda ?? this.buyerTcda,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      facilityId: facilityId ?? this.facilityId,
      meterSerialNumber: meterSerialNumber ?? this.meterSerialNumber,
      meterPhotoUrl: meterPhotoUrl ?? this.meterPhotoUrl,
      meterPhoto2Url: meterPhoto2Url ?? this.meterPhoto2Url,
      manualOverrideReason: manualOverrideReason ?? this.manualOverrideReason,
      isManualReading: isManualReading ?? this.isManualReading,
      analystId: analystId ?? this.analystId,
      analystTcda: analystTcda ?? this.analystTcda,
      timestamp: timestamp ?? this.timestamp,
      paymentConfirmed: paymentConfirmed ?? this.paymentConfirmed,
      paymentReference: paymentReference ?? this.paymentReference,
      signatureHash: signatureHash ?? this.signatureHash,
      usedInArrivalCuttingLot:
          usedInArrivalCuttingLot ?? this.usedInArrivalCuttingLot,
      usedAt: usedAt ?? this.usedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      isLateSync: isLateSync ?? this.isLateSync,
    );
  }
}
