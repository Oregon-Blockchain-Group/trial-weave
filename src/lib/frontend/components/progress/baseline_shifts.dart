import 'package:flutter/material.dart';

import '../../../backend/models/factor.dart';
import '../../../backend/models/factor_log.dart';
import '../../../core/theme.dart';

/// For each baseline factor, shows the user's baseline rating, the average
/// of their recent check-ins (last 30 days), and the delta with directional
/// styling.
class BaselineShifts extends StatelessWidget {
  const BaselineShifts({
    super.key,
    required this.baseline,
    required this.recentCheckIns,
  });

  final Map<String, int> baseline;
  final List<FactorLog> recentCheckIns;

  @override
  Widget build(BuildContext context) {
    if (baseline.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'No baseline captured yet — finish onboarding to start tracking shifts.',
          style: AppText.bodyMuted,
          textAlign: TextAlign.center,
        ),
      );
    }

    final averages = _averageByFactor(recentCheckIns);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < kBaselineFactors.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.borderSubtle),
            _Row(
              factor: kBaselineFactors[i],
              baseline: baseline[kBaselineFactors[i].key],
              recentAvg: averages[kBaselineFactors[i].key],
            ),
          ],
        ],
      ),
    );
  }

  static Map<String, double> _averageByFactor(List<FactorLog> logs) {
    final sums = <String, double>{};
    final counts = <String, int>{};
    for (final l in logs) {
      sums[l.factorKey] = (sums[l.factorKey] ?? 0) + l.rating;
      counts[l.factorKey] = (counts[l.factorKey] ?? 0) + 1;
    }
    return {for (final key in sums.keys) key: sums[key]! / counts[key]!};
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.factor,
    required this.baseline,
    required this.recentAvg,
  });

  final Factor factor;
  final int? baseline;
  final double? recentAvg;

  @override
  Widget build(BuildContext context) {
    final delta = (baseline != null && recentAvg != null)
        ? (recentAvg! - baseline!)
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(factor.label, style: AppText.body)),
          _Stat(label: 'Baseline', value: baseline?.toString() ?? '—'),
          const SizedBox(width: 12),
          _Stat(
            label: '30-day avg',
            value: recentAvg != null ? recentAvg!.toStringAsFixed(1) : '—',
          ),
          const SizedBox(width: 12),
          SizedBox(width: 60, child: _DeltaChip(delta: delta)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(label, style: AppText.caption),
      Text(
        value,
        style: const TextStyle(
          fontFamily: AppText.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.inkBlack,
        ),
      ),
    ],
  );
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta});
  final double? delta;

  @override
  Widget build(BuildContext context) {
    if (delta == null) {
      return const _ChipBox(
        text: '—',
        bg: AppColors.borderSubtle,
        fg: AppColors.muted,
        icon: null,
      );
    }
    final d = delta!;
    if (d.abs() < 0.1) {
      return const _ChipBox(
        text: 'flat',
        bg: AppColors.borderSubtle,
        fg: AppColors.muted,
        icon: Icons.remove,
      );
    }
    if (d > 0) {
      return _ChipBox(
        text: '+${d.toStringAsFixed(1)}',
        bg: AppColors.successBg,
        fg: AppColors.success,
        icon: Icons.arrow_upward,
      );
    }
    return _ChipBox(
      text: d.toStringAsFixed(1),
      bg: AppColors.dangerBg,
      fg: AppColors.danger,
      icon: Icons.arrow_downward,
    );
  }
}

class _ChipBox extends StatelessWidget {
  const _ChipBox({
    required this.text,
    required this.bg,
    required this.fg,
    required this.icon,
  });
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 2),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
