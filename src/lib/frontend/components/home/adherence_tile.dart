import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import 'home_card.dart';

class AdherenceTile extends ConsumerWidget {
  const AdherenceTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regimenAsync = ref.watch(activeRegimenProvider);
    final dosesAsync = ref.watch(recentDoseLogsProvider);

    return HomeCard(
      child: regimenAsync.when(
        loading: () => const _Loading(),
        error: (e, _) =>
            Text('$e', style: const TextStyle(color: AppColors.danger)),
        data: (regimen) {
          if (regimen == null) return const _Empty('No active regimen');
          return dosesAsync.when(
            loading: () => const _Loading(),
            error: (e, _) =>
                Text('$e', style: const TextStyle(color: AppColors.danger)),
            data: (doses) {
              final stride = regimen.frequency == 'weekly' ? 7 : 1;
              const window = 30;
              final daysSinceStart = DateTime.now()
                  .difference(regimen.startedAt)
                  .inDays
                  .clamp(0, window);
              if (daysSinceStart < 1) {
                return const _Empty('Adherence builds after your first day');
              }
              final expected = (daysSinceStart / stride).ceil().clamp(1, 999);
              final actual = doses.length;
              final pct = ((actual / expected) * 100).clamp(0, 100).round();
              return _Body(pct: pct, actual: actual, expected: expected);
            },
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.pct,
    required this.actual,
    required this.expected,
  });
  final int pct;
  final int actual;
  final int expected;

  @override
  Widget build(BuildContext context) {
    final color = pct >= 80
        ? AppColors.success
        : pct >= 50
        ? AppColors.warning
        : AppColors.danger;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ADHERENCE · LAST 30 DAYS', style: AppText.eyebrow),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$pct%', style: AppText.displayLg.copyWith(color: color)),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '$actual of $expected doses',
                style: AppText.bodyMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 6,
            backgroundColor: AppColors.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
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
      const Text('ADHERENCE · LAST 30 DAYS', style: AppText.eyebrow),
      const SizedBox(height: 6),
      Text(message, style: AppText.bodyMuted),
    ],
  );
}
