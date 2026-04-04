// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inspectionService)
final inspectionServiceProvider = InspectionServiceProvider._();

final class InspectionServiceProvider
    extends
        $FunctionalProvider<
          InspectionService,
          InspectionService,
          InspectionService
        >
    with $Provider<InspectionService> {
  InspectionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inspectionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inspectionServiceHash();

  @$internal
  @override
  $ProviderElement<InspectionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InspectionService create(Ref ref) {
    return inspectionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InspectionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InspectionService>(value),
    );
  }
}

String _$inspectionServiceHash() => r'1d1913cd2c1cec01ccc0a2dd860fe1a1a9406823';
