import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/models/cohort_side_effect_severity.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';

/// Side-effect incidence + severity distribution table. Defaults to showing
/// your drug only (so the screen isn't dominated by other drugs' rows);
/// the [showAllDrugs] flag flips to all-drug view if needed later.
class SideEffectsSeverityCard extends ConsumerWidget {
  const SideEffectsSeverityCard({super.key, this.showAllDrugs = false});

  final bool showAllDrugs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowsAsync = ref.watch(filteredCohortSideEffectSeverityProvider);
    final yourBrand = ref.watch(activeRegimenProvider).valueOrNull?.brand;

    return rowsAsync.when(
      loading: () => const _Card(child: _Loading()),
      error: (e, _) => _Card(child: _Error('$e')),
      data: (rows) {
        var filtered = rows;
        if (!showAllDrugs && yourBrand != null) {
          filtered = rows
              .where(
                (r) => r.drugBrand.toLowerCase() == yourBrand.toLowerCase(),
              )
              .toList();
        }
        if (filtered.isEmpty) return const _Card(child: _Empty());

        // If we're in all-drugs mode, group visually by drug brand.
        if (showAllDrugs) {
          final byDrug = <String, List<CohortSideEffectSeverity>>{};
          for (final r in filtered) {
            (byDrug[r.drugBrand] ??= []).add(r);
          }
          return Column(
            children: [
              for (final brand in byDrug.keys.toList()..sort())
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DrugGroup(
                    brand: brand,
                    rows: byDrug[brand]!,
                    isYours: yourBrand != null &&
                        brand.toLowerCase() == yourBrand.toLowerCase(),
                  ),
                ),
            ],
          );
        }

        // Single drug — just the rows.
        return _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(yourBrand ?? 'Your drug', style: AppText.title),
              const SizedBox(height: 4),
              Text(
                'n=${filtered.first.nCohort} matched users',
                style: AppText.caption,
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < filtered.length; i++) ...[
                if (i > 0)
                  const Divider(height: 18, color: AppColors.borderSubtle),
                _EffectRow(row: filtered[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DrugGroup extends StatelessWidget {
  const _DrugGroup({
    required this.brand,
    required this.rows,
    required this.isYours,
  });
  final String brand;
  final List<CohortSideEffectSeverity> rows;
  final bool isYours;

  @override
  Widget build(BuildContext context) {
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
              Expanded(child: Text(brand, style: AppText.title)),
              Text('n=${rows.first.nCohort}', style: AppText.caption),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 16, color: AppColors.borderSubtle),
            _EffectRow(row: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _EffectRow extends StatelessWidget {
  const _EffectRow({required this.row});
  final CohortSideEffectSeverity row;

  @override
  Widget build(BuildContext context) {
    final total = row.countMild + row.countModerate + row.countSevere;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                row.sideEffect,
                style: AppText.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '${row.incidencePct.toStringAsFixed(0)}%',
              style: AppText.body.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Text(
              '(${row.usersReporting} of ${row.nCohort})',
              style: AppText.caption,
            ),
          ],
        ),
        const SizedBox(height: 6),
        _SeverityBar(
          mild: row.countMild,
          moderate: row.countModerate,
          severe: row.countSevere,
        ),
        if (total > 0) ...[
          const SizedBox(height: 4),
          Text(
            'avg severity ${row.meanSeverity.toStringAsFixed(1)}/5',
            style: AppText.caption,
          ),
        ],
      ],
    );
  }
}

class _SeverityBar extends StatelessWidget {
  const _SeverityBar({
    required this.mild,
    required this.moderate,
    required this.severe,
  });
  final int mild;
  final int moderate;
  final int severe;

  @override
  Widget build(BuildContext context) {
    final total = mild + moderate + severe;
    if (total == 0) {
      return Container(
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.borderSubtle,
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 6,
        child: Row(
          children: [
            Expanded(flex: mild, child: Container(color: AppColors.success)),
            Expanded(
              flex: moderate,
              child: Container(color: AppColors.warning),
            ),
            Expanded(flex: severe, child: Container(color: AppColors.danger)),
          ],
        ),
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
    'No side-effect data for this cohort yet.',
    style: AppText.bodyMuted,
    textAlign: TextAlign.center,
  );
}
