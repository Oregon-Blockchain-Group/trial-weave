import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/cohort_outcome.dart';
import '../../../backend/models/factor.dart';
import '../../../backend/models/factor_log.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import '../../components/cohort/matched_cohort_card.dart';

class CohortOutcomesScreen extends ConsumerWidget {
  const CohortOutcomesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outcomesAsync = ref.watch(filteredCohortOutcomesProvider);
    final regimenAsync = ref.watch(activeRegimenProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final weightsAsync = ref.watch(recentWeightLogsProvider);
    final baselineAsync = ref.watch(latestBaselineProvider);
    final checkInsAsync = ref.watch(recentCheckInsProvider);

    final yourBrand = regimenAsync.valueOrNull?.brand;
    final startingLb = profileAsync.valueOrNull?.startingWeightLb;
    final weights = weightsAsync.valueOrNull;
    final latestLb = (weights != null && weights.isNotEmpty)
        ? weights.first.weightLb
        : null;
    final yourLossPct = (startingLb != null && startingLb > 0 && latestLb != null)
        ? ((startingLb - latestLb) / startingLb) * 100
        : null;
    final yourLossLb = (startingLb != null && latestLb != null)
        ? startingLb - latestLb
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cohort'),
        ),
        title: const Text('Outcomes', style: AppText.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const MatchedCohortCard(),
            const SizedBox(height: 16),
            outcomesAsync.when(
              loading: () => const _Loading(),
              error: (e, _) => _ErrorBox('$e'),
              data: (rows) {
                if (rows.isEmpty) return const _EmptyBox();
                final sorted = [...rows]
                  ..sort(
                    (a, b) =>
                        b.medianWeightLossPct.compareTo(a.medianWeightLossPct),
                  );
                // Exact-match (case-insensitive) lookup of the user's drug
                // in the cohort results. Null when their drug didn't clear
                // the privacy floor for their demographic filters.
                CohortOutcome? yourRow;
                for (final r in sorted) {
                  if (yourBrand != null &&
                      r.drugBrand.toLowerCase() == yourBrand.toLowerCase()) {
                    yourRow = r;
                    break;
                  }
                }
                final topRow = sorted.first;
                final yourIsTop =
                    yourRow != null && yourRow.drugBrand == topRow.drugBrand;
                final startedAt = regimenAsync.valueOrNull?.startedAt;
                final weeksOnTherapy = startedAt == null
                    ? null
                    : (DateTime.now().difference(startedAt).inDays / 7)
                        .floor();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroCard(
                      yourBrand: yourBrand,
                      yourRow: yourRow,
                      yourLossPct: yourLossPct,
                      yourLossLb: yourLossLb,
                    ),
                    const SizedBox(height: 16),
                    _DrugComparisonCard(
                      rows: sorted,
                      yourBrand: yourBrand,
                      yourIsTop: yourIsTop,
                    ),
                    if (yourRow != null) ...[
                      const SizedBox(height: 16),
                      _YourMetricsCard(
                        drugBrand: yourRow.drugBrand,
                        yourLossLb: yourLossLb,
                        weeksOnTherapy: weeksOnTherapy,
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('YOUR CHANGES', style: AppText.eyebrow),
            const SizedBox(height: 4),
            const Text(
              'Where you started vs. your most recent check-in.',
              style: AppText.bodyMuted,
            ),
            const SizedBox(height: 12),
            _BaselineShifts(
              baselineAsync: baselineAsync,
              checkInsAsync: checkInsAsync,
            ),
          ],
        ),
      ),
    );
  }
}

/// Top-of-page hero anchored on the user's actual drug. Three states:
///   1. No active regimen → soft prompt to onboard.
///   2. Has regimen, drug in cohort results → the canonical hero.
///   3. Has regimen, drug NOT in cohort results → "didn't clear floor" copy
///      so the user understands the page is showing other drugs instead.
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.yourBrand,
    required this.yourRow,
    required this.yourLossPct,
    required this.yourLossLb,
  });
  final String? yourBrand;
  final CohortOutcome? yourRow;
  final double? yourLossPct;
  final double? yourLossLb;

  @override
  Widget build(BuildContext context) {
    if (yourBrand == null) {
      return _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('FOR PEOPLE LIKE YOU', style: AppText.eyebrow),
            SizedBox(height: 6),
            Text(
              'Start a regimen to see how you compare to others like you.',
              style: AppText.bodyMuted,
            ),
          ],
        ),
      );
    }
    if (yourRow == null) {
      return _Card(
        accent: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FOR PEOPLE LIKE YOU', style: AppText.eyebrow),
            const SizedBox(height: 8),
            Text(
              'There aren\'t yet enough people like you on $yourBrand to show '
              'comparable stats while protecting privacy.',
              style: AppText.title,
            ),
            const SizedBox(height: 8),
            const Text(
              'Below: drugs that other people in your demographic cohort are '
              'using. Useful for seeing how your drug stacks up against the '
              'alternatives.',
              style: AppText.bodyMuted,
            ),
          ],
        ),
      );
    }
    final percentile = _estimatePercentile(yourLossPct, yourRow!.medianWeightLossPct);
    final youText = yourLossPct == null
        ? '—'
        : '${yourLossPct!.toStringAsFixed(1)}%'
            '${yourLossLb != null ? ' · ${yourLossLb!.toStringAsFixed(1)} lb' : ''}';
    return _Card(
      accent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FOR PEOPLE LIKE YOU', style: AppText.eyebrow),
          const SizedBox(height: 8),
          Text(
            'On ${yourRow!.drugBrand}, your cohort\'s median weight change is '
            '${yourRow!.medianWeightLossPct.toStringAsFixed(1)}%.',
            style: AppText.title,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('YOU', style: AppText.eyebrow),
                    const SizedBox(height: 2),
                    Text(youText, style: AppText.displayMd),
                  ],
                ),
              ),
              if (percentile != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkTeal,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    '~${percentile}th percentile',
                    style: const TextStyle(
                      fontFamily: AppText.fontFamily,
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (yourLossPct == null) ...[
            const SizedBox(height: 8),
            const Text(
              'Log a weight to see where you fall in this cohort.',
              style: AppText.bodyMuted,
            ),
          ],
        ],
      ),
    );
  }
}

/// Comparison rows of the user's metrics vs. the cohort median.
/// Companion personal metrics that the hero doesn't already show — lb
/// lost (the hero highlights the % only) and weeks on therapy.
class _YourMetricsCard extends StatelessWidget {
  const _YourMetricsCard({
    required this.drugBrand,
    required this.yourLossLb,
    required this.weeksOnTherapy,
  });
  final String drugBrand;
  final double? yourLossLb;
  final int? weeksOnTherapy;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YOUR PROGRESS', style: AppText.eyebrow),
          const SizedBox(height: 4),
          Text(drugBrand, style: AppText.bodyMuted),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Pounds lost',
                  value: yourLossLb == null
                      ? '—'
                      : '${yourLossLb!.toStringAsFixed(1)} lb',
                ),
              ),
              Expanded(
                child: _MetricTile(
                  label: 'Weeks on therapy',
                  value: weeksOnTherapy == null
                      ? '—'
                      : '$weeksOnTherapy',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppText.eyebrow),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppText.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.inkBlack,
          ),
        ),
      ],
    );
  }
}

/// Horizontal-bar comparison of every drug in the user's demographic
/// cohort. Top performer gets the dark accent; user's drug is outlined.
class _DrugComparisonCard extends StatelessWidget {
  const _DrugComparisonCard({
    required this.rows,
    required this.yourBrand,
    required this.yourIsTop,
  });
  final List<CohortOutcome> rows;
  final String? yourBrand;
  final bool yourIsTop;

  @override
  Widget build(BuildContext context) {
    final max = rows.first.medianWeightLossPct;
    final top = rows.first;
    String insight;
    if (yourBrand == null) {
      insight =
          '${top.drugBrand} had the largest median weight change in your '
          'demographic cohort.';
    } else if (yourIsTop) {
      insight =
          'You\'re on the best-performing drug in your cohort by median '
          'weight change.';
    } else {
      insight =
          '${top.drugBrand} had the largest median weight change in your '
          'cohort. Worth discussing with your prescriber whether it\'s a fit '
          'for you.';
    }
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HOW DRUGS COMPARE', style: AppText.eyebrow),
          const SizedBox(height: 4),
          const Text(
            'Median weight change in your demographic cohort.',
            style: AppText.bodyMuted,
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            _DrugBar(
              row: rows[i],
              max: max,
              isYours: yourBrand != null &&
                  rows[i].drugBrand.toLowerCase() == yourBrand!.toLowerCase(),
              isTop: i == 0,
            ),
            if (i < rows.length - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.tealTint,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.darkTeal),
            ),
            child: Text(
              insight,
              style: const TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 12,
                color: AppColors.inkBlack,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Informational only. Your prescriber decides what\'s right for you.',
            style: TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 11,
              color: AppColors.muted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrugBar extends StatelessWidget {
  const _DrugBar({
    required this.row,
    required this.max,
    required this.isYours,
    required this.isTop,
  });
  final CohortOutcome row;
  final double max;
  final bool isYours;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    final fill = max == 0 ? 0.0 : (row.medianWeightLossPct / max).clamp(0.0, 1.0);
    final barColor = isTop ? AppColors.darkTeal : AppColors.muted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(row.drugBrand, style: AppText.body),
                  if (isYours) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkTeal,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'YOU',
                        style: TextStyle(
                          fontFamily: AppText.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${row.medianWeightLossPct.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.inkBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Stack(
            children: [
              Container(height: 8, color: AppColors.borderSubtle),
              FractionallySizedBox(
                widthFactor: fill,
                child: Container(height: 8, color: barColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BaselineShifts extends StatelessWidget {
  const _BaselineShifts({
    required this.baselineAsync,
    required this.checkInsAsync,
  });
  final AsyncValue<Map<String, int>> baselineAsync;
  final AsyncValue<List<FactorLog>> checkInsAsync;

  @override
  Widget build(BuildContext context) {
    return baselineAsync.when(
      loading: () => const _Loading(),
      error: (e, _) => _ErrorBox('$e'),
      data: (baseline) => checkInsAsync.when(
        loading: () => const _Loading(),
        error: (e, _) => _ErrorBox('$e'),
        data: (checkIns) {
          final latestByKey = <String, FactorLog>{};
          for (final log in checkIns) {
            final existing = latestByKey[log.factorKey];
            if (existing == null || log.loggedAt.isAfter(existing.loggedAt)) {
              latestByKey[log.factorKey] = log;
            }
          }
          final rows = <_FactorRow>[];
          for (final f in kFactorCatalog) {
            if (f.isGlp1Specific) continue;
            final start = baseline[f.key];
            final now = latestByKey[f.key]?.rating;
            if (start == null && now == null) continue;
            rows.add(_FactorRow(factor: f, baseline: start, current: now));
          }
          if (rows.isEmpty) {
            return _Card(
              child: const Text(
                'No baseline or check-ins yet. Log a check-in to see your '
                'shifts here.',
                style: AppText.bodyMuted,
                textAlign: TextAlign.center,
              ),
            );
          }
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [for (final r in rows) _FactorTile(row: r)],
          );
        },
      ),
    );
  }
}

class _FactorRow {
  const _FactorRow({
    required this.factor,
    required this.baseline,
    required this.current,
  });
  final Factor factor;
  final int? baseline;
  final int? current;
}

class _FactorTile extends StatelessWidget {
  const _FactorTile({required this.row});
  final _FactorRow row;

  @override
  Widget build(BuildContext context) {
    final base = row.baseline;
    final cur = row.current;
    final improved = (base != null && cur != null)
        ? cur > base
        : null;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(row.factor.label.toUpperCase(), style: AppText.eyebrow),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${base ?? '–'}',
                style: const TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 14,
                  color: AppColors.muted,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.arrow_forward,
                  size: 12,
                  color: AppColors.muted,
                ),
              ),
              Text(
                '${cur ?? '–'}',
                style: const TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkBlack,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              if (improved != null)
                Icon(
                  improved ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: improved ? AppColors.success : AppColors.danger,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.accent = false});
  final Widget child;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent ? AppColors.tealTint : AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: accent ? AppColors.darkTeal : AppColors.border,
        ),
      ),
      child: child,
    );
  }
}

/// Rough percentile from a single median value. Assumes cohort std ≈
/// 30% of the median's absolute value; clamps to 5-95.
int? _estimatePercentile(double? you, double median) {
  if (you == null) return null;
  final std = (median.abs() * 0.3).clamp(1.0, 30.0);
  final z = (you - median) / std;
  final pct = 50 + (z * 25);
  return pct.clamp(5, 95).round();
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: CircularProgressIndicator(),
    ),
  );
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.dangerBg,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      border: Border.all(color: AppColors.danger),
    ),
    child: Text(
      message,
      style: const TextStyle(color: AppColors.danger, fontSize: 13),
    ),
  );
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      border: Border.all(color: AppColors.border),
    ),
    child: const Text(
      'No drugs cleared the 20-person privacy floor for this demographic '
      'cohort. Try widening filters via your profile.',
      style: AppText.bodyMuted,
      textAlign: TextAlign.center,
    ),
  );
}
