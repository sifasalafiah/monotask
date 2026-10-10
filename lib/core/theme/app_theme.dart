import 'package:flutter/material.dart';

class AppThemeData {
  final String id;
  final String name;
  final bool isDark;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color danger;
  final Color warning;

  const AppThemeData({
    required this.id,
    required this.name,
    this.isDark = true,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.danger,
    required this.warning,
  });

  ThemeData toThemeData() {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: danger,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? surfaceLight.withValues(alpha: 0.4) : surfaceLight,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: surfaceLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? surfaceLight.withValues(alpha: 0.6) : surfaceLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        hintStyle: TextStyle(
          color: textSecondary.withValues(alpha: 0.7),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12);
          }
          return TextStyle(color: textSecondary, fontSize: 12);
        }),
      ),
    );
  }
}

class AppThemes {
  /// Monotask Signature Light Mode with #FFAC33 primary
  static const amberLight = AppThemeData(
    id: 'amber_light',
    name: 'Monotask Amber (Light)',
    isDark: false,
    primary: Color(0xFFFFAC33), // Exact #FFAC33
    secondary: Color(0xFFE5941E),
    accent: Color(0xFFFFBF66),
    background: Color(0xFFFBF8F2),
    surface: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFEDE6D8),
    textPrimary: Color(0xFF1E1B18),
    textSecondary: Color(0xFF78716C),
    danger: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
  );

  /// Monotask Signature Dark Mode with #FFAC33 primary
  static const amberDark = AppThemeData(
    id: 'amber_dark',
    name: 'Monotask Amber (Dark)',
    isDark: true,
    primary: Color(0xFFFFAC33), // Exact #FFAC33
    secondary: Color(0xFFE5941E),
    accent: Color(0xFFFFBF66),
    background: Color(0xFF13110E),
    surface: Color(0xFF1F1B16),
    surfaceLight: Color(0xFF332B20),
    textPrimary: Color(0xFFFFFBEB),
    textSecondary: Color(0xFFFDE68A),
    danger: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
  );

  static const forest = AppThemeData(
    id: 'forest',
    name: 'Forest Emerald',
    isDark: true,
    primary: Color(0xFF10B981), // Emerald
    secondary: Color(0xFF059669),
    accent: Color(0xFF34D399),
    background: Color(0xFF0B1410),
    surface: Color(0xFF14241D),
    surfaceLight: Color(0xFF1F382E),
    textPrimary: Color(0xFFF0FDF4),
    textSecondary: Color(0xFF86EFAC),
    danger: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
  );

  static const cyberpunk = AppThemeData(
    id: 'cyberpunk',
    name: 'Cyber Midnight',
    isDark: true,
    primary: Color(0xFF8B5CF6), // Neon Purple
    secondary: Color(0xFFEC4899), // Neon Pink
    accent: Color(0xFF06B6D4), // Cyan
    background: Color(0xFF0B0A12),
    surface: Color(0xFF171424),
    surfaceLight: Color(0xFF28233D),
    textPrimary: Color(0xFFF5F3FF),
    textSecondary: Color(0xFFA78BFA),
    danger: Color(0xFFFF2A6D),
    warning: Color(0xFFFFB800),
  );

  static const nord = AppThemeData(
    id: 'nord',
    name: 'Nordic Frost',
    isDark: true,
    primary: Color(0xFF38BDF8), // Frost Blue
    secondary: Color(0xFF0284C7),
    accent: Color(0xFF7DD3FC),
    background: Color(0xFF0A1118),
    surface: Color(0xFF131E2A),
    surfaceLight: Color(0xFF213244),
    textPrimary: Color(0xFFF0F9FF),
    textSecondary: Color(0xFF7DD3FC),
    danger: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
  );

  static final Map<String, AppThemeData> all = {
    'amber_light': amberLight,
    'amber_dark': amberDark,
    'forest': forest,
    'cyberpunk': cyberpunk,
    'nord': nord,
  };

  static AppThemeData getTheme(String id) => all[id] ?? amberLight;
}
