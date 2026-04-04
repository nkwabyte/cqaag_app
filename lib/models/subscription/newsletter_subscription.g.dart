// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newsletter_subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NewsletterSubscription _$NewsletterSubscriptionFromJson(
  Map<String, dynamic> json,
) => _NewsletterSubscription(
  id: json['id'] as String,
  email: json['email'] as String,
  subscribedAt: DateTime.parse(json['subscribed_at'] as String),
  isActive: json['is_active'] as bool? ?? true,
  source: json['source'] as String? ?? "guest_events_screen",
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$NewsletterSubscriptionToJson(
  _NewsletterSubscription instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'subscribed_at': instance.subscribedAt.toIso8601String(),
  'is_active': instance.isActive,
  'source': instance.source,
  'updated_at': instance.updatedAt?.toIso8601String(),
};
