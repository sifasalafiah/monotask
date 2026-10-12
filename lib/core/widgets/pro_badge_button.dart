import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../iap/iap_service.dart';
import '../theme/app_theme.dart';
import '../../features/gamification/state/gamification_provider.dart';
import '../../features/paywall/paywall_modal.dart';

/// Reusable PRO badge button displayed in AppBars across all navigation tabs.
/// Automatically hides itself when user is already Pro.
class ProBadgeButton extends ConsumerWidget {
  const ProBadgeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iap = ref.watch(iapProvider);
    if (iap.isPro) return const SizedBox.shrink();

    final profile = ref.watch(gamificationProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Center(
        child: TextButton.icon(
          icon: const Icon(Icons.workspace_premium_rounded, size: 16),
          label: const Text('Pro'),
          style: TextButton.styleFrom(
            foregroundColor: theme.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.primary.withValues(alpha: 0.35)),
            ),
            backgroundColor: theme.primary.withValues(alpha: 0.1),
          ),
          onPressed: () => showPaywallModal(context),
        ),
      ),
    );
  }
}
