import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/cohort_outcome.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import 'home_card.dart';

class CohortTeaserTile extends ConsumerWidget {
  const CohortTeaserTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regimenAsync = ref.watch(activeRegimenProvider);
    final outcomesAsync = ref.watch(cohortOutcomesProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final weightsAsync = ref.watch(recentWeightLogsProvider);

    return HomeCard(
      onTap: () => context.go('/insights'),
      child: regimenAsync.when(
        loading: () => const _Loading(),
        error: (e, _) =>
            Text('$e', style: const TextStyle(color: AppColors.danger)),
        data: (regimen) => outcomesAsync.when(
          loading: () => const _Loading(),
          error: (e, _) =>
              Text('$e', style: const TextStyle(color: AppColors.danger)),
          data: (outcomes) {
            if (regimen == null) {
              return const _Empty(
                'Start a regimen to compare against a cohort.',
              );
            }
            final match = _findMatch(outcomes, regimen.brand);
            if (match == null) {
              return const _Empty(
                'Your cohort needs 20+ users before we can show outcomes here.',
              );
            }
            final yourLossPct =
                profileAsync.valueOrNull?.startingWeightLb != null &&
                    weightsAsync.valueOrNull?.isNotEmpty == true
                ? _yourLossPct(
                    profileAsync.value!.startingWeightLb!,
                    weightsAsync.value!.first.weightLb,
                  )
                : null;
            return _Body(
              brand: match.drugBrand,
              medianPct: match.medianWeightLossPct,
              nUsers: match.nUsers,
              yourPct: yourLossPct,
            );
          },
        ),
      ),
    );
  }

  static CohortOutcome? _findMatch(List<CohortOutcome> outcomes, String brand) {
    for (final o in outcomes) {
      if (o.drugBrand.toLowerCase() == brand.toLowerCase()) return o;
    }
    return null;
  }

  static double _yourLossPct(double starting, double current) {
    if (starting <= 0) return 0;
    return ((starting - current) / starting) * 100;
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.brand,
    required this.medianPct,
    required this.nUsers,
    required this.yourPct,
  });
  final String brand;
  final double medianPct;
  final int nUsers;
  final double? yourPct;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('YOUR COHORT', style: AppText.eyebrow),
        const SizedBox(height: 6),
        Text('$brand · n=$nUsers', style: AppText.bodyMuted),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Stat(
                label: 'Cohort median',
                value: '${medianPct.toStringAsFixed(1)}%',
              ),
            ),
            Container(
              width: 1,
              height: 32,
              color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            Expanded(
              child: _Stat(
                label: 'You',
                value: yourPct != null
                    ? '${yourPct!.toStringAsFixed(1)}%'
                    : '—',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppText.caption),
      const SizedBox(height: 2),
      Text(value, style: AppText.title),
    ],
  );
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 60,
    child: Center(child: CircularProgressIndicator()),
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('YOUR COHORT', style: AppText.eyebrow),
      const SizedBox(height: 6),
      Text(message, style: AppText.bodyMuted),
    ],
  );
}
