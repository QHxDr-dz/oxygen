import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';

class UserHeaderWidget extends StatelessWidget {
  final String name;
  final String goal;
  final String photoUrl;
  final String photoSemanticLabel;
  final int notificationCount;

  const UserHeaderWidget({
    required this.name,
    required this.goal,
    required this.photoUrl,
    required this.photoSemanticLabel,
    required this.notificationCount,
    super.key,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          label: photoSemanticLabel,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary.withAlpha(128),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppTheme.surfaceDark,
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppTheme.textMutedDark,
                    size: 24,
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppTheme.surfaceDark,
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppTheme.textMutedDark,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting 👋',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondaryDark,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name.split(' ').first,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        _HeaderIconButton(icon: Icons.calendar_today_outlined, onTap: () {}),
        const SizedBox(width: 8),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _HeaderIconButton(icon: Icons.notifications_outlined, onTap: () {}),
            if (notificationCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.backgroundDark,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      notificationCount > 9 ? '9+' : '$notificationCount',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderDark, width: 0.5),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textSecondaryDark),
      ),
    );
  }
}
