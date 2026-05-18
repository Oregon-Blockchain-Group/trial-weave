import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import '../../components/cohort/matched_cohort_card.dart';
import '../../components/nav/bottom_nav.dart';

class CohortHomeScreen extends ConsumerWidget {
  const CohortHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outcomesAsync = ref.watch(filteredCohortOutcomesProvider);
    final sideEffectsAsync = ref.watch(filteredCohortSideEffectsProvider);
    final costAsync = ref.watch(filteredCohortCostProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        title: const Text('Cohort', style: AppText.title),
      ),
      bottomNavigationBar: const BottomNav(currentRoute: '/cohort'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const MatchedCohortCard(),
            const SizedBox(height: 24),
            const Text('EXPLORE', style: AppText.eyebrow),
            const SizedBox(height: 8),
            _DrillInCard(
              title: 'Outcomes',
              subtitle: outcomesAsync.when(
                loading: () => 'Loading…',
                error: (e, _) => 'Error',
                data: (rows) => rows.isEmpty
                    ? 'No drugs cleared the privacy floor for this filter.'
                    : '${rows.length} drug${rows.length == 1 ? '' : 's'} '
                          'with comparable cohorts',
              ),
              onTap: () => context.go('/cohort/outcomes'),
            ),
            const SizedBox(height: 10),
            _DrillInCard(
              title: 'Side effects',
              subtitle: sideEffectsAsync.when(
                loading: () => 'Loading…',
                error: (e, _) => 'Error',
                data: (rows) => rows.isEmpty
                    ? 'No side-effect data for this filter.'
                    : '${_distinctBrands(rows.map((r) => r.drugBrand))} drugs · '
                          '${_distinctEffects(rows.map((r) => r.sideEffect))} effects',
              ),
              onTap: () => context.go('/cohort/side-effects'),
            ),
            const SizedBox(height: 10),
            _DrillInCard(
              title: 'Cost',
              subtitle: costAsync.when(
                loading: () => 'Loading…',
                error: (e, _) => 'Error',
                data: (rows) => rows.isEmpty
                    ? 'No cost data for this filter.'
                    : '${rows.length} drug${rows.length == 1 ? '' : 's'} with '
                          'monthly cost data',
              ),
              onTap: () => context.go('/cohort/cost'),
            ),
          ],
        ),
      ),
    );
  }

  static int _distinctBrands(Iterable<String> brands) => brands.toSet().length;
  static int _distinctEffects(Iterable<String> effects) =>
      effects.toSet().length;
}

class _DrillInCard extends StatelessWidget {
  const _DrillInCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.title),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppText.bodyMuted),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
