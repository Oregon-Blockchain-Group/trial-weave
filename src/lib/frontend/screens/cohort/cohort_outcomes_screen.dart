import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/cohort_outcome.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import '../../components/cohort/filter_chips_bar.dart';

class CohortOutcomesScreen extends ConsumerWidget {
  const CohortOutcomesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outcomesAsync = ref.watch(filteredCohortOutcomesProvider);
    final regimenAsync = ref.watch(activeRegimenProvider);

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
            const FilterChipsBar(),
            const SizedBox(height: 16),
            const Text(
              'Median weight loss % by drug for the matched cohort. Higher '
              'is better.',
              style: AppText.bodyMuted,
            ),
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
                final maxPct = sorted.first.medianWeightLossPct;
                final yourBrand = regimenAsync.valueOrNull?.brand;
                return Column(
                  children: [
                    for (var i = 0; i < sorted.length; i++)
                      Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                        child: _OutcomeBar(
                          row: sorted[i],
                          maxPct: maxPct,
                          isYours:
                              yourBrand != null &&
                              sorted[i].drugBrand.toLowerCase() ==
                                  yourBrand.toLowerCase(),
                          isBest: i == 0,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OutcomeBar extends StatelessWidget {
  const _OutcomeBar({
    required this.row,
    required this.maxPct,
    required this.isYours,
    required this.isBest,
  });
  final CohortOutcome row;
  final double maxPct;
  final bool isYours;
  final bool isBest;

  @override
  Widget build(BuildContext context) {
    final width = (row.medianWeightLossPct / maxPct).clamp(0.0, 1.0);
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
              if (isBest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: const Text(
                    'Best in cohort',
                    style: TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
              if (isYours)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
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
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${row.medianWeightLossPct.toStringAsFixed(1)}%',
                style: AppText.displayMd,
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('median · n=${row.nUsers}', style: AppText.caption),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: width,
              minHeight: 8,
              backgroundColor: AppColors.borderSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(
                isYours ? AppColors.darkTeal : AppColors.skyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
      'No drugs cleared the 20-person privacy floor for this filter combo. '
      'Try loosening the filters.',
      style: AppText.bodyMuted,
      textAlign: TextAlign.center,
    ),
  );
}
