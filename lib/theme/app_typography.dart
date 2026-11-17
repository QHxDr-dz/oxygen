import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// Typography helpers for Latin and Arabic copy.
///
/// The app remains dark-mode-only and startup text scaling is untouched. These
/// helpers are intentionally standalone so screens can adopt them gradually.
abstract final class AppTypography {
  static const String latinFontFamily = 'Inter';
  static const String arabicFontFamily = 'IBM Plex Sans Arabic';

  static const TextTheme _baseDarkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.4,
      height: 1.15,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.4,
      height: 1.15,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.35,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.35,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.35,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.45,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.45,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textMuted,
      height: 1.45,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.1,
      height: 1.2,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      letterSpacing: 0.2,
      height: 1.2,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
      letterSpacing: 0.3,
      height: 1.3,
    ),
  );

  /// Inter-based dark text theme used by the app's default theme.
  static TextTheme get darkTextTheme =>
      GoogleFonts.interTextTheme(_baseDarkTextTheme);

  static TextStyle get titleLarge =>
      darkTextTheme.titleLarge ??
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  static TextStyle get labelLarge =>
      darkTextTheme.labelLarge ??
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  /// Neutral Inter theme retained for the unused light-theme API.
  static TextTheme get neutralLatinTextTheme => GoogleFonts.interTextTheme();

  /// Arabic text theme using the already-supported Google Fonts family.
  ///
  /// Sizes, weights and colors from [base] are preserved; line height is
  /// relaxed for Arabic readability.
  static TextTheme arabicTextTheme([TextTheme? base]) {
    final source = base ?? darkTextTheme;
    final arabic = GoogleFonts.ibmPlexSansArabicTextTheme(source);
    return arabic.copyWith(
      displayLarge: _withArabicHeight(arabic.displayLarge, 1.35),
      displayMedium: _withArabicHeight(arabic.displayMedium, 1.35),
      headlineLarge: _withArabicHeight(arabic.headlineLarge, 1.4),
      headlineMedium: _withArabicHeight(arabic.headlineMedium, 1.45),
      headlineSmall: _withArabicHeight(arabic.headlineSmall, 1.45),
      titleLarge: _withArabicHeight(arabic.titleLarge, 1.45),
      titleMedium: _withArabicHeight(arabic.titleMedium, 1.45),
      titleSmall: _withArabicHeight(arabic.titleSmall, 1.45),
      bodyLarge: _withArabicHeight(arabic.bodyLarge),
      bodyMedium: _withArabicHeight(arabic.bodyMedium),
      bodySmall: _withArabicHeight(arabic.bodySmall),
      labelLarge: _withArabicHeight(arabic.labelLarge, 1.3),
      labelMedium: _withArabicHeight(arabic.labelMedium, 1.3),
      labelSmall: _withArabicHeight(arabic.labelSmall, 1.3),
    );
  }

  /// Returns the appropriate text theme for a locale.
  ///
  /// Locale wiring in `main.dart` is intentionally unchanged; this helper is
  /// available for future UI adoption.
  static TextTheme textThemeFor(Locale? locale) {
    if (locale?.languageCode == 'ar') return arabicTextTheme();
    return darkTextTheme;
  }

  /// Numeric style with tabular figures for stats, timers and counters.
  static TextStyle numeric({
    double fontSize = 16,
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.2,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle? _withArabicHeight(
    TextStyle? style, [
    double height = 1.55,
  ]) {
    return style?.copyWith(height: height);
  }
}
