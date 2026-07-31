import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class TodayWorkoutCardWidget extends StatelessWidget {
  final String name;
  final String type;
  final int exerciseCount;
  final int estimatedMinutes;
  final String status;
  final bool isRestDay;
  final VoidCallback? onStartTap;

  const TodayWorkoutCardWidget({
    required this.name,
    required this.type,
    required this.exerciseCount,
    required this.estimatedMinutes,
    required this.status,
    required this.isRestDay,
    this.onStartTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isRestDay) {
      return _RestDayCard();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderDark, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.borderDark, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(38),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.today_rounded,
                    size: 16,
                    color: AppTheme.primaryLight,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Today's Workout",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
                const Spacer(),
                if (status == 'in_progress')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withAlpha(38),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'In Progress',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MetaChip(
                      icon: Icons.category_outlined,
                      label: type,
                      color: AppTheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    _MetaChip(
                      icon: Icons.fitness_center_outlined,
                      label: '$exerciseCount exercises',
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    _MetaChip(
                      icon: Icons.timer_outlined,
                      label: '~$estimatedMinutes min',
                      color: AppTheme.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _WorkoutCTAButton(
                  status: status,
                  onTap:
                      onStartTap ??
                      () => context.push(AppRoutes.workoutPlayerScreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RestDayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondary.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondary.withAlpha(77), width: 0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.secondary.withAlpha(38),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.self_improvement_rounded,
              size: 26,
              color: AppTheme.secondaryLight,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rest & Recovery Day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your muscles are rebuilding. Stay hydrated and sleep well.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryDark,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(51), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCTAButton extends StatefulWidget {
  final String status;
  final VoidCallback onTap;

  const _WorkoutCTAButton({required this.status, required this.onTap});

  @override
  State<_WorkoutCTAButton> createState() => _WorkoutCTAButtonState();
}

class _WorkoutCTAButtonState extends State<_WorkoutCTAButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _label {
    switch (widget.status) {
      case 'in_progress':
        return 'Continue Workout';
      case 'completed':
        return 'Redo Workout';
      default:
        return 'Start Workout';
    }
  }

  IconData get _icon {
    switch (widget.status) {
      case 'completed':
        return Icons.refresh_rounded;
      default:
        return Icons.play_arrow_rounded;
    }
  }

  List<Color> get _gradientColors {
    if (widget.status == 'completed') {
      return [AppTheme.success, const Color(0xFF059669)];
    }
    return [AppTheme.primary, AppTheme.secondary];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _gradientColors[0].withAlpha(77),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icon, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
