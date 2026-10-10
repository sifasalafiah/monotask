import 'app_strings.dart';
import 'translations/en.dart';
import 'translations/id.dart';

/// Centralized registry for supported application languages.
///
/// HOW TO ADD A NEW LANGUAGE (1 FILE WORKFLOW):
/// 1. Create a new file in `lib/core/localization/translations/<code >.dart`
///    implementing `AppStrings` (e.g. `es.dart` or `ja.dart`).
/// 2. Add 2 entries below in `supportedLanguages` and `languageNames`.
class AppLocaleConfig {
  static const String defaultLanguageCode = 'en';

  static final Map<String, AppStrings Function()> supportedLanguages = {
    'en': () => EnStrings(),
    'id': () => IdStrings(),
    // e.g. 'es': () => EsStrings(),
    // e.g. 'ja': () => JaStrings(),
  };

  static final Map<String, String> languageNames = {
    'en': 'English',
    'id': 'Bahasa Indonesia',
    // 'es': 'Español',
    // 'ja': '日本語',
  };

  static AppStrings getStrings(String languageCode) {
    final builder = supportedLanguages[languageCode] ?? supportedLanguages[defaultLanguageCode]!;
    return builder();
  }
}
