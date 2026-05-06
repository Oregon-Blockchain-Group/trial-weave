import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/auth_state_provider.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../backend/repositories/auth_repository.dart';
import '../../../core/theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final regimenAsync = ref.watch(activeRegimenProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Profile', style: AppText.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.tealTint,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.email ?? 'signed in', style: AppText.title),
                  const SizedBox(height: 4),
                  regimenAsync.when(
                    loading: () => const Text(
                      'Loading regimen…',
                      style: AppText.bodyMuted,
                    ),
                    error: (e, _) => Text(
                      '$e',
                      style: const TextStyle(color: AppColors.danger),
                    ),
                    data: (r) => Text(
                      r != null
                          ? '${r.brand} ${r.dose ?? ''} · ${r.frequency ?? ''}'
                          : 'No active regimen.',
                      style: AppText.bodyMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('SETTINGS', style: AppText.eyebrow),
            const SizedBox(height: 8),
            _Row(
              icon: Icons.person_outline,
              label: 'Edit profile',
              subtitle: 'Demographics + starting weight',
              onTap: () => context.go('/profile/edit'),
            ),
            const SizedBox(height: 10),
            _Row(
              icon: Icons.medical_services_outlined,
              label: 'Regimen',
              subtitle: 'Switch drugs or stop your current one',
              onTap: () => context.go('/profile/regimen'),
            ),
            const SizedBox(height: 10),
            _Row(
              icon: Icons.lock_outline,
              label: 'Data & privacy',
              subtitle: 'Export your data or delete your account',
              onTap: () => context.go('/profile/data-privacy'),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/welcome');
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkTeal),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.title),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
