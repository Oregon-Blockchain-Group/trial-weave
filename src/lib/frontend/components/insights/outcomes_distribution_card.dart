import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/models/cohort_outcome_distribution.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';

/// Per-drug outcomes distribution: p25/median/p75 of weight loss % plus
/// responder rates for the 5/10/15% milestones. Your drug is highlighted.
class OutcomesDistributionCard extends ConsumerWidget {
  const OutcomesDistributionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowsAsync = ref.watch(filteredCohortOutcomesDistributionProvider);
    final yourBrand = ref.watch(activeRegimenProvider).valueOrNull?.brand;

    return rowsAsync.when(
      loading: () => const _Card(child: _Loading()),
      error: (e, _) => _Card(child: _Error('$e')),
      data: (rows) {
        if (rows.isEmpty) return const _Card(child: _Empty());
        final sorted = [...rows]
          ..sort((a, b) => b.medianLossPct.compareTo(a.medianLossPct));
        return Column(
          children: [
            for (var i = 0; i < sorted.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                child: _OutcomeRow(
                  row: sorted[i],
                  isYours: yourBrand != null &&
                      sorted[i].drugBrand.toLowerCase() ==
                          yourBrand.toLowerCase(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OutcomeRow extends StatelessWidget {
  const _OutcomeRow({required this.row, required this.isYours});
  final CohortOutcomeDistribution row;
  final bool isYours;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isYours ? AppColors.tealTint : AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: isYours ? AppColors.darkTeal : AppColors.border,
          width: isYours ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(row.drugBrand, style: AppText.title)),
              if (isYours)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.darkTeal,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: const Text(
                    'Your drug',
                    style: TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${row.medianLossPct.toStringAsFixed(1)}%',
                style: AppText.displayMd,
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  'median · n=${row.nUsers}',
                  style: AppText.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _IqrBar(
            p25: row.p25LossPct,
            median: row.medianLossPct,
            p75: row.p75LossPct,
            color: isYours ? AppColors.darkTeal : AppColors.skyBlue,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Milestone(label: '≥5%', pct: row.pctHit5),
              const SizedBox(width: 8),
              _Milestone(label: '≥10%', pct: row.pctHit10),
              const SizedBox(width: 8),
              _Milestone(label: '≥15%', pct: row.pctHit15),
            ],
          ),
        ],
      ),
    );
  }
}

/// Renders p25 → p75 as a band with a median tick. Normalized to the row's
/// own p75 so each row tells its own story; cross-row comparison is via the
/// numeric values, not the bar length.
class _IqrBar extends StatelessWidget {
  const _IqrBar({
    required this.p25,
    required this.median,
    required this.p75,
    required this.color,
  });
  final double p25;
  final double median;
  final double p75;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxScale = (p75 * 1.1).clamp(1.0, 50.0);
        final p25X = (p25 / maxScale).clamp(0.0, 1.0) * c.maxWidth;
        final p75X = (p75 / maxScale).clamp(0.0, 1.0) * c.maxWidth;
        final medianX = (median / maxScale).clamp(0.0, 1.0) * c.maxWidth;
        return SizedBox(
          height: 18,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 8,
                child: Container(
                  height: 2,
                  color: AppColors.borderSubtle,
                ),
              ),
              Positioned(
                left: p25X,
                width: (p75X - p25X).clamp(2.0, c.maxWidth),
                top: 6,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Positioned(
                left: medianX - 1,
                top: 2,
                child: Container(width: 2, height: 14, color: color),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Milestone extends StatelessWidget {
  const _Milestone({required this.label, required this.pct});
  final String label;
  final double pct;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.borderSubtle,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          children: [
            Text(label, style: AppText.eyebrow),
            const SizedBox(height: 2),
            Text(
              '${pct.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.inkBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
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
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _Error extends StatelessWidget {
  const _Error(this.message);
  final String message;
  @override
  Widget build(BuildContext context) =>
      Text(message, style: const TextStyle(color: AppColors.danger));
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => const Text(
    'No drugs cleared the privacy floor for this filter. Loosen filters to '
    'see more.',
    style: AppText.bodyMuted,
    textAlign: TextAlign.center,
  );
}
