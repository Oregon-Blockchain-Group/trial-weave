import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../backend/models/weight_log.dart';
import '../../../core/theme.dart';

/// Full weight-over-time chart for the Progress screen. X axis is days
/// since the earliest log; bottom labels show "M/D" at evenly-spaced ticks.
class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.logs});

  /// Chronological order (oldest first) — what `listSince` already returns.
  final List<WeightLog> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.length < 2) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'Log a few more weights to see your trend.',
          style: AppText.bodyMuted,
          textAlign: TextAlign.center,
        ),
      );
    }

    final origin = logs.first.date;
    final spots = <FlSpot>[
      for (final w in logs)
        FlSpot(w.date.difference(origin).inDays.toDouble(), w.weightLb),
    ];

    final maxX = spots.last.x;
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    // Pad so the line doesn't touch the chart edges.
    final yPad = ((maxY - minY).abs() * 0.1).clamp(1.0, 10.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: maxX,
            minY: minY - yPad,
            maxY: maxY + yPad,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: AppColors.borderSubtle, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      value.toStringAsFixed(0),
                      style: AppText.caption,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  interval: (maxX / 4).clamp(1, 1000),
                  getTitlesWidget: (value, meta) {
                    final d = origin.add(Duration(days: value.round()));
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${d.month}/${d.day}',
                        style: AppText.caption,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.darkTeal,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.tealTint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
