import 'package:flutter/material.dart';

import '../../../backend/models/side_effect.dart';
import '../../../backend/models/side_effect_log.dart';
import '../../../core/theme.dart';

/// Aggregates side-effect logs in the last 90 days into one row per side
/// effect, showing total count and average severity. Sorted by count desc.
class SideEffectTrends extends StatelessWidget {
  const SideEffectTrends({super.key, required this.logs});

  final List<SideEffectLog> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'No side effects logged in the last 90 days. Nice.',
          style: AppText.bodyMuted,
          textAlign: TextAlign.center,
        ),
      );
    }

    final summaries = _summarize(logs);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < summaries.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.borderSubtle),
            _Row(summary: summaries[i]),
          ],
        ],
      ),
    );
  }

  static List<_Summary> _summarize(List<SideEffectLog> logs) {
    final counts = <String, int>{};
    final severitySums = <String, int>{};
    for (final l in logs) {
      counts[l.name] = (counts[l.name] ?? 0) + 1;
      severitySums[l.name] = (severitySums[l.name] ?? 0) + l.severity;
    }
    final out = <_Summary>[
      for (final name in counts.keys)
        _Summary(
          key: name,
          label: _labelFor(name),
          count: counts[name]!,
          avgSeverity: severitySums[name]! / counts[name]!,
        ),
    ];
    out.sort((a, b) => b.count.compareTo(a.count));
    return out;
  }

  static String _labelFor(String key) {
    for (final se in kSideEffectCatalog) {
      if (se.key == key) return se.label;
    }
    return key;
  }
}

class _Summary {
  _Summary({
    required this.key,
    required this.label,
    required this.count,
    required this.avgSeverity,
  });
  final String key;
  final String label;
  final int count;
  final double avgSeverity;
}

class _Row extends StatelessWidget {
  const _Row({required this.summary});
  final _Summary summary;

  @override
  Widget build(BuildContext context) {
    final severityColor = summary.avgSeverity >= 4
        ? AppColors.danger
        : summary.avgSeverity >= 3
        ? AppColors.warning
        : AppColors.success;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(summary.label, style: AppText.body)),
          Text(
            '${summary.count}×',
            style: const TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.inkBlack,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              'sev ${summary.avgSeverity.toStringAsFixed(1)}',
              style: TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: severityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
