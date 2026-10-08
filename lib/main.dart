import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cqaag_app/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forward framework errors to console
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER_FRAMEWORK_ERROR: ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PLATFORM_DISPATCHER_ERROR: $error\n$stack');
    return true;
  };

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('.env load warning: $e');
  }

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      debugPrint('Firestore settings warning: $e');
    }
  } catch (e, stack) {
    debugPrint('Firebase.initializeApp warning: $e\n$stack');
  }

  AdaptiveThemeMode? savedThemeMode;
  try {
    savedThemeMode = await AdaptiveTheme.getThemeMode();
  } catch (e) {
    debugPrint('AdaptiveTheme mode warning: $e');
  }

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
          builder: (ThemeData theme, ThemeData darkTheme) {
            return MaterialApp.router(
              title: 'C.Q.A.A.G App',
              theme: theme,
              debugShowCheckedModeBanner: false,
              darkTheme: darkTheme,
              routerConfig: router,
            );
          },
        );
      },
    );
  }
}
