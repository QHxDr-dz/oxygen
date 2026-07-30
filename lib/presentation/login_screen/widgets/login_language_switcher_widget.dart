import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class LoginLanguageSwitcherWidget extends StatelessWidget {
  final String currentLocale;
  final VoidCallback onToggle;

  const LoginLanguageSwitcherWidget({
    required this.currentLocale,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withAlpha(153),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppTheme.borderDark.withAlpha(204),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentLocale == 'en' ? '🇺🇸' : '🇸🇦',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                currentLocale == 'en' ? 'EN' : 'AR',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.unfold_more_rounded,
                size: 14,
                color: AppTheme.textMutedDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
