import 'package:flutter/material.dart';

class PetStateModel {
  String petName;
  int level;
  int currentExp;
  int expToNextLevel;
  int health; // 0-100
  int energy; // 0-100
  String activeSkinId;
  DateTime lastFocusTime;

  PetStateModel({
    this.petName = 'Koda',
    this.level = 1,
    this.currentExp = 0,
    this.expToNextLevel = 100,
    this.health = 100,
    this.energy = 100,
    this.activeSkinId = 'skin_sprout',
    required this.lastFocusTime,
  });

  Map<String, dynamic> toJson() => {
    'petName': petName,
    'level': level,
    'currentExp': currentExp,
    'expToNextLevel': expToNextLevel,
    'health': health,
    'energy': energy,
    'activeSkinId': activeSkinId,
    'lastFocusTime': lastFocusTime.toIso8601String(),
  };

  factory PetStateModel.fromJson(Map<String, dynamic> json) => PetStateModel(
    petName: json['petName'] as String? ?? 'Koda',
    level: json['level'] as int? ?? 1,
    currentExp: json['currentExp'] as int? ?? 0,
    expToNextLevel: json['expToNextLevel'] as int? ?? 100,
    health: json['health'] as int? ?? 100,
    energy: json['energy'] as int? ?? 100,
    activeSkinId: json['activeSkinId'] as String? ?? 'skin_sprout',
    lastFocusTime: json['lastFocusTime'] != null
        ? DateTime.parse(json['lastFocusTime'] as String)
        : DateTime.now(),
  );

  /// Damage the pet when a session is abandoned
  void applyDamage(int damageAmount) {
    health = (health - damageAmount).clamp(0, 100);
  }

  /// Nourish and level up the pet on completed sessions
  void addExp(int expGained) {
    currentExp += expGained;
    health = (health + 10).clamp(0, 100);
    energy = (energy + 15).clamp(0, 100);

    while (currentExp >= expToNextLevel) {
      currentExp -= expToNextLevel;
      level++;
      expToNextLevel = (expToNextLevel * 1.35).round();
    }
  }
}

class InventoryItemModel {
  final String itemId;
  final String itemType; // "skin", "theme", "sound"
  final DateTime acquiredAt;

  InventoryItemModel({
    required this.itemId,
    required this.itemType,
    required this.acquiredAt,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'itemType': itemType,
    'acquiredAt': acquiredAt.toIso8601String(),
  };

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) => InventoryItemModel(
    itemId: json['itemId'] as String,
    itemType: json['itemType'] as String,
    acquiredAt: DateTime.parse(json['acquiredAt'] as String),
  );
}

class UserGamificationProfile {
  int coinBalance;
  int totalSessionsCompleted;
  int totalFocusMinutes;
  int currentStreakDays;
  DateTime lastStreakDate;
  PetStateModel petState;
  List<InventoryItemModel> unlockedInventory;
  String activeAppTheme;

  UserGamificationProfile({
    this.coinBalance = 0,
    this.totalSessionsCompleted = 0,
    this.totalFocusMinutes = 0,
    this.currentStreakDays = 0,
    required this.lastStreakDate,
    required this.petState,
    List<InventoryItemModel>? unlockedInventory,
    this.activeAppTheme = 'amber_light',
  }) : unlockedInventory = unlockedInventory ?? [
    InventoryItemModel(itemId: 'skin_sprout', itemType: 'skin', acquiredAt: DateTime.now()),
    InventoryItemModel(itemId: 'theme_amber_light', itemType: 'theme', acquiredAt: DateTime.now()),
  ];

  Map<String, dynamic> toJson() => {
    'coinBalance': coinBalance,
    'totalSessionsCompleted': totalSessionsCompleted,
    'totalFocusMinutes': totalFocusMinutes,
    'currentStreakDays': currentStreakDays,
    'lastStreakDate': lastStreakDate.toIso8601String(),
    'petState': petState.toJson(),
    'unlockedInventory': unlockedInventory.map((i) => i.toJson()).toList(),
    'activeAppTheme': activeAppTheme,
  };

  factory UserGamificationProfile.fromJson(Map<String, dynamic> json) => UserGamificationProfile(
    coinBalance: json['coinBalance'] as int? ?? 0,
    totalSessionsCompleted: json['totalSessionsCompleted'] as int? ?? 0,
    totalFocusMinutes: json['totalFocusMinutes'] as int? ?? 0,
    currentStreakDays: json['currentStreakDays'] as int? ?? 0,
    lastStreakDate: json['lastStreakDate'] != null
        ? DateTime.parse(json['lastStreakDate'] as String)
        : DateTime.now(),
    petState: json['petState'] != null
        ? PetStateModel.fromJson(json['petState'] as Map<String, dynamic>)
        : PetStateModel(lastFocusTime: DateTime.now()),
    unlockedInventory: (json['unlockedInventory'] as List<dynamic>?)
            ?.map((e) => InventoryItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    activeAppTheme: json['activeAppTheme'] as String? ?? 'amber_light',
  );

  bool hasItem(String itemId) {
    final catalogItem = ShopCatalog.items.where((i) => i.id == itemId).firstOrNull;
    if (catalogItem != null && catalogItem.price == 0) return true;
    return unlockedInventory.any((i) => i.itemId == itemId);
  }

  bool isThemeUnlocked(String themeId) {
    if (themeId == 'amber_light' || themeId == 'amber_dark') return true;
    final fullId = themeId.startsWith('theme_') ? themeId : 'theme_$themeId';
    return hasItem(fullId);
  }

  bool isSoundUnlocked(String? soundId) {
    if (soundId == null || soundId == 'sound_rain') return true;
    return hasItem(soundId);
  }
}

class ShopCatalogItem {
  final String id;
  final String name;
  final String type; // 'skin', 'theme', 'sound'
  final int price;
  final String description;
  final IconData iconData;

  const ShopCatalogItem({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.description,
    required this.iconData,
  });
}

class ShopCatalog {
  static const List<ShopCatalogItem> items = [
    // Skins
    ShopCatalogItem(
      id: 'skin_sprout',
      name: 'Forest Sprout',
      type: 'skin',
      price: 0,
      description: 'Default woodland seedling companion.',
      iconData: Icons.eco_rounded,
    ),
    ShopCatalogItem(
      id: 'skin_fox',
      name: 'Cyber Kitsune',
      type: 'skin',
      price: 120,
      description: 'A glowing guardian companion.',
      iconData: Icons.pets_rounded,
    ),
    ShopCatalogItem(
      id: 'skin_dragon',
      name: 'Astral Drake',
      type: 'skin',
      price: 250,
      description: 'Legendary companion born from deep focus.',
      iconData: Icons.auto_awesome_rounded,
    ),
    ShopCatalogItem(
      id: 'skin_owl',
      name: 'Scholar Owl',
      type: 'skin',
      price: 80,
      description: 'Wise keeper of focus knowledge.',
      iconData: Icons.school_rounded,
    ),

    // Themes
    ShopCatalogItem(
      id: 'theme_amber_light',
      name: 'Monotask Amber (Light)',
      type: 'theme',
      price: 0,
      description: 'Signature warm amber with crisp, clean surfaces.',
      iconData: Icons.light_mode_rounded,
    ),
    ShopCatalogItem(
      id: 'theme_amber_dark',
      name: 'Monotask Amber (Dark)',
      type: 'theme',
      price: 0,
      description: 'Signature warm amber on deep slate.',
      iconData: Icons.dark_mode_rounded,
    ),
    ShopCatalogItem(
      id: 'theme_forest',
      name: 'Forest Emerald',
      type: 'theme',
      price: 60,
      description: 'Organic greens and earthy dark tones.',
      iconData: Icons.forest_rounded,
    ),
    ShopCatalogItem(
      id: 'theme_cyberpunk',
      name: 'Cyber Midnight',
      type: 'theme',
      price: 150,
      description: 'Vibrant neon purple and electric cyan palette.',
      iconData: Icons.bolt_rounded,
    ),
    ShopCatalogItem(
      id: 'theme_nord',
      name: 'Nordic Frost',
      type: 'theme',
      price: 100,
      description: 'Cool glacial blues with minimalist slate backgrounds.',
      iconData: Icons.ac_unit_rounded,
    ),

    // Ambient Soundscapes
    ShopCatalogItem(
      id: 'sound_rain',
      name: 'Rainstorm Sanctuary',
      type: 'sound',
      price: 0,
      description: 'Soothing rain drops on a cozy wooden rooftop.',
      iconData: Icons.water_drop_rounded,
    ),
    ShopCatalogItem(
      id: 'sound_waves',
      name: 'Tidal Waves',
      type: 'sound',
      price: 60,
      description: 'Rhythmic ocean surf along a peaceful shoreline.',
      iconData: Icons.waves_rounded,
    ),
    ShopCatalogItem(
      id: 'sound_campfire',
      name: 'Night Campfire',
      type: 'sound',
      price: 80,
      description: 'Crisp crackling pine wood under star-filled skies.',
      iconData: Icons.local_fire_department_rounded,
    ),
    ShopCatalogItem(
      id: 'sound_white_noise',
      name: 'Pure White Noise',
      type: 'sound',
      price: 50,
      description: 'Even static frequencies designed to drown out distractions.',
      iconData: Icons.air_rounded,
    ),
    ShopCatalogItem(
      id: 'sound_lofi',
      name: 'Midnight Lo-Fi',
      type: 'sound',
      price: 100,
      description: 'Relaxing ambient beats for deep programming states.',
      iconData: Icons.headphones_rounded,
    ),
  ];
}
