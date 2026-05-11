import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Shared card chrome for every home tile. Tiles compose their own bodies
/// inside; this just enforces consistent padding, radius, and border so the
/// home grid reads as a single visual system.
class HomeCard extends StatelessWidget {
  const HomeCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
    if (onTap == null) return body;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: body,
    );
  }
}
