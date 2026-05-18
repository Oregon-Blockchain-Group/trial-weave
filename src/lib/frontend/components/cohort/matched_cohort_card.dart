import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/cohort_filters_provider.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';

/// Read-only summary of the dimensions used to match the User's cohort
/// (sex, age band, indication, GLP-1 history, drug brand, supply) plus the
/// total people across drugs that cleared the privacy floor. The "Change
/// these" button routes to the edit-profile screen — the canonical place
/// to alter any of these dimensions.
class MatchedCohortCard extends ConsumerWidget {
  const MatchedCohortCard({super.key});

  static const _sexLabels = {
    'female': 'Female',
    'male': 'Male',
    'intersex': 'Intersex',
    'other': 'Other sex',
    'prefer_not_to_say': 'Sex: n/a',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(cohortFiltersProvider);
    final outcomesAsync = ref.watch(filteredCohortOutcomesProvider);

    final pills = <String>[
      if (filters.ageMin != null && filters.ageMax != null)
        'Age ${filters.ageMin}–${filters.ageMax}'
      else
        'Any age',
      _sexLabels[filters.sex] ?? 'Any sex',
      filters.raceEthnicity ?? 'Any race / ethnicity',
    ];

    final nLabel = outcomesAsync.when(
      loading: () => '…',
      error: (_, _) => '—',
      data: (rows) {
        final total = rows.fold<int>(0, (sum, r) => sum + r.nUsers);
        return '$total people';
      },
    );

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
          Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 16, color: AppColors.darkTeal),
              const SizedBox(width: 6),
              const Text('YOUR MATCHED COHORT', style: AppText.eyebrow),
              const Spacer(),
              Text(
                nLabel,
                style: const TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 12,
                  color: AppColors.muted,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final p in pills) _CohortPill(label: p)],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.go('/profile/edit'),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit my demographics'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.darkTeal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CohortPill extends StatelessWidget {
  const _CohortPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tealTint,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.darkTeal),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppText.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTeal,
        ),
      ),
    );
  }
}
