import 'package:freezed_annotation/freezed_annotation.dart';

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
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Inspection({
    required String id,
    required String inspectorId,
    // Basic Info
    String? truckNumber,
    String? company,
    @Default(0.0) double quantity,

    // Quality Metrics
    @Default(0.0) double moistureContent,
    @Default(0) int nutCount,
    @Default(0.0) double kor,

    @Default([]) List<String> imageUrls,
    @Default(InspectionStatus.pending) InspectionStatus status,

    String? notes,
    DateTime? completedAt,
  }) = _Inspection;

  factory Inspection.fromJson(Map<String, dynamic> json) => _$InspectionFromJson(json);
}
