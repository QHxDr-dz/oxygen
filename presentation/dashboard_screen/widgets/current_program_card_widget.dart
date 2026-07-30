import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../theme/app_theme.dart';

class CurrentProgramCardWidget extends StatefulWidget {
  final String name;
  final String difficulty;
  final int currentWeek;
  final int totalWeeks;
  final int completedDays;
  final int totalDays;

  const CurrentProgramCardWidget({
    required this.name,
    required this.difficulty,
    required this.currentWeek,
    required this.totalWeeks,
    required this.completedDays,
    required this.totalDays,
    super.key,
  });

  @override
  State<CurrentProgramCardWidget> createState() =>
      _CurrentProgramCardWidgetState();
}

class _CurrentProgramCardWidgetState extends State<CurrentProgramCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _circleController;
  late Animation<double> _circleAnim;

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    final progress = widget.completedDays / widget.totalDays;
    _circleAnim = Tween<double>(begin: 0, end: progress).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeOutCubic),
    );
    _circleController.forward();
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  Color get _difficultyColor {
    switch (widget.difficulty.toLowerCase()) {
      case 'beginner':
        return AppTheme.success;
      case 'intermediate':
        return AppTheme.accent;
      case 'advanced':
        return AppTheme.error;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderDark, width: 0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _difficultyColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: _difficultyColor.withOpacity(0.4),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        widget.difficulty,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _difficultyColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'Week ${widget.currentWeek}/${widget.totalWeeks}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryDark,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.completedDays} of ${widget.totalDays} days completed',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: AnimatedBuilder(
                    animation: _circleAnim,
                    builder: (_, __) => LinearProgressIndicator(
                      value: _circleAnim.value,
                      backgroundColor: AppTheme.backgroundDark.withOpacity(0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.secondary,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Circular progress
          AnimatedBuilder(
            animation: _circleAnim,
            builder: (context, child) {
              final percent = (widget.completedDays / widget.totalDays * 100)
                  .round();
              return SizedBox(
                width: 72,
                height: 72,
                child: CustomPaint(
                  painter: _CircularProgressPainter(
                    progress: _circleAnim.value,
                    primaryColor: AppTheme.secondary,
                    backgroundColor: AppTheme.borderDark,
                    strokeWidth: 5,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimaryDark,
                            height: 1,
                          ),
                        ),
                        const Text(
                          'done',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.textMutedDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter old) => old.progress != progress;
}
