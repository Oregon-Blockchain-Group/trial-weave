import 'package:flutter/cupertino.dart';

import 'onboarding_theme.dart';

/// Bottom-anchored primary button used at the end of every onboarding
/// screen. Disabled (greyed) state mirrors the wireframe.
class OnboardingContinueBar extends StatelessWidget {
  const OnboardingContinueBar({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.label = 'Continue',
  });

  final bool enabled;
  final String label;
  final VoidCallback? onPressed;

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
          disabledColor: OnboardingColors.primary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          onPressed: enabled ? onPressed : null,
          child: Text(
            label,
            style: const TextStyle(
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
