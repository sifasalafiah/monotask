import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

class RewardedAdState {
  final bool isLoaded;
  final bool isLoading;

  const RewardedAdState({this.isLoaded = false, this.isLoading = false});
}

class RewardedAdNotifier extends StateNotifier<RewardedAdState> {
  final AdService _adService;
  RewardedAd? _ad;

  RewardedAdNotifier(this._adService) : super(const RewardedAdState());

  /// Requests a rewarded ad on demand with a timeout.
  /// Does NOT pre-load on startup.
  /// Returns the loaded [RewardedAd] if filled, or `null` if not filled/failed.
  Future<RewardedAd?> requestAd({Duration timeout = const Duration(seconds: 15)}) async {
    if (!_adService.shouldShowAds) return null;

    state = const RewardedAdState(isLoading: true);
    final completer = Completer<RewardedAd?>();

    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: _adService.adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          state = const RewardedAdState(isLoaded: true);
          if (!completer.isCompleted) {
            completer.complete(ad);
          } else {
            ad.dispose();
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          state = const RewardedAdState();
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      ),
    );

    try {
      final loadedAd = await completer.future.timeout(
        timeout,
        onTimeout: () {
          debugPrint('Rewarded ad request timed out');
          state = const RewardedAdState();
          return null;
        },
      );
      return loadedAd;
    } catch (e) {
      debugPrint('Error while requesting rewarded ad: $e');
      state = const RewardedAdState();
      return null;
    }
  }

  /// Displays the loaded [ad] fullscreen and waits until dismissal.
  /// Returns `true` if the user earned the reward, `false` otherwise.
  Future<bool> showLoadedAd(RewardedAd ad) async {
    final completer = Completer<bool>();
    bool rewarded = false;

    // Prevent App Open ad from appearing on top of rewarded ad
    _adService.setShowingFullScreenAd(true);

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _adService.setShowingFullScreenAd(false);
        ad.dispose();
        state = const RewardedAdState();
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        _adService.setShowingFullScreenAd(false);
        ad.dispose();
        state = const RewardedAdState();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
      },
    );

    return completer.future;
  }

  /// Shows the cached rewarded ad if available and calls [onEarnedReward] when finished.
  Future<bool> show({required VoidCallback onEarnedReward}) async {
    if (_ad == null || !state.isLoaded) return false;
    final ad = _ad!;
    _ad = null;
    final rewarded = await showLoadedAd(ad);
    if (rewarded) {
      onEarnedReward();
    }
    return rewarded;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }
}

final rewardedAdProvider = StateNotifierProvider<RewardedAdNotifier, RewardedAdState>((ref) {
  final adService = ref.watch(adServiceProvider);
  return RewardedAdNotifier(adService);
});
