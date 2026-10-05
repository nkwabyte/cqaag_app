import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cqaag_app/models/inspection/cut_test.dart';
import 'package:cqaag_app/models/inspection/analysis_types.dart';
import 'package:cqaag_app/models/location/captured_location.dart';
import 'package:cqaag_app/models/payment/payment_settings.dart';

part 'inspection.freezed.dart';
part 'inspection.g.dart';

enum InspectionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('rejected')
  rejected,
  @JsonValue('pending_sync')
  pendingSync,
  /// An Export certificate waiting at the CQAAG approval desk.
  @JsonValue('pending_approval')
  pendingApproval,
  /// An Export certificate CQAAG declined to approve.
  @JsonValue('approval_declined')
  approvalDeclined,
}

/// Where a certificate stands with the CQAAG approval desk, stored as the
/// website stores it in `approval_status`.
///
/// Only Export certificates need approval before they are valid; every other
/// type is [notRequired].
enum CertificateApprovalStatus {
  notRequired('not_required', 'Not required'),
  pending('pending', 'Awaiting CQAAG approval'),
  approved('approved', 'CQAAG approved'),
  declined('declined', 'Not approved');

  const CertificateApprovalStatus(this.value, this.label);

  final String value;
  final String label;

  static CertificateApprovalStatus fromValue(String? value) {
    return CertificateApprovalStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => CertificateApprovalStatus.notRequired,
    );
  }
}

@freezed
abstract class Inspection with _$Inspection {
  const Inspection._();

  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Inspection({
    required String id, // Firebase auto-generated document ID
    String? inspectionId, // Custom inspection ID (e.g., INS-20260114-4X9P)
    required String inspectorId,

    // Batch and Farmer Info
    String? batchId,
    String? farmerName, // Acts as Supplier/Farmer Name
    String? location, // Text-based location (e.g., "Wenchi District, Bono Region")
    CapturedLocation? capturedLocation, // GPS-captured location with coordinates
    String? town,
    String? chapter,
    String? exactLocation,

    // Basic Info
    String? truckNumber,
    String? company,
    String? buyerName,
    String? waybillNumber,
    String? analysisType,
    @Default(0.0) double quantity,
    @Default(0) int quantityBags,

    /// The individual cut tests behind this inspection, in order.
    ///
    /// The report shows each one in its own column and the mean in AVERAGE.
    /// The flat quality fields below hold that mean, so existing records and
    /// the website continue to read the same values as before.
    @Default(<CutTest>[]) List<CutTest> cutTests,

    // Quality Metrics (averages across [cutTests])
    @Default(0.0) double moistureContent,
    @Default(0) int nutCount, // Raw Nut Count
    @Default(0.0) double kor,

    // Defect Metrics
    @Default(0.0) double goodKernels,
    @Default(0.0) double spottedKernels,
    @Default(0.0) double immatureKernels,
    @Default(0.0) double oilyKernels,
    @Default(0.0) double voidKernels,
    @Default(0.0) double fullyDamagedKernels,
    @Default(0.0) double emptyShells,
    @Default(0.0) double totalDefective,
    @Default(0.0) double totalSpotted,

    @Default([]) List<String> imageUrls,
    @JsonKey(unknownEnumValue: InspectionStatus.pending) @Default(InspectionStatus.pending) InspectionStatus status,

    String? notes,

    // Persistent QC-Code for this inspection
    String? qcCode,

    // Export Specific RCN Quality Report Fields
    String? blNumber,
    String? shipperDetails,
    String? consigneeDetails,
    @Default('GHANA') String originCountry,
    String? destinationCountry,
    String? transportDescription,
    String? pod, // Port of Destination
    String? pol, // Port of Loading
    String? containerCountAndSizes,
    double? grossWeight,
    double? netWeight,
    String? packageDescription,
    String? samplePlaceAndDate,
    String? cuttingTestPlaceAndDate,
    @Default(false) bool isAuthorized,
    String? authorizedSignature,
    String? authorizedBy,
    @Default([]) List<String> cuttingImageUrls,

    // Analyst identity, denormalised so the approval desk and the decision
    // email do not have to look the analyst up.
    String? inspectorName,
    String? inspectorEmail,

    // Certificate fee — paid before a Moisture Control, Dispatch, Export or
    // Arbitration certificate can be submitted. Field names match the website.
    @Default(0.0) double reportFeeAmount,
    @Default('GHS') String reportFeeCurrency,

    /// `not_required`, `pending_verification`, `verified` or `rejected`.
    @Default('not_required') String reportFeeStatus,
    @Default('') String reportFeeEvidenceUrl,
    @Default('') String reportFeeReference,
    @Default('') String reportFeeMomoNetwork,
    @Default('') String reportFeeMomoNumber,
    @Default('') String reportFeeMomoAccountName,
    @Default('') String reportFeePaidAt,
    @Default('') String reportFeeVerifiedAt,
    @Default('') String reportFeeVerifiedBy,

    // CQAAG approval — Export certificates are not valid until approved.
    //
    // Dates are ISO strings, left empty until set: the shared Firestore rules
    // reject an Export certificate created with anything but an empty
    // `approved_at` and `approval_seal_url`.
    @Default('not_required') String approvalStatus,
    @Default('') String approvalRequestedAt,
    @Default('') String approvedAt,
    @Default('') String approvedByUid,
    @Default('') String approvedByName,

    /// Image of the association seal, with the president's signature embedded
    /// when an admin has uploaded the signed seal, copied on at approval time.
    @Default('') String approvalSealUrl,
    @Default(false) bool approvalSealIncludesSignature,
    @Default('') String declinedAt,
    @Default('') String declineReason,
    @Default('') String declinedByUid,
    @Default('') String declinedByName,

    /// Export cutting pictures uploaded from the website.
    @Default([]) List<String> reportPhotos,

    // Timestamps
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) = _Inspection;

  factory Inspection.fromJson(Map<String, dynamic> json) => _$InspectionFromJson(json);

  /// Whether this certificate is an Export certificate.
  bool get isExport => AnalysisTypes.isExport(analysisType);

  CertificateApprovalStatus get approval => CertificateApprovalStatus.fromValue(approvalStatus);

  /// Whether the certificate can be relied on: types that need no approval
  /// always are; Export certificates only once CQAAG has approved them.
  bool get isCertificateValid {
    if (!isExport) return true;
    return approval == CertificateApprovalStatus.approved;
  }

  /// Whether a certificate fee was charged for this inspection.
  bool get hasReportFee => reportFeeStatus != 'not_required' && reportFeeAmount > 0;

  PaymentStatus get reportFeePayment => PaymentStatus.fromValue(reportFeeStatus);

  DateTime? get approvedAtTime => DateTime.tryParse(approvedAt);

  DateTime? get approvalRequestedAtTime => DateTime.tryParse(approvalRequestedAt);

  /// Every photo on the inspection, without repeats, for the approval desk.
  List<String> get allPhotoUrls => {...imageUrls, ...cuttingImageUrls, ...reportPhotos}.where((u) => u.startsWith('http')).toList();

  /// Cut tests to render on the report.
  ///
  /// Inspections recorded before cut tests were stored individually only have
  /// the averaged fields. Those are presented as a single cut test so older
  /// records still fill the first column instead of showing an empty table.
  List<CutTest> get effectiveCutTests {
    final nonEmpties = cutTests.where((c) => !c.isEmpty).toList();
    if (nonEmpties.isNotEmpty) return nonEmpties;

    return [
      CutTest(
        index: 1,
        moistureContent: moistureContent,
        nutCount: nutCount,
        fullyDamagedNuts: fullyDamagedKernels,
        voidNuts: voidKernels,
        oilNuts: oilyKernels,
        spottedNuts: spottedKernels,
        immatureNuts: immatureKernels,
        goodKernels: goodKernels,
        emptyShells: emptyShells,
      ),
    ];
  }
}
