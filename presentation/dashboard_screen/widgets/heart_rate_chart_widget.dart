import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/app_theme.dart';

class HeartRateChartWidget extends StatefulWidget {
  final List<double> heartRateData;

  const HeartRateChartWidget({required this.heartRateData, super.key});

  @override
  State<HeartRateChartWidget> createState() => _HeartRateChartWidgetState();
}

class _HeartRateChartWidgetState extends State<HeartRateChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  String _selectedPeriod = 'Today';
  int? _touchedIndex;

  final List<String> _periods = ['Today', 'Week', 'Month'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.heartRateData.asMap().entries.map((e) {
      final isHigh = e.value > 140;
      final isTouched = _touchedIndex == e.key;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value,
            width: isTouched ? 12 : 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            gradient: LinearGradient(
              colors: isHigh
                  ? [AppTheme.error, AppTheme.error.withOpacity(0.6)]
                  : [AppTheme.primary, AppTheme.secondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderDark, width: 0.5),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 15,
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Heart Rate',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryDark,
                        ),
                      ),
                      Text(
                        'BPM over session',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMutedDark,
                        ),
                      ),
                    ],
                  ),
                ),
                // Period selector
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppTheme.borderDark, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _periods.map((p) {
                      final isSelected = p == _selectedPeriod;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPeriod = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            p,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textMutedDark,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Peak indicator
            Row(
              children: [
                const Text(
                  'Peak: ',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMutedDark),
                ),
                Text(
                  '${widget.heartRateData.reduce((a, b) => a > b ? a : b).round()} BPM',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Avg: ',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMutedDark),
                ),
                Text(
                  '${(widget.heartRateData.reduce((a, b) => a + b) / widget.heartRateData.length).round()} BPM',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY: 200,
                  minY: 0,
                  barGroups: _buildBarGroups(),
                  barTouchData: BarTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (response?.spot != null &&
                            event is FlTapUpEvent == false) {
                          _touchedIndex = response!.spot!.touchedBarGroupIndex;
                        } else {
                          _touchedIndex = null;
                        }
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: AppTheme.surfaceDark.withOpacity(0.95),
                      tooltipRoundedRadius: 8,
                      tooltipBorder: const BorderSide(
                        color: AppTheme.borderDark,
                        width: 0.5,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.round()} BPM',
                          const TextStyle(
                            color: AppTheme.textPrimaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 50,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppTheme.borderDark.withOpacity(0.5),
                      strokeWidth: 0.5,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 50,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Text(
                            '${value.round()}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textMutedDark,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
