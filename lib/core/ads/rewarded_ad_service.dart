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

  RewardedAdNotifier(this._adService) : super(const RewardedAdState()) {
    _load();
  }

  void _load() {
    if (!_adService.shouldShowAds) return;
    state = const RewardedAdState(isLoading: true);
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: _adService.adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          state = const RewardedAdState(isLoaded: true);
        },
        onAdFailedToLoad: (_) {
          state = const RewardedAdState();
        },
      ),
    );
  }

  /// Shows the rewarded ad and calls [onEarnedReward] when user finishes.
  /// Returns false if ad is not ready.
  Future<bool> show({required VoidCallback onEarnedReward}) async {
    if (_ad == null || !state.isLoaded) return false;

    bool rewarded = false;
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        state = const RewardedAdState();
        _load(); // pre-load next
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _ad = null;
        state = const RewardedAdState();
        _load();
      },
    );

    await _ad!.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
        onEarnedReward();
      },
    );
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
