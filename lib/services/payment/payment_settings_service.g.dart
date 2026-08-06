// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_settings_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for [PaymentSettingsService].

@ProviderFor(paymentSettingsService)
final paymentSettingsServiceProvider = PaymentSettingsServiceProvider._();

/// Provider for [PaymentSettingsService].

final class PaymentSettingsServiceProvider
    extends
        $FunctionalProvider<
          PaymentSettingsService,
          PaymentSettingsService,
          PaymentSettingsService
        >
    with $Provider<PaymentSettingsService> {
  /// Provider for [PaymentSettingsService].
  PaymentSettingsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentSettingsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentSettingsServiceHash();

  @$internal
  @override
  $ProviderElement<PaymentSettingsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentSettingsService create(Ref ref) {
    return paymentSettingsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentSettingsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentSettingsService>(value),
    );
  }
}

String _$paymentSettingsServiceHash() =>
    r'8a7ada698c8692a0a576a30be32bf0cdaa3c15f2';

/// Live payment settings for any screen that needs the fee or MoMo account.

@ProviderFor(paymentSettings)
final paymentSettingsProvider = PaymentSettingsProvider._();

/// Live payment settings for any screen that needs the fee or MoMo account.

final class PaymentSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaymentSettings>,
          PaymentSettings,
          Stream<PaymentSettings>
        >
    with $FutureModifier<PaymentSettings>, $StreamProvider<PaymentSettings> {
  /// Live payment settings for any screen that needs the fee or MoMo account.
  PaymentSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentSettingsHash();

  @$internal
  @override
  $StreamProviderElement<PaymentSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PaymentSettings> create(Ref ref) {
    return paymentSettings(ref);
  }
}

String _$paymentSettingsHash() => r'306689455963b7339f6f264fa02eb9b385410fc4';
