import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ads/rewarded_ad_service.dart';
import '../../../core/database/models/gamification_model.dart';
import '../../../core/iap/iap_service.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../focus/state/focus_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../state/gamification_provider.dart';

class PetSanctuaryScreen extends ConsumerStatefulWidget {
  const PetSanctuaryScreen({super.key});

  @override
  ConsumerState<PetSanctuaryScreen> createState() => _PetSanctuaryScreenState();
}

class _PetSanctuaryScreenState extends ConsumerState<PetSanctuaryScreen> {
  String _selectedCategory = 'skin'; // 'skin', 'theme', 'sound'

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final profile = ref.watch(gamificationProvider);
    final notifier = ref.read(gamificationProvider.notifier);
    final focus = ref.watch(focusProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);
    final pet = profile.petState;

    String stageName;
    if (pet.level < 3) {
      stageName = s.petGrowthStageEgg;
    } else if (pet.level < 6) {
      stageName = s.petGrowthStageHatchling;
    } else if (pet.level < 10) {
      stageName = s.petGrowthStageCompanion;
    } else {
      stageName = s.petGrowthStageGuardian;
    }

    IconData skinIcon = Icons.eco_rounded;
    if (pet.activeSkinId == 'skin_fox') skinIcon = Icons.pets_rounded;
    if (pet.activeSkinId == 'skin_dragon') skinIcon = Icons.auto_awesome_rounded;
    if (pet.activeSkinId == 'skin_owl') skinIcon = Icons.school_rounded;

    final expProgress = (pet.currentExp / pet.expToNextLevel).clamp(0.0, 1.0);
    final healthProgress = (pet.health / 100.0).clamp(0.0, 1.0);

    final currentCategoryItems = ShopCatalog.items
        .where((item) => item.type == _selectedCategory)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.navPet),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: theme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded, size: 15, color: Colors.amber),
                const SizedBox(width: 5),
                Text(
                  '${profile.coinBalance}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: s.settingsTitle,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Companion Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.surface, theme.surfaceLight.withValues(alpha: 0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.isDark ? theme.surfaceLight.withValues(alpha: 0.5) : theme.surfaceLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar & Level badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.surfaceLight,
                          border: Border.all(color: theme.primary, width: 3),
                        ),
                        child: Center(
                          child: Icon(skinIcon, size: 48, color: theme.primary),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            s.petLevel(pet.level),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    pet.petName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stageName,
                    style: TextStyle(fontSize: 12, color: theme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),

                  // Health Bar
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, size: 14, color: theme.danger),
                      const SizedBox(width: 4),
                      Text(s.petHealth, style: TextStyle(color: theme.textPrimary, fontSize: 12)),
                      const Spacer(),
                      Text('${pet.health}/100', style: TextStyle(color: theme.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: healthProgress,
                      minHeight: 7,
                      backgroundColor: theme.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pet.health > 50 ? theme.primary : (pet.health > 25 ? Colors.orange : theme.danger),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // EXP Bar
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('EXP', style: TextStyle(color: theme.textPrimary, fontSize: 12)),
                      const Spacer(),
                      Text('${pet.currentExp}/${pet.expToNextLevel}', style: TextStyle(color: theme.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: expProgress,
                      minHeight: 7,
                      backgroundColor: theme.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Condition Hint
                  Text(
                    pet.health < 40 ? s.petMoodHurt : s.petThriving,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: pet.health < 40 ? theme.danger : theme.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Shop Header
            Row(
              children: [
                Text(
                  s.shopTitle,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary),
                ),
                const Spacer(),
                const Icon(Icons.local_fire_department_rounded, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  s.currentStreak(profile.currentStreakDays),
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Symmetrical Segmented Tabs (Identical equal widths)
            Container(
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: theme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ShopSegmentItem(
                      title: s.shopSkins,
                      isSelected: _selectedCategory == 'skin',
                      theme: theme,
                      onTap: () => setState(() => _selectedCategory = 'skin'),
                    ),
                  ),
                  Expanded(
                    child: _ShopSegmentItem(
                      title: s.shopThemes,
                      isSelected: _selectedCategory == 'theme',
                      theme: theme,
                      onTap: () => setState(() => _selectedCategory = 'theme'),
                    ),
                  ),
                  Expanded(
                    child: _ShopSegmentItem(
                      title: s.shopSounds,
                      isSelected: _selectedCategory == 'sound',
                      theme: theme,
                      onTap: () => setState(() => _selectedCategory = 'sound'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Seamless Inline Catalog List (No nested scroll collision, completely clean)
            ...currentCategoryItems.map((item) {
              final iap = ref.watch(iapProvider);
              // Pro users own everything
              final isOwned = iap.isPro || profile.hasItem(item.id) || item.price == 0;
              final isEquipped = (item.type == 'skin' && profile.petState.activeSkinId == item.id) ||
                  (item.type == 'theme' && profile.activeAppTheme == item.id.replaceFirst('theme_', '')) ||
                  (item.type == 'sound' && focus.activeSoundTrack == item.id);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isEquipped
                        ? theme.primary.withValues(alpha: 0.4)
                        : (theme.isDark ? theme.surfaceLight.withValues(alpha: 0.4) : theme.surfaceLight),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isEquipped ? theme.primary.withValues(alpha: 0.15) : theme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.iconData,
                      size: 20,
                      color: isEquipped ? theme.primary : theme.textPrimary,
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    item.description,
                    style: TextStyle(
                      color: theme.textSecondary.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                  trailing: isEquipped
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            s.equipped,
                            style: TextStyle(color: theme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        )
                      : isOwned
                          ? OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.primary,
                                side: BorderSide(color: theme.primary),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                if (item.type == 'skin') {
                                  notifier.equipSkin(item.id);
                                } else if (item.type == 'theme') {
                                  notifier.equipTheme(item.id.replaceFirst('theme_', ''));
                                } else if (item.type == 'sound') {
                                  ref.read(focusProvider.notifier).setAmbientSound(item.id);
                                }
                              },
                              child: Text(s.equip, style: const TextStyle(fontSize: 12)),
                            )
                          : _BuyTrailing(item: item, theme: theme, s: s),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ShopSegmentItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final AppThemeData theme;
  final VoidCallback onTap;

  const _ShopSegmentItem({
    required this.title,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : theme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Buy trailing widget — coin purchase button + rewarded ad bypass button
class _BuyTrailing extends ConsumerWidget {
  final ShopCatalogItem item;
  final AppThemeData theme;
  final dynamic s; // AppStrings

  const _BuyTrailing({required this.item, required this.theme, required this.s});

  Future<void> _buyCoin(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(gamificationProvider.notifier);
    final success = await notifier.purchaseItem(item);
    if (success && item.type == 'sound') {
      ref.read(focusProvider.notifier).setAmbientSound(item.id);
    }
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.notEnoughCoins as String)),
      );
    }
  }

  Future<void> _watchAd(BuildContext context, WidgetRef ref) async {
    final rewardedNotifier = ref.read(rewardedAdProvider.notifier);
    await rewardedNotifier.show(
      onEarnedReward: () async {
        final gNotifier = ref.read(gamificationProvider.notifier);
        await gNotifier.grantItemFree(item);
        if (item.type == 'sound') {
          ref.read(focusProvider.notifier).setAmbientSound(item.id);
        }
        // Show success message after the ad callback
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adState = ref.watch(rewardedAdProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Coin purchase button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _buyCoin(context, ref),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on_rounded, size: 12, color: Colors.white),
              const SizedBox(width: 3),
              Text('${item.price}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        // Watch ad bypass (only when ad is loaded)
        if (adState.isLoaded) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _watchAd(context, ref),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_circle_outline_rounded, size: 11, color: theme.primary),
                const SizedBox(width: 2),
                Text(
                  s.adWatchToUnlock as String,
                  style: TextStyle(fontSize: 10, color: theme.primary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
