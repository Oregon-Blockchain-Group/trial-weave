import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/providers/cohort_filters_provider.dart';
import '../../../core/theme.dart';

/// Three single-select chip groups (Sex / Indication / Prior GLP-1) that
/// drive cohortFiltersProvider. Each group has an "All" pill that maps to
/// null in the filter state.
class FilterChipsBar extends ConsumerWidget {
  const FilterChipsBar({super.key});

  static const _sex = [
    _Option(null, 'Any'),
    _Option('female', 'Female'),
    _Option('male', 'Male'),
  ];

  static const _indication = [
    _Option(null, 'Any reason'),
    _Option('weight', 'Weight loss'),
    _Option('t2d', 'T2D'),
    _Option('both', 'Both'),
  ];

  static const _priorGlp1 = [
    _Option(null, 'Any history'),
    _Option('naive', 'GLP-1 naive'),
    _Option('switched', 'Switched'),
    _Option('restarted', 'Restarted'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(cohortFiltersProvider);
    final notifier = ref.read(cohortFiltersProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Group(
          label: 'SEX',
          options: _sex,
          selected: filters.sex,
          onSelected: notifier.setSex,
        ),
        const SizedBox(height: 10),
        _Group(
          label: 'REASON',
          options: _indication,
          selected: filters.indication,
          onSelected: notifier.setIndication,
        ),
        const SizedBox(height: 10),
        _Group(
          label: 'GLP-1 HISTORY',
          options: _priorGlp1,
          selected: filters.priorGlp1,
          onSelected: notifier.setPriorGlp1,
        ),
      ],
    );
  }
}

class _Option {
  const _Option(this.value, this.label);
  final String? value;
  final String label;
}

class _Group extends StatelessWidget {
  const _Group({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final List<_Option> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.eyebrow),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final o in options) ...[
                _Chip(
                  label: o.label,
                  selected: selected == o.value,
                  onTap: () => onSelected(o.value),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.tealTint : AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected ? AppColors.darkTeal : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppText.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.darkTeal : AppColors.inkBlack,
          ),
        ),
      ),
    );
  }
}
