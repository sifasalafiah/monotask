import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/local_storage_service.dart';

// ---------------------------------------------------------------------------
// Ad Unit IDs
// Debug builds → Google test ad unit IDs (safe, always show test ads)
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
// UMP Consent helper
// ---------------------------------------------------------------------------

/// Run UMP consent flow:
/// 1. requestConsentInfoUpdate
/// 2. loadAndShowConsentFormIfRequired  (shows native Google consent form if needed)
/// 3. Returns true when done (whether consent was shown or not)
///
/// In debug builds, pass [testDeviceId] (printed to logcat on first run) and
/// set [forceEea] = true to simulate EU geography on any device.
Future<void> gatherConsent({
  String? testDeviceId,
  bool forceEea = false,
}) async {
  final params = kDebugMode
      ? ConsentRequestParameters(
          consentDebugSettings: ConsentDebugSettings(
            testIdentifiers: testDeviceId != null ? [testDeviceId] : [],
            debugGeography: forceEea
                ? DebugGeography.debugGeographyEea
                : DebugGeography.debugGeographyDisabled,
          ),
        )
      : ConsentRequestParameters();

  final completer = _UmpCompleter();

  ConsentInformation.instance.requestConsentInfoUpdate(
    params,
    () async {
      // Consent info updated — show form if required
      ConsentForm.loadAndShowConsentFormIfRequired((formError) {
        if (formError != null) {
          debugPrint('UMP form error: ${formError.message}');
        }
        completer.complete();
      });
    },
    (FormError error) {
      debugPrint('UMP requestConsentInfoUpdate error: ${error.message}');
      completer.complete(); // Don't block ads on consent error
    },
  );

  return completer.future;
}

/// Minimal completer to bridge callback-style UMP API to Future.
class _UmpCompleter {
  final _inner = Completer<void>();
  bool _completed = false;

  Future<void> get future => _inner.future;

  void complete() {
    if (!_completed) {
      _completed = true;
      _inner.complete();
    }
  }
}

// ---------------------------------------------------------------------------
// AdMob Service — initialization + App Open Ad
// ---------------------------------------------------------------------------
class AdService {
  final LocalStorageService _storage;
  AppOpenAd? _appOpenAd;
  bool _isLoadingAppOpen = false;
  DateTime? _appOpenLoadTime;

  AdService(this._storage);

  bool get _showAds => !_storage.getIsPro();

  /// Initialize MobileAds SDK after UMP consent has been gathered.
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadAppOpenAd();
  }

  void _loadAppOpenAd() {
    if (!_showAds || _isLoadingAppOpen) return;
    _isLoadingAppOpen = true;

    AppOpenAd.load(
      adUnitId: AdIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          _isLoadingAppOpen = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed: $error');
          _isLoadingAppOpen = false;
        },
      ),
    );
  }

  bool get _isAppOpenAdAvailable {
    if (_appOpenAd == null || _appOpenLoadTime == null) return false;
    return DateTime.now().difference(_appOpenLoadTime!) < const Duration(hours: 4);
  }

  Future<void> showAppOpenAdIfAvailable() async {
    if (!_showAds) return;
    if (!_isAppOpenAdAvailable) {
      _loadAppOpenAd();
      return;
    }
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
    );
    await _appOpenAd!.show();
  }

  bool get shouldShowAds => _showAds;

  AdRequest get adRequest => const AdRequest();
}

final adServiceProvider = Provider<AdService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return AdService(storage);
});
