import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Pill-style segmented control. Active tab gets a white card with shadow,
/// inactive tabs are flat and muted. Used by the home dashboard's
/// Today/Trends/Cohort selector.
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<SegmentedOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.borderSubtle,
        borderRadius: BorderRadius.circular(AppRadii.md + 2),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: _Pill(
                label: o.label,
                active: o.value == value,
                onTap: () => onChanged(o.value),
              ),
            ),
        ],
      ),
    );
  }
}

class SegmentedOption<T> {
  const SegmentedOption({required this.value, required this.label});
  final T value;
  final String label;
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppText.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.inkBlack : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
