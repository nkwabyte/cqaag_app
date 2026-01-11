// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Inspection _$InspectionFromJson(Map<String, dynamic> json) => _Inspection(
  id: json['id'] as String,
  inspectorId: json['inspector_id'] as String,
  truckNumber: json['truck_number'] as String?,
  company: json['company'] as String?,
  quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
  moistureContent: (json['moisture_content'] as num?)?.toDouble() ?? 0.0,
  nutCount: (json['nut_count'] as num?)?.toInt() ?? 0,
  kor: (json['kor'] as num?)?.toDouble() ?? 0.0,
  imageUrls:
      (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  status:
      $enumDecodeNullable(_$InspectionStatusEnumMap, json['status']) ??
      InspectionStatus.pending,
  notes: json['notes'] as String?,
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
);

Map<String, dynamic> _$InspectionToJson(_Inspection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inspector_id': instance.inspectorId,
      'truck_number': instance.truckNumber,
      'company': instance.company,
      'quantity': instance.quantity,
      'moisture_content': instance.moistureContent,
      'nut_count': instance.nutCount,
      'kor': instance.kor,
      'image_urls': instance.imageUrls,
      'status': _$InspectionStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'completed_at': instance.completedAt?.toIso8601String(),
    };

const _$InspectionStatusEnumMap = {
  InspectionStatus.pending: 'pending',
  InspectionStatus.inProgress: 'in_progress',
  InspectionStatus.completed: 'completed',
  InspectionStatus.rejected: 'rejected',
};
