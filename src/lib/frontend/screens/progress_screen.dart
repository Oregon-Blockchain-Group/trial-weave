import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backend/providers/repositories_providers.dart';
import '../../core/theme.dart';
import '../components/nav/bottom_nav.dart';
import '../components/progress/baseline_shifts.dart';
import '../components/progress/side_effect_trends.dart';
import '../components/progress/weight_chart.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightsAsync = ref.watch(progressWeightLogsProvider);
    final baselineAsync = ref.watch(latestBaselineProvider);
    final checkInsAsync = ref.watch(recentCheckInsProvider);
    final sideEffectsAsync = ref.watch(recentSideEffectsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        title: const Text('Progress', style: AppText.title),
      ),
      bottomNavigationBar: const BottomNav(currentRoute: '/progress'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(progressWeightLogsProvider);
            ref.invalidate(latestBaselineProvider);
            ref.invalidate(recentCheckInsProvider);
            ref.invalidate(recentSideEffectsProvider);
            await Future<void>.delayed(const Duration(milliseconds: 200));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
                  data: (checkIns) => BaselineShifts(
                    baseline: baseline,
                    recentCheckIns: checkIns,
                  ),
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
          ),
        ),
      ),
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
