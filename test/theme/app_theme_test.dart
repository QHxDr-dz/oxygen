import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as google_fonts_base;
import 'package:oxygenclub/theme/app_theme.dart';
import 'package:oxygenclub/theme/app_tokens.dart';
import 'package:oxygenclub/theme/app_typography.dart';

/// Minimal in-memory asset manifest so GoogleFonts resolves its font requests
/// locally during tests instead of attempting runtime network fetches.
class _FakeFontAssetManifest implements AssetManifest {
  const _FakeFontAssetManifest(this._assets);

  final List<String> _assets;

  @override
  List<String> listAssets() => _assets;

  @override
  List<AssetMetadata>? getAssetVariants(String key) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const fontAssets = <String>[
    'google_fonts/Inter-Regular.ttf',
    'google_fonts/Inter-Medium.ttf',
    'google_fonts/Inter-SemiBold.ttf',
    'google_fonts/Inter-Bold.ttf',
    'google_fonts/IBMPlexSansArabic-Regular.ttf',
    'google_fonts/IBMPlexSansArabic-Medium.ttf',
    'google_fonts/IBMPlexSansArabic-SemiBold.ttf',
    'google_fonts/IBMPlexSansArabic-Bold.ttf',
  ];

  late AssetManifest? originalManifest;

  setUp(() {
    originalManifest = google_fonts_base.assetManifest;
    google_fonts_base.assetManifest = const _FakeFontAssetManifest(fontAssets);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
          if (message == null) return null;
          final key = utf8.decode(
            message.buffer.asUint8List(
              message.offsetInBytes,
              message.lengthInBytes,
            ),
          );
          if (!fontAssets.contains(key)) return null;
          return ByteData.sublistView(Uint8List.fromList(const <int>[0]));
        });
  });

  tearDown(() {
    google_fonts_base.assetManifest = originalManifest;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('OxygenClub design tokens', () {
    test('uses charcoal/graphite semantic surface colors', () {
      expect(AppColors.canvas, const Color(0xFF0B1015));
      expect(AppColors.surface, const Color(0xFF121A22));
      expect(AppColors.surfaceRaised, const Color(0xFF17212B));
      expect(AppColors.borderSubtle, const Color(0xFF24313D));
      expect(AppColors.textPrimary, const Color(0xFFF4F7FA));
    });

    test('keeps amber accent distinct from warning and adds oxygen mint', () {
      expect(AppColors.accentAmber, const Color(0xFFF59E0B));
      expect(AppColors.warning, const Color(0xFFE0A33A));
      expect(AppColors.oxygenMint, const Color(0xFF2FC3A7));
      expect(AppColors.accentAmber, isNot(AppColors.warning));
      expect(AppColors.secondary, AppColors.oxygenMint);
    });

    test('defines spacing, radius, elevation and motion scales', () {
      expect(AppSpacing.xs, 4);
      expect(AppSpacing.sm, 8);
      expect(AppSpacing.md, 12);
      expect(AppSpacing.lg, 16);
      expect(AppSpacing.xl, 20);
      expect(AppSpacing.xxl, 24);
      expect(AppRadius.control, 12);
      expect(AppRadius.card, 16);
      expect(AppRadius.hero, 20);
      expect(AppRadius.pill, 999);
      expect(AppElevation.card, 0);
      expect(AppElevation.overlayShadows, isNotEmpty);
      expect(AppMotion.press.inMilliseconds, 120);
      expect(AppMotion.fade.inMilliseconds, 180);
      expect(AppMotion.slide.inMilliseconds, 240);
      expect(AppMotion.progress.inMilliseconds, 320);
    });
  });

  group('AppTheme dark compatibility', () {
    test('dark theme is dark and consumes semantic tokens', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, AppColors.canvas);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.oxygenMint);
      expect(theme.colorScheme.tertiary, AppColors.accentAmber);
      expect(theme.colorScheme.error, AppColors.error);
      expect(theme.colorScheme.outline, AppColors.borderSubtle);
      expect(theme.textTheme.bodyMedium?.fontSize, 14);
      expect(theme.textTheme.bodyMedium?.color, AppColors.textSecondary);
    });

    test('applies tokenized card and button shapes', () {
      final theme = AppTheme.darkTheme;
      final cardShape = theme.cardTheme.shape! as RoundedRectangleBorder;
      final buttonStyle = theme.elevatedButtonTheme.style!;
      final buttonShape =
          buttonStyle.shape!.resolve({})! as RoundedRectangleBorder;

      expect(cardShape.borderRadius, BorderRadius.circular(AppRadius.card));
      expect(
        buttonShape.borderRadius,
        BorderRadius.circular(AppRadius.control),
      );
      expect(buttonStyle.backgroundColor!.resolve({}), AppColors.primary);
    });

    test('existing public constants remain available as aliases', () {
      expect(AppTheme.accent, const Color(0xFFF59E0B));
      expect(AppTheme.primary, AppColors.primary);
      expect(AppTheme.backgroundDark, AppColors.canvas);
      expect(AppTheme.surfaceDark, AppColors.surface);
      expect(AppTheme.cardDark, AppColors.surface);
      expect(AppTheme.borderDark, AppColors.borderSubtle);
      expect(AppTheme.textPrimaryDark, AppColors.textPrimary);
      expect(AppTheme.textSecondaryDark, AppColors.textSecondary);
      expect(AppTheme.textMutedDark, AppColors.textMuted);
    });
  });

  group('AppTypography', () {
    test('Latin and Arabic helpers use distinct supported font families', () {
      final latin = AppTypography.darkTextTheme;
      final arabic = AppTypography.arabicTextTheme();

      expect(
        latin.bodyMedium?.fontFamily,
        startsWith(AppTypography.latinFontFamily),
      );
      expect(
        arabic.bodyMedium?.fontFamily,
        startsWith(AppTypography.arabicFontFamily.replaceAll(' ', '')),
      );
      expect(arabic.bodyMedium?.fontSize, latin.bodyMedium?.fontSize);
      expect(
        arabic.bodyMedium?.height,
        greaterThan(latin.bodyMedium?.height ?? 0),
      );
    });

    test('locale helper selects Arabic only for Arabic locale', () {
      final arabic = AppTypography.textThemeFor(const Locale('ar'));
      final english = AppTypography.textThemeFor(const Locale('en'));
      final fallback = AppTypography.textThemeFor(null);

      expect(
        arabic.bodyMedium?.fontFamily,
        startsWith(AppTypography.arabicFontFamily.replaceAll(' ', '')),
      );
      expect(
        english.bodyMedium?.fontFamily,
        startsWith(AppTypography.latinFontFamily),
      );
      expect(
        fallback.bodyMedium?.fontFamily,
        startsWith(AppTypography.latinFontFamily),
      );
    });
  });
}
