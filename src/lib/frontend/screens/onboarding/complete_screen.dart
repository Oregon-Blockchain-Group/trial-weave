import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Material, MaterialType, Icons, IconData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../components/onboarding/onboarding_theme.dart';
import '../../components/onboarding/progress_bar.dart';

class _MatchFactor {
  const _MatchFactor({
    required this.icon,
    required this.label,
    required this.detail,
  });
  final IconData icon;
  final String label;
  final String detail;
}

const _matchFactors = <_MatchFactor>[
  _MatchFactor(
    icon: Icons.medication_outlined,
    label: 'Same medication & dose stage',
    detail: 'Semaglutide, weeks 0–8 of titration',
  ),
  _MatchFactor(
    icon: Icons.person_outline,
    label: 'Similar age & sex',
    detail: 'Female, 30–39',
  ),
  _MatchFactor(
    icon: Icons.monitor_weight_outlined,
    label: 'Comparable starting BMI',
    detail: 'BMI 28–32 at start of therapy',
  ),
  _MatchFactor(
    icon: Icons.favorite_border,
    label: 'Overlapping health history',
    detail: 'PCOS · no GI or pancreatitis history',
  ),
];

const _noteAmber = Color(0xFFB45309);

class CompleteScreen extends ConsumerWidget {
  const CompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Column(
            children: [
              const OnboardingProgressBar(step: 5, totalSteps: 5),
              Expanded(
                child: Container(
                  color: OnboardingColors.bgScroll,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _hero(),
                        const SizedBox(height: 16),
                        _cohortCard(),
                        const SizedBox(height: 16),
                        _previewCard(),
                      ],
                    ),
                  ),
                ),
              ),
              _GoBar(onPressed: () => context.go('/home')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero() => Column(
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: OnboardingColors.selectedBg,
        ),
        child: const Icon(
          Icons.check,
          size: 32,
          color: OnboardingColors.primary,
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        "You're all set!",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: OnboardingColors.ink,
        ),
      ),
      const SizedBox(height: 8),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: OnboardingColors.sub,
              height: 1.5,
            ),
            children: [
              TextSpan(text: 'We matched you to '),
              TextSpan(
                text: '1,247',
                style: TextStyle(
                  color: OnboardingColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text:
                    ' people on Trial Weave whose profile lines up with yours.',
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );

  Widget _cohortCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: CupertinoColors.white,
      border: Border.all(color: OnboardingColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOW WE BUILT YOUR COHORT',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: OnboardingColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'We grouped you with members who share the four factors that most shape GLP-1 outcomes. Stricter matches as you log more.',
          style: TextStyle(
            fontSize: 12,
            color: OnboardingColors.sub,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _matchFactors.length; i++) ...[
          _factorRow(_matchFactors[i]),
          if (i < _matchFactors.length - 1) const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
        Container(height: 1, color: OnboardingColors.border),
        const SizedBox(height: 12),
        const Text(
          "Race, ethnicity, and other demographics are stored privately and used only when you opt in to a sub-analysis — they don't drive your default cohort.",
          style: TextStyle(
            fontSize: 11,
            color: OnboardingColors.sub,
            height: 1.5,
          ),
        ),
      ],
    ),
  );

  Widget _factorRow(_MatchFactor f) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: OnboardingColors.selectedBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(f.icon, size: 18, color: OnboardingColors.primary),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              f.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: OnboardingColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              f.detail,
              style: const TextStyle(
                fontSize: 12,
                color: OnboardingColors.sub,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(top: 8, left: 8),
        child: Icon(Icons.check, size: 16, color: OnboardingColors.primary),
      ),
    ],
  );

  Widget _previewCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: OnboardingColors.selectedBg,
      border: Border.all(color: OnboardingColors.primary.withValues(alpha: 0.3)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR COHORT PREVIEW',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: OnboardingColors.primary,
          ),
        ),
        SizedBox(height: 6),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: OnboardingColors.ink,
              height: 1.5,
            ),
            children: [
              TextSpan(text: 'At '),
              TextSpan(
                text: '12 weeks',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text:
                    ', members matched to you reported a median weight change of ',
              ),
              TextSpan(
                text: '−11.8 lb',
                style: TextStyle(
                  color: OnboardingColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text:
                    ' (middle 80% range: −4 to −21 lb). Your own number replaces this once you start logging weight.',
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'ILLUSTRATIVE DEMO DATA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: _noteAmber,
          ),
        ),
      ],
    ),
  );
}

class _GoBar extends StatelessWidget {
  const _GoBar({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(top: BorderSide(color: OnboardingColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: OnboardingColors.primary,
          borderRadius: BorderRadius.circular(12),
          onPressed: onPressed,
          child: const Text(
            'Go to my dashboard',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
