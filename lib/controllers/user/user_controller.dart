import 'package:cqaag_app/models/user/app_user.dart';
import 'package:cqaag_app/services/index.dart'; // Exporting user_service.dart via index later
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_controller.g.dart';

@riverpod
class UserController extends _$UserController {
  @override
  FutureOr<void> build() {
    // Initial state is void
  }

  Future<void> updateUserStatus(String userId, AppUserStatus status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(userServiceProvider).updateUserStatus(userId, status));
  }
}

// Filter provider for searching users
@riverpod
class UserFilter extends _$UserFilter {
  @override
  String build() => '';

  void setFilter(String query) {
    state = query;
  }
}

// Provider for all users, filtered by the search query
@riverpod
Stream<List<AppUser>> filteredUsers(Ref ref) {
  final userService = ref.watch(userServiceProvider);
  final filter = ref.watch(userFilterProvider);

  return userService.streamAllUsers().map((users) {
    if (filter.isEmpty) return users;

    final query = filter.toLowerCase();
    return users.where((user) {
      final matchesName = '${user.firstName} ${user.lastName}'.toLowerCase().contains(query);
      final matchesEmail = user.email.toLowerCase().contains(query);
      final matchesPhone = user.phoneNumber?.toLowerCase().contains(query) ?? false;
      return matchesName || matchesEmail || matchesPhone;
    }).toList();
  });
}
