import 'package:cqaag_app/index.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'user_controller.freezed.dart';
part 'user_controller.g.dart';

@freezed
abstract class UserState with _$UserState {
  const UserState._();

  const factory UserState({
    AppUser? currentUser,
    @Default([]) List<AppUser> allUsers,
    @Default(false) bool isLoading,
  }) = _UserState;

  bool get isAuthenticated => currentUser != null;
  bool get isAdmin => currentUser?.isAdmin ?? false;

  List<AppUser> get filteredUsers {
    return allUsers;
  }
}

@Riverpod(keepAlive: true)
class UserController extends _$UserController {
  @override
  Stream<UserState> build() {
    final authUser = ref.watch(authServiceProvider).currentUser;

    if (authUser == null) {
      return Stream.value(const UserState());
    }

    final userService = ref.watch(userServiceProvider);

    // Stream for the current user's profile
    final currentUserStream = userService.streamUser(authUser.uid);

    // Stream for all users (for admin purposes mostly, but good to have cached)
    // Be careful with large datasets. If users collection is huge, we might want to lazy load this.
    final allUsersStream = userService.streamAllUsers();

    return Rx.combineLatest2<AppUser?, List<AppUser>, UserState>(
      currentUserStream,
      allUsersStream,
      (currentUser, allUsers) {
        return UserState(
          currentUser: currentUser,
          allUsers: allUsers,
        );
      },
    );
  }

  /// Update user status (Admin only typically)
  Future<void> updateUserStatus(String userId, AppUserStatus status) async {
    await ref.read(userServiceProvider).updateUserStatus(userId, status);
  }

  /// Update own profile
  Future<void> updateProfile(AppUser user) async {
    await ref.read(userServiceProvider).updateUser(user);
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
// We can now derive this from the UserController state
@riverpod
List<AppUser> filteredUsers(Ref ref) {
  final userState = ref.watch(userControllerProvider).value;
  final filter = ref.watch(userFilterProvider);

  if (userState == null) return [];

  final users = userState.allUsers;

  if (filter.isEmpty) return users;

  final query = filter.toLowerCase();
  return users.where((user) {
    final matchesName = '${user.firstName} ${user.lastName}'.toLowerCase().contains(query);
    final matchesEmail = user.email.toLowerCase().contains(query);
    final matchesPhone = user.phoneNumber?.toLowerCase().contains(query) ?? false;

    return matchesName || matchesEmail || matchesPhone;
  }).toList();
}

// Provider to fetch inspector profile by ID - keep as future for specific lookups
@riverpod
Future<AppUser?> inspectorProfile(Ref ref, String userId) {
  final userService = ref.watch(userServiceProvider);
  return userService.getUserById(userId);
}
