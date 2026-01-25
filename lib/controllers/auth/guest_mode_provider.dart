import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cqaag_app/models/auth_mode.dart';

part 'guest_mode_provider.g.dart';

/// Provider to manage guest mode state
@riverpod
class GuestMode extends _$GuestMode {
  @override
  AuthMode build() {
    return AuthMode.unauthenticated;
  }

  /// Enable guest mode
  void enableGuestMode() {
    state = AuthMode.guest;
  }

  /// Disable guest mode (when user logs in or signs up)
  void disableGuestMode() {
    state = AuthMode.unauthenticated;
  }

  /// Set authenticated mode
  void setAuthenticated() {
    state = AuthMode.authenticated;
  }

  /// Check if user is in guest mode
  bool get isGuest => state == AuthMode.guest;

  /// Check if user is authenticated
  bool get isAuthenticated => state == AuthMode.authenticated;
}
