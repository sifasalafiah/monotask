import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/database/local_storage_service.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../gamification/state/gamification_provider.dart';
import '../home/presentation/main_navigation_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onFinish() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setOnboardingCompleted();
    if (!mounted) return;

    // Check if UMP consent is required (EU/EEA geography).
    // canRequestAds() returns false when consent hasn't been obtained yet.
    final consentRequired = !await ConsentInformation.instance.canRequestAds();

    if (!mounted) return;

    if (consentRequired) {
      // --- Eligible: Onboard → Consent → 3s → Paywall ---
      // Show Google's native UMP consent form, then proceed.
      await _showConsentForm();
    }

    if (!mounted) return;
    // --- Both paths land here → 3s → Paywall ---
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _PostOnboardingGate()),
    );
  }

  Future<void> _showConsentForm() async {
    final completer = _SimpleCompleter();
    ConsentForm.loadAndShowConsentFormIfRequired((formError) {
      if (formError != null) {
        debugPrint('UMP consent form error: ${formError.message}');
      }
      completer.complete();
    });
    return completer.future;
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final profile = ref.watch(gamificationProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);

    final pages = [
      _OnboardPage(
        icon: Icons.timer_rounded,
        title: s.onboarding1Title,
        subtitle: s.onboarding1Subtitle,
        color: theme.primary,
        theme: theme,
      ),
      _OnboardPage(
        icon: Icons.pets_rounded,
        title: s.onboarding2Title,
        subtitle: s.onboarding2Subtitle,
        color: Colors.amber,
        theme: theme,
      ),
      _OnboardPage(
        icon: Icons.shield_rounded,
        title: s.onboarding3Title,
        subtitle: s.onboarding3Subtitle,
        color: const Color(0xFF10B981),
        theme: theme,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button top-right
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 16, 0),
                child: TextButton(
                  onPressed: _onFinish,
                  child: Text(
                    s.onboardingSkip,
                    style: TextStyle(color: theme.textSecondary, fontSize: 14),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: pages,
              ),
            ),

            // Dots indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.primary
                          : theme.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    shadowColor: theme.primary.withValues(alpha: 0.4),
                  ),
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage < 2 ? s.onboardingNext : s.onboardingGetStarted,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final AppThemeData theme;

  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration container
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
            ),
            child: Icon(icon, size: 68, color: color),
          ),
          const SizedBox(height: 44),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: theme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Handles the 3-second wait then shows paywall
class _PostOnboardingGate extends ConsumerStatefulWidget {
  const _PostOnboardingGate();

  @override
  ConsumerState<_PostOnboardingGate> createState() => _PostOnboardingGateState();
}

class _PostOnboardingGateState extends ConsumerState<_PostOnboardingGate> {
  @override
  void initState() {
    super.initState();
    _proceed();
  }

  Future<void> _proceed() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // Pass showPaywallOnStart=true so MainNavigationScreen handles the
    // 3s delay + paywall from its own mounted context (not from this
    // widget which gets disposed immediately after pushReplacement).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(showPaywallOnStart: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(gamificationProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);
    return Scaffold(
      backgroundColor: theme.background,
      body: Center(
        child: CircularProgressIndicator(color: theme.primary),
      ),
    );
  }
}

/// Minimal Completer to bridge UMP callback API to Future.
class _SimpleCompleter {
  final _c = Completer<void>();
  bool _done = false;

  Future<void> get future => _c.future;

  void complete() {
    if (!_done) {
      _done = true;
      _c.complete();
    }
  }
}
