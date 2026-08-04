// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SubscriptionService

@ProviderFor(subscriptionService)
final subscriptionServiceProvider = SubscriptionServiceProvider._();

/// Provider for SubscriptionService

final class SubscriptionServiceProvider
    extends
        $FunctionalProvider<
          SubscriptionService,
          SubscriptionService,
          SubscriptionService
        >
    with $Provider<SubscriptionService> {
  /// Provider for SubscriptionService
  SubscriptionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionServiceHash();

  @$internal
  @override
  $ProviderElement<SubscriptionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SubscriptionService create(Ref ref) {
    return subscriptionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscriptionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscriptionService>(value),
    );
  }
}

String _$subscriptionServiceHash() =>
    r'51fb58091d7babc315c400f9d2c3d7beebd82fc8';

/// Controller for handling subscription operations

@ProviderFor(SubscriptionController)
final subscriptionControllerProvider = SubscriptionControllerProvider._();

/// Controller for handling subscription operations
final class SubscriptionControllerProvider
    extends $NotifierProvider<SubscriptionController, SubscriptionState> {
  /// Controller for handling subscription operations
  SubscriptionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionControllerHash();

  @$internal
  @override
  SubscriptionController create() => SubscriptionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscriptionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscriptionState>(value),
    );
  }
}

String _$subscriptionControllerHash() =>
    r'1c1fca4497496f45ee0fb275b16e4de0262ab210';

/// Controller for handling subscription operations

abstract class _$SubscriptionController extends $Notifier<SubscriptionState> {
  SubscriptionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SubscriptionState, SubscriptionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SubscriptionState, SubscriptionState>,
              SubscriptionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
