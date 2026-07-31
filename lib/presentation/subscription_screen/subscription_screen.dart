import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../features/subscription/presentation/providers/subscription_state_notifier.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_skeleton_widget.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionNotifierProvider.notifier).loadSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Subscription',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.card_membership_rounded,
                          size: 14,
                          color: AppTheme.accent,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Membership',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SubscriptionState state) {
    if (state.isLoading && state.subscription == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const ShimmerBox(height: 200, borderRadius: 20),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: ShimmerBox(height: 100, borderRadius: 16)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 100, borderRadius: 16)),
              ],
            ),
          ],
        ),
      );
    }

    if (state.error != null && state.subscription == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.textMutedDark,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(color: AppTheme.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref
                  .read(subscriptionNotifierProvider.notifier)
                  .loadSubscription(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.subscription == null) {
      return const EmptyStateWidget(
        icon: Icons.card_membership_outlined,
        title: 'No Active Subscription',
        description:
            'You don\'t have an active subscription. Contact your gym to get started.',
      );
    }

    final sub = state.subscription!;
    final dateFormat = DateFormat('MMM d, yyyy');

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(subscriptionNotifierProvider.notifier).loadSubscription(),
      color: AppTheme.primary,
      backgroundColor: AppTheme.surfaceDark,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          children: [
            // Main plan card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF2D1B69)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.plan.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${sub.plan.amount.toStringAsFixed(0)} / ${sub.plan.days} days',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withAlpha(180),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusBadge(status: sub.status),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${sub.daysLeft} days remaining',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${(sub.progressFraction * 100).toInt()}% used',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(160),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: sub.progressFraction,
                          backgroundColor: Colors.white.withAlpha(30),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            sub.daysLeft < 7
                                ? AppTheme.error
                                : AppTheme.success,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _DateInfo(
                          label: 'Start Date',
                          value: dateFormat.format(sub.startDate),
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withAlpha(30),
                      ),
                      Expanded(
                        child: _DateInfo(
                          label: 'End Date',
                          value: dateFormat.format(sub.endDate),
                          icon: Icons.event_outlined,
                          isRight: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.timer_outlined,
                    label: 'Days Left',
                    value: '${sub.daysLeft}',
                    color: sub.daysLeft < 7 ? AppTheme.error : AppTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.calendar_month_outlined,
                    label: 'Duration',
                    value: '${sub.plan.days} days',
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderDark, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Subscription Status',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sub.isOngoing
                              ? 'Your membership is active and in good standing.'
                              : sub.isExpired
                              ? 'Your membership has expired. Please renew.'
                              : 'Your membership has been cancelled.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'ongoing':
        color = AppTheme.success;
        label = 'Active';
        break;
      case 'expired':
        color = AppTheme.error;
        label = 'Expired';
        break;
      default:
        color = AppTheme.textMutedDark;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isRight;
  const _DateInfo({
    required this.label,
    required this.value,
    required this.icon,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isRight ? 16 : 0, right: isRight ? 0 : 16),
      child: Column(
        crossAxisAlignment: isRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(140)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
