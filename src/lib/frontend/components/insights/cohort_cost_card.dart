import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/models/cohort_cost.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';

/// Median monthly out-of-pocket cost per drug brand, with your drug
/// highlighted and your current-month cost surfaced at the top.
class CohortCostCard extends ConsumerWidget {
  const CohortCostCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowsAsync = ref.watch(filteredCohortCostProvider);
    final yourBrand = ref.watch(activeRegimenProvider).valueOrNull?.brand;
    final myCost = ref.watch(currentMonthCostProvider).valueOrNull;

    return Column(
      children: [
        if (myCost != null)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.tealTint,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Your this month', style: AppText.eyebrow),
                ),
                Text('\$${myCost.amountUsd}', style: AppText.displayMd),
              ],
            ),
          ),
        rowsAsync.when(
          loading: () => const _Card(child: _Loading()),
          error: (e, _) => _Card(child: _Error('$e')),
          data: (rows) {
            if (rows.isEmpty) return const _Card(child: _Empty());
            final sorted = [...rows]..sort(
                (a, b) =>
                    a.medianMonthlyCostUsd.compareTo(b.medianMonthlyCostUsd),
              );
            final maxCost = sorted
                .map((r) => r.medianMonthlyCostUsd)
                .reduce((a, b) => a > b ? a : b);
            return Column(
              children: [
                for (var i = 0; i < sorted.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                    child: _CostRow(
                      row: sorted[i],
                      maxCost: maxCost,
                      isYours: yourBrand != null &&
                          sorted[i].drugBrand.toLowerCase() ==
                              yourBrand.toLowerCase(),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.row,
    required this.maxCost,
    required this.isYours,
  });
  final CohortCost row;
  final double maxCost;
  final bool isYours;

  @override
  Widget build(BuildContext context) {
    final width = (row.medianMonthlyCostUsd / maxCost).clamp(0.0, 1.0);
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
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${row.medianMonthlyCostUsd.toStringAsFixed(0)}',
                style: AppText.displayMd,
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  'median/month · n=${row.nUsers}',
                  style: AppText.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: width,
              minHeight: 6,
              backgroundColor: AppColors.borderSubtle,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.skyBlue),
            ),
          ),
        ],
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
    'No cost data for cohorts of 20+. Try loosening the filters.',
    style: AppText.bodyMuted,
    textAlign: TextAlign.center,
  );
}
