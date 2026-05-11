import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/models/factor.dart';
import '../../../backend/models/factor_log.dart';
import '../../../backend/models/side_effect.dart';
import '../../../backend/models/side_effect_log.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import '../charts/hero_ring.dart';
import '../progress/weight_chart.dart';

class TrendsPane extends ConsumerWidget {
  const TrendsPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightsAsync = ref.watch(progressWeightLogsProvider);
    final baselineAsync = ref.watch(latestBaselineProvider);
    final checkInsAsync = ref.watch(recentCheckInsProvider);
    final sideEffectsAsync = ref.watch(recentSideEffectsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Weight trend',
            sub: 'Since starting your regimen',
          ),
          const SizedBox(height: 8),
          weightsAsync.when(
            loading: () => const _SkeletonCard(height: 220),
            error: (e, _) => _ErrorCard('$e'),
            data: (logs) => WeightChart(logs: logs),
          ),
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'Well-being shifts',
            sub: 'Baseline → recent average',
          ),
          const SizedBox(height: 8),
          baselineAsync.when(
            loading: () => const _SkeletonCard(height: 200),
            error: (e, _) => _ErrorCard('$e'),
            data: (baseline) => checkInsAsync.when(
              loading: () => const _SkeletonCard(height: 200),
              error: (e, _) => _ErrorCard('$e'),
              data: (checkIns) =>
                  _FactorPillsCard(baseline: baseline, checkIns: checkIns),
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Side effects · 90 days', sub: 'Top reported'),
          const SizedBox(height: 8),
          sideEffectsAsync.when(
            loading: () => const _SkeletonCard(height: 140),
            error: (e, _) => _ErrorCard('$e'),
            data: (logs) => _SideEffectGrid(logs: logs),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.sub});
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: AppText.eyebrow),
        const SizedBox(height: 2),
        Text(
          sub,
          style: const TextStyle(
            fontFamily: AppText.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.inkBlack,
          ),
        ),
      ],
    );
  }
}

class _FactorPillsCard extends StatelessWidget {
  const _FactorPillsCard({required this.baseline, required this.checkIns});
  final Map<String, int> baseline;
  final List<FactorLog> checkIns;

  @override
  Widget build(BuildContext context) {
    if (baseline.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'No baseline yet — finish onboarding to start tracking shifts.',
          style: AppText.bodyMuted,
          textAlign: TextAlign.center,
        ),
      );
    }
    final averages = _avgByFactor(checkIns);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (final f in kBaselineFactors)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _FactorPill(
                factor: f,
                from: baseline[f.key]?.toDouble(),
                to: averages[f.key],
              ),
            ),
        ],
      ),
    );
  }

  static Map<String, double> _avgByFactor(List<FactorLog> logs) {
    final sums = <String, double>{};
    final counts = <String, int>{};
    for (final l in logs) {
      sums[l.factorKey] = (sums[l.factorKey] ?? 0) + l.rating;
      counts[l.factorKey] = (counts[l.factorKey] ?? 0) + 1;
    }
    return {for (final k in sums.keys) k: sums[k]! / counts[k]!};
  }
}

class _FactorPill extends StatelessWidget {
  const _FactorPill({
    required this.factor,
    required this.from,
    required this.to,
  });
  final Factor factor;
  final double? from;
  final double? to;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            factor.label,
            style: const TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 11,
              color: AppColors.muted,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 14,
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                Widget? fromDot;
                Widget? toDot;
                if (from != null) {
                  final left = ((from! - 1) / 4).clamp(0.0, 1.0) * (w - 10);
                  fromDot = Positioned(
                    left: left,
                    top: 2,
                    child: const _Dot(
                      color: Color(0xFF9CA3AF),
                      withOutline: true,
                    ),
                  );
                }
                if (to != null) {
                  final left = ((to! - 1) / 4).clamp(0.0, 1.0) * (w - 10);
                  toDot = Positioned(
                    left: left,
                    top: 2,
                    child: const _Dot(
                      color: AppColors.darkTeal,
                      withOutline: true,
                    ),
                  );
                }
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.borderSubtle,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    ?fromDot,
                    ?toDot,
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            from != null && to != null
                ? '${from!.toInt()}→${to!.toStringAsFixed(0)}'
                : (from != null ? '${from!.toInt()}→—' : '—'),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.inkBlack,
            ),
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, this.withOutline = false});
  final Color color;
  final bool withOutline;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: withOutline ? Border.all(color: Colors.white, width: 2) : null,
      ),
    );
  }
}

class _SideEffectGrid extends StatelessWidget {
  const _SideEffectGrid({required this.logs});
  final List<SideEffectLog> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'No side effects in the last 90 days. Nice.',
          style: AppText.bodyMuted,
          textAlign: TextAlign.center,
        ),
      );
    }
    final counts = <String, int>{};
    for (final l in logs) {
      counts[l.name] = (counts[l.name] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(3).toList();
    final maxCount = top.first.value;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          for (final entry in top) ...[
            Expanded(
              child: _DonutCell(
                label: _label(entry.key),
                count: entry.value,
                value: entry.value / maxCount,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _label(String key) {
    for (final s in kSideEffectCatalog) {
      if (s.key == key) return s.label;
    }
    return key;
  }
}

class _DonutCell extends StatelessWidget {
  const _DonutCell({
    required this.label,
    required this.count,
    required this.value,
  });
  final String label;
  final int count;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppText.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        HeroRing(
          size: 56,
          value: value,
          progressColor: AppColors.darkTeal,
          strokeWidth: 5,
          center: Text(
            '$count',
            style: const TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.inkBlack,
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard(this.message);
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.danger),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.danger, fontSize: 12),
      ),
    );
  }
}
