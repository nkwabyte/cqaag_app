// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_credentials_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memberCredentialsService)
final memberCredentialsServiceProvider = MemberCredentialsServiceProvider._();

final class MemberCredentialsServiceProvider
    extends
        $FunctionalProvider<
          MemberCredentialsService,
          MemberCredentialsService,
          MemberCredentialsService
        >
    with $Provider<MemberCredentialsService> {
  MemberCredentialsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberCredentialsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberCredentialsServiceHash();

  @$internal
  @override
  $ProviderElement<MemberCredentialsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MemberCredentialsService create(Ref ref) {
    return memberCredentialsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberCredentialsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberCredentialsService>(value),
    );
  }
}

String _$memberCredentialsServiceHash() =>
    r'4d105ee303480f80cb20ed3bffaf9560661f0fbb';
