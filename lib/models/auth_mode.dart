/// Enum to represent the authentication mode of the user
enum AuthMode {
  /// User is authenticated with a valid account
  authenticated,

  /// User is using the app as a guest without authentication
  guest,

  /// User is not authenticated and not in guest mode
  unauthenticated,
}
