import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/ads/ad_service.dart';
import 'core/database/local_storage_service.dart';
import 'core/localization/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/gamification/state/gamification_provider.dart';
import 'features/home/presentation/main_navigation_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storageService = LocalStorageService(prefs);
  await storageService.init();

  // --- UMP Consent (must run before MobileAds.initialize) ---
  // In debug builds: always simulate EEA geography so consent form always shows.
  // Replace testDeviceId with the hash printed in logcat on first run.
  await gatherConsent(
    forceEea: kDebugMode,
    testDeviceId: kDebugMode ? '7DE9ED6305EE99978DF6F5CAD00ED1C9' : null,
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localStorageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MonotaskApp(),
    ),
  );
}

class MonotaskApp extends ConsumerStatefulWidget {
  const MonotaskApp({super.key});

  @override
  ConsumerState<MonotaskApp> createState() => _MonotaskAppState();
}

class _MonotaskAppState extends ConsumerState<MonotaskApp> {
  @override
  void initState() {
    super.initState();
    _initAds();
  }

  Future<void> _initAds() async {
    final adService = ref.read(adServiceProvider);
    await adService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(gamificationProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);
    final s = ref.watch(stringsProvider);
    final storage = ref.read(localStorageServiceProvider);

    return MaterialApp(
      title: s.appName,
      debugShowCheckedModeBanner: false,
      theme: theme.toThemeData(),
      home: storage.getOnboardingCompleted()
          ? const MainNavigationScreen()
          : const OnboardingScreen(),
    );
  }
}
