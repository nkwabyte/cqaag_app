import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cqaag_app/index.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  // Use a ValueNotifier to hold the auth state.
  // This allows us to listen to changes without rebuilding the GoRouter invocation itself.
  final authNotifier = ValueNotifier<AsyncValue<User?>>(const AsyncLoading());

  // Initialize with current state if available (though usually starts loading)
  if (ref.exists(authStateProvider)) {
    authNotifier.value = ref.read(authStateProvider);
  }

  // Listen to the provider and update the notifier
  ref.listen(authStateProvider, (_, next) {
    authNotifier.value = next;
  });

  // Dispose the notifier when the provider is disposed
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.value;
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final isLoggedIn = authState.asData?.value != null;

      final isSplash = state.uri.path == '/';
      final isBoarding = state.uri.path == '/${BoardingScreen.id}';
      final isLogin = state.uri.path == '/${LoginScreen.id}';
      final isRegister = state.uri.path == '/${RegisterScreen.id}';
      final isForgotPassword = state.uri.path == '/${ForgotPasswordScreen.id}';

      final isPublicRoute = isSplash || isBoarding || isLogin || isRegister || isForgotPassword;

      if (isLoading || hasError) return null;

      if (isLoggedIn) {
        // If logged in and on a public route (Splash, Boarding, Login, Register), redirect to Dashboard
        if (isPublicRoute && !isSplash) {
          return '/${DashboardScreen.id}';
        }
      } else {
        // If not logged in and on a protected route, redirect to Login
        if (!isPublicRoute) {
          return '/${LoginScreen.id}';
        }
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: SplashScreen.id,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/${BoardingScreen.id}',
        name: BoardingScreen.id,
        builder: (context, state) => const BoardingScreen(),
      ),
      GoRoute(
        path: '/${LoginScreen.id}',
        name: LoginScreen.id,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/${RegisterScreen.id}',
        name: RegisterScreen.id,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/${ForgotPasswordScreen.id}',
        name: ForgotPasswordScreen.id,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/${TermsAndConditionsScreen.id}',
        name: TermsAndConditionsScreen.id,
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),
      GoRoute(
        path: '/${MembershipApplicationScreen.id}',
        name: MembershipApplicationScreen.id,
        builder: (context, state) => const MembershipApplicationScreen(),
      ),
      GoRoute(
        path: '/${DashboardScreen.id}',
        name: DashboardScreen.id,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/${AdminDashboardScreen.id}',
        name: AdminDashboardScreen.id,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      // History flow routes
      GoRoute(
        path: '/${DistrictDetailScreen.id}',
        name: DistrictDetailScreen.id,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final district = extras['district'] as String;
          final inspections = extras['inspections'] as List<Inspection>;
          return DistrictDetailScreen(district: district, inspections: inspections);
        },
      ),
      GoRoute(
        path: '/${TownDetailScreen.id}',
        name: TownDetailScreen.id,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final town = extras['town'] as String;
          final inspections = extras['inspections'] as List<Inspection>;
          return TownDetailScreen(town: town, inspections: inspections);
        },
      ),
      // Home flow routes
      GoRoute(
        path: '/${QualityInspectionWizard.id}',
        name: QualityInspectionWizard.id,
        builder: (context, state) => const QualityInspectionWizard(),
      ),
      GoRoute(
        path: '/${QualityResultScreen.id}',
        name: QualityResultScreen.id,
        builder: (context, state) {
          final inspection = state.extra as Inspection;
          return QualityResultScreen(inspection: inspection);
        },
      ),
      GoRoute(
        path: '/${TraceabilityScreen.id}',
        name: TraceabilityScreen.id,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Inspection) {
            return Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: const Center(child: Text("Inspection data not found")),
            );
          }
          return TraceabilityScreen(inspection: extra);
        },
      ),
      // Profile/Membership routes
      GoRoute(
        path: '/${CodeOfEthicsScreen.id}',
        name: CodeOfEthicsScreen.id,
        builder: (context, state) => const CodeOfEthicsScreen(),
      ),
      GoRoute(
        path: '/${ConstitutionScreen.id}',
        name: ConstitutionScreen.id,
        builder: (context, state) => const ConstitutionScreen(),
      ),
      GoRoute(
        path: '/${MembershipAgreementScreen.id}',
        name: MembershipAgreementScreen.id,
        builder: (context, state) {
          final applicationData = state.extra as Map<String, dynamic>?;
          return MembershipAgreementScreen(applicationData: applicationData ?? {});
        },
      ),

      // Admin Details Routes
      GoRoute(
        path: '/${AdminUserDetailScreen.id}',
        name: AdminUserDetailScreen.id,
        builder: (context, state) {
          final user = state.extra as AppUser;
          return AdminUserDetailScreen(user: user);
        },
      ),
      GoRoute(
        path: '/${AdminMemberDetailScreen.id}',
        name: AdminMemberDetailScreen.id,
        builder: (context, state) {
          final app = state.extra as MembershipApplication;
          return AdminMemberDetailScreen(application: app);
        },
      ),
      GoRoute(
        path: '/${VerificationUploadScreen.id}',
        name: VerificationUploadScreen.id,
        builder: (context, state) => const VerificationUploadScreen(),
      ),
      GoRoute(
        path: '/${EditProfileScreen.id}',
        name: EditProfileScreen.id,
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
}
