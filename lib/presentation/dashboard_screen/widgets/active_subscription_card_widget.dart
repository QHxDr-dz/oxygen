import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/status_badge_widget.dart';

class ActiveSubscriptionCardWidget extends StatefulWidget {
  final String plan;
  final String status;
  final int daysLeft;
  final int totalDays;
  final String startDate;
  final String endDate;

  const ActiveSubscriptionCardWidget({
    required this.plan,
    required this.status,
    required this.daysLeft,
    required this.totalDays,
    required this.startDate,
    required this.endDate,
    super.key,
  });

  @override
  State<ActiveSubscriptionCardWidget> createState() =>
      _ActiveSubscriptionCardWidgetState();
}

class _ActiveSubscriptionCardWidgetState
    extends State<ActiveSubscriptionCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    final targetProgress = widget.daysLeft / widget.totalDays.toDouble();
    _progressAnim = Tween<double>(begin: 0, end: targetProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    if (widget.status == 'expired' || widget.status == 'cancelled') {
      return AppTheme.error;
    }
    if (widget.daysLeft <= 7) return AppTheme.warning;
    return AppTheme.success;
  }

  BadgeStatus get _badgeStatus {
    if (widget.status == 'expired') return BadgeStatus.expired;
    if (widget.status == 'cancelled') return BadgeStatus.inactive;
    if (widget.daysLeft <= 7) return BadgeStatus.warning;
    return BadgeStatus.active;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withAlpha(38),
            AppTheme.secondary.withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withAlpha(77), width: 0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 18,
                  color: AppTheme.primaryLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plan,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                    const Text(
                      'Active Subscription',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMutedDark,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadgeWidget(status: _badgeStatus),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.daysLeft}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: _statusColor,
                          height: 1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'days left',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Expires ${widget.endDate}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMutedDark,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Started ${widget.startDate}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMutedDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.totalDays} day plan',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMutedDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, child) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: _progressAnim.value,
                      backgroundColor: AppTheme.backgroundDark.withAlpha(128),
                      valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${((widget.daysLeft / widget.totalDays) * 100).round()}% remaining',
                        style: TextStyle(
                          fontSize: 11,
                          color: _statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${widget.totalDays - widget.daysLeft} days used',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMutedDark,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
