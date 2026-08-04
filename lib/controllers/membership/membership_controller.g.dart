// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing membership application state

@ProviderFor(MembershipController)
final membershipControllerProvider = MembershipControllerProvider._();

/// Controller for managing membership application state
final class MembershipControllerProvider
    extends $StreamNotifierProvider<MembershipController, MembershipState> {
  /// Controller for managing membership application state
  MembershipControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membershipControllerHash();

  @$internal
  @override
  MembershipController create() => MembershipController();
}

String _$membershipControllerHash() =>
    r'9491fc173e89b3620acecf01bfc65be06e5597b9';

/// Controller for managing membership application state

abstract class _$MembershipController extends $StreamNotifier<MembershipState> {
  Stream<MembershipState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MembershipState>, MembershipState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MembershipState>, MembershipState>,
              AsyncValue<MembershipState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for all membership applications (Admin)

@ProviderFor(allMembershipApplications)
final allMembershipApplicationsProvider = AllMembershipApplicationsProvider._();

/// Provider for all membership applications (Admin)

final class AllMembershipApplicationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MembershipApplication>>,
          List<MembershipApplication>,
          Stream<List<MembershipApplication>>
        >
    with
        $FutureModifier<List<MembershipApplication>>,
        $StreamProvider<List<MembershipApplication>> {
  /// Provider for all membership applications (Admin)
  AllMembershipApplicationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allMembershipApplicationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allMembershipApplicationsHash();

  @$internal
  @override
  $StreamProviderElement<List<MembershipApplication>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MembershipApplication>> create(Ref ref) {
    return allMembershipApplications(ref);
  }
}

String _$allMembershipApplicationsHash() =>
    r'4ab4cd1e0f01d96e0f7b77b916321d1bb4d3f4ae';
