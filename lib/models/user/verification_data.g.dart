// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerificationData _$VerificationDataFromJson(Map<String, dynamic> json) =>
    _VerificationData(
      idCardFrontUrl: json['id_card_front_url'] as String,
      idCardBackUrl: json['id_card_back_url'] as String,
      idCardNumber: json['id_card_number'] as String,
      selfieUrl: json['selfie_url'] as String,
      verifiedBy: json['verified_by'] as String?,
      dateVerified: json['date_verified'] == null
          ? null
          : DateTime.parse(json['date_verified'] as String),
    );

Map<String, dynamic> _$VerificationDataToJson(_VerificationData instance) =>
    <String, dynamic>{
      'id_card_front_url': instance.idCardFrontUrl,
      'id_card_back_url': instance.idCardBackUrl,
      'id_card_number': instance.idCardNumber,
      'selfie_url': instance.selfieUrl,
      'verified_by': instance.verifiedBy,
      'date_verified': instance.dateVerified?.toIso8601String(),
    };
