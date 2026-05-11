import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';

/// 4-cell stat strip that overlaps the gradient top section. Reads from
/// home providers; values fall back to "—" when data isn't ready yet.
class MetricStrip extends ConsumerWidget {
  const MetricStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final weights = ref.watch(recentWeightLogsProvider).valueOrNull ?? [];
    final regimen = ref.watch(activeRegimenProvider).valueOrNull;
    final outcomes = ref.watch(cohortOutcomesProvider).valueOrNull ?? [];
    final sideEffects = ref.watch(recentSideEffectsProvider).valueOrNull ?? [];
    final myCost = ref.watch(currentMonthCostProvider).valueOrNull;
    final cohortCost = ref.watch(filteredCohortCostProvider).valueOrNull ?? [];

    final currentWeight = weights.isNotEmpty ? weights.first.weightLb : null;
    final weightDelta =
        (profile?.startingWeightLb != null && currentWeight != null)
        ? currentWeight - profile!.startingWeightLb!
        : null;

    final myLossPct =
        (profile?.startingWeightLb != null &&
            currentWeight != null &&
            profile!.startingWeightLb! > 0)
        ? ((profile.startingWeightLb! - currentWeight) /
                  profile.startingWeightLb!) *
              100
        : null;
    final cohortMedianPct = regimen != null
        ? _findMedian(outcomes, regimen.brand)
        : null;
    final cohortDeltaPts = (myLossPct != null && cohortMedianPct != null)
        ? myLossPct - cohortMedianPct
        : null;

    final cohortMedianCost = regimen != null
        ? _findCohortCost(cohortCost, regimen.brand)
        : null;
    final costDelta = (myCost != null && cohortMedianCost != null)
        ? (myCost.amountUsd - cohortMedianCost).round()
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg + 2),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _Cell(
            label: 'Weight',
            value: currentWeight != null
                ? currentWeight.toStringAsFixed(1)
                : '—',
            unit: currentWeight != null ? 'lb' : null,
            delta: _formatDeltaLb(weightDelta),
            deltaTone: weightDelta == null
                ? _Tone.neutral
                : weightDelta < 0
                ? _Tone.good
                : _Tone.warn,
          ),
          _Divider(),
          _Cell(
            label: 'Cohort',
            value: cohortDeltaPts != null
                ? (cohortDeltaPts >= 0
                      ? '+${cohortDeltaPts.toStringAsFixed(0)}'
                      : cohortDeltaPts.toStringAsFixed(0))
                : '—',
            unit: cohortDeltaPts != null ? 'pts' : null,
            delta: cohortDeltaPts == null
                ? null
                : (cohortDeltaPts >= 0 ? 'above median' : 'below median'),
            deltaTone: cohortDeltaPts == null
                ? _Tone.neutral
                : cohortDeltaPts >= 0
                ? _Tone.good
                : _Tone.warn,
          ),
          _Divider(),
          _Cell(
            label: 'Side fx',
            value: '${sideEffects.length}',
            delta: sideEffects.isEmpty ? 'none in 90d' : 'last 90d',
            deltaTone: sideEffects.isEmpty ? _Tone.good : _Tone.neutral,
          ),
          _Divider(),
          _Cell(
            label: 'Cost / mo',
            value: myCost != null ? '\$${myCost.amountUsd}' : '—',
            delta: costDelta == null
                ? null
                : (costDelta < 0 ? '\$$costDelta' : '+\$$costDelta'),
            deltaTone: costDelta == null
                ? _Tone.neutral
                : costDelta < 0
                ? _Tone.good
                : _Tone.warn,
          ),
        ],
      ),
    );
  }

  static String? _formatDeltaLb(double? d) {
    if (d == null) return null;
    if (d.abs() < 0.05) return 'flat';
    return d < 0 ? d.toStringAsFixed(1) : '+${d.toStringAsFixed(1)}';
  }

  static double? _findMedian(List outcomes, String brand) {
    for (final o in outcomes) {
      if (o.drugBrand.toLowerCase() == brand.toLowerCase()) {
        return o.medianWeightLossPct;
      }
    }
    return null;
  }

  static double? _findCohortCost(List rows, String brand) {
    for (final r in rows) {
      if (r.drugBrand.toLowerCase() == brand.toLowerCase()) {
        return r.medianMonthlyCostUsd;
      }
    }
    return null;
  }
}

enum _Tone { good, warn, neutral }

class _Cell extends StatelessWidget {
  const _Cell({
    required this.label,
    required this.value,
    this.unit,
    this.delta,
    required this.deltaTone,
  });
  final String label;
  final String value;
  final String? unit;
  final String? delta;
  final _Tone deltaTone;

  @override
  Widget build(BuildContext context) {
    final deltaColor = switch (deltaTone) {
      _Tone.good => AppColors.success,
      _Tone.warn => AppColors.danger,
      _Tone.neutral => AppColors.muted,
    };
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkBlack,
                    height: 1,
                  ),
                ),
                if (unit != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1, left: 2),
                    child: Text(
                      unit!,
                      style: const TextStyle(
                        fontFamily: AppText.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
            if (delta != null) ...[
              const SizedBox(height: 2),
              Text(
                delta!,
                style: TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: deltaColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.borderSubtle);
}
