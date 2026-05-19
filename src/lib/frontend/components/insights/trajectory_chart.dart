import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/models/cohort_weight_trajectory_point.dart';
import '../../../backend/models/weight_log.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';

/// Median weight-loss trajectory (% loss vs. weeks since regimen start) for
/// each drug brand in the matched cohort, with the caller's own trajectory
/// overlaid in a bolder accent line.
///
/// Reads:
///   - filteredCohortWeightTrajectoryProvider — cohort medians (server)
///   - currentProfileProvider + activeRegimenProvider + progressWeightLogsProvider
///     — your trajectory, computed locally with the same weekly buckets the
///     server uses (latest weight in each week since `regimen.started_at`)
class TrajectoryChart extends ConsumerWidget {
  const TrajectoryChart({super.key});

  static const _palette = <Color>[
    AppColors.skyBlue,
    AppColors.deepNavy,
    AppColors.mediumTeal,
    AppColors.warning,
    AppColors.success,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cohortAsync = ref.watch(filteredCohortWeightTrajectoryProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final regimen = ref.watch(activeRegimenProvider).valueOrNull;
    final myWeights = ref.watch(progressWeightLogsProvider).valueOrNull ?? [];
    final myBrand = regimen?.brand.toLowerCase();

    return cohortAsync.when(
      loading: () => const _Card(child: _Loading()),
      error: (e, _) => _Card(child: _Error('$e')),
      data: (rows) {
        if (rows.isEmpty) return const _Card(child: _Empty());
        final byDrug = _groupByDrug(rows);
        final mine = (profile?.startingWeightLb != null && regimen != null)
            ? _computeMyTrajectory(
                startingWeightLb: profile!.startingWeightLb!,
                startedAt: regimen.startedAt,
                logs: myWeights,
              )
            : const <_MyPoint>[];

        // Color assignment is deterministic on brand order so legend matches.
        final brands = byDrug.keys.toList()..sort();
        final colors = <String, Color>{};
        var paletteIdx = 0;
        for (final b in brands) {
          if (myBrand != null && b.toLowerCase() == myBrand) {
            colors[b] = AppColors.darkTeal; // your drug stands out
          } else {
            colors[b] = _palette[paletteIdx % _palette.length];
            paletteIdx++;
          }
        }

        final maxWeek = rows.map((r) => r.week).fold(0, (a, b) => a > b ? a : b);
        final maxY = _maxLossPct(rows, mine);

        return _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: maxWeek.toDouble().clamp(4, 52),
                    minY: 0,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => const FlLine(
                        color: AppColors.borderSubtle,
                        strokeWidth: 1,
                      ),
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
                          reservedSize: 36,
                          getTitlesWidget: (v, _) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              '${v.toStringAsFixed(0)}%',
                              style: AppText.caption,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          interval: 4,
                          getTitlesWidget: (v, _) => Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'w${v.toStringAsFixed(0)}',
                              style: AppText.caption,
                            ),
                          ),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      for (final brand in brands)
                        _cohortLine(
                          points: byDrug[brand]!,
                          color: colors[brand]!,
                          isYours:
                              myBrand != null && brand.toLowerCase() == myBrand,
                        ),
                      if (mine.isNotEmpty) _myLine(mine),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) =>
                            AppColors.inkBlack.withValues(alpha: 0.85),
                        getTooltipItems: (spots) => spots
                            .map(
                              (s) => LineTooltipItem(
                                '${s.y.toStringAsFixed(1)}%',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Legend(
                brands: brands,
                colors: colors,
                yourBrand: regimen?.brand,
                hasMine: mine.isNotEmpty,
              ),
            ],
          ),
        );
      },
    );
  }

  static LineChartBarData _cohortLine({
    required List<CohortWeightTrajectoryPoint> points,
    required Color color,
    required bool isYours,
  }) {
    return LineChartBarData(
      spots: [
        for (final p in points) FlSpot(p.week.toDouble(), p.medianLossPct),
      ],
      isCurved: true,
      color: color.withValues(alpha: isYours ? 1.0 : 0.65),
      barWidth: isYours ? 2.8 : 1.6,
      dotData: const FlDotData(show: false),
    );
  }

  static LineChartBarData _myLine(List<_MyPoint> mine) {
    return LineChartBarData(
      spots: [for (final p in mine) FlSpot(p.week.toDouble(), p.lossPct)],
      isCurved: true,
      color: AppColors.inkBlack,
      barWidth: 3.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, _, _, _) => FlDotCirclePainter(
          radius: 3,
          color: AppColors.inkBlack,
          strokeWidth: 1.5,
          strokeColor: Colors.white,
        ),
      ),
    );
  }

  static Map<String, List<CohortWeightTrajectoryPoint>> _groupByDrug(
    List<CohortWeightTrajectoryPoint> rows,
  ) {
    final m = <String, List<CohortWeightTrajectoryPoint>>{};
    for (final r in rows) {
      (m[r.drugBrand] ??= []).add(r);
    }
    for (final v in m.values) {
      v.sort((a, b) => a.week.compareTo(b.week));
    }
    return m;
  }

  static double _maxLossPct(
    List<CohortWeightTrajectoryPoint> rows,
    List<_MyPoint> mine,
  ) {
    double m = 5;
    for (final r in rows) {
      if (r.medianLossPct > m) m = r.medianLossPct;
    }
    for (final p in mine) {
      if (p.lossPct > m) m = p.lossPct;
    }
    return (m * 1.15).clamp(5, 50);
  }

  static List<_MyPoint> _computeMyTrajectory({
    required double startingWeightLb,
    required DateTime startedAt,
    required List<WeightLog> logs,
  }) {
    // Match the server's bucketing: floor((logged_at - started_at) / 7 days).
    final latestByWeek = <int, WeightLog>{};
    for (final w in logs) {
      if (w.loggedAt.isBefore(startedAt)) continue;
      final week = w.loggedAt.difference(startedAt).inDays ~/ 7;
      if (week < 0) continue;
      final prev = latestByWeek[week];
      if (prev == null || w.loggedAt.isAfter(prev.loggedAt)) {
        latestByWeek[week] = w;
      }
    }
    final weeks = latestByWeek.keys.toList()..sort();
    return [
      for (final w in weeks)
        _MyPoint(
          week: w,
          lossPct:
              ((startingWeightLb - latestByWeek[w]!.weightLb) /
                  startingWeightLb) *
              100,
        ),
    ];
  }
}

class _MyPoint {
  const _MyPoint({required this.week, required this.lossPct});
  final int week;
  final double lossPct;
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.brands,
    required this.colors,
    required this.yourBrand,
    required this.hasMine,
  });
  final List<String> brands;
  final Map<String, Color> colors;
  final String? yourBrand;
  final bool hasMine;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        if (hasMine)
          const _LegendItem(
            color: AppColors.inkBlack,
            label: 'You',
            bold: true,
          ),
        for (final b in brands)
          _LegendItem(
            color: colors[b]!,
            label: b,
            bold:
                yourBrand != null && b.toLowerCase() == yourBrand!.toLowerCase(),
          ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.bold,
  });
  final Color color;
  final String label;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppText.fontFamily,
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.inkBlack,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 220,
    child: Center(child: CircularProgressIndicator()),
  );
}

class _Error extends StatelessWidget {
  const _Error(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 220,
    child: Center(
      child: Text(message, style: const TextStyle(color: AppColors.danger)),
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 180,
    child: Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'No drugs cleared the 20-person privacy floor for this filter '
          'combination. Try loosening the filters.',
          style: AppText.bodyMuted,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
