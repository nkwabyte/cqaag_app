import 'package:cqaag_app/index.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_controller.g.dart';
part 'subscription_controller.freezed.dart';

/// Provider for SubscriptionService
@riverpod
SubscriptionService subscriptionService(Ref ref) {
  return SubscriptionService();
}

/// State for subscription operations
@freezed
abstract class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState({
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    String? errorMessage,
  }) = _SubscriptionState;
}

/// Controller for handling subscription operations
@riverpod
class SubscriptionController extends _$SubscriptionController {
  @override
  SubscriptionState build() {
    return const SubscriptionState();
  }

  /// Subscribe an email to the newsletter
  Future<void> subscribe(String email) async {
    // Validate email
    if (email.trim().isEmpty) {
      state = const SubscriptionState(
        errorMessage: 'Please enter your email address',
      );
      return;
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      state = const SubscriptionState(
        errorMessage: 'Please enter a valid email address',
      );
      return;
    }

    // Set loading state
    state = const SubscriptionState(isLoading: true);

    try {
      final service = ref.read(subscriptionServiceProvider);
      await service.subscribe(email);

      // Success
      state = const SubscriptionState(isSuccess: true);
    } catch (e) {
      // Error
      state = SubscriptionState(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Reset the state
  void reset() {
    state = const SubscriptionState();
  }
}
