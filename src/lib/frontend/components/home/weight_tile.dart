import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/weight_log.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import 'home_card.dart';

class WeightTile extends ConsumerWidget {
  const WeightTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final weightsAsync = ref.watch(recentWeightLogsProvider);

    return HomeCard(
      onTap: () => context.go('/log/weight'),
      child: profileAsync.when(
        loading: () => const _Loading(),
        error: (e, _) =>
            Text('$e', style: const TextStyle(color: AppColors.danger)),
        data: (profile) => weightsAsync.when(
          loading: () => const _Loading(),
          error: (e, _) =>
              Text('$e', style: const TextStyle(color: AppColors.danger)),
          data: (weights) {
            final starting = profile?.startingWeightLb;
            if (weights.isEmpty) {
              return const _Empty(
                'Log your first weight to start tracking change.',
              );
            }
            final current = weights.first.weightLb; // newest first
            final delta = starting != null ? current - starting : null;
            return _Body(
              currentLb: current,
              deltaLb: delta,
              sparkline: _SparklinePoints.fromWeights(weights),
            );
          },
        ),
      ),
    );
  }
}

/// Chronological points for the sparkline (oldest -> newest), with x as
/// the day index from the first point.
class _SparklinePoints {
  _SparklinePoints({required this.points});
  final List<FlSpot> points;

  factory _SparklinePoints.fromWeights(List<WeightLog> weightsNewestFirst) {
    final chronological = weightsNewestFirst.reversed.toList();
    if (chronological.isEmpty) return _SparklinePoints(points: const []);
    final origin = chronological.first.date;
    final points = <FlSpot>[
      for (final w in chronological)
        FlSpot(w.date.difference(origin).inDays.toDouble(), w.weightLb),
    ];
    return _SparklinePoints(points: points);
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.currentLb,
    required this.deltaLb,
    required this.sparkline,
  });
  final double currentLb;
  final double? deltaLb;
  final _SparklinePoints sparkline;

  @override
  Widget build(BuildContext context) {
    final deltaText = deltaLb == null
        ? null
        : (deltaLb! < 0
              ? '${deltaLb!.toStringAsFixed(1)} lb'
              : '+${deltaLb!.toStringAsFixed(1)} lb');
    final deltaColor = deltaLb == null
        ? AppColors.muted
        : (deltaLb! < 0 ? AppColors.success : AppColors.warning);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WEIGHT', style: AppText.eyebrow),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${currentLb.toStringAsFixed(1)} lb',
              style: AppText.displayLg,
            ),
            const SizedBox(width: 10),
            if (deltaText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '$deltaText vs start',
                  style: TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: deltaColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: sparkline.points.length < 2
              ? const Center(
                  child: Text(
                    'Log a few more weights to see a trend',
                    style: AppText.caption,
                  ),
                )
              : LineChart(
                  LineChartData(
                    lineTouchData: const LineTouchData(enabled: false),
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: sparkline.points,
                        isCurved: true,
                        color: AppColors.darkTeal,
                        barWidth: 2,
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
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 80,
    child: Center(child: CircularProgressIndicator()),
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('WEIGHT', style: AppText.eyebrow),
      const SizedBox(height: 6),
      Text(message, style: AppText.bodyMuted),
    ],
  );
}
