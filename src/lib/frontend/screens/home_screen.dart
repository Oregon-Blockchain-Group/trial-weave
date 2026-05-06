import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backend/providers/auth_state_provider.dart';
import '../../backend/repositories/auth_repository.dart';
import '../../core/theme.dart';

/// Stage 1 placeholder. Real adherence / next-dose / weight summary / cohort
/// teaser wiring lands in Stage 4.
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $email', style: AppText.displayLg),
              const SizedBox(height: 8),
              const Text(
                'You\'re signed in. Onboarding, home tiles, progress, and '
                'cohort screens land in subsequent stages.',
                style: AppText.bodyMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
