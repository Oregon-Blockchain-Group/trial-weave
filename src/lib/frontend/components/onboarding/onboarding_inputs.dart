import 'package:flutter/cupertino.dart';

import 'onboarding_theme.dart';

/// Labelled section used to group form fields on onboarding screens. The
/// label sits above the child; `trailing` typically shows an "Optional" or
/// "Select all that apply" hint on the right.
class OnboardingSection extends StatelessWidget {
  const OnboardingSection({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
  });

  final String label;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: OnboardingColors.ink,
                    height: 1.4,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
        child,
      ],
    );
  }
}

/// Single-line text field styled to match the onboarding design.
class OnboardingTextField extends StatelessWidget {
  const OnboardingTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.onChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final TextInputType keyboardType;
  final String? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border.all(color: OnboardingColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              placeholderStyle: const TextStyle(
                fontSize: 14,
                color: OnboardingColors.placeholder,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: OnboardingColors.ink,
              ),
              keyboardType: keyboardType,
              decoration: null,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: onChanged,
            ),
          ),
          if (suffix != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                suffix!,
                style: const TextStyle(
                  fontSize: 14,
                  color: OnboardingColors.sub,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Rectangular selectable tile used in 2-column grids (e.g. gender).
class OnboardingSelectableTile extends StatelessWidget {
  const OnboardingSelectableTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.height = 48,
  });

  final bool selected;
  final double height;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? OnboardingColors.selectedBg
              : CupertinoColors.white,
          border: Border.all(
            color: selected ? OnboardingColors.primary : OnboardingColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

/// Pill-shaped chip for multi-select lists (race/ethnicity, comorbidities).
class OnboardingChipTile extends StatelessWidget {
  const OnboardingChipTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? OnboardingColors.selectedBg
              : CupertinoColors.white,
          border: Border.all(
            color: selected ? OnboardingColors.primary : OnboardingColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? OnboardingColors.primary : OnboardingColors.ink,
          ),
        ),
      ),
    );
  }
}

/// Lays out [children] in a 2-column grid with consistent spacing.
class OnboardingGrid2 extends StatelessWidget {
  const OnboardingGrid2({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      final left = children[i];
      final right =
          i + 1 < children.length ? children[i + 1] : const SizedBox();
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < children.length ? 8 : 0),
          child: Row(
            children: [
              Expanded(child: left),
              const SizedBox(width: 8),
              Expanded(child: right),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}
