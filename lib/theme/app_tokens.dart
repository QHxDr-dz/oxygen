import 'package:flutter/material.dart';

/// Lightweight semantic tokens for the OxygenClub premium dark theme.
///
/// These values are consumed by [AppTheme] and are intended to be used by new
/// UI components without pulling styling logic into business or data layers.
abstract final class AppColors {
  // Charcoal / graphite surfaces.
  static const Color canvas = Color(0xFF0B1015);
  static const Color surface = Color(0xFF121A22);
  static const Color surfaceRaised = Color(0xFF17212B);
  static const Color surfaceMuted = Color(0xFF0F171F);

  // Borders and dividers.
  static const Color borderSubtle = Color(0xFF24313D);
  static const Color borderStrong = Color(0xFF334454);

  // Text.
  static const Color textPrimary = Color(0xFFF4F7FA);
  static const Color textSecondary = Color(0xFFA8B5C4);
  static const Color textMuted = Color(0xFF738293);

  // Primary brand blue.
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryBright = Color(0xFF60A5FA);
  static const Color primaryDeep = Color(0xFF1D4ED8);
  static const Color primarySubtle = Color(0x242563EB);
  static const Color primaryContainerText = Color(0xFFBFDBFE);

  /// Restrained wellness accent. Also backs the legacy `secondary` alias.
  static const Color oxygenMint = Color(0xFF2FC3A7);
  static const Color oxygenMintBright = Color(0xFF6FE3CC);
  static const Color oxygenMintSubtle = Color(0x1F2FC3A7);
  static const Color secondary = oxygenMint;
  static const Color secondaryBright = oxygenMintBright;
  static const Color secondarySubtle = oxygenMintSubtle;
  static const Color secondaryContainer = Color(0xFF123B36);
  static const Color secondaryContainerText = Color(0xFFA7F3E4);

  /// Existing Oxygen amber. Reserved for achievements, records and energy.
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentAmber = accent;
  static const Color accentSubtle = Color(0x1FF59E0B);
  static const Color onAccent = Color(0xFF1A1204);

  // Semantic status colors.
  static const Color warning = Color(0xFFE0A33A);
  static const Color success = Color(0xFF2FBF87);
  static const Color successSubtle = Color(0x1F2FBF87);
  static const Color error = Color(0xFFF87171);
  static const Color danger = error;
  static const Color dangerSubtle = Color(0x1FF87171);

  // Fixed on-color values.
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = textSecondary;

  // Light values retained only for API compatibility; the app is dark-only.
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
}

/// 4px-based spacing scale.
abstract final class AppSpacing {
  static const double zero = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  static const double screenGutter = lg;
  static const double screenGutterWide = xxl;
  static const double cardPadding = xl;
  static const double sectionGap = xxl;
  static const double bottomNavClearance = 96;

  static const double buttonHorizontalPadding = xxl;
  static const double buttonVerticalPadding = 14;
}

/// Consistent corner radii.
abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double control = 12;
  static const double card = 16;
  static const double hero = 20;
  static const double pill = 999;
}

/// Border-first elevation with restrained shadows for overlays only.
abstract final class AppElevation {
  static const double none = 0;
  static const double card = 0;
  static const double raised = 4;
  static const double overlay = 16;

  static const List<BoxShadow> overlayShadows = [
    BoxShadow(
      color: Color(0x52000000),
      blurRadius: overlay,
      offset: Offset(0, 4),
    ),
  ];
}

/// Purposeful motion durations and curves.
abstract final class AppMotion {
  static const Duration press = Duration(milliseconds: 120);
  static const Duration fade = Duration(milliseconds: 180);
  static const Duration slide = Duration(milliseconds: 240);
  static const Duration progress = Duration(milliseconds: 320);

  static Curve get standard => Curves.easeOutCubic;
}
