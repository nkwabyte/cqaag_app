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
    r'5ae7907a4a57afb227e48d3030538f12e20a4e95';

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
