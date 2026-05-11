import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/cohort_outcome.dart';
import '../../../backend/models/dose_log.dart';
import '../../../backend/models/regimen.dart';
import '../../../backend/providers/auth_state_provider.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import '../charts/hero_ring.dart';

/// Gradient teal hero section that anchors the home dashboard. Composes:
///   - logo + Lokahi · GLP-1 small caps
///   - bell + avatar buttons
///   - "Day N · BRAND" eyebrow
///   - "Good morning, NAME" greeting
///   - "Day-of-week, date · Next dose in Hh Mm" subline
///   - Hero adherence card (white-translucent) with ring + counts +
///     streak pill
class DashboardTop extends ConsumerWidget {
  const DashboardTop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final regimen = ref.watch(activeRegimenProvider).valueOrNull;
    final lastDose = ref.watch(lastDoseProvider).valueOrNull;
    final recentDoses = ref.watch(recentDoseLogsProvider).valueOrNull ?? [];
    final outcomes = ref.watch(cohortOutcomesProvider).valueOrNull ?? [];

    final adherence = _computeAdherence(regimen, recentDoses);
    final stats = _computeStats(regimen, lastDose, outcomes);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.darkTeal, AppColors.mediumTeal],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopRow(),
              const SizedBox(height: 16),
              Text(
                stats.eyebrow,
                style: const TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Color(0xCCFFFFFF),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _greeting(user?.email),
                style: const TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stats.subline,
                style: const TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 12,
                  color: Color(0xD9FFFFFF),
                ),
              ),
              const SizedBox(height: 18),
              _HeroAdherenceCard(adherence: adherence),
            ],
          ),
        ),
      ),
    );
  }

  static String _greeting(String? email) {
    final h = DateTime.now().hour;
    final salutation = h < 12
        ? 'Good morning'
        : h < 17
        ? 'Good afternoon'
        : 'Good evening';
    final name = email == null ? 'there' : email.split('@').first;
    return '$salutation, $name';
  }

  static _AdherenceData _computeAdherence(
    Regimen? regimen,
    List<DoseLog> recent,
  ) {
    if (regimen == null) {
      return const _AdherenceData(value: 0, taken: 0, expected: 0);
    }
    final stride = regimen.frequency == 'weekly' ? 7 : 1;
    const window = 30;
    final daysSinceStart = DateTime.now()
        .difference(regimen.startedAt)
        .inDays
        .clamp(0, window);
    final expected = (daysSinceStart / stride).ceil().clamp(1, 999);
    final taken = recent.length;
    final value = (taken / expected).clamp(0.0, 1.0);
    return _AdherenceData(
      value: value.toDouble(),
      taken: taken,
      expected: expected,
    );
  }

  static _Stats _computeStats(
    Regimen? regimen,
    DoseLog? lastDose,
    List<CohortOutcome> outcomes,
  ) {
    if (regimen == null) {
      final now = DateTime.now();
      return _Stats(
        eyebrow: 'NO ACTIVE REGIMEN',
        subline: _formatWeekdayDate(now),
      );
    }
    final daysSince = DateTime.now().difference(regimen.startedAt).inDays;
    final eyebrow = 'DAY ${daysSince + 1} · ${regimen.brand.toUpperCase()}';

    final next = _nextDoseCountdown(regimen, lastDose);
    final subline = '${_formatWeekdayDate(DateTime.now())}$next';

    return _Stats(eyebrow: eyebrow, subline: subline);
  }

  static String _nextDoseCountdown(Regimen regimen, DoseLog? lastDose) {
    if (lastDose == null) return ' · log your first dose';
    final stride = regimen.frequency == 'weekly' ? 7 : 1;
    final due = lastDose.takenAt.add(Duration(days: stride));
    final now = DateTime.now();
    final diff = due.difference(now);
    if (diff.isNegative) return ' · dose overdue';
    if (diff.inDays >= 1) return ' · next dose in ${diff.inDays}d';
    if (diff.inHours >= 1) {
      final h = diff.inHours;
      final m = diff.inMinutes - h * 60;
      return ' · next dose in ${h}h ${m}m';
    }
    return ' · next dose in ${diff.inMinutes}m';
  }

  static String _formatWeekdayDate(DateTime d) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }
}

class _TopRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Trial Weave',
              style: TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'LŌKAHI · GLP-1',
              style: TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                color: Color(0xB3FFFFFF),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _IconBubble(icon: Icons.notifications_none, onTap: () {}),
            const SizedBox(width: 8),
            _IconBubble(
              icon: Icons.person_outline,
              onTap: () => GoRouter.of(context).go('/profile'),
            ),
          ],
        ),
      ],
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _HeroAdherenceCard extends StatelessWidget {
  const _HeroAdherenceCard({required this.adherence});
  final _AdherenceData adherence;

  @override
  Widget build(BuildContext context) {
    final pct = (adherence.value * 100).round();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          HeroRing(
            size: 64,
            value: adherence.value,
            trackColor: Colors.white.withValues(alpha: 0.2),
            progressColor: Colors.white,
            strokeWidth: 5,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$pct%',
                  style: const TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const Text(
                  'adhere',
                  style: TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xB3FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adherence.expected == 0
                      ? 'No doses scheduled yet'
                      : '${adherence.taken} of ${adherence.expected} doses on schedule',
                  style: const TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Last 30 days',
                  style: TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontSize: 11,
                    color: Color(0xD9FFFFFF),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 12,
                        color: Color(0xFFFFA94D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${adherence.taken}-dose streak',
                        style: const TextStyle(
                          fontFamily: AppText.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdherenceData {
  const _AdherenceData({
    required this.value,
    required this.taken,
    required this.expected,
  });
  final double value;
  final int taken;
  final int expected;
}

class _Stats {
  _Stats({required this.eyebrow, required this.subline});
  final String eyebrow;
  final String subline;
}
