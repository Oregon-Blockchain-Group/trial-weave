import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../backend/providers/repositories_providers.dart';
import '../../backend/repositories/auth_repository.dart';
import '../../core/theme.dart';
import '../components/home/adherence_tile.dart';
import '../components/home/cohort_teaser_tile.dart';
import '../components/home/greeting_tile.dart';
import '../components/home/next_dose_tile.dart';
import '../components/home/weight_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trial Weave'),
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.inkBlack,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              // Profile screen ships in Stage 7. Sign out for now.
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(activeRegimenProvider);
            ref.invalidate(currentProfileProvider);
            ref.invalidate(lastDoseProvider);
            ref.invalidate(recentDoseLogsProvider);
            ref.invalidate(recentWeightLogsProvider);
            ref.invalidate(cohortOutcomesProvider);
            // Wait briefly so the indicator doesn't snap shut before the
            // FutureProviders kick off.
            await Future<void>.delayed(const Duration(milliseconds: 200));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              const GreetingTile(),
              const SizedBox(height: 20),
              const NextDoseTile(),
              const SizedBox(height: 12),
              const AdherenceTile(),
              const SizedBox(height: 12),
              const WeightTile(),
              const SizedBox(height: 12),
              const CohortTeaserTile(),
              const SizedBox(height: 28),
              const Text('QUICK ACTIONS', style: AppText.eyebrow),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickAction(
                    icon: Icons.checklist_outlined,
                    label: 'Daily check-in',
                    onTap: () => context.go('/check-in/post-dose'),
                  ),
                  _QuickAction(
                    icon: Icons.healing_outlined,
                    label: 'Side effects',
                    onTap: () => context.go('/check-in/side-effect'),
                  ),
                  _QuickAction(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Log weight',
                    onTap: () => context.go('/log/weight'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
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
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.darkTeal),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 13,
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
