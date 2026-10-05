// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kit_order_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(kitOrderService)
final kitOrderServiceProvider = KitOrderServiceProvider._();

final class KitOrderServiceProvider
    extends
        $FunctionalProvider<KitOrderService, KitOrderService, KitOrderService>
    with $Provider<KitOrderService> {
  KitOrderServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kitOrderServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kitOrderServiceHash();

  @$internal
  @override
  $ProviderElement<KitOrderService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KitOrderService create(Ref ref) {
    return kitOrderService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KitOrderService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KitOrderService>(value),
    );
  }
}

String _$kitOrderServiceHash() => r'9c836ae45005e42731a5b294aeb835194761e38b';
