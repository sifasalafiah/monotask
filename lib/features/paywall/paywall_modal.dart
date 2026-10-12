import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/iap/iap_service.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../gamification/state/gamification_provider.dart';

/// Full-screen paywall modal shown after onboarding.
/// Has an X close button top-right and a restore purchase link.
Future<void> showPaywallModal(BuildContext context) async {
  await Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (ctx, anim1, anim2) => const PaywallModal(),
      transitionsBuilder: (ctx, animation, secondaryAnim, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    ),
  );
}

class PaywallModal extends ConsumerWidget {
  const PaywallModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final iap = ref.watch(iapProvider);
    final profile = ref.watch(gamificationProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);

    // Auto-dismiss when purchase completes successfully
    if (iap.isPro && Navigator.of(context).canPop()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
    }

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 44),
                  Text(
                    s.proTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: theme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // Hero icon
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primary, theme.primary.withValues(alpha: 0.6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, size: 46, color: Colors.white),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      s.proTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.proTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: theme.textSecondary),
                    ),

                    const SizedBox(height: 32),

                    // Feature list
                    _FeatureTile(
                      icon: Icons.block_rounded,
                      text: s.proFeatureNoAds,
                      theme: theme,
                    ),
                    _FeatureTile(
                      icon: Icons.lock_open_rounded,
                      text: s.proFeatureAllUnlocked,
                      theme: theme,
                    ),
                    _FeatureTile(
                      icon: Icons.stars_rounded,
                      text: s.proFeatureNoCoins,
                      theme: theme,
                    ),

                    const SizedBox(height: 36),

                    // Price display (from store or loading)
                    if (iap.product != null)
                      Text(
                        iap.product!.price,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      )
                    else
                      Text(
                        iap.status == IAPStatus.unavailable ? '' : '...',
                        style: TextStyle(fontSize: 28, color: theme.textSecondary),
                      ),

                    if (iap.product != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'One-time purchase',
                        style: TextStyle(fontSize: 13, color: theme.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                children: [
                  if (iap.isPro) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.primary.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: theme.primary),
                          const SizedBox(width: 8),
                          Text(
                            s.proAlreadyOwned,
                            style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ] else if (iap.status == IAPStatus.loading) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: null,
                        child: Text(s.proLoading),
                      ),
                    ),
                  ] else if (iap.status == IAPStatus.unavailable) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.surfaceLight,
                          foregroundColor: theme.textSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: null,
                        child: Text(s.proLoading),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                          shadowColor: theme.primary.withValues(alpha: 0.4),
                        ),
                        onPressed: iap.status == IAPStatus.available
                            ? () => ref.read(iapProvider.notifier).buyPro()
                            : null,
                        child: iap.errorMessage != null
                            ? Text(s.proPrice, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                            : Text(s.proPrice, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    if (iap.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        s.proPurchaseFailed,
                        style: TextStyle(color: theme.danger, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: iap.isRestoring
                              ? null
                              : () => ref.read(iapProvider.notifier).restorePurchases(),
                          child: Text(
                            iap.isRestoring ? s.proRestoring : s.proRestorePurchase,
                            style: TextStyle(color: theme.textSecondary, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            s.proSkip,
                            style: TextStyle(color: theme.textSecondary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final AppThemeData theme;

  const _FeatureTile({required this.icon, required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: theme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
          ),
          Icon(Icons.check_rounded, color: theme.primary, size: 18),
        ],
      ),
    );
  }
}
