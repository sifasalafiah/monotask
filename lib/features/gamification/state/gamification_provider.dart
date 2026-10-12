import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_storage_service.dart';
import '../../../core/database/models/gamification_model.dart';

class GamificationNotifier extends StateNotifier<UserGamificationProfile> {
  final LocalStorageService _storage;

  GamificationNotifier(this._storage)
      : super(
          UserGamificationProfile(
            lastStreakDate: DateTime.now(),
            petState: PetStateModel(lastFocusTime: DateTime.now()),
          ),
        ) {
    _load();
  }

  Future<void> _load() async {
    state = await _storage.loadProfile();
  }

  Future<void> awardSessionRewards({
    required int focusMinutes,
    required int coins,
    required int exp,
  }) async {
    final pet = state.petState;
    pet.addExp(exp);

    // Calculate streak
    final now = DateTime.now();
    int newStreak = state.currentStreakDays;
    final diffDays = now.difference(state.lastStreakDate).inDays;
    if (diffDays == 1) {
      newStreak++;
    } else if (diffDays > 1) {
      newStreak = 1;
    }

    state = UserGamificationProfile(
      coinBalance: state.coinBalance + coins,
      totalSessionsCompleted: state.totalSessionsCompleted + 1,
      totalFocusMinutes: state.totalFocusMinutes + focusMinutes,
      currentStreakDays: newStreak,
      lastStreakDate: now,
      petState: pet,
      unlockedInventory: state.unlockedInventory,
      activeAppTheme: state.activeAppTheme,
    );
    await _storage.saveProfile(state);
  }

  Future<void> penalizeAbandonedSession({int damage = 25}) async {
    final pet = state.petState;
    pet.applyDamage(damage);

    state = UserGamificationProfile(
      coinBalance: state.coinBalance,
      totalSessionsCompleted: state.totalSessionsCompleted,
      totalFocusMinutes: state.totalFocusMinutes,
      currentStreakDays: state.currentStreakDays,
      lastStreakDate: state.lastStreakDate,
      petState: pet,
      unlockedInventory: state.unlockedInventory,
      activeAppTheme: state.activeAppTheme,
    );
    await _storage.saveProfile(state);
  }

  Future<bool> purchaseItem(ShopCatalogItem item) async {
    if (state.hasItem(item.id)) return true; // Already owned
    if (state.coinBalance < item.price) return false; // Not enough coins

    final updatedInventory = [
      ...state.unlockedInventory,
      InventoryItemModel(itemId: item.id, itemType: item.type, acquiredAt: DateTime.now()),
    ];

    state = UserGamificationProfile(
      coinBalance: state.coinBalance - item.price,
      totalSessionsCompleted: state.totalSessionsCompleted,
      totalFocusMinutes: state.totalFocusMinutes,
      currentStreakDays: state.currentStreakDays,
      lastStreakDate: state.lastStreakDate,
      petState: state.petState,
      unlockedInventory: updatedInventory,
      activeAppTheme: item.type == 'theme' ? item.id.replaceFirst('theme_', '') : state.activeAppTheme,
    );
    await _storage.saveProfile(state);
    return true;
  }

  Future<void> equipSkin(String skinId) async {
    final pet = state.petState;
    pet.activeSkinId = skinId;
    state = UserGamificationProfile(
      coinBalance: state.coinBalance,
      totalSessionsCompleted: state.totalSessionsCompleted,
      totalFocusMinutes: state.totalFocusMinutes,
      currentStreakDays: state.currentStreakDays,
      lastStreakDate: state.lastStreakDate,
      petState: pet,
      unlockedInventory: state.unlockedInventory,
      activeAppTheme: state.activeAppTheme,
    );
    await _storage.saveProfile(state);
  }

  Future<void> equipTheme(String themeId) async {
    state = UserGamificationProfile(
      coinBalance: state.coinBalance,
      totalSessionsCompleted: state.totalSessionsCompleted,
      totalFocusMinutes: state.totalFocusMinutes,
      currentStreakDays: state.currentStreakDays,
      lastStreakDate: state.lastStreakDate,
      petState: state.petState,
      unlockedInventory: state.unlockedInventory,
      activeAppTheme: themeId,
    );
    await _storage.saveProfile(state);
  }

  /// Grants an item for free (e.g., via rewarded ad) without deducting coins.
  Future<void> grantItemFree(ShopCatalogItem item) async {
    if (state.hasItem(item.id)) return;

    final updatedInventory = [
      ...state.unlockedInventory,
      InventoryItemModel(itemId: item.id, itemType: item.type, acquiredAt: DateTime.now()),
    ];

    final pet = state.petState;
    if (item.type == 'skin') {
      pet.activeSkinId = item.id;
    }

    state = UserGamificationProfile(
      coinBalance: state.coinBalance,
      totalSessionsCompleted: state.totalSessionsCompleted,
      totalFocusMinutes: state.totalFocusMinutes,
      currentStreakDays: state.currentStreakDays,
      lastStreakDate: state.lastStreakDate,
      petState: pet,
      unlockedInventory: updatedInventory,
      activeAppTheme: item.type == 'theme'
          ? item.id.replaceFirst('theme_', '')
          : state.activeAppTheme,
    );
    await _storage.saveProfile(state);
  }
}

final gamificationProvider = StateNotifierProvider<GamificationNotifier, UserGamificationProfile>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return GamificationNotifier(storage);
});
