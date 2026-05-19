import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backend/providers/repositories_providers.dart';
import '../../core/theme.dart';
import '../components/home/cohort_pane.dart';
import '../components/home/dashboard_top.dart';
import '../components/home/metric_strip.dart';
import '../components/home/segmented_tabs.dart';
import '../components/home/today_pane.dart';
import '../components/home/trends_pane.dart';
import '../components/nav/bottom_nav.dart';

enum _DashTab { today, trends, cohort }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _DashTab _tab = _DashTab.today;

  Future<void> _refreshAll() async {
    ref.invalidate(activeRegimenProvider);
    ref.invalidate(currentProfileProvider);
    ref.invalidate(lastDoseProvider);
    ref.invalidate(recentDoseLogsProvider);
    ref.invalidate(recentWeightLogsProvider);
    ref.invalidate(progressWeightLogsProvider);
    ref.invalidate(recentSideEffectsProvider);
    ref.invalidate(latestBaselineProvider);
    ref.invalidate(recentCheckInsProvider);
    ref.invalidate(cohortOutcomesProvider);
    ref.invalidate(filteredCohortOutcomesProvider);
    ref.invalidate(filteredCohortCostProvider);
    ref.invalidate(currentMonthCostProvider);
    ref.invalidate(recentActivityProvider);
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshAll,
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 32),
                          child: DashboardTop(),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: MetricStrip(),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                      child: SegmentedTabs<_DashTab>(
                        value: _tab,
                        options: const [
                          SegmentedOption(
                            value: _DashTab.today,
                            label: 'Today',
                          ),
                          SegmentedOption(
                            value: _DashTab.trends,
                            label: 'Trends',
                          ),
                          SegmentedOption(
                            value: _DashTab.cohort,
                            label: 'Cohort',
                          ),
                        ],
                        onChanged: (v) => setState(() => _tab = v),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: KeyedSubtree(
                        key: ValueKey(_tab),
                        child: switch (_tab) {
                          _DashTab.today => const TodayPane(),
                          _DashTab.trends => const TrendsPane(),
                          _DashTab.cohort => const CohortPane(),
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const BottomNav(currentRoute: '/home'),
        ],
      ),
    );
  }
}
