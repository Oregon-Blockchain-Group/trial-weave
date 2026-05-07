import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/activity_entry.dart';
import '../../../backend/models/dose_log.dart';
import '../../../backend/models/regimen.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';

class TodayPane extends ConsumerWidget {
  const TodayPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _DoseCard(),
          SizedBox(height: 12),
          _RegimenRow(),
          SizedBox(height: 12),
          _QuickLogGrid(),
          SizedBox(height: 12),
          _ActivityCard(),
        ],
      ),
    );
  }
}

class _DoseCard extends ConsumerStatefulWidget {
  const _DoseCard();

  @override
  ConsumerState<_DoseCard> createState() => _DoseCardState();
}

/// Three real states + a transient "just logged" flash:
///   - none:         no last dose ever → enabled, "Log your first dose"
///   - dueOrOverdue: enough time has passed since last dose → enabled
///   - logged:       last dose was within the current dose period →
///                   disabled, shows "Last dose Xh ago · next in Y"
///   - justLogged:   logged in the last 5 minutes → green flash
enum _DoseState { none, dueOrOverdue, logged, justLogged }

class _DoseCardState extends ConsumerState<_DoseCard> {
  bool _busy = false;

  Future<void> _logNow() async {
    final regimen = await ref.read(activeRegimenProvider.future);
    if (regimen == null) {
      if (mounted) context.go('/profile/regimen/switch');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(doseLogsRepositoryProvider).log(regimenId: regimen.id);
      ref.invalidate(lastDoseProvider);
      ref.invalidate(recentDoseLogsProvider);
      ref.invalidate(recentActivityProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final regimen = ref.watch(activeRegimenProvider).valueOrNull;
    final lastDose = ref.watch(lastDoseProvider).valueOrNull;
    final state = _classify(regimen, lastDose);
    final isLocked =
        _busy || state == _DoseState.logged || state == _DoseState.justLogged;

    final isJust = state == _DoseState.justLogged;
    final isLogged = state == _DoseState.logged;

    final bg = isJust
        ? AppColors.successBg
        : isLogged
        ? AppColors.borderSubtle
        : AppColors.darkTeal;
    final fg = isJust
        ? AppColors.success
        : isLogged
        ? AppColors.muted
        : Colors.white;

    final headline = switch (state) {
      _DoseState.justLogged => 'Logged just now',
      _DoseState.logged =>
        regimen != null ? '${regimen.brand} ${regimen.dose ?? ''}' : 'Logged',
      _DoseState.dueOrOverdue =>
        regimen != null
            ? '${regimen.brand} ${regimen.dose ?? ''}'
            : 'Tap to log',
      _DoseState.none =>
        regimen != null ? 'Log your first dose' : 'No active regimen',
    };

    final subline = switch (state) {
      _DoseState.justLogged =>
        'Next dose in ${_humanDuration(_nextDue(regimen, lastDose).difference(DateTime.now()))}',
      _DoseState.logged =>
        'Last dose ${_ago(lastDose!.takenAt)} · next in ${_humanDuration(_nextDue(regimen, lastDose).difference(DateTime.now()))}',
      _DoseState.dueOrOverdue => 'Due now · tap to log',
      _DoseState.none =>
        regimen != null
            ? '${_capitalize(regimen.frequency)} dose · tap to log'
            : 'Start a regimen to track doses',
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked ? null : _logNow,
        borderRadius: BorderRadius.circular(AppRadii.lg + 2),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadii.lg + 2),
            border: isJust
                ? Border.all(color: AppColors.success, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isJust
                      ? AppColors.success
                      : isLogged
                      ? AppColors.cardBg
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  isJust
                      ? Icons.check
                      : isLogged
                      ? Icons.check_circle_outline
                      : Icons.medical_services,
                  color: isJust
                      ? Colors.white
                      : isLogged
                      ? AppColors.muted
                      : Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: TextStyle(
                        fontFamily: AppText.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subline,
                      style: TextStyle(
                        fontFamily: AppText.fontFamily,
                        fontSize: 12,
                        color: fg.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              if (_busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else if (state == _DoseState.dueOrOverdue ||
                  state == _DoseState.none)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: const Text(
                    '1 tap',
                    style: TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static _DoseState _classify(Regimen? regimen, DoseLog? lastDose) {
    if (regimen == null || lastDose == null) return _DoseState.none;
    final stride = regimen.frequency == 'weekly' ? 7 : 1;
    final due = lastDose.takenAt.add(Duration(days: stride));
    final now = DateTime.now();
    if (!now.isBefore(due)) return _DoseState.dueOrOverdue;
    if (now.difference(lastDose.takenAt) < const Duration(minutes: 5)) {
      return _DoseState.justLogged;
    }
    return _DoseState.logged;
  }

  static DateTime _nextDue(Regimen? regimen, DoseLog? lastDose) {
    final stride = regimen?.frequency == 'weekly' ? 7 : 1;
    return (lastDose?.takenAt ?? DateTime.now()).add(Duration(days: stride));
  }

  static String _ago(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  static String _humanDuration(Duration d) {
    if (d.isNegative) return 'overdue';
    if (d.inDays >= 1) {
      return d.inDays == 1 ? '1 day' : '${d.inDays} days';
    }
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes - h * 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${d.inMinutes}m';
  }

  static String _capitalize(String? s) {
    if (s == null || s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _RegimenRow extends ConsumerWidget {
  const _RegimenRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regimen = ref.watch(activeRegimenProvider).valueOrNull;
    if (regimen == null) return const SizedBox.shrink();
    final daysSince = DateTime.now().difference(regimen.startedAt).inDays + 1;

    return InkWell(
      onTap: () => context.go('/profile/regimen'),
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.tealTint,
                borderRadius: BorderRadius.circular(AppRadii.md + 2),
              ),
              child: const Icon(
                Icons.medication_outlined,
                color: AppColors.darkTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current regimen',
                    style: TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${regimen.brand} ${regimen.dose ?? ''} · '
                    '${regimen.generic ?? ''} · day $daysSince',
                    style: const TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tealTint,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                _capitalize(regimen.frequency),
                style: const TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTeal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalize(String? s) {
    if (s == null || s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _QuickLogGrid extends StatelessWidget {
  const _QuickLogGrid();

  @override
  Widget build(BuildContext context) {
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
          const Text('QUICK LOG', style: AppText.eyebrow),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _QuickButton(
                  icon: Icons.healing_outlined,
                  label: 'Side fx',
                  onTap: () => context.go('/check-in/side-effect'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _QuickButton(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  onTap: () => context.go('/log/weight'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _QuickButton(
                  icon: Icons.checklist_outlined,
                  label: 'Check-in',
                  onTap: () => context.go('/check-in/post-dose'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _QuickButton(
                  icon: Icons.swap_horiz,
                  label: 'Switch',
                  onTap: () => context.go('/profile/regimen/switch'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.darkTeal),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.inkBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends ConsumerWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(recentActivityProvider);
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
          const Text('RECENT ACTIVITY', style: AppText.eyebrow),
          const SizedBox(height: 4),
          const Text(
            'Last 14 days',
            style: TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.inkBlack,
            ),
          ),
          const SizedBox(height: 8),
          entriesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                Text('$e', style: const TextStyle(color: AppColors.danger)),
            data: (entries) => entries.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Nothing logged yet — start with a dose or weight.',
                      style: AppText.bodyMuted,
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < entries.length; i++)
                        _TimelineRow(
                          entry: entries[i],
                          isFirst: i == 0,
                          isLast: i == entries.length - 1,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });
  final ActivityEntry entry;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color iconColor;
    final Color iconBg;
    switch (entry.kind) {
      case ActivityKind.dose:
        icon = Icons.medical_services;
        iconColor = AppColors.darkTeal;
        iconBg = AppColors.tealTint;
        break;
      case ActivityKind.weight:
        icon = Icons.monitor_weight;
        iconColor = AppColors.success;
        iconBg = AppColors.successBg;
        break;
      case ActivityKind.sideEffect:
        icon = Icons.error_outline;
        iconColor = AppColors.warning;
        iconBg = AppColors.warningBg;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 38,
            child: Text(
              _ago(entry.at),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 10,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 12, color: iconColor),
              ),
              if (!isLast)
                Expanded(child: Container(width: 1, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 0, bottom: isLast ? 0 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkBlack,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    entry.subtitle,
                    style: const TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _ago(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'now';
  }
}
