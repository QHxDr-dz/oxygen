import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

// V3 Liquid Glass BottomNav — BackdropFilter blur + frosted surface + animated pill
// LOCKED: BackdropFilter blur must not be removed

class _TabSpec {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int? branchIndex;

  const _TabSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.branchIndex,
  });
}

class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavigation({required this.navigationShell, super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation>
    with SingleTickerProviderStateMixin {
  int _selectedVisualIndex = 0;
  late AnimationController _pillController;

  final List<_TabSpec> _tabs = const [
    _TabSpec(
      label: 'Dashboard',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
      branchIndex: 0,
    ),
    _TabSpec(
      label: 'Workouts',
      icon: Icons.fitness_center_outlined,
      selectedIcon: Icons.fitness_center_rounded,
      branchIndex: null,
    ),
    _TabSpec(
      label: 'History',
      icon: Icons.history_outlined,
      selectedIcon: Icons.history_rounded,
      branchIndex: null,
    ),
    _TabSpec(
      label: 'Alerts',
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications_rounded,
      branchIndex: null,
    ),
    _TabSpec(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      branchIndex: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pillController.dispose();
    super.dispose();
  }

  void _onTabTap(int visualIndex) {
    final spec = _tabs[visualIndex];
    if (spec.branchIndex == null) return; // stub tab — silent ignore
    setState(() => _selectedVisualIndex = visualIndex);
    widget.navigationShell.goBranch(
      spec.branchIndex!,
      initialLocation: spec.branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        // LOCKED: BackdropFilter blur — core V3 Liquid Glass technique
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64 + bottomPadding,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withAlpha(166),
            border: const Border(
              top: BorderSide(color: AppTheme.borderDark, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_tabs.length, (i) {
                  final tab = _tabs[i];
                  final isActive = i == _selectedVisualIndex;
                  final isStub = tab.branchIndex == null;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onTabTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: Opacity(
                        opacity: isStub ? 0.4 : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                width: isActive ? 48 : 36,
                                height: isActive ? 32 : 32,
                                decoration: isActive
                                    ? BoxDecoration(
                                        color: AppTheme.primary.withAlpha(51),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppTheme.primary.withAlpha(
                                            102,
                                          ),
                                          width: 0.5,
                                        ),
                                      )
                                    : null,
                                child: Center(
                                  child: Icon(
                                    isActive ? tab.selectedIcon : tab.icon,
                                    size: 20,
                                    color: isActive
                                        ? AppTheme.primary
                                        : AppTheme.textMutedDark,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isActive
                                      ? AppTheme.primary
                                      : AppTheme.textMutedDark,
                                ),
                                child: Text(tab.label),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
