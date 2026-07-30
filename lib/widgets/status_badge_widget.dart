import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BadgeStatus {
  active,
  inactive,
  completed,
  pending,
  warning,
  rest,
  expired,
}

class StatusBadgeWidget extends StatelessWidget {
  final BadgeStatus status;
  final String? customLabel;
  final double fontSize;

  const StatusBadgeWidget({
    required this.status,
    this.customLabel,
    this.fontSize = 11,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: config.borderColor, width: 0.5),
      ),
      child: Text(
        customLabel ?? config.label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: config.textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  _BadgeConfig _getConfig() {
    switch (status) {
      case BadgeStatus.active:
        return _BadgeConfig(
          label: 'Active',
          bgColor: AppTheme.success.withAlpha(38),
          borderColor: AppTheme.success.withAlpha(102),
          textColor: AppTheme.success,
        );
      case BadgeStatus.completed:
        return _BadgeConfig(
          label: 'Completed',
          bgColor: AppTheme.primary.withAlpha(38),
          borderColor: AppTheme.primary.withAlpha(102),
          textColor: AppTheme.primaryLight,
        );
      case BadgeStatus.pending:
        return _BadgeConfig(
          label: 'Pending',
          bgColor: AppTheme.accent.withAlpha(38),
          borderColor: AppTheme.accent.withAlpha(102),
          textColor: AppTheme.accent,
        );
      case BadgeStatus.warning:
        return _BadgeConfig(
          label: 'Warning',
          bgColor: AppTheme.warning.withAlpha(38),
          borderColor: AppTheme.warning.withAlpha(102),
          textColor: AppTheme.warning,
        );
      case BadgeStatus.rest:
        return _BadgeConfig(
          label: 'Rest Day',
          bgColor: AppTheme.secondary.withAlpha(38),
          borderColor: AppTheme.secondary.withAlpha(102),
          textColor: AppTheme.secondaryLight,
        );
      case BadgeStatus.expired:
        return _BadgeConfig(
          label: 'Expired',
          bgColor: AppTheme.error.withAlpha(38),
          borderColor: AppTheme.error.withAlpha(102),
          textColor: AppTheme.error,
        );
      case BadgeStatus.inactive:
        return _BadgeConfig(
          label: 'Inactive',
          bgColor: AppTheme.borderDark.withAlpha(77),
          borderColor: AppTheme.borderDark,
          textColor: AppTheme.textMutedDark,
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  _BadgeConfig({
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });
}
