import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/regimen.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';

class RegimenScreen extends ConsumerWidget {
  const RegimenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allRegimensProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        title: const Text('Regimen', style: AppText.title),
      ),
      body: SafeArea(
        child: allAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$e', style: const TextStyle(color: AppColors.danger)),
          ),
          data: (all) {
            final active = all.where((r) => r.isActive).toList();
            final history = all.where((r) => !r.isActive).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                const Text('CURRENT', style: AppText.eyebrow),
                const SizedBox(height: 8),
                if (active.isEmpty)
                  _NoActiveCard(
                    onSwitch: () => context.go('/profile/regimen/switch'),
                  )
                else
                  _ActiveCard(
                    regimen: active.first,
                    onSwitch: () => context.go('/profile/regimen/switch'),
                    onStop: () => _confirmStop(context, ref, active.first),
                  ),
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const Text('HISTORY', style: AppText.eyebrow),
                  const SizedBox(height: 8),
                  for (final r in history) ...[
                    _HistoryRow(regimen: r),
                    const SizedBox(height: 8),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmStop(
    BuildContext context,
    WidgetRef ref,
    Regimen current,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Stop ${current.brand}?'),
        content: const Text(
          'Stopping marks your current regimen ended. Past dose, weight, '
          'and check-in logs stay; you just won\'t have an active drug '
          'until you start a new one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(regimensRepositoryProvider).endActive();
    ref.invalidate(activeRegimenProvider);
    ref.invalidate(allRegimensProvider);
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({
    required this.regimen,
    required this.onSwitch,
    required this.onStop,
  });
  final Regimen regimen;
  final VoidCallback onSwitch;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tealTint,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.darkTeal, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(regimen.brand, style: AppText.displayMd),
          const SizedBox(height: 4),
          Text(
            '${regimen.dose ?? ''} · ${regimen.frequency ?? ''} · '
            '${regimen.indication ?? ''}',
            style: AppText.bodyMuted,
          ),
          const SizedBox(height: 4),
          Text(
            'Started ${_fmtDate(regimen.startedAt)}',
            style: AppText.caption,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onSwitch,
                  child: const Text('Switch drug'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onStop,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger, width: 1.5),
                  ),
                  child: const Text('Stop drug'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoActiveCard extends StatelessWidget {
  const _NoActiveCard({required this.onSwitch});
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('No active regimen', style: AppText.title),
          const SizedBox(height: 4),
          const Text(
            'Start a new regimen to keep logging and comparing.',
            style: AppText.bodyMuted,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onSwitch,
            child: const Text('Start a regimen'),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.regimen});
  final Regimen regimen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(regimen.brand, style: AppText.title),
                const SizedBox(height: 2),
                Text(
                  '${regimen.dose ?? ''} · ${regimen.frequency ?? ''}',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          Text(
            '${_fmtDate(regimen.startedAt)} → '
            '${regimen.endedAt != null ? _fmtDate(regimen.endedAt!) : '—'}',
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
