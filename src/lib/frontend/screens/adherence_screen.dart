import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backend/models/cohort_adherence.dart';
import '../../backend/models/dose_log.dart';
import '../../backend/models/regimen.dart';
import '../../backend/providers/repositories_providers.dart';
import '../../core/theme.dart';
import '../components/home/segmented_tabs.dart';
import '../components/nav/bottom_nav.dart';

enum _Window {
  w8(8, '8 weeks'),
  w12(12, '12 weeks'),
  w26(26, '26 weeks');

  const _Window(this.weeks, this.label);
  final int weeks;
  final String label;
}

/// Adherence tab — how reliably the User has hit their dose schedule.
/// Window-scoped headline %, current streak, weekly timeline, and a
/// comparison against the cohort median for the same drug.
class AdherenceScreen extends ConsumerStatefulWidget {
  const AdherenceScreen({super.key});

  @override
  ConsumerState<AdherenceScreen> createState() => _AdherenceScreenState();
}

class _AdherenceScreenState extends ConsumerState<AdherenceScreen> {
  _Window _window = _Window.w12;

  Future<void> _refresh() async {
    ref.invalidate(activeRegimenProvider);
    ref.invalidate(activeRegimenDoseLogsProvider);
    ref.invalidate(filteredCohortAdherenceProvider);
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    final regimenAsync = ref.watch(activeRegimenProvider);
    final dosesAsync = ref.watch(activeRegimenDoseLogsProvider);
    final cohortAsync = ref.watch(filteredCohortAdherenceProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        title: const Text('Adherence', style: AppText.title),
      ),
      bottomNavigationBar: const BottomNav(currentRoute: '/adherence'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: regimenAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                '$e',
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
            data: (regimen) {
              if (regimen == null) {
                return const _NoRegimen();
              }
              final cadence = _cadenceDaysFor(regimen.form);
              if (cadence == null) {
                return _UnknownCadence(form: regimen.form);
              }
              return dosesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    '$e',
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
                data: (doses) {
                  final stats = _computeStats(
                    regimen: regimen,
                    doses: doses,
                    cadenceDays: cadence,
                    windowWeeks: _window.weeks,
                  );
                  final cohort = cohortAsync.valueOrNull ?? const [];
                  final myCohortRow = _findCohortRow(cohort, regimen.brand);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      SegmentedTabs<_Window>(
                        value: _window,
                        options: const [
                          SegmentedOption(value: _Window.w8, label: '8w'),
                          SegmentedOption(value: _Window.w12, label: '12w'),
                          SegmentedOption(value: _Window.w26, label: '26w'),
                        ],
                        onChanged: (v) => setState(() => _window = v),
                      ),
                      const SizedBox(height: 16),
                      _HeadlineCard(stats: stats, window: _window),
                      const SizedBox(height: 12),
                      _StreakCard(streakWeeks: stats.streakWeeks),
                      const SizedBox(height: 12),
                      const _SectionHeader('Weekly timeline'),
                      const SizedBox(height: 8),
                      _TimelineCard(
                        buckets: stats.weeklyBuckets,
                      ),
                      const SizedBox(height: 16),
                      const _SectionHeader('You vs. cohort'),
                      const SizedBox(height: 8),
                      _CohortComparisonCard(
                        yourPct: stats.adherencePct,
                        cohortRow: myCohortRow,
                        drugBrand: regimen.brand,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static int? _cadenceDaysFor(String? form) {
    switch (form) {
      case 'injection':
        return 7;
      case 'pill':
        return 1;
      default:
        return null;
    }
  }

  static CohortAdherence? _findCohortRow(
    List<CohortAdherence> rows,
    String brand,
  ) {
    for (final r in rows) {
      if (r.drugBrand.toLowerCase() == brand.toLowerCase()) return r;
    }
    return null;
  }
}

// ── Stats computation ───────────────────────────────────────────────────

class _AdherenceStats {
  const _AdherenceStats({
    required this.adherencePct,
    required this.taken,
    required this.expected,
    required this.streakWeeks,
    required this.weeklyBuckets,
  });
  final double adherencePct;
  final int taken;
  final int expected;
  final int streakWeeks;
  final List<_WeeklyBucket> weeklyBuckets; // chronological, oldest first
}

class _WeeklyBucket {
  const _WeeklyBucket({
    required this.weekIndex,
    required this.taken,
    required this.expected,
  });
  final int weekIndex;
  final int taken;
  final int expected;

  _Tier get tier {
    if (expected == 0) return _Tier.upcoming;
    if (taken >= expected) return _Tier.onTrack;
    if (taken == 0) return _Tier.missed;
    return _Tier.partial;
  }
}

enum _Tier { onTrack, partial, missed, upcoming }

_AdherenceStats _computeStats({
  required Regimen regimen,
  required List<DoseLog> doses,
  required int cadenceDays,
  required int windowWeeks,
}) {
  final now = DateTime.now();
  final windowStart = now.subtract(Duration(days: windowWeeks * 7));
  // Anchor weekly buckets to whichever is later: regimen start or window start.
  final start = regimen.startedAt.isAfter(windowStart)
      ? regimen.startedAt
      : windowStart;
  final dosesPerWeek = (7 / cadenceDays).round().clamp(1, 7);

  final buckets = <_WeeklyBucket>[];
  for (var i = 0; i < windowWeeks; i++) {
    final bucketStart = start.add(Duration(days: i * 7));
    final bucketEnd = bucketStart.add(const Duration(days: 7));
    if (bucketStart.isAfter(now)) break;

    final taken = doses
        .where(
          (d) =>
              !d.takenAt.isBefore(bucketStart) && d.takenAt.isBefore(bucketEnd),
        )
        .length;

    // Expected for this bucket: prorated if the bucket runs past `now`.
    final daysCovered = bucketEnd.isAfter(now)
        ? now.difference(bucketStart).inDays.clamp(0, 7)
        : 7;
    final expected = ((daysCovered / cadenceDays).floor()).clamp(0, dosesPerWeek);

    buckets.add(
      _WeeklyBucket(weekIndex: i, taken: taken, expected: expected),
    );
  }

  final totalTaken = buckets.fold<int>(0, (s, b) => s + b.taken);
  final totalExpected = buckets.fold<int>(0, (s, b) => s + b.expected);
  final adherencePct = totalExpected == 0
      ? 0.0
      : (totalTaken / totalExpected).clamp(0.0, 1.0) * 100.0;

  // Streak: consecutive on-track weeks ending at the most recent completed
  // week (skip the currently-in-progress week so a fresh week doesn't
  // immediately break the streak).
  var streak = 0;
  final completed = buckets
      .where((b) => b.expected >= (dosesPerWeek))
      .toList();
  for (var i = completed.length - 1; i >= 0; i--) {
    if (completed[i].tier == _Tier.onTrack) {
      streak++;
    } else {
      break;
    }
  }

  return _AdherenceStats(
    adherencePct: adherencePct,
    taken: totalTaken,
    expected: totalExpected,
    streakWeeks: streak,
    weeklyBuckets: buckets,
  );
}

// ── Cards ───────────────────────────────────────────────────────────────

class _HeadlineCard extends StatelessWidget {
  const _HeadlineCard({required this.stats, required this.window});
  final _AdherenceStats stats;
  final _Window window;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tealTint,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.darkTeal, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR ADHERENCE · ${window.label.toUpperCase()}',
              style: AppText.eyebrow),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stats.adherencePct.toStringAsFixed(0)}%',
                style: AppText.displayLg.copyWith(fontSize: 40, height: 1),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${stats.taken} of ${stats.expected} doses',
                  style: AppText.bodyMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streakWeeks});
  final int streakWeeks;

  @override
  Widget build(BuildContext context) {
    final hasStreak = streakWeeks >= 1;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: hasStreak ? AppColors.warningBg : AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(
              Icons.local_fire_department,
              color: hasStreak ? AppColors.warning : AppColors.muted,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasStreak
                      ? '$streakWeeks-week streak'
                      : 'No active streak',
                  style:
                      AppText.body.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  hasStreak
                      ? 'Consecutive on-track weeks'
                      : 'A perfect week kicks off a streak',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.buckets});
  final List<_WeeklyBucket> buckets;

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
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final b in buckets)
                _Cell(tier: b.tier, label: 'w${b.weekIndex + 1}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              _LegendDot(color: AppColors.success, label: 'On track'),
              SizedBox(width: 12),
              _LegendDot(color: AppColors.warning, label: 'Partial'),
              SizedBox(width: 12),
              _LegendDot(color: AppColors.danger, label: 'Missed'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.tier, required this.label});
  final _Tier tier;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (tier) {
      _Tier.onTrack => AppColors.success,
      _Tier.partial => AppColors.warning,
      _Tier.missed => AppColors.danger,
      _Tier.upcoming => AppColors.borderSubtle,
    };
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: tier == _Tier.upcoming ? 1.0 : 0.18),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppText.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: tier == _Tier.upcoming ? AppColors.muted : color,
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppText.caption),
      ],
    );
  }
}

class _CohortComparisonCard extends StatelessWidget {
  const _CohortComparisonCard({
    required this.yourPct,
    required this.cohortRow,
    required this.drugBrand,
  });
  final double yourPct;
  final CohortAdherence? cohortRow;
  final String drugBrand;

  @override
  Widget build(BuildContext context) {
    if (cohortRow == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          '$drugBrand cohort hasn\'t cleared the 20-person privacy floor for '
          'the current filters yet.',
          style: AppText.bodyMuted,
        ),
      );
    }
    final row = cohortRow!;
    final delta = yourPct - row.medianAdherencePct;
    final ahead = delta >= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'You',
                  value: '${yourPct.toStringAsFixed(0)}%',
                  bold: true,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: '$drugBrand median',
                  value: '${row.medianAdherencePct.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ahead ? AppColors.successBg : AppColors.warningBg,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              ahead
                  ? '+${delta.toStringAsFixed(0)} points above cohort median'
                  : '${delta.toStringAsFixed(0)} points below cohort median',
              style: TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ahead ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cohort IQR: ${row.p25AdherencePct.toStringAsFixed(0)}–'
            '${row.p75AdherencePct.toStringAsFixed(0)}% · n=${row.nUsers}',
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppText.eyebrow),
        const SizedBox(height: 2),
        Text(
          value,
          style: bold
              ? AppText.displayMd
              : AppText.displayMd.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;
  @override
  Widget build(BuildContext context) =>
      Text(label.toUpperCase(), style: AppText.eyebrow);
}

class _NoRegimen extends StatelessWidget {
  const _NoRegimen();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('No active regimen', style: AppText.title),
            SizedBox(height: 8),
            Text(
              'Adherence only makes sense once you have a regimen with a '
              'dose schedule. Add one in the You tab to get started.',
              style: AppText.bodyMuted,
            ),
          ],
        ),
      ),
    ],
  );
}

class _UnknownCadence extends StatelessWidget {
  const _UnknownCadence({required this.form});
  final String? form;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Unknown dose cadence', style: AppText.title),
            const SizedBox(height: 8),
            Text(
              'Adherence is computed assuming injection = weekly or pill = '
              'daily. Your regimen has form "${form ?? '—'}", which doesn\'t '
              'fit either. Update the regimen in the You tab to enable '
              'adherence tracking.',
              style: AppText.bodyMuted,
            ),
          ],
        ),
      ),
    ],
  );
}
