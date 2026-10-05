// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(websiteApiService)
final websiteApiServiceProvider = WebsiteApiServiceProvider._();

final class WebsiteApiServiceProvider
    extends
        $FunctionalProvider<
          WebsiteApiService,
          WebsiteApiService,
          WebsiteApiService
        >
    with $Provider<WebsiteApiService> {
  WebsiteApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'websiteApiServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$websiteApiServiceHash();

  @$internal
  @override
  $ProviderElement<WebsiteApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WebsiteApiService create(Ref ref) {
    return websiteApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebsiteApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebsiteApiService>(value),
    );
  }
}

String _$websiteApiServiceHash() => r'871bb382f5975f9da3e3e3c68b67fdbbb0e2906c';
