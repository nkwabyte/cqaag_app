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
    extends
        $AsyncNotifierProvider<MembershipController, MembershipApplication?> {
  /// Controller for managing membership application state
  MembershipControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipControllerProvider',
        isAutoDispose: true,
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
    r'71348979fcd6bf922a2ab3781f6cd9f732c1ee33';

/// Controller for managing membership application state

abstract class _$MembershipController
    extends $AsyncNotifier<MembershipApplication?> {
  FutureOr<MembershipApplication?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<MembershipApplication?>, MembershipApplication?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<MembershipApplication?>,
                MembershipApplication?
              >,
              AsyncValue<MembershipApplication?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider to stream user's membership application

@ProviderFor(userMembershipApplication)
final userMembershipApplicationProvider = UserMembershipApplicationFamily._();

/// Provider to stream user's membership application

final class UserMembershipApplicationProvider
    extends
        $FunctionalProvider<
          AsyncValue<MembershipApplication?>,
          MembershipApplication?,
          Stream<MembershipApplication?>
        >
    with
        $FutureModifier<MembershipApplication?>,
        $StreamProvider<MembershipApplication?> {
  /// Provider to stream user's membership application
  UserMembershipApplicationProvider._({
    required UserMembershipApplicationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userMembershipApplicationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userMembershipApplicationHash();

  @override
  String toString() {
    return r'userMembershipApplicationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<MembershipApplication?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MembershipApplication?> create(Ref ref) {
    final argument = this.argument as String;
    return userMembershipApplication(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserMembershipApplicationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userMembershipApplicationHash() =>
    r'5ae05499282efe7f5fe0148237be1f34d3e433eb';

/// Provider to stream user's membership application

final class UserMembershipApplicationFamily extends $Family
    with $FunctionalFamilyOverride<Stream<MembershipApplication?>, String> {
  UserMembershipApplicationFamily._()
    : super(
        retry: null,
        name: r'userMembershipApplicationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to stream user's membership application

  UserMembershipApplicationProvider call(String userId) =>
      UserMembershipApplicationProvider._(argument: userId, from: this);

  @override
  String toString() => r'userMembershipApplicationProvider';
}

/// Provider to stream a specific application by ID

@ProviderFor(membershipApplicationById)
final membershipApplicationByIdProvider = MembershipApplicationByIdFamily._();

/// Provider to stream a specific application by ID

final class MembershipApplicationByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<MembershipApplication?>,
          MembershipApplication?,
          Stream<MembershipApplication?>
        >
    with
        $FutureModifier<MembershipApplication?>,
        $StreamProvider<MembershipApplication?> {
  /// Provider to stream a specific application by ID
  MembershipApplicationByIdProvider._({
    required MembershipApplicationByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'membershipApplicationByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$membershipApplicationByIdHash();

  @override
  String toString() {
    return r'membershipApplicationByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<MembershipApplication?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MembershipApplication?> create(Ref ref) {
    final argument = this.argument as String;
    return membershipApplicationById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MembershipApplicationByIdProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$membershipApplicationByIdHash() =>
    r'e881915dc8cb46ef5e7fcf0e65d052accd860fc1';

/// Provider to stream a specific application by ID

final class MembershipApplicationByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<MembershipApplication?>, String> {
  MembershipApplicationByIdFamily._()
    : super(
        retry: null,
        name: r'membershipApplicationByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to stream a specific application by ID

  MembershipApplicationByIdProvider call(String applicationId) =>
      MembershipApplicationByIdProvider._(argument: applicationId, from: this);

  @override
  String toString() => r'membershipApplicationByIdProvider';
}

/// Provider to stream all applications (for admin use)

@ProviderFor(allMembershipApplications)
final allMembershipApplicationsProvider = AllMembershipApplicationsProvider._();

/// Provider to stream all applications (for admin use)

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
  /// Provider to stream all applications (for admin use)
  AllMembershipApplicationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allMembershipApplicationsProvider',
        isAutoDispose: true,
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
    r'34d947ae4c25ca56a5f5ca966e51577b89bf94c4';
