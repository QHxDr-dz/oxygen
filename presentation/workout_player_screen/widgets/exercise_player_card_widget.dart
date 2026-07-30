import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';

class ExercisePlayerCardWidget extends StatefulWidget {
  final String exerciseName;
  final String targetMuscle;
  final String equipment;
  final String gifUrl;
  final String gifSemanticLabel;
  final String instructions;
  final String reps;
  final double weight;
  final void Function(double) onWeightChanged;

  const ExercisePlayerCardWidget({
    required this.exerciseName,
    required this.targetMuscle,
    required this.equipment,
    required this.gifUrl,
    required this.gifSemanticLabel,
    required this.instructions,
    required this.reps,
    required this.weight,
    required this.onWeightChanged,
    super.key,
  });

  @override
  State<ExercisePlayerCardWidget> createState() =>
      _ExercisePlayerCardWidgetState();
}

class _ExercisePlayerCardWidgetState extends State<ExercisePlayerCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isInstructionsExpanded = false;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late double _localWeight;

  @override
  void initState() {
    super.initState();
    _localWeight = widget.weight;
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void didUpdateWidget(ExercisePlayerCardWidget old) {
    super.didUpdateWidget(old);
    if (old.exerciseName != widget.exerciseName) {
      _localWeight = widget.weight;
      _entranceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderDark, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GIF / Image section
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Semantics(
                  label: widget.gifSemanticLabel,
                  child: CachedNetworkImage(
                    imageUrl: widget.gifUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 220,
                      color: AppTheme.backgroundDark,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              size: 24,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Loading exercise...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMutedDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 220,
                      color: AppTheme.backgroundDark,
                      child: Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          size: 48,
                          color: AppTheme.primary.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise name
                    Text(
                      widget.exerciseName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimaryDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Chips row
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _ExerciseChip(
                          icon: Icons.sports_gymnastics_rounded,
                          label: widget.targetMuscle,
                          color: AppTheme.secondary,
                        ),
                        _ExerciseChip(
                          icon: Icons.hardware_rounded,
                          label: widget.equipment,
                          color: AppTheme.primary,
                        ),
                        _ExerciseChip(
                          icon: Icons.repeat_rounded,
                          label: '${widget.reps} reps',
                          color: AppTheme.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Weight input
                    _WeightInputWidget(
                      weight: _localWeight,
                      onChanged: (w) {
                        setState(() => _localWeight = w);
                        widget.onWeightChanged(w);
                      },
                    ),
                    const SizedBox(height: 14),
                    // Instructions expandable
                    GestureDetector(
                      onTap: () => setState(
                        () =>
                            _isInstructionsExpanded = !_isInstructionsExpanded,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundDark.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.borderDark,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: AppTheme.textSecondaryDark,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Instructions',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondaryDark,
                                  ),
                                ),
                                const Spacer(),
                                AnimatedRotation(
                                  turns: _isInstructionsExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: AppTheme.textMutedDark,
                                  ),
                                ),
                              ],
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              child: _isInstructionsExpanded
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        widget.instructions,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondaryDark,
                                          height: 1.6,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ExerciseChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightInputWidget extends StatelessWidget {
  final double weight;
  final void Function(double) onChanged;

  const _WeightInputWidget({required this.weight, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monitor_weight_outlined,
            size: 16,
            color: AppTheme.primaryLight,
          ),
          const SizedBox(width: 8),
          const Text(
            'Weight',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // Decrease
          _WeightButton(
            icon: Icons.remove_rounded,
            onTap: () {
              if (weight > 0) onChanged(weight - 2.5);
            },
          ),
          const SizedBox(width: 12),
          Text(
            '${weight.toStringAsFixed(1)} kg',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimaryDark,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 12),
          // Increase
          _WeightButton(
            icon: Icons.add_rounded,
            onTap: () => onChanged(weight + 2.5),
          ),
        ],
      ),
    );
  }
}

class _WeightButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _WeightButton({required this.icon, required this.onTap});

  @override
  State<_WeightButton> createState() => _WeightButtonState();
}

class _WeightButtonState extends State<_WeightButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        scale: _controller,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Icon(widget.icon, size: 16, color: AppTheme.primaryLight),
        ),
      ),
    );
  }
}
