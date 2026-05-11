import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import 'onboarding_theme.dart';

/// Top-of-screen progress indicator for the onboarding flow: a back chevron,
/// a row of dashes filled up to [step], and an "N of M" label.
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.step,
    required this.totalSteps,
    this.onBack,
  });

  final int step;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: OnboardingColors.ink,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: List.generate(totalSteps, (i) {
                final filled = i < step;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 4),
                    decoration: BoxDecoration(
                      color: filled
                          ? OnboardingColors.primary
                          : OnboardingColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              '$step of $totalSteps',
              style: const TextStyle(
                fontSize: 12,
                color: OnboardingColors.sub,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
