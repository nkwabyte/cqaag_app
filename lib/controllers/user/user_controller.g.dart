// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserController)
final userControllerProvider = UserControllerProvider._();

final class UserControllerProvider
    extends $StreamNotifierProvider<UserController, UserState> {
  UserControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userControllerHash();

  @$internal
  @override
  UserController create() => UserController();
}

String _$userControllerHash() => r'e0f3b18c7f03fb1e347ca71cdbaa61a99c467d00';

abstract class _$UserController extends $StreamNotifier<UserState> {
  Stream<UserState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserState>, UserState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserState>, UserState>,
              AsyncValue<UserState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(UserFilter)
final userFilterProvider = UserFilterProvider._();

final class UserFilterProvider extends $NotifierProvider<UserFilter, String> {
  UserFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userFilterHash();

  @$internal
  @override
  UserFilter create() => UserFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$userFilterHash() => r'ed59a74f56e225f9c1521aee1d374b82c6243b61';

abstract class _$UserFilter extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredUsers)
final filteredUsersProvider = FilteredUsersProvider._();

final class FilteredUsersProvider
    extends $FunctionalProvider<List<AppUser>, List<AppUser>, List<AppUser>>
    with $Provider<List<AppUser>> {
  FilteredUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredUsersHash();

  @$internal
  @override
  $ProviderElement<List<AppUser>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<AppUser> create(Ref ref) {
    return filteredUsers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AppUser> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AppUser>>(value),
    );
  }
}

String _$filteredUsersHash() => r'4af030b5eec8d7033eb2a49518de0eb62590692e';

@ProviderFor(inspectorProfile)
final inspectorProfileProvider = InspectorProfileFamily._();

final class InspectorProfileProvider
    extends
        $FunctionalProvider<AsyncValue<AppUser?>, AppUser?, FutureOr<AppUser?>>
    with $FutureModifier<AppUser?>, $FutureProvider<AppUser?> {
  InspectorProfileProvider._({
    required InspectorProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'inspectorProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inspectorProfileHash();

  @override
  String toString() {
    return r'inspectorProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AppUser?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppUser?> create(Ref ref) {
    final argument = this.argument as String;
    return inspectorProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InspectorProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inspectorProfileHash() => r'5a279e380324ee804e26e818339b567ef35799e2';

final class InspectorProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AppUser?>, String> {
  InspectorProfileFamily._()
    : super(
        retry: null,
        name: r'inspectorProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InspectorProfileProvider call(String userId) =>
      InspectorProfileProvider._(argument: userId, from: this);

  @override
  String toString() => r'inspectorProfileProvider';
}
