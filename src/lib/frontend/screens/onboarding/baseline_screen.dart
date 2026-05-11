import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/factor.dart';
import '../../../backend/providers/onboarding_provider.dart';
import '../../components/onboarding/continue_bar.dart';
import '../../components/onboarding/onboarding_theme.dart';
import '../../components/onboarding/progress_bar.dart';

class BaselineScreen extends ConsumerStatefulWidget {
  const BaselineScreen({super.key});

  @override
  ConsumerState<BaselineScreen> createState() => _BaselineScreenState();
}

class _BaselineScreenState extends ConsumerState<BaselineScreen> {
  late Map<String, int?> _ratings;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(onboardingProvider).baselineRatings;
    _ratings = {for (final f in kBaselineFactors) f.key: existing[f.key]};
  }

  bool get _canContinue =>
      kBaselineFactors.every((f) => _ratings[f.key] != null);

  void _onContinue() {
    final notifier = ref.read(onboardingProvider.notifier);
    for (final f in kBaselineFactors) {
      notifier.setBaselineRating(f.key, _ratings[f.key]!);
    }
    context.go('/onboarding/consent');
  }

  void _onBack() => context.go('/onboarding/medication');

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Column(
            children: [
              OnboardingProgressBar(step: 3, totalSteps: 5, onBack: _onBack),
              const _Header(),
              Expanded(
                child: Container(
                  color: OnboardingColors.bgScroll,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < kBaselineFactors.length; i++) ...[
                          _factorRow(kBaselineFactors[i]),
                          if (i < kBaselineFactors.length - 1)
                            const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              OnboardingContinueBar(
                enabled: _canContinue,
                onPressed: _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _factorRow(Factor factor) {
    final selected = _ratings[factor.key];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            factor.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: OnboardingColors.ink,
            ),
          ),
        ),
        Row(
          children: [
            for (var n = 1; n <= 5; n++) ...[
              Expanded(child: _ratingButton(factor.key, n, selected == n)),
              if (n < 5) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                factor.lowAnchor,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: OnboardingColors.primary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                factor.highAnchor,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: OnboardingColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ratingButton(String key, int n, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _ratings[key] = n),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? OnboardingColors.primary : CupertinoColors.white,
          border: Border.all(
            color: selected ? OnboardingColors.primary : OnboardingColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$n',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: selected ? CupertinoColors.white : OnboardingColors.ink,
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set your baselines',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: OnboardingColors.ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Rate each factor 1–5 so we can track how things change over time.',
            style: TextStyle(
              fontSize: 14,
              color: OnboardingColors.sub,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
