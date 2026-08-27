// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mtn_momo_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mtnMomoService)
final mtnMomoServiceProvider = MtnMomoServiceProvider._();

final class MtnMomoServiceProvider
    extends $FunctionalProvider<MtnMomoService, MtnMomoService, MtnMomoService>
    with $Provider<MtnMomoService> {
  MtnMomoServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mtnMomoServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mtnMomoServiceHash();

  @$internal
  @override
  $ProviderElement<MtnMomoService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MtnMomoService create(Ref ref) {
    return mtnMomoService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MtnMomoService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MtnMomoService>(value),
    );
  }
}

String _$mtnMomoServiceHash() => r'0647641f1ce17cfff3135422dd6e53092fe3e6e8';
