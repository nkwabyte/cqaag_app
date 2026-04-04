import 'package:freezed_annotation/freezed_annotation.dart';

part 'newsletter_subscription.freezed.dart';
part 'newsletter_subscription.g.dart';

@freezed
abstract class NewsletterSubscription with _$NewsletterSubscription {
  const NewsletterSubscription._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory NewsletterSubscription({
    /// Unique subscription ID
    required String id,

    /// Subscriber email address
    required String email,

    /// When the subscription was created
    required DateTime subscribedAt,

    /// Whether the subscription is active
    @Default(true) bool isActive,

    /// Source of subscription (e.g., "guest_events_screen")
    @Default("guest_events_screen") String source,

    /// When the subscription was last updated
    DateTime? updatedAt,
  }) = _NewsletterSubscription;

  factory NewsletterSubscription.fromJson(Map<String, dynamic> json) => _$NewsletterSubscriptionFromJson(json);
}
