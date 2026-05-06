import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/factor.dart';
import '../../../backend/providers/onboarding_provider.dart';
import '../../../core/theme.dart';
import '../../components/onboarding/step_indicator.dart';
import '../../components/sliders/factor_slider.dart';

class BaselineScreen extends ConsumerStatefulWidget {
  const BaselineScreen({super.key});

  @override
  ConsumerState<BaselineScreen> createState() => _BaselineScreenState();
}

class _BaselineScreenState extends ConsumerState<BaselineScreen> {
  late Map<String, int> _ratings;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(onboardingProvider).baselineRatings;
    _ratings = {for (final f in kBaselineFactors) f.key: existing[f.key] ?? 3};
  }

  void _onContinue() {
    final notifier = ref.read(onboardingProvider.notifier);
    for (final entry in _ratings.entries) {
      notifier.setBaselineRating(entry.key, entry.value);
    }
    context.go('/onboarding/consent');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding/demographics'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepIndicator(step: 3),
              const SizedBox(height: 20),
              const Text('How are you doing now?', style: AppText.displayLg),
              const SizedBox(height: 6),
              const Text(
                'Rate each on a 1-5 scale. This is your baseline — every '
                'check-in compares back against it.',
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final f in kBaselineFactors) ...[
                        FactorSlider(
                          factor: f,
                          value: _ratings[f.key]!,
                          onChanged: (v) => setState(() => _ratings[f.key] = v),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _onContinue,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
