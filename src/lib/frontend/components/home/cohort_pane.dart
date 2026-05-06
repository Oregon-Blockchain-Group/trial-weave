import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/cohort_cost.dart';
import '../../../backend/models/cohort_outcome.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';

class CohortPane extends ConsumerWidget {
  const CohortPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outcomesAsync = ref.watch(filteredCohortOutcomesProvider);
    final costAsync = ref.watch(filteredCohortCostProvider);
    final regimen = ref.watch(activeRegimenProvider).valueOrNull;
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final weights = ref.watch(recentWeightLogsProvider).valueOrNull ?? [];

    final myLossPct =
        (profile?.startingWeightLb != null &&
            weights.isNotEmpty &&
            profile!.startingWeightLb! > 0)
        ? ((profile.startingWeightLb! - weights.first.weightLb) /
                  profile.startingWeightLb!) *
              100
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PercentileCard(
            outcomes: outcomesAsync.valueOrNull ?? [],
            myBrand: regimen?.brand,
            myLossPct: myLossPct,
          ),
          const SizedBox(height: 12),
          _OutcomesByDrugCard(
            outcomesAsync: outcomesAsync,
            myBrand: regimen?.brand,
          ),
          const SizedBox(height: 12),
          _CostByDrugCard(costAsync: costAsync, myBrand: regimen?.brand),
          const SizedBox(height: 12),
          _SeeMoreButton(),
        ],
      ),
    );
  }
}

class _PercentileCard extends StatelessWidget {
  const _PercentileCard({
    required this.outcomes,
    required this.myBrand,
    required this.myLossPct,
  });
  final List<CohortOutcome> outcomes;
  final String? myBrand;
  final double? myLossPct;

  @override
  Widget build(BuildContext context) {
    final myCohort = myBrand == null
        ? null
        : outcomes
              .where((o) => o.drugBrand.toLowerCase() == myBrand!.toLowerCase())
              .firstOrNull;

    final hasData = myCohort != null && myLossPct != null;
    final pct = hasData
        ? _percentileForLoss(myLossPct!, myCohort.medianWeightLossPct)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkTeal, AppColors.deepNavy],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COHORT PERCENTILE',
            style: TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Color(0xB3FFFFFF),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pct != null ? 'Top $pct' : 'Not enough data',
                style: const TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: Colors.white,
                ),
              ),
              if (pct != null)
                const Padding(
                  padding: EdgeInsets.only(bottom: 4, left: 2),
                  child: Text(
                    '%',
                    style: TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xD9FFFFFF),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hasData
                ? 'Faster than ${(100 - pct!)}% of similar people on '
                      '${myCohort.drugBrand} · n=${myCohort.nUsers}'
                : (myBrand == null
                      ? 'Start a regimen to compare against a cohort.'
                      : 'Your $myBrand cohort needs 20+ users before we can show outcomes.'),
            style: const TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 12,
              color: Color(0xE6FFFFFF),
            ),
          ),
          const SizedBox(height: 12),
          if (pct != null) _PercentileBar(percentile: 100 - pct),
        ],
      ),
    );
  }

  /// Crude percentile estimate: assume cohort loss % is normal-ish around
  /// median. If user is ahead of median, they're "top X%" where X comes from
  /// how far ahead. This is a stand-in for a real cohort_percentile RPC.
  static int _percentileForLoss(double mine, double median) {
    if (median <= 0) return 50;
    final ratio = mine / median;
    // ratio 1.0 = median = top 50%. ratio 1.5 = ~top 25%. ratio 2 = top 10%.
    if (ratio >= 2) return 10;
    if (ratio >= 1.5) return 25;
    if (ratio >= 1.2) return 35;
    if (ratio >= 1.0) return 50;
    if (ratio >= 0.8) return 65;
    if (ratio >= 0.5) return 80;
    return 90;
  }
}

class _PercentileBar extends StatelessWidget {
  const _PercentileBar({required this.percentile});

  /// 0 = slowest, 100 = fastest
  final int percentile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 12,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final fillWidth = (percentile / 100).clamp(0.0, 1.0) * w;
              final markerLeft = (fillWidth - 6).clamp(0.0, w - 12);
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: Container(
                      width: fillWidth,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: markerLeft,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkTeal, width: 2),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Slowest',
              style: TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 9,
                color: Color(0xB3FFFFFF),
              ),
            ),
            Text(
              'Median',
              style: TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 9,
                color: Color(0xB3FFFFFF),
              ),
            ),
            Text(
              'You',
              style: TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 9,
                color: Color(0xB3FFFFFF),
              ),
            ),
            Text(
              'Fastest',
              style: TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 9,
                color: Color(0xB3FFFFFF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OutcomesByDrugCard extends StatelessWidget {
  const _OutcomesByDrugCard({
    required this.outcomesAsync,
    required this.myBrand,
  });
  final AsyncValue<List<CohortOutcome>> outcomesAsync;
  final String? myBrand;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WEIGHT LOSS BY DRUG', style: AppText.eyebrow),
          const SizedBox(height: 4),
          const Text(
            'Median %',
            style: TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.inkBlack,
            ),
          ),
          const SizedBox(height: 10),
          outcomesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                Text('$e', style: const TextStyle(color: AppColors.danger)),
            data: (rows) {
              if (rows.isEmpty) {
                return const Text(
                  'No drugs cleared the privacy floor yet.',
                  style: AppText.bodyMuted,
                );
              }
              final sorted = [...rows]
                ..sort(
                  (a, b) =>
                      b.medianWeightLossPct.compareTo(a.medianWeightLossPct),
                );
              final maxPct = sorted.first.medianWeightLossPct;
              return Column(
                children: [
                  for (final o in sorted)
                    _BarRow(
                      label: o.drugBrand,
                      value: o.medianWeightLossPct / maxPct,
                      trailing: '${o.medianWeightLossPct.toStringAsFixed(1)}%',
                      isYours:
                          myBrand != null &&
                          o.drugBrand.toLowerCase() == myBrand!.toLowerCase(),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CostByDrugCard extends StatelessWidget {
  const _CostByDrugCard({required this.costAsync, required this.myBrand});
  final AsyncValue<List<CohortCost>> costAsync;
  final String? myBrand;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COST · MONTHLY', style: AppText.eyebrow),
          const SizedBox(height: 4),
          const Text(
            'Cohort median',
            style: TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.inkBlack,
            ),
          ),
          const SizedBox(height: 10),
          costAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                Text('$e', style: const TextStyle(color: AppColors.danger)),
            data: (rows) {
              if (rows.isEmpty) {
                return const Text(
                  'No cost data yet.',
                  style: AppText.bodyMuted,
                );
              }
              final sorted = [...rows]
                ..sort(
                  (a, b) =>
                      a.medianMonthlyCostUsd.compareTo(b.medianMonthlyCostUsd),
                );
              final maxCost = sorted
                  .map((r) => r.medianMonthlyCostUsd)
                  .reduce((a, b) => a > b ? a : b);
              return Column(
                children: [
                  for (final r in sorted)
                    _BarRow(
                      label: r.drugBrand,
                      value: r.medianMonthlyCostUsd / maxCost,
                      trailing:
                          '\$${r.medianMonthlyCostUsd.toStringAsFixed(0)}',
                      isYours:
                          myBrand != null &&
                          r.drugBrand.toLowerCase() == myBrand!.toLowerCase(),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.trailing,
    required this.isYours,
  });
  final String label;
  final double value;
  final String trailing;
  final bool isYours;

  @override
  Widget build(BuildContext context) {
    final barColor = isYours ? AppColors.darkTeal : const Color(0xFF9CA3AF);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 12,
                fontWeight: isYours ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.inkBlack,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppColors.borderSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 50,
            child: Text(
              trailing,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.inkBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeeMoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.go('/cohort'),
      icon: const Icon(Icons.arrow_forward, size: 16),
      label: const Text('See full cohort screens'),
    );
  }
}
