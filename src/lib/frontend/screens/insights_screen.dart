import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backend/providers/repositories_providers.dart';
import '../../core/theme.dart';
import '../components/cohort/filter_chips_bar.dart';
import '../components/home/segmented_tabs.dart';
import '../components/insights/cohort_cost_card.dart';
import '../components/insights/outcomes_distribution_card.dart';
import '../components/insights/side_effects_severity_card.dart';
import '../components/insights/trajectory_chart.dart';
import '../components/nav/bottom_nav.dart';
import '../components/progress/baseline_shifts.dart';
import '../components/progress/side_effect_trends.dart';
import '../components/progress/weight_chart.dart';

enum _InsightsTab { you, cohort }

/// Insights tab — combines the old Progress (your data) and Cohort
/// (people-like-you data) into a single screen with a segmented control.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  _InsightsTab _tab = _InsightsTab.you;

  Future<void> _refreshAll() async {
    ref.invalidate(progressWeightLogsProvider);
    ref.invalidate(latestBaselineProvider);
    ref.invalidate(recentCheckInsProvider);
    ref.invalidate(recentSideEffectsProvider);
    ref.invalidate(filteredCohortWeightTrajectoryProvider);
    ref.invalidate(filteredCohortOutcomesDistributionProvider);
    ref.invalidate(filteredCohortSideEffectSeverityProvider);
    ref.invalidate(filteredCohortCostProvider);
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        title: const Text('Insights', style: AppText.title),
      ),
      bottomNavigationBar: const BottomNav(currentRoute: '/insights'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              SegmentedTabs<_InsightsTab>(
                value: _tab,
                options: const [
                  SegmentedOption(value: _InsightsTab.you, label: 'You'),
                  SegmentedOption(value: _InsightsTab.cohort, label: 'Cohort'),
                ],
                onChanged: (v) => setState(() => _tab = v),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(_tab),
                  child: switch (_tab) {
                    _InsightsTab.you => const _YouPane(),
                    _InsightsTab.cohort => const _CohortPane(),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YouPane extends ConsumerWidget {
  const _YouPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightsAsync = ref.watch(progressWeightLogsProvider);
    final baselineAsync = ref.watch(latestBaselineProvider);
    final checkInsAsync = ref.watch(recentCheckInsProvider);
    final sideEffectsAsync = ref.watch(recentSideEffectsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Weight'),
        const SizedBox(height: 8),
        weightsAsync.when(
          loading: () => const _LoadingBlock(),
          error: (e, _) => _ErrorBlock('$e'),
          data: (logs) => WeightChart(logs: logs),
        ),
        const SizedBox(height: 24),
        const _SectionHeader('Baseline shifts'),
        const SizedBox(height: 8),
        baselineAsync.when(
          loading: () => const _LoadingBlock(),
          error: (e, _) => _ErrorBlock('$e'),
          data: (baseline) => checkInsAsync.when(
            loading: () => const _LoadingBlock(),
            error: (e, _) => _ErrorBlock('$e'),
            data: (checkIns) =>
                BaselineShifts(baseline: baseline, recentCheckIns: checkIns),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionHeader('Side effects · last 90 days'),
        const SizedBox(height: 8),
        sideEffectsAsync.when(
          loading: () => const _LoadingBlock(),
          error: (e, _) => _ErrorBlock('$e'),
          data: (logs) => SideEffectTrends(logs: logs),
        ),
      ],
    );
  }
}

class _CohortPane extends ConsumerWidget {
  const _CohortPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filters', style: AppText.eyebrow),
        const SizedBox(height: 4),
        const Text(
          'Narrow the cohort to people like you. Privacy floor still applies — '
          'drugs with under 20 matched users are dropped.',
          style: AppText.bodyMuted,
        ),
        const SizedBox(height: 12),
        const FilterChipsBar(),
        const SizedBox(height: 24),
        const _SectionHeader('Your drug vs. alternatives'),
        const SizedBox(height: 4),
        const Text(
          'Median weight loss % over weeks since regimen start. Your line is '
          'overlaid in black.',
          style: AppText.caption,
        ),
        const SizedBox(height: 8),
        const TrajectoryChart(),
        const SizedBox(height: 24),
        const _SectionHeader('Outcomes distribution'),
        const SizedBox(height: 4),
        const Text(
          'Current median + IQR per drug, plus the share of users who hit '
          'each milestone at any point.',
          style: AppText.caption,
        ),
        const SizedBox(height: 8),
        const OutcomesDistributionCard(),
        const SizedBox(height: 24),
        const _SectionHeader('Side effects'),
        const SizedBox(height: 4),
        const Text(
          'Incidence and severity distribution for your drug. Bar color: '
          'green = mild, orange = moderate, red = severe.',
          style: AppText.caption,
        ),
        const SizedBox(height: 8),
        const SideEffectsSeverityCard(),
        const SizedBox(height: 24),
        const _SectionHeader('Cost'),
        const SizedBox(height: 4),
        const Text(
          'Median monthly out-of-pocket cost. Your this-month cost is shown '
          'at the top when logged.',
          style: AppText.caption,
        ),
        const SizedBox(height: 8),
        const CohortCostCard(),
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

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      border: Border.all(color: AppColors.border),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock(this.message);
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

