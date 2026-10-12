import 'package:flutter_test/flutter_test.dart';
import 'package:monotask/core/localization/app_locale.dart';
import 'package:monotask/core/localization/translations/en.dart';
import 'package:monotask/core/localization/translations/id.dart';

void main() {
  group('Monotask i18n & Localization Tests', () {
    test('English translations are complete and valid', () {
      final en = EnStrings();
      expect(en.appName, equals('Monotask'));
      expect(en.focusModePomodoro, equals('Pomodoro'));
      expect(en.petLevel(1), equals('Level 1'));
      expect(en.emergencyPassesLeft(2), equals('2 emergency passes left'));
      expect(en.currentStreak(5), equals('5 Day Streak'));
      expect(en.unlockInSanctuaryPrompt.isNotEmpty, isTrue);
      expect(en.adConfirmTitle, equals('Watch Ad to Unlock?'));
      expect(en.adConfirmDesc('Dragon').contains('Dragon'), isTrue);
      expect(en.adUnavailableTitle, equals('Ad Unavailable'));
      expect(en.adUnavailableDesc.isNotEmpty, isTrue);
      expect(en.adRewardUnlockedAndApplied('Dragon'), equals('"Dragon" has been unlocked and equipped!'));
      expect(en.unlockWithCoins, equals('Unlock with Coins'));
      expect(en.unlockWithAd, equals('Watch Ad (Free)'));
      expect(en.orDivider, equals('or'));
    });

    test('Indonesian translations are complete and valid', () {
      final id = IdStrings();
      expect(id.appName, equals('Monotask'));
      expect(id.focusModePomodoro, equals('Pomodoro'));
      expect(id.petLevel(2), equals('Level 2'));
      expect(id.emergencyPassesLeft(1), equals('Tersisa 1 tiket darurat'));
      expect(id.currentStreak(3), equals('Streak 3 Hari Berturut-turut'));
      expect(id.unlockInSanctuaryPrompt.isNotEmpty, isTrue);
      expect(id.adConfirmTitle, equals('Tonton Iklan untuk Membuka?'));
      expect(id.adConfirmDesc('Naga').contains('Naga'), isTrue);
      expect(id.adUnavailableTitle, equals('Iklan Belum Tersedia'));
      expect(id.adUnavailableDesc.isNotEmpty, isTrue);
      expect(id.adRewardUnlockedAndApplied('Naga'), equals('"Naga" berhasil dibuka dan langsung diterapkan!'));
      expect(id.unlockWithCoins, equals('Buka dengan Koin'));
      expect(id.unlockWithAd, equals('Tonton Iklan (Gratis)'));
      expect(id.orDivider, equals('atau'));
    });

    test('Registry returns correct translations and default fallback', () {
      final enStrings = AppLocaleConfig.getStrings('en');
      expect(enStrings.runtimeType, equals(EnStrings));

      final idStrings = AppLocaleConfig.getStrings('id');
      expect(idStrings.runtimeType, equals(IdStrings));

      final fallback = AppLocaleConfig.getStrings('unknown_code');
      expect(fallback.runtimeType, equals(EnStrings));
    });
  });
}
