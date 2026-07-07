import 'package:flutter/material.dart';

abstract final class AppColors {
  // Dark - Cyberpunk/Neon space theme
  static const backgroundTop = Color(0xFF060613);
  static const backgroundBottom = Color(0xFF0E0E27);
  static const accent = Color(0xFF00E5FF); // Cyber Cyan
  static const accentSecondary = Color(0xFFFF007F); // Cyber Magenta
  static const surface = Color(0xFF131332);
  static const surfaceLight = Color(0xFF1F1F4E);
  static const textPrimary = Color(0xFFF2F4FF);
  static const textMuted = Color(0xFF8692C0);
  static const danger = Color(0xFFFF2A5F);

  // Light — refined palette
  static const lightBackground = Color(0xFFF5F7FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFEAF0F9);
  static const lightText = Color(0xFF080E27);
  static const lightMuted = Color(0xFF6E7A9D);
  static const lightAccent = Color(0xFF0066FF); // Electric Blue
  static const lightAccentSoft = Color(0xFF4DA3FF);
}

ThemeData buildDarkTheme() => _buildTheme(
      brightness: Brightness.dark,
      background: AppColors.backgroundTop,
      surface: AppColors.surface,
      surfaceLight: AppColors.surfaceLight,
      primary: AppColors.accent,
      secondary: AppColors.accentSecondary,
      onSurface: AppColors.textPrimary,
      muted: AppColors.textMuted,
      onPrimary: AppColors.backgroundTop,
    );

ThemeData buildLightTheme() => _buildTheme(
      brightness: Brightness.light,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      surfaceLight: AppColors.lightSurfaceAlt,
      primary: AppColors.lightAccent,
      secondary: AppColors.lightAccentSoft,
      onSurface: AppColors.lightText,
      muted: AppColors.lightMuted,
      onPrimary: Colors.white,
    );

ThemeData buildAppTheme() => buildDarkTheme();

ThemeData _buildTheme({
  required Brightness brightness,
  required Color background,
  required Color surface,
  required Color surfaceLight,
  required Color primary,
  required Color secondary,
  required Color onSurface,
  required Color muted,
  required Color onPrimary,
}) {
  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    onSecondary: onPrimary,
    error: AppColors.danger,
    onError: Colors.white,
    surface: surface,
    onSurface: onSurface,
  );

 return ThemeData(
  useMaterial3: true,
  brightness: brightness,
  colorScheme: colorScheme,

  scaffoldBackgroundColor: background,

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    foregroundColor: onSurface,
  ),

  textTheme: TextTheme(
    bodyLarge: TextStyle(color: onSurface),
    bodyMedium: TextStyle(color: onSurface),
    titleMedium: TextStyle(color: onSurface),
  ),

  textSelectionTheme: TextSelectionThemeData(
    cursorColor: primary,
    selectionColor: primary.withValues(alpha: 0.25),
    selectionHandleColor: primary,
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,

    fillColor: brightness == Brightness.dark
        ? const Color(0xFF262D36)
        : Colors.white,

    hintStyle: TextStyle(
      color: muted,
      fontWeight: FontWeight.w400,
    ),

    labelStyle: TextStyle(
      color: muted,
      fontWeight: FontWeight.w500,
    ),

    floatingLabelStyle: TextStyle(
      color: primary,
      fontWeight: FontWeight.w600,
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(
        color: brightness == Brightness.dark
            ? Colors.white12
            : Colors.black12,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(
        color: primary,
        width: 2,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: AppColors.danger,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: AppColors.danger,
        width: 2,
      ),
    ),

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 18,
    ),
  ),

  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: surfaceLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: onSurface,
      side: BorderSide(
        color: primary.withValues(alpha: 0.45),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    ),
  ),

  cardTheme: CardThemeData(
    color: surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);
}

ColorSchemeExtension colorsOf(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return ColorSchemeExtension(isDark: isDark);
}

class ColorSchemeExtension {
  const ColorSchemeExtension({required this.isDark});
  final bool isDark;

  Color get backgroundTop => isDark ? AppColors.backgroundTop : AppColors.lightBackground;
  Color get backgroundBottom => isDark ? AppColors.backgroundBottom : AppColors.lightSurfaceAlt;
  Color get accent => isDark ? AppColors.accent : AppColors.lightAccent;
  Color get accentSecondary => AppColors.accentSecondary;
  Color get surface => isDark ? AppColors.surface : AppColors.lightSurface;
  Color get surfaceLight => isDark ? AppColors.surfaceLight : AppColors.lightSurfaceAlt;
  Color get textPrimary => isDark ? AppColors.textPrimary : AppColors.lightText;
  Color get textMuted => isDark ? AppColors.textMuted : AppColors.lightMuted;
  Color get danger => AppColors.danger;
}
