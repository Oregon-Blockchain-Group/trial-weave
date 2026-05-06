import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../backend/providers/auth_state_provider.dart';
import '../../backend/repositories/auth_repository.dart';
import '../../core/theme.dart';

/// Stage 1 placeholder + Stage 3 quick-action tiles. Real adherence /
/// next-dose / weight summary / cohort teaser wiring lands in Stage 4.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final email = user?.email ?? 'there';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trial Weave'),
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.inkBlack,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Hello, $email', style: AppText.displayLg),
              const SizedBox(height: 4),
              const Text(
                'Quick actions — Stage 4 will replace these with adherence, '
                'next-dose, weight, and cohort tiles.',
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: 24),
              _ActionTile(
                icon: Icons.medical_services_outlined,
                label: 'Log a dose',
                onTap: () => context.go('/log/dose'),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.monitor_weight_outlined,
                label: 'Log weight',
                onTap: () => context.go('/log/weight'),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.checklist_outlined,
                label: 'Daily check-in',
                onTap: () => context.go('/check-in/post-dose'),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.healing_outlined,
                label: 'Side effects',
                onTap: () => context.go('/check-in/side-effect'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
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
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkTeal),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppText.title)),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
