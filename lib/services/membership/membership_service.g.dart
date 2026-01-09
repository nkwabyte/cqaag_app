// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for MembershipService

@ProviderFor(membershipService)
final membershipServiceProvider = MembershipServiceProvider._();

/// Provider for MembershipService

final class MembershipServiceProvider
    extends
        $FunctionalProvider<
          MembershipService,
          MembershipService,
          MembershipService
        >
    with $Provider<MembershipService> {
  /// Provider for MembershipService
  MembershipServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membershipServiceHash();

  @$internal
  @override
  $ProviderElement<MembershipService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MembershipService create(Ref ref) {
    return membershipService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MembershipService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MembershipService>(value),
    );
  }
}

String _$membershipServiceHash() => r'374c1704db297869f10788475db9f209b32eff9a';
