import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cqaag_app/models/inspection/cut_test.dart';
import 'package:cqaag_app/models/location/captured_location.dart';

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
    @Default(InspectionStatus.pending) InspectionStatus status,

    String? notes,

    // Timestamps
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) = _Inspection;

  factory Inspection.fromJson(Map<String, dynamic> json) => _$InspectionFromJson(json);

  /// Cut tests to render on the report.
  ///
  /// Inspections recorded before cut tests were stored individually only have
  /// the averaged fields. Those are presented as a single cut test so older
  /// records still fill the first column instead of showing an empty table.
  List<CutTest> get effectiveCutTests {
    if (cutTests.isNotEmpty) return cutTests;

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
