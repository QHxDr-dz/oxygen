import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class SetControlsWidget extends StatefulWidget {
  final int currentSetIndex;
  final int totalSets;
  final VoidCallback onPrevious;
  final VoidCallback onCompleteSet;
  final VoidCallback onNext;
  final bool canGoPrevious;
  final bool canGoNext;

  const SetControlsWidget({
    required this.currentSetIndex,
    required this.totalSets,
    required this.onPrevious,
    required this.onCompleteSet,
    required this.onNext,
    required this.canGoPrevious,
    required this.canGoNext,
    super.key,
  });

  @override
  State<SetControlsWidget> createState() => _SetControlsWidgetState();
}

class _SetControlsWidgetState extends State<SetControlsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isLastSet => widget.currentSetIndex >= widget.totalSets - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(242),
        border: const Border(
          top: BorderSide(color: AppTheme.borderDark, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Set ${widget.currentSetIndex + 1} of ${widget.totalSets}',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _NavButton(
                icon: Icons.skip_previous_rounded,
                label: 'Prev',
                onTap: widget.canGoPrevious ? widget.onPrevious : null,
                isEnabled: widget.canGoPrevious,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ScaleTransition(
                  scale: _pulseAnim,
                  child: _CompleteSetButton(
                    isLastSet: _isLastSet,
                    onTap: widget.onCompleteSet,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _NavButton(
                icon: Icons.skip_next_rounded,
                label: 'Next',
                onTap: widget.canGoNext ? widget.onNext : null,
                isEnabled: widget.canGoNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.35,
        child: Container(
          width: 64,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.backgroundDark.withAlpha(153),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderDark, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppTheme.textSecondaryDark),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMutedDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompleteSetButton extends StatefulWidget {
  final bool isLastSet;
  final VoidCallback onTap;

  const _CompleteSetButton({required this.isLastSet, required this.onTap});

  @override
  State<_CompleteSetButton> createState() => _CompleteSetButtonState();
}

class _CompleteSetButtonState extends State<_CompleteSetButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.reverse(),
      onTapUp: (_) {
        _pressController.forward();
        widget.onTap();
      },
      onTapCancel: () => _pressController.forward(),
      child: ScaleTransition(
        scale: _pressController,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isLastSet
                  ? [AppTheme.success, const Color(0xFF059669)]
                  : [AppTheme.primary, AppTheme.secondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (widget.isLastSet ? AppTheme.success : AppTheme.primary)
                    .withAlpha(89),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isLastSet
                    ? Icons.check_circle_rounded
                    : Icons.check_rounded,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isLastSet ? 'Complete Exercise' : 'Complete Set',
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
