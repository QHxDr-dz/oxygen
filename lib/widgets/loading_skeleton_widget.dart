import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingSkeletonWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingSkeletonWidget({
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    super.key,
  });

  @override
  State<LoadingSkeletonWidget> createState() => _LoadingSkeletonWidgetState();
}

class _LoadingSkeletonWidgetState extends State<LoadingSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shimmerAnimation = Tween<double>(
      begin: -0.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                AppTheme.surfaceDark,
                AppTheme.borderDark.withAlpha(128),
                AppTheme.surfaceDark,
              ],
              stops: [
                (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                _shimmerAnimation.value.clamp(0.0, 1.0),
                (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }
}

class DashboardSkeletonWidget extends StatelessWidget {
  const DashboardSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LoadingSkeletonWidget(
                width: 44,
                height: 44,
                borderRadius: 22,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  LoadingSkeletonWidget(width: 120, height: 14),
                  SizedBox(height: 6),
                  LoadingSkeletonWidget(width: 80, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const LoadingSkeletonWidget(height: 120, borderRadius: 16),
          const SizedBox(height: 16),
          const LoadingSkeletonWidget(height: 100, borderRadius: 16),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: LoadingSkeletonWidget(height: 80, borderRadius: 12),
              ),
              SizedBox(width: 12),
              Expanded(
                child: LoadingSkeletonWidget(height: 80, borderRadius: 12),
              ),
              SizedBox(width: 12),
              Expanded(
                child: LoadingSkeletonWidget(height: 80, borderRadius: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const LoadingSkeletonWidget(height: 200, borderRadius: 16),
        ],
      ),
    );
  }
}
