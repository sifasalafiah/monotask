import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../theme/app_theme.dart';
import '../../features/gamification/state/gamification_provider.dart';
import 'ad_service.dart';

/// Native ad widget using AdMob NativeTemplateStyle.
/// Includes image/video, app icon, headline, body, and CTA button.
///
/// Load is triggered once in [initState] — meaning the ad only requests
/// when the widget is first inserted into the tree (i.e. when the user
/// opens that page). It is disposed when the widget leaves the tree.
///
/// [templateType]:
///   - [TemplateType.small]  → 120px tall — between sections
///   - [TemplateType.medium] → 300px tall — full-width placement
class NativeAdBannerWidget extends ConsumerStatefulWidget {
  final TemplateType templateType;

  const NativeAdBannerWidget({
    super.key,
    this.templateType = TemplateType.small,
  });

  @override
  ConsumerState<NativeAdBannerWidget> createState() => _NativeAdBannerWidgetState();
}

class _NativeAdBannerWidgetState extends ConsumerState<NativeAdBannerWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load ad immediately when the page is opened.
    // This runs once per widget instance — not on tab switches in IndexedStack.
    _loadAd();
  }

  void _loadAd() {
    if (kIsWeb) return;

    final adService = ref.read(adServiceProvider);
    if (!adService.shouldShowAds) return;

    final profile = ref.read(gamificationProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);
    final isDark = theme.isDark;

    _nativeAd = NativeAd(
      adUnitId: AdIds.native,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('NativeAd failed to load: $error');
          ad.dispose();
          if (mounted) setState(() => _nativeAd = null);
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType,
        mainBackgroundColor: theme.surface,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: theme.primary,
          style: NativeTemplateFontStyle.bold,
          size: 13.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: isDark ? const Color(0xFFF1F1F5) : const Color(0xFF1A1A2E),
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: isDark ? const Color(0xFFB5B7C4) : const Color(0xFF666680),
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: isDark ? const Color(0xFF888B9E) : const Color(0xFF999999),
          style: NativeTemplateFontStyle.normal,
          size: 11.0,
        ),
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adService = ref.watch(adServiceProvider);
    if (!adService.shouldShowAds || kIsWeb) return const SizedBox.shrink();

    final profile = ref.watch(gamificationProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);
    final double height = widget.templateType == TemplateType.medium ? 300.0 : 120.0;

    return Container(
      width: double.infinity,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.isDark
              ? theme.surfaceLight.withValues(alpha: 0.4)
              : theme.surfaceLight,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _isAdLoaded && _nativeAd != null
                ? AdWidget(ad: _nativeAd!)
                : Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
          ),
          if (_isAdLoaded)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Ad',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
