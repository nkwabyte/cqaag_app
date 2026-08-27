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
    extends $StreamNotifierProvider<InspectionController, InspectionState> {
  InspectionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inspectionControllerProvider',
        isAutoDispose: false,
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
    r'7c3990fe6846eb309f8f82b1c781d0c89490c8a8';

abstract class _$InspectionController extends $StreamNotifier<InspectionState> {
  Stream<InspectionState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<InspectionState>, InspectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<InspectionState>, InspectionState>,
              AsyncValue<InspectionState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
