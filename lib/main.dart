import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cqaag_app/core/index.dart';

import 'package:cqaag_app/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(ProviderScope(child: MyApp(savedThemeMode: savedThemeMode)));
}

class MyApp extends ConsumerWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard mobile design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return AdaptiveTheme(
          light: AppTheme.lightTheme,
          dark: AppTheme.darkTheme,
          initial: savedThemeMode ?? AdaptiveThemeMode.light,
          builder: (theme, darkTheme) => MaterialApp.router(
            title: 'CQAAG App',
            theme: theme,
            darkTheme: darkTheme,
            routerConfig: router,
          ),
        );
      },
    );
  }
}
