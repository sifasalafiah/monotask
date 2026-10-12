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
import '../../../core/widgets/pro_badge_button.dart';

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
          const ProBadgeButton(),
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
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: isOwned
                        ? () {
                            if (item.type == 'skin') {
                              notifier.equipSkin(item.id);
                            } else if (item.type == 'theme') {
                              notifier.equipTheme(item.id.replaceFirst('theme_', ''));
                            } else if (item.type == 'sound') {
                              ref.read(focusProvider.notifier).setAmbientSound(item.id);
                            }
                          }
                        : () => _showUnlockSheet(context, ref, item, theme, s),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    color: theme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    color: theme.textSecondary.withValues(alpha: 0.75),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (isEquipped)
                            Container(
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
                          else if (isOwned)
                            OutlinedButton(
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
                          else
                            _BuyTrailing(item: item, theme: theme, s: s),
                        ],
                      ),
                    ),
                  ),
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

/// Buy trailing widget — coin purchase button + watch ad button
class _BuyTrailing extends ConsumerWidget {
  final ShopCatalogItem item;
  final AppThemeData theme;
  final dynamic s; // AppStrings

  const _BuyTrailing({required this.item, required this.theme, required this.s});

  Future<void> _buyCoin(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(gamificationProvider.notifier);
    final success = await notifier.purchaseItem(item);
    if (success) {
      if (item.type == 'skin') {
        await notifier.equipSkin(item.id);
      } else if (item.type == 'theme') {
        await notifier.equipTheme(item.id.replaceFirst('theme_', ''));
      } else if (item.type == 'sound') {
        ref.read(focusProvider.notifier).setAmbientSound(item.id);
      }
    }
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.notEnoughCoins as String)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IntrinsicWidth(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Coin purchase button
          InkWell(
            onTap: () => _buyCoin(context, ref),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on_rounded, size: 12, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(
                    '${item.price}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Center(
              child: Text(
                s.orDivider as String,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          // Watch ad button
          InkWell(
            onTap: () => _handleWatchAd(context, ref, item, s, theme),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_circle_filled_rounded, size: 11, color: theme.primary),
                  const SizedBox(width: 3),
                  Text(
                    s.adWatchToUnlock as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet displaying both unlock methods (Coin or Watch Ad)
void _showUnlockSheet(BuildContext context, WidgetRef ref, ShopCatalogItem item, AppThemeData theme, dynamic s) {
  final profile = ref.read(gamificationProvider);
  final canAfford = profile.coinBalance >= item.price;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.iconData, color: theme.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.unlockItemTitle(item.name) as String,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: TextStyle(fontSize: 12, color: theme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                s.unlockChooseMethod as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              // Option 1: Unlock with Coins
              InkWell(
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final notifier = ref.read(gamificationProvider.notifier);
                  final success = await notifier.purchaseItem(item);
                  if (success) {
                    if (item.type == 'skin') {
                      await notifier.equipSkin(item.id);
                    } else if (item.type == 'theme') {
                      await notifier.equipTheme(item.id.replaceFirst('theme_', ''));
                    } else if (item.type == 'sound') {
                      ref.read(focusProvider.notifier).setAmbientSound(item.id);
                    }
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.notEnoughCoins as String)),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: canAfford ? Colors.amber.withValues(alpha: 0.5) : theme.surfaceLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.unlockWithCoins as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.unlockWithCoinsDesc(item.price, profile.coinBalance) as String,
                              style: TextStyle(fontSize: 11, color: theme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: canAfford ? Colors.amber.shade700 : theme.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.price}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: canAfford ? Colors.white : theme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: theme.surfaceLight, height: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        s.orDivider as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: theme.surfaceLight, height: 1)),
                  ],
                ),
              ),
              // Option 2: Watch Ad (Free)
              InkWell(
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _handleWatchAd(context, ref, item, s, theme);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_circle_filled_rounded, color: theme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.unlockWithAd as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.unlockWithAdDesc as String,
                              style: TextStyle(fontSize: 11, color: theme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Confirmation popup -> request ad on demand -> show ad -> unlock & apply
Future<void> _handleWatchAd(
  BuildContext context,
  WidgetRef ref,
  ShopCatalogItem item,
  dynamic s,
  AppThemeData theme,
) async {
  // 1. Popup konfirmasi sebelum request ad
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_circle_filled_rounded, color: theme.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s.adConfirmTitle as String,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary),
              ),
            ),
          ],
        ),
        content: Text(
          s.adConfirmDesc(item.name) as String,
          style: TextStyle(fontSize: 14, color: theme.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.cancel as String, style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(s.adConfirmAction as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) return;

  // 2. Tampilkan dialog loading saat memuat iklan
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (loadingContext) {
      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.adLoadingTitle as String,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.adLoadingDesc as String,
                        style: TextStyle(fontSize: 12, color: theme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  // 3. Request ad sekarang (on demand)
  final rewardedNotifier = ref.read(rewardedAdProvider.notifier);
  final ad = await rewardedNotifier.requestAd(timeout: const Duration(seconds: 15));

  // Tutup dialog loading
  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  if (!context.mounted) {
    ad?.dispose();
    return;
  }

  // 4. Jika NOT FILLED / gagal load -> Tampilkan modal "Iklan Tidak Tersedia"
  if (ad == null) {
    showDialog(
      context: context,
      builder: (errContext) {
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  s.adUnavailableTitle as String,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: theme.textPrimary),
                ),
              ),
            ],
          ),
          content: Text(
            s.adUnavailableDesc as String,
            style: TextStyle(fontSize: 13, color: theme.textSecondary, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(errContext).pop(),
              child: Text(s.ok as String),
            ),
          ],
        );
      },
    );
    return;
  }

  // 5. Jika FILLED -> Tampilkan ad
  final earned = await rewardedNotifier.showLoadedAd(ad);

  if (!context.mounted) return;

  if (earned) {
    // Reward diperoleh -> Unlock dan langsung apply!
    final gNotifier = ref.read(gamificationProvider.notifier);
    await gNotifier.grantItemFree(item);

    if (item.type == 'skin') {
      await gNotifier.equipSkin(item.id);
    } else if (item.type == 'theme') {
      await gNotifier.equipTheme(item.id.replaceFirst('theme_', ''));
    } else if (item.type == 'sound') {
      ref.read(focusProvider.notifier).setAmbientSound(item.id);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.adRewardUnlockedAndApplied(item.name) as String),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.adNotCompleted as String),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
