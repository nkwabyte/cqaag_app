import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cqaag_app/index.dart';

class TermsAndConditionsScreen extends HookConsumerWidget {
  static const String id = 'terms_conditions_screen';

  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProfileProvider).value;
    final isAuthenticated = user != null;

    final isLoading = useState(false);

    Future<void> handleAcceptance() async {
      if (isAuthenticated) {
        try {
          isLoading.value = true;
          await ref.read(userServiceProvider).updateUserData(user.id, {'has_accepted_terms': true});
          if (context.mounted) {
            context.goNamed(DashboardScreen.id);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating profile: $e')),
            );
          }
        } finally {
          isLoading.value = false;
        }
      } else {
        context.goNamed(DashboardScreen.id);
      }
    }

    // Arriving straight from registration there is nothing to go back to.
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final fromRegister = extra?['fromRegister'] as bool? ?? false;

    final needsAcceptance = !isAuthenticated || !user.hasAcceptedTerms;

    return LegalDocumentReader(
      type: LegalDocumentType.termsOfService,
      showBack: !fromRegister,
      footer: needsAcceptance
          ? Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "By continuing, you also acknowledge our ",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
                      ),
                      InkWell(
                        onTap: () => context.pushNamed(PrivacyPolicyScreen.id),
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        " in full.",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  Gap(12.h),
                  CustomButton(
                    text: "I Accept and Continue to Dashboard",
                    isLoading: isLoading.value,
                    onPressed: handleAcceptance,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
