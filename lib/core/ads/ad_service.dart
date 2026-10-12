import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_storage_service.dart';

// ---------------------------------------------------------------------------
// Ad Unit IDs
// Debug builds → Google test ad unit IDs
// Release builds → production IDs
// ---------------------------------------------------------------------------
class AdIds {
  static String get appOpen {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9257395921'
          : 'ca-app-pub-3940256099942544/5575463023';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-4676075129526023/6634537516'
        : 'ca-app-pub-4676075129526023/2317027712';
  }

  static String get native {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/2247696110'
          : 'ca-app-pub-3940256099942544/3986624511';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-4676075129526023/4555169084'
        : 'ca-app-pub-4676075129526023/1382210830';
  }

  static String get rewarded {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-4676075129526023/7947619187'
        : 'ca-app-pub-4676075129526023/2695292506';
  }
}

// ---------------------------------------------------------------------------
// AdMob Service — initialization + App Open Ad on resume
// ---------------------------------------------------------------------------
class AdService with WidgetsBindingObserver {
  final LocalStorageService _storage;

  AppOpenAd? _appOpenAd;
  bool _isLoadingAppOpen = false;
  DateTime? _appOpenLoadTime;

  /// Prevents showing App Open Ad on top of another full-screen ad
  bool _isShowingFullScreenAd = false;
  DateTime? _lastFullScreenAdDismissedTime;

  /// Skip App Open Ad on the very first launch (cold start)
  bool _isFirstLaunch = true;

  AdService(this._storage);

  bool get _showAds => !_storage.getIsPro();

  Future<void> initialize() async {
    // Update consent info silently on every launch (required by UMP SDK).
    _updateConsentInfo();

    await MobileAds.instance.initialize();

    // Register lifecycle observer so we can show App Open Ad on resume.
    WidgetsBinding.instance.addObserver(this);

    _loadAppOpenAd();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAd?.dispose();
  }

  // ---------------------------------------------------------------------------
  // App Lifecycle — show App Open Ad when app resumes from background
  // ---------------------------------------------------------------------------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isFirstLaunch) {
        // Cold start — skip this one, mark as done
        _isFirstLaunch = false;
        return;
      }
      if (_isShowingFullScreenAd) {
        // Returning from a rewarded/interstitial — don't stack ads
        return;
      }
      if (_lastFullScreenAdDismissedTime != null &&
          DateTime.now().difference(_lastFullScreenAdDismissedTime!) < const Duration(seconds: 4)) {
        // Just returned from dismissing an in-app ad (rewarded/interstitial)
        // Suppress App Open ad so it only shows when resuming from another external app
        return;
      }
      _showAppOpenAdIfAvailable();
    }
  }

  // ---------------------------------------------------------------------------
  // App Open Ad
  // ---------------------------------------------------------------------------
  void _loadAppOpenAd() {
    if (!_showAds || _isLoadingAppOpen || _appOpenAd != null) return;
    _isLoadingAppOpen = true;

    AppOpenAd.load(
      adUnitId: AdIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          _isLoadingAppOpen = false;
          debugPrint('AppOpenAd loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
          _isLoadingAppOpen = false;
        },
      ),
    );
  }

  bool get _isAppOpenAdAvailable {
    if (_appOpenAd == null || _appOpenLoadTime == null) return false;
    // Ads expire after 4 hours
    return DateTime.now().difference(_appOpenLoadTime!) < const Duration(hours: 4);
  }

  void _showAppOpenAdIfAvailable() {
    if (!_showAds || !_isAppOpenAdAvailable) {
      _loadAppOpenAd(); // pre-load for next time
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _isShowingFullScreenAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingFullScreenAd = false;
        _lastFullScreenAdDismissedTime = DateTime.now();
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AppOpenAd failed to show: $error');
        _isShowingFullScreenAd = false;
        _lastFullScreenAdDismissedTime = DateTime.now();
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
    );

    _appOpenAd!.show();
  }

  /// Call this before showing a rewarded/interstitial ad to prevent
  /// App Open Ad from appearing on top of it when the user returns.
  void setShowingFullScreenAd(bool value) {
    _isShowingFullScreenAd = value;
    if (!value) {
      _lastFullScreenAdDismissedTime = DateTime.now();
    }
  }

  // ---------------------------------------------------------------------------
  // UMP Consent info update (silent, every launch)
  // ---------------------------------------------------------------------------
  void _updateConsentInfo() {
    final params = kDebugMode
        ? ConsentRequestParameters(
            consentDebugSettings: ConsentDebugSettings(
              testIdentifiers: const ['7DE9ED6305EE99978DF6F5CAD00ED1C9'],
              debugGeography: DebugGeography.debugGeographyEea,
            ),
          )
        : ConsentRequestParameters();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () {},
      (error) => debugPrint('UMP info update error: ${error.message}'),
    );
  }

  bool get shouldShowAds => _showAds;
  AdRequest get adRequest => const AdRequest();
}

final adServiceProvider = Provider<AdService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return AdService(storage);
});
