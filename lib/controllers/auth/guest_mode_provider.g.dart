// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to manage guest mode state

@ProviderFor(GuestMode)
final guestModeProvider = GuestModeProvider._();

/// Provider to manage guest mode state
final class GuestModeProvider extends $NotifierProvider<GuestMode, AuthMode> {
  /// Provider to manage guest mode state
  GuestModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guestModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guestModeHash();

  @$internal
  @override
  GuestMode create() => GuestMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthMode>(value),
    );
  }
}

String _$guestModeHash() => r'48c864bf2b86f16712214715436ee7e04f94d0b1';

/// Provider to manage guest mode state

abstract class _$GuestMode extends $Notifier<AuthMode> {
  AuthMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthMode, AuthMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthMode, AuthMode>,
              AuthMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
