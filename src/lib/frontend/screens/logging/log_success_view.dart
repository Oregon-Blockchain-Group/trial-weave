import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class LogSuccessView extends StatelessWidget {
  const LogSuccessView({
    super.key,
    this.eyebrow = 'Logged',
    required this.title,
  });

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.screenBg,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.tealTint,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.darkTeal, width: 2),
            ),
            child: const Icon(
              Icons.check,
              size: 28,
              color: AppColors.darkTeal,
              weight: 700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            eyebrow.toUpperCase(),
            style: AppText.eyebrow.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppText.title,
          ),
        ],
      ),
    );
  }
}
