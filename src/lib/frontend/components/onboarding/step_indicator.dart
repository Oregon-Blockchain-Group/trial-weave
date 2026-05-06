import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// "Step N of 4" eyebrow plus four progress dots. Used at the top of every
/// onboarding screen.
class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.step, this.total = 4});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP $step OF $total', style: AppText.eyebrow),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 1; i <= total; i++) ...[
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= step
                        ? AppColors.darkTeal
                        : AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i != total) const SizedBox(width: 6),
            ],
          ],
        ),
      ],
    );
  }
}
