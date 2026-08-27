// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_maintenance_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(systemMaintenanceService)
final systemMaintenanceServiceProvider = SystemMaintenanceServiceProvider._();

final class SystemMaintenanceServiceProvider
    extends
        $FunctionalProvider<
          SystemMaintenanceService,
          SystemMaintenanceService,
          SystemMaintenanceService
        >
    with $Provider<SystemMaintenanceService> {
  SystemMaintenanceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemMaintenanceServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemMaintenanceServiceHash();

  @$internal
  @override
  $ProviderElement<SystemMaintenanceService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SystemMaintenanceService create(Ref ref) {
    return systemMaintenanceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SystemMaintenanceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SystemMaintenanceService>(value),
    );
  }
}

String _$systemMaintenanceServiceHash() =>
    r'081fd1d195a077c236ce183bb03a20f755ab4e2d';
