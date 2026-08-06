// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cut_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CutTest _$CutTestFromJson(Map<String, dynamic> json) => _CutTest(
  index: (json['index'] as num).toInt(),
  label: json['label'] as String?,
  moistureContent: (json['moisture_content'] as num?)?.toDouble() ?? 0.0,
  nutCount: (json['nut_count'] as num?)?.toInt() ?? 0,
  fullyDamagedNuts: (json['fully_damaged_nuts'] as num?)?.toDouble() ?? 0.0,
  voidNuts: (json['void_nuts'] as num?)?.toDouble() ?? 0.0,
  oilNuts: (json['oil_nuts'] as num?)?.toDouble() ?? 0.0,
  spottedNuts: (json['spotted_nuts'] as num?)?.toDouble() ?? 0.0,
  immatureNuts: (json['immature_nuts'] as num?)?.toDouble() ?? 0.0,
  goodKernels: (json['good_kernels'] as num?)?.toDouble() ?? 0.0,
  emptyShells: (json['empty_shells'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$CutTestToJson(_CutTest instance) => <String, dynamic>{
  'index': instance.index,
  'label': instance.label,
  'moisture_content': instance.moistureContent,
  'nut_count': instance.nutCount,
  'fully_damaged_nuts': instance.fullyDamagedNuts,
  'void_nuts': instance.voidNuts,
  'oil_nuts': instance.oilNuts,
  'spotted_nuts': instance.spottedNuts,
  'immature_nuts': instance.immatureNuts,
  'good_kernels': instance.goodKernels,
  'empty_shells': instance.emptyShells,
};
