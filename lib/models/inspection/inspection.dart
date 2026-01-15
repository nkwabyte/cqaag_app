import 'package:freezed_annotation/freezed_annotation.dart';
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
}

@freezed
abstract class Inspection with _$Inspection {
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

    // Basic Info
    String? truckNumber,
    String? company,
    @Default(0.0) double quantity,
    @Default(0) int quantityBags,

    // Quality Metrics
    @Default(0.0) double moistureContent,
    @Default(0) int nutCount, // Raw Nut Count
    @Default(0.0) double kor,

    // Defect Metrics
    @Default(0.0) double goodKernels,
    @Default(0.0) double spottedKernels,
    @Default(0.0) double immatureKernels,
    @Default(0.0) double oilyKernels,
    @Default(0.0) double voidKernels,
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
}
