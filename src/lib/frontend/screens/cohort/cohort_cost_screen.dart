import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/cohort_cost.dart';
import '../../../backend/models/cost_log.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import '../../components/cohort/filter_chips_bar.dart';

class CohortCostScreen extends ConsumerWidget {
  const CohortCostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowsAsync = ref.watch(filteredCohortCostProvider);
    final regimenAsync = ref.watch(activeRegimenProvider);
    final myCostAsync = ref.watch(currentMonthCostProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cohort'),
        ),
        title: const Text('Cost', style: AppText.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const FilterChipsBar(),
            const SizedBox(height: 16),
            const Text(
              'Median monthly out-of-pocket cost by drug for the matched '
              'cohort. Lower is better.',
              style: AppText.bodyMuted,
            ),
            const SizedBox(height: 16),
            _MyCostCard(
              myCostAsync: myCostAsync,
              onEdit: () => _showEditDialog(context, ref),
            ),
            const SizedBox(height: 16),
            rowsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => _ErrorBox('$e'),
              data: (rows) {
                if (rows.isEmpty) return const _EmptyBox();
                final sorted = [...rows]
                  ..sort(
                    (a, b) => a.medianMonthlyCostUsd.compareTo(
                      b.medianMonthlyCostUsd,
                    ),
                  );
                final maxCost = sorted
                    .map((r) => r.medianMonthlyCostUsd)
                    .reduce((a, b) => a > b ? a : b);
                final yourBrand = regimenAsync.valueOrNull?.brand;
                return Column(
                  children: [
                    for (var i = 0; i < sorted.length; i++)
                      Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                        child: _CostRow(
                          row: sorted[i],
                          maxCost: maxCost,
                          isYours:
                              yourBrand != null &&
                              sorted[i].drugBrand.toLowerCase() ==
                                  yourBrand.toLowerCase(),
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

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final amount = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('This month\'s cost'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: '\$ ',
            hintText: 'e.g., 1099',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final n = int.tryParse(controller.text.trim());
              if (n != null && n >= 0) Navigator.of(ctx).pop(n);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (amount == null) return;
    await ref
        .read(costLogsRepositoryProvider)
        .upsertForMonth(month: DateTime.now(), amountUsd: amount);
    ref.invalidate(currentMonthCostProvider);
    ref.invalidate(filteredCohortCostProvider);
  }
}

class _MyCostCard extends StatelessWidget {
  const _MyCostCard({required this.myCostAsync, required this.onEdit});
  final AsyncValue<CostLog?> myCostAsync;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tealTint,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('YOUR THIS MONTH', style: AppText.eyebrow),
                const SizedBox(height: 4),
                myCostAsync.when(
                  loading: () => const Text('—', style: AppText.displayMd),
                  error: (e, _) => Text(
                    '$e',
                    style: const TextStyle(color: AppColors.danger),
                  ),
                  data: (c) => Text(
                    c == null ? 'Not entered' : '\$${c.amountUsd}',
                    style: AppText.displayMd,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Edit')),
        ],
      ),
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
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.skyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
      'No cost data for cohorts of 20+. Try loosening the filters.',
      style: AppText.bodyMuted,
      textAlign: TextAlign.center,
    ),
  );
}
