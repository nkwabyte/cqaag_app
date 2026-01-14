// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InspectionController)
final inspectionControllerProvider = InspectionControllerProvider._();

final class InspectionControllerProvider
    extends $AsyncNotifierProvider<InspectionController, List<Inspection>> {
  InspectionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inspectionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inspectionControllerHash();

  @$internal
  @override
  InspectionController create() => InspectionController();
}

String _$inspectionControllerHash() =>
    r'83de2328b74bcc6fbc2dea1fcabb460fd2fddf98';

abstract class _$InspectionController extends $AsyncNotifier<List<Inspection>> {
  FutureOr<List<Inspection>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Inspection>>, List<Inspection>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Inspection>>, List<Inspection>>,
              AsyncValue<List<Inspection>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider to stream recent inspections for home screen

@ProviderFor(recentInspections)
final recentInspectionsProvider = RecentInspectionsProvider._();

/// Provider to stream recent inspections for home screen

final class RecentInspectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Inspection>>,
          List<Inspection>,
          Stream<List<Inspection>>
        >
    with $FutureModifier<List<Inspection>>, $StreamProvider<List<Inspection>> {
  /// Provider to stream recent inspections for home screen
  RecentInspectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentInspectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentInspectionsHash();

  @$internal
  @override
  $StreamProviderElement<List<Inspection>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Inspection>> create(Ref ref) {
    return recentInspections(ref);
  }
}

String _$recentInspectionsHash() => r'871c930f7e3163f012174fe6db9fbd9987b28475';

/// Provider to stream all completed inspections (for history screen - all users)

@ProviderFor(allCompletedInspections)
final allCompletedInspectionsProvider = AllCompletedInspectionsProvider._();

/// Provider to stream all completed inspections (for history screen - all users)

final class AllCompletedInspectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Inspection>>,
          List<Inspection>,
          Stream<List<Inspection>>
        >
    with $FutureModifier<List<Inspection>>, $StreamProvider<List<Inspection>> {
  /// Provider to stream all completed inspections (for history screen - all users)
  AllCompletedInspectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allCompletedInspectionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allCompletedInspectionsHash();

  @$internal
  @override
  $StreamProviderElement<List<Inspection>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Inspection>> create(Ref ref) {
    return allCompletedInspections(ref);
  }
}

String _$allCompletedInspectionsHash() =>
    r'089bb766f1191df530c928ab5f47f9c9ca0f82ea';

/// Provider to stream user's uncompleted inspections

@ProviderFor(userUncompletedInspections)
final userUncompletedInspectionsProvider =
    UserUncompletedInspectionsProvider._();

/// Provider to stream user's uncompleted inspections

final class UserUncompletedInspectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Inspection>>,
          List<Inspection>,
          Stream<List<Inspection>>
        >
    with $FutureModifier<List<Inspection>>, $StreamProvider<List<Inspection>> {
  /// Provider to stream user's uncompleted inspections
  UserUncompletedInspectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userUncompletedInspectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userUncompletedInspectionsHash();

  @$internal
  @override
  $StreamProviderElement<List<Inspection>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Inspection>> create(Ref ref) {
    return userUncompletedInspections(ref);
  }
}

String _$userUncompletedInspectionsHash() =>
    r'cb356824c312a12f76a0cd41e8109ac71b7eaa98';

/// Provider for prioritized inspections (uncompleted first, then recent completed)

@ProviderFor(userPrioritizedInspections)
final userPrioritizedInspectionsProvider =
    UserPrioritizedInspectionsProvider._();

/// Provider for prioritized inspections (uncompleted first, then recent completed)

final class UserPrioritizedInspectionsProvider
    extends
        $FunctionalProvider<
          List<Inspection>,
          List<Inspection>,
          List<Inspection>
        >
    with $Provider<List<Inspection>> {
  /// Provider for prioritized inspections (uncompleted first, then recent completed)
  UserPrioritizedInspectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPrioritizedInspectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPrioritizedInspectionsHash();

  @$internal
  @override
  $ProviderElement<List<Inspection>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Inspection> create(Ref ref) {
    return userPrioritizedInspections(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Inspection> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Inspection>>(value),
    );
  }
}

String _$userPrioritizedInspectionsHash() =>
    r'f07fc89618bf11957425b4a20bb3530d4480133a';
