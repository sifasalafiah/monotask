import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_locale.dart';
import 'app_strings.dart';

const String _prefLocaleKey = 'monotask_selected_language';

class LocaleNotifier extends StateNotifier<String> {
  final SharedPreferences? _prefs;

  LocaleNotifier(this._prefs) : super(_prefs?.getString(_prefLocaleKey) ?? AppLocaleConfig.defaultLanguageCode);

  Future<void> setLocale(String languageCode) async {
    if (!AppLocaleConfig.supportedLanguages.containsKey(languageCode)) return;
    state = languageCode;
    await _prefs?.setString(_prefLocaleKey, languageCode);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main()');
});

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

final stringsProvider = Provider<AppStrings>((ref) {
  final code = ref.watch(localeProvider);
  return AppLocaleConfig.getStrings(code);
});

/// Ergonomic extension for any BuildContext
extension LocalizationExtension on BuildContext {
  AppStrings get strings {
    final container = ProviderScope.containerOf(this, listen: false);
    return container.read(stringsProvider);
  }
}
