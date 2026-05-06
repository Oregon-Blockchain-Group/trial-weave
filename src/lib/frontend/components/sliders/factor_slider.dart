import 'package:flutter/material.dart';

import '../../../backend/models/factor.dart';
import '../../../core/theme.dart';

/// A 1-5 slider for a single [Factor], with low/high anchor labels and the
/// current value displayed prominently.
class FactorSlider extends StatelessWidget {
  const FactorSlider({
    super.key,
    required this.factor,
    required this.value,
    required this.onChanged,
  });

  final Factor factor;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(factor.label, style: AppText.title),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tealTint,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTeal,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: AppColors.darkTeal,
              inactiveTrackColor: AppColors.borderSubtle,
              thumbColor: AppColors.darkTeal,
              overlayColor: AppColors.darkTeal.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(factor.lowAnchor, style: AppText.caption),
              Text(factor.highAnchor, style: AppText.caption),
            ],
          ),
        ],
      ),
    );
  }
}
