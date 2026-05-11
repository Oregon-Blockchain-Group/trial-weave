import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Shown at app startup when `.env` is missing or required keys are blank.
/// Replaces the white-screen-of-death failure mode with copy-paste-able
/// instructions for getting the app running.
class MisconfiguredScreen extends StatelessWidget {
  const MisconfiguredScreen({super.key, required this.missingKeys});

  final List<String> missingKeys;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trial Weave — setup required',
      theme: buildAppTheme(),
      home: Scaffold(
        backgroundColor: AppColors.screenBg,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Setup required', style: AppText.displayLg),
                    const SizedBox(height: 8),
                    Text(
                      'Trial Weave can\'t start because the following config '
                      'values are missing from src/.env:',
                      style: AppText.bodyMuted,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final k in missingKeys)
                            Text(
                              '• $k',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                color: AppColors.warning,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Fix it', style: AppText.title),
                    const SizedBox(height: 8),
                    Text(
                      '1. From the repo root: cp src/.env.example src/.env\n'
                      '2. Open src/.env and paste your Supabase project URL '
                      'and anon key from your project\'s API settings.\n'
                      '3. Restart the app.',
                      style: AppText.body,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Both values are public by Supabase\'s design — RLS '
                      'policies protect data, not key obscurity.',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
