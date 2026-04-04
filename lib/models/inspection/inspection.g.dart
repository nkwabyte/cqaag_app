// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Inspection _$InspectionFromJson(Map<String, dynamic> json) => _Inspection(
  id: json['id'] as String,
  inspectionId: json['inspection_id'] as String?,
  inspectorId: json['inspector_id'] as String,
  batchId: json['batch_id'] as String?,
  farmerName: json['farmer_name'] as String?,
  location: json['location'] as String?,
  capturedLocation: json['captured_location'] == null
      ? null
      : CapturedLocation.fromJson(
          json['captured_location'] as Map<String, dynamic>,
        ),
  town: json['town'] as String?,
  chapter: json['chapter'] as String?,
  truckNumber: json['truck_number'] as String?,
  company: json['company'] as String?,
  quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
  quantityBags: (json['quantity_bags'] as num?)?.toInt() ?? 0,
  moistureContent: (json['moisture_content'] as num?)?.toDouble() ?? 0.0,
  nutCount: (json['nut_count'] as num?)?.toInt() ?? 0,
  kor: (json['kor'] as num?)?.toDouble() ?? 0.0,
  goodKernels: (json['good_kernels'] as num?)?.toDouble() ?? 0.0,
  spottedKernels: (json['spotted_kernels'] as num?)?.toDouble() ?? 0.0,
  immatureKernels: (json['immature_kernels'] as num?)?.toDouble() ?? 0.0,
  oilyKernels: (json['oily_kernels'] as num?)?.toDouble() ?? 0.0,
  voidKernels: (json['void_kernels'] as num?)?.toDouble() ?? 0.0,
  totalDefective: (json['total_defective'] as num?)?.toDouble() ?? 0.0,
  totalSpotted: (json['total_spotted'] as num?)?.toDouble() ?? 0.0,
  imageUrls:
      (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  status:
      $enumDecodeNullable(_$InspectionStatusEnumMap, json['status']) ??
      InspectionStatus.pending,
  notes: json['notes'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
);

Map<String, dynamic> _$InspectionToJson(_Inspection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inspection_id': instance.inspectionId,
      'inspector_id': instance.inspectorId,
      'batch_id': instance.batchId,
      'farmer_name': instance.farmerName,
      'location': instance.location,
      'captured_location': instance.capturedLocation?.toJson(),
      'town': instance.town,
      'chapter': instance.chapter,
      'truck_number': instance.truckNumber,
      'company': instance.company,
      'quantity': instance.quantity,
      'quantity_bags': instance.quantityBags,
      'moisture_content': instance.moistureContent,
      'nut_count': instance.nutCount,
      'kor': instance.kor,
      'good_kernels': instance.goodKernels,
      'spotted_kernels': instance.spottedKernels,
      'immature_kernels': instance.immatureKernels,
      'oily_kernels': instance.oilyKernels,
      'void_kernels': instance.voidKernels,
      'total_defective': instance.totalDefective,
      'total_spotted': instance.totalSpotted,
      'image_urls': instance.imageUrls,
      'status': _$InspectionStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };

const _$InspectionStatusEnumMap = {
  InspectionStatus.pending: 'pending',
  InspectionStatus.inProgress: 'in_progress',
  InspectionStatus.completed: 'completed',
  InspectionStatus.rejected: 'rejected',
};
