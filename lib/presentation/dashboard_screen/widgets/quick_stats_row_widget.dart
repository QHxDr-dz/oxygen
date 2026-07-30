import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class QuickStatsRowWidget extends StatefulWidget {
  final int completedWorkouts;
  final int totalSessions;
  final int completionRate;
  final int personalRecords;

  const QuickStatsRowWidget({
    required this.completedWorkouts,
    required this.totalSessions,
    required this.completionRate,
    required this.personalRecords,
    super.key,
  });

  @override
  State<QuickStatsRowWidget> createState() => _QuickStatsRowWidgetState();
}

class _QuickStatsRowWidgetState extends State<QuickStatsRowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anims = List.generate(4, (i) {
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(i * 0.15, 0.6 + i * 0.1, curve: Curves.easeOutCubic),
      );
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData(
        icon: Icons.check_circle_rounded,
        value: '${widget.completedWorkouts}',
        label: 'Completed',
        color: AppTheme.success,
      ),
      _StatData(
        icon: Icons.timeline_rounded,
        value: '${widget.totalSessions}',
        label: 'Sessions',
        color: AppTheme.primary,
      ),
      _StatData(
        icon: Icons.percent_rounded,
        value: '${widget.completionRate}%',
        label: 'Completion',
        color: AppTheme.secondary,
      ),
      _StatData(
        icon: Icons.emoji_events_rounded,
        value: '${widget.personalRecords}',
        label: 'Records',
        color: AppTheme.accent,
      ),
    ];

    return Row(
      children: List.generate(stats.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < stats.length - 1 ? 10 : 0),
            child: FadeTransition(
              opacity: _anims[i],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_anims[i]),
                child: _StatTile(data: stats[i]),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StatData {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatData({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}

class _StatTile extends StatelessWidget {
  final _StatData data;

  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: data.color.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 16, color: data.color),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimaryDark,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textMutedDark,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
