import 'package:firebase_auth/firebase_auth.dart';

/// Utility class to map Firebase error codes to user-friendly messages
class FirebaseErrorMapper {
  /// Map Firebase Auth error codes to user-friendly messages
  static String mapAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        // Email/Password Authentication Errors
        case 'invalid-email':
          return 'The email address is not valid. Please check and try again.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'user-not-found':
          return 'No account found with this email. Please sign up first.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account with this email already exists. Please sign in instead.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled. Please contact support.';
        case 'weak-password':
          return 'Password is too weak. Please use at least 8 characters with letters and numbers.';

        // Account Management Errors
        case 'requires-recent-login':
          return 'For security, please sign in again to continue.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with this email using a different sign-in method.';
        case 'credential-already-in-use':
          return 'This credential is already associated with a different account.';

        // Network & Server Errors
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a moment and try again.';
        case 'internal-error':
          return 'An internal error occurred. Please try again later.';

        // Token & Session Errors
        case 'invalid-credential':
          return 'Invalid credentials. Please check your email and password.';
        case 'invalid-verification-code':
          return 'Invalid verification code. Please check and try again.';
        case 'invalid-verification-id':
          return 'Verification session expired. Please request a new code.';
        case 'session-expired':
          return 'Your session has expired. Please sign in again.';

        // Phone Authentication Errors
        case 'invalid-phone-number':
          return 'Invalid phone number format. Please check and try again.';
        case 'missing-phone-number':
          return 'Please enter a phone number.';
        case 'quota-exceeded':
          return 'SMS quota exceeded. Please try again later.';

        // Multi-factor Authentication Errors
        case 'multi-factor-auth-required':
          return 'Additional verification required. Please complete the authentication.';
        case 'maximum-second-factor-count-exceeded':
          return 'Maximum number of second factors reached.';

        // Password Reset Errors
        case 'expired-action-code':
          return 'This reset link has expired. Please request a new one.';
        case 'invalid-action-code':
          return 'This reset link is invalid. Please request a new one.';

        // Custom Token Errors
        case 'invalid-custom-token':
          return 'Invalid authentication token. Please sign in again.';
        case 'custom-token-mismatch':
          return 'Authentication token mismatch. Please sign in again.';

        default:
          return 'Authentication failed. Please try again.';
      }
    }

    // Handle Firestore errors
    if (error is FirebaseException) {
      return mapFirestoreError(error);
    }

    // Generic error handling
    return _extractErrorMessage(error);
  }

  /// Map Firestore error codes to user-friendly messages
  static String mapFirestoreError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This data already exists.';
      case 'resource-exhausted':
        return 'Service quota exceeded. Please try again later.';
      case 'failed-precondition':
        return 'Operation cannot be performed in the current state.';
      case 'aborted':
        return 'Operation was aborted. Please try again.';
      case 'out-of-range':
        return 'Invalid data range provided.';
      case 'unimplemented':
        return 'This feature is not yet available.';
      case 'internal':
        return 'An internal error occurred. Please try again later.';
      case 'unavailable':
        return 'Service is currently unavailable. Please try again later.';
      case 'data-loss':
        return 'Data loss detected. Please contact support.';
      case 'unauthenticated':
        return 'Please sign in to continue.';
      case 'deadline-exceeded':
        return 'Operation timed out. Please try again.';
      case 'cancelled':
        return 'Operation was cancelled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Extract a clean error message from various error types
  static String _extractErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred.';

    String message = error.toString();

    // Remove common prefixes
    message = message
        .replaceAll('Exception: ', '')
        .replaceAll(
          'Error: ',
          '',
        )
        .replaceAll('[firebase_auth/', '')
        .replaceAll('[cloud_firestore/', '')
        .replaceAll(']', '')
        .trim();

    // If message is still technical, provide generic message
    if (message.isEmpty || message.length > 200) {
      return 'An error occurred. Please try again.';
    }

    return message;
  }

  /// Get a user-friendly error message from any error
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException || error is FirebaseException) {
      return mapAuthError(error);
    }
    return _extractErrorMessage(error);
  }
}
