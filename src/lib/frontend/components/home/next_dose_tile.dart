import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import 'home_card.dart';

class NextDoseTile extends ConsumerWidget {
  const NextDoseTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regimenAsync = ref.watch(activeRegimenProvider);
    final lastDoseAsync = ref.watch(lastDoseProvider);

    return HomeCard(
      onTap: () => context.go('/log/dose'),
      child: regimenAsync.when(
        loading: () => const _LoadingBody(),
        error: (e, _) => _ErrorBody('$e'),
        data: (regimen) {
          if (regimen == null) {
            return _Empty(
              title: 'No active regimen',
              body: 'Start one from Profile → Regimen.',
            );
          }
          return lastDoseAsync.when(
            loading: () => const _LoadingBody(),
            error: (e, _) => _ErrorBody('$e'),
            data: (last) {
              if (last == null) {
                return _Body(
                  eyebrow: 'NEXT DOSE',
                  headline: 'Log your first dose',
                  sub: '${regimen.brand} ${regimen.dose ?? ''}',
                  cta: 'Log it',
                );
              }
              final stride = regimen.frequency == 'weekly' ? 7 : 1;
              final due = last.takenAt.add(Duration(days: stride));
              final now = DateTime.now();
              final daysOut = _daysBetween(now, due);
              final headline = _headlineFor(daysOut);
              return _Body(
                eyebrow: 'NEXT DOSE',
                headline: headline,
                sub:
                    '${regimen.brand} ${regimen.dose ?? ''} · '
                    '${regimen.frequency ?? ''}',
                cta: daysOut <= 0 ? 'Log it now' : 'Log a dose',
              );
            },
          );
        },
      ),
    );
  }

  /// Calendar-day diff (today = 0, tomorrow = 1, yesterday = -1). Ignores
  /// time-of-day so "tomorrow at 8am" and "tomorrow at 11pm" both read as
  /// "Tomorrow."
  static int _daysBetween(DateTime now, DateTime then) {
    final a = DateTime(now.year, now.month, now.day);
    final b = DateTime(then.year, then.month, then.day);
    return b.difference(a).inDays;
  }

  static String _headlineFor(int daysOut) {
    if (daysOut < 0) {
      return 'Overdue by ${-daysOut} day${-daysOut == 1 ? '' : 's'}';
    }
    if (daysOut == 0) return 'Today';
    if (daysOut == 1) return 'Tomorrow';
    return 'In $daysOut days';
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.eyebrow,
    required this.headline,
    required this.sub,
    required this.cta,
  });
  final String eyebrow;
  final String headline;
  final String sub;
  final String cta;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow, style: AppText.eyebrow),
              const SizedBox(height: 6),
              Text(headline, style: AppText.displayMd),
              const SizedBox(height: 4),
              Text(sub, style: AppText.bodyMuted),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.darkTeal,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            cta,
            style: const TextStyle(
              fontFamily: AppText.fontFamily,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 60,
    child: Center(child: CircularProgressIndicator()),
  );
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody(this.message);
  final String message;
  @override
  Widget build(BuildContext context) =>
      Text(message, style: const TextStyle(color: AppColors.danger));
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('NEXT DOSE', style: AppText.eyebrow),
      const SizedBox(height: 6),
      Text(title, style: AppText.displayMd),
      const SizedBox(height: 4),
      Text(body, style: AppText.bodyMuted),
    ],
  );
}
