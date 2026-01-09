import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cqaag_app/services/index.dart';
import 'package:cqaag_app/views/index.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final isLoggedIn = authState.asData?.value != null;

      final isSplash = state.uri.path == '/';
      final isBoarding = state.uri.path == '/${BoardingScreen.id}';
      final isLogin = state.uri.path == '/${LoginScreen.id}';
      final isRegister = state.uri.path == '/${RegisterScreen.id}';

      final isPublicRoute = isSplash || isBoarding || isLogin || isRegister;

      if (isLoading || hasError) return null;

      if (isLoggedIn) {
        // If logged in and on a public route (Splash, Boarding, Login, Register), redirect to Dashboard
        if (isPublicRoute) {
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
    routes: [
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
      // History flow routes
      GoRoute(
        path: '/${DistrictDetailScreen.id}',
        name: DistrictDetailScreen.id,
        builder: (context, state) => const DistrictDetailScreen(),
      ),
      GoRoute(
        path: '/${TownDetailScreen.id}',
        name: TownDetailScreen.id,
        builder: (context, state) => const TownDetailScreen(),
      ),
      // Home flow routes
      GoRoute(
        path: '/${QualityResultScreen.id}',
        name: QualityResultScreen.id,
        builder: (context, state) => const QualityResultScreen(),
      ),
      GoRoute(
        path: '/${TraceabilityScreen.id}',
        name: TraceabilityScreen.id,
        builder: (context, state) => const TraceabilityScreen(),
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
    ],
  );
}
