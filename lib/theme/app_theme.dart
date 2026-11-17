// THEME LOCK: dark — source: explicit user instruction "Dark Mode only"
// Scaffold.backgroundColor = AppTheme.backgroundDark — ALL screens
import 'package:flutter/material.dart';

import 'app_tokens.dart';
import 'app_typography.dart';

/// Public theme API.
///
/// Existing constants remain as compatibility aliases so untouched screens keep
/// compiling. New UI should prefer the semantic names and token classes.
class AppTheme {
  // Brand colors — compatibility aliases.
  static const Color primary = AppColors.primary;
  static const Color primaryLight = AppColors.primaryBright;
  static const Color primaryDark = AppColors.primaryDeep;
  static const Color secondary = AppColors.secondary;
  static const Color secondaryLight = AppColors.secondaryBright;
  static const Color accent = AppColors.accentAmber;
  static const Color success = AppColors.success;
  static const Color error = AppColors.error;
  static const Color warning = AppColors.warning;

  // New semantic names.
  static const Color oxygenMint = AppColors.oxygenMint;
  static const Color accentAmber = AppColors.accentAmber;
  static const Color canvas = AppColors.canvas;
  static const Color surface = AppColors.surface;
  static const Color surfaceRaised = AppColors.surfaceRaised;
  static const Color surfaceMuted = AppColors.surfaceMuted;
  static const Color borderSubtle = AppColors.borderSubtle;
  static const Color borderStrong = AppColors.borderStrong;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted;

  // Dark surfaces — compatibility aliases.
  static const Color backgroundDark = AppColors.canvas;
  static const Color surfaceDark = AppColors.surface;
  static const Color cardDark = AppColors.surface;
  static const Color borderDark = AppColors.borderSubtle;

  // Light surfaces — retained for API compatibility; app is dark-only.
  static const Color backgroundLight = AppColors.backgroundLight;
  static const Color surfaceLight = AppColors.surfaceLight;
  static const Color cardLight = AppColors.cardLight;
  static const Color borderLight = AppColors.borderLight;

  // Text — compatibility aliases.
  static const Color textPrimaryDark = AppColors.textPrimary;
  static const Color textSecondaryDark = AppColors.textSecondary;
  static const Color textMutedDark = AppColors.textMuted;

  static const Color textPrimaryLight = AppColors.textPrimaryLight;
  static const Color textSecondaryLight = AppColors.textSecondaryLight;
  static const Color textMutedLight = AppColors.textMutedLight;

  // Gradient stops retained for compatibility.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [AppColors.canvas, AppColors.surfaceRaised],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryDeep,
      onPrimaryContainer: AppColors.primaryContainerText,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onPrimary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.secondaryContainerText,
      tertiary: AppColors.accentAmber,
      onTertiary: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      outline: AppColors.borderSubtle,
      outlineVariant: AppColors.surfaceMuted,
      surfaceContainerHighest: AppColors.surfaceRaised,
      onSurfaceVariant: AppColors.onSurfaceVariant,
    ),
    scaffoldBackgroundColor: AppColors.canvas,
    textTheme: AppTypography.darkTextTheme,
    appBarTheme: AppBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: AppElevation.none,
      scrolledUnderElevation: AppElevation.none,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppTypography.darkTextTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: AppElevation.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: AppColors.surfaceMuted.withAlpha(204),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderSubtle,
      thickness: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: AppElevation.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonHorizontalPadding,
          vertical: AppSpacing.buttonVerticalPadding,
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: AppElevation.none,
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onPrimary,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      outline: AppColors.borderLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: AppTypography.neutralLatinTextTheme,
  );
}
