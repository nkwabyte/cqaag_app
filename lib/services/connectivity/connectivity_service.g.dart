// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for ConnectivityService

@ProviderFor(connectivityService)
final connectivityServiceProvider = ConnectivityServiceProvider._();

/// Provider for ConnectivityService

final class ConnectivityServiceProvider
    extends
        $FunctionalProvider<
          ConnectivityService,
          ConnectivityService,
          ConnectivityService
        >
    with $Provider<ConnectivityService> {
  /// Provider for ConnectivityService
  ConnectivityServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityServiceHash();

  @$internal
  @override
  $ProviderElement<ConnectivityService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectivityService create(Ref ref) {
    return connectivityService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityService>(value),
    );
  }
}

String _$connectivityServiceHash() =>
    r'95e1b48f96e075c047a46e92aa33a19a18e68e05';

/// Provider for connectivity status stream

@ProviderFor(connectivityStatus)
final connectivityStatusProvider = ConnectivityStatusProvider._();

/// Provider for connectivity status stream

final class ConnectivityStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConnectivityResult>>,
          List<ConnectivityResult>,
          Stream<List<ConnectivityResult>>
        >
    with
        $FutureModifier<List<ConnectivityResult>>,
        $StreamProvider<List<ConnectivityResult>> {
  /// Provider for connectivity status stream
  ConnectivityStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityStatusHash();

  @$internal
  @override
  $StreamProviderElement<List<ConnectivityResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConnectivityResult>> create(Ref ref) {
    return connectivityStatus(ref);
  }
}

String _$connectivityStatusHash() =>
    r'6aae7a28139baf96e70b62ec707e028466c784d5';

/// Provider to check if currently connected

@ProviderFor(isConnected)
final isConnectedProvider = IsConnectedProvider._();

/// Provider to check if currently connected

final class IsConnectedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider to check if currently connected
  IsConnectedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isConnectedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isConnectedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isConnected(ref);
  }
}

String _$isConnectedHash() => r'e82c9ad6007b3396508dc74d47e36a3ba73b8778';

/// Provider to check if has internet access

@ProviderFor(hasInternetAccess)
final hasInternetAccessProvider = HasInternetAccessProvider._();

/// Provider to check if has internet access

final class HasInternetAccessProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider to check if has internet access
  HasInternetAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasInternetAccessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasInternetAccessHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return hasInternetAccess(ref);
  }
}

String _$hasInternetAccessHash() => r'6dea646b37da8fed4dd308733a8a5f22641657ea';
