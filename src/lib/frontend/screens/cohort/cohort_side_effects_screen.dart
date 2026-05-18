import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/cohort_side_effect.dart';
import '../../../backend/models/side_effect.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import '../../components/cohort/matched_cohort_card.dart';

class CohortSideEffectsScreen extends ConsumerWidget {
  const CohortSideEffectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowsAsync = ref.watch(filteredCohortSideEffectsProvider);
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
        title: const Text('Side effects', style: AppText.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const MatchedCohortCard(),
            const SizedBox(height: 16),
            const Text(
              'Incidence = % of users in the cohort who reported each side '
              'effect at least once. Severity is intentionally not shown — '
              'self-rated severity isn\'t comparable across users.',
              style: AppText.bodyMuted,
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
                final yourBrand = regimenAsync.valueOrNull?.brand;
                final byBrand = _groupByBrand(rows);
                final brands = byBrand.keys.toList()..sort();
                return Column(
                  children: [
                    for (var i = 0; i < brands.length; i++)
                      Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                        child: _BrandCard(
                          brand: brands[i],
                          effects: byBrand[brands[i]]!,
                          isYours:
                              yourBrand != null &&
                              brands[i].toLowerCase() ==
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

  static Map<String, List<CohortSideEffect>> _groupByBrand(
    List<CohortSideEffect> rows,
  ) {
    final out = <String, List<CohortSideEffect>>{};
    for (final r in rows) {
      out.putIfAbsent(r.drugBrand, () => []).add(r);
    }
    for (final list in out.values) {
      list.sort((a, b) => b.incidencePct.compareTo(a.incidencePct));
    }
    return out;
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({
    required this.brand,
    required this.effects,
    required this.isYours,
  });
  final String brand;
  final List<CohortSideEffect> effects;
  final bool isYours;

  @override
  Widget build(BuildContext context) {
    final n = effects.first.nUsers;
    return Container(
      padding: const EdgeInsets.all(16),
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
              Text('n=$n', style: AppText.caption),
              if (isYours) ...[
                const SizedBox(width: 8),
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
            ],
          ),
          const SizedBox(height: 12),
          for (final e in effects) ...[
            _EffectRow(effect: e),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _EffectRow extends StatelessWidget {
  const _EffectRow({required this.effect});
  final CohortSideEffect effect;

  @override
  Widget build(BuildContext context) {
    final width = (effect.incidencePct / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(_label(effect.sideEffect), style: AppText.body),
            ),
            Text(
              '${effect.incidencePct.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.inkBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: LinearProgressIndicator(
            value: width,
            minHeight: 6,
            backgroundColor: AppColors.borderSubtle,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.skyBlue),
          ),
        ),
      ],
    );
  }

  static String _label(String key) {
    for (final se in kSideEffectCatalog) {
      if (se.key == key) return se.label;
    }
    return key;
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
      'No side-effect data for cohorts of 20+. Try loosening the filters.',
      style: AppText.bodyMuted,
      textAlign: TextAlign.center,
    ),
  );
}
