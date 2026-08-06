// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentSettings _$PaymentSettingsFromJson(Map<String, dynamic> json) =>
    _PaymentSettings(
      registrationFee: (json['registration_fee'] as num?)?.toDouble() ?? 500.0,
      currency: json['currency'] as String? ?? 'GHS',
      momoNumber: json['momo_number'] as String? ?? '+233 55 333 0931',
      momoNetwork: json['momo_network'] as String? ?? 'MTN',
      momoAccountName:
          json['momo_account_name'] as String? ?? 'Amoafo Ebenezer',
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      updatedBy: json['updated_by'] as String?,
    );

Map<String, dynamic> _$PaymentSettingsToJson(_PaymentSettings instance) =>
    <String, dynamic>{
      'registration_fee': instance.registrationFee,
      'currency': instance.currency,
      'momo_number': instance.momoNumber,
      'momo_network': instance.momoNetwork,
      'momo_account_name': instance.momoAccountName,
      'updated_at': instance.updatedAt?.toIso8601String(),
      'updated_by': instance.updatedBy,
    };
