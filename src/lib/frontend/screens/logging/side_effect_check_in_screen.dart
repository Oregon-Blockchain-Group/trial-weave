import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/side_effect.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import 'log_success_view.dart';

class SideEffectCheckInScreen extends ConsumerStatefulWidget {
  const SideEffectCheckInScreen({super.key});

  @override
  ConsumerState<SideEffectCheckInScreen> createState() =>
      _SideEffectCheckInScreenState();
}

class _SideEffectCheckInScreenState
    extends ConsumerState<SideEffectCheckInScreen> {
  /// Map of side-effect key → severity (1-5). Absent key = not selected.
  final Map<String, int> _selected = {};
  bool _busy = false;
  bool _success = false;
  String? _error;

  void _toggle(String key) {
    setState(() {
      if (_selected.containsKey(key)) {
        _selected.remove(key);
      } else {
        _selected[key] = 3;
      }
    });
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      // Skip = no side effects this dose, which is meaningful. Just navigate.
      setState(() => _success = true);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) context.go('/home');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final regimen = await ref.read(activeRegimenProvider.future);
      await ref
          .read(sideEffectLogsRepositoryProvider)
          .insertBatch(regimenId: regimen?.id, severityByName: _selected);
      if (!mounted) return;
      setState(() => _success = true);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) context.go('/home');
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _error = 'Couldn\'t save the side effects: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return const Scaffold(
        body: SafeArea(
          child: LogSuccessView(title: 'Side effects saved'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Side effects', style: AppText.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Anything bothering you?', style: AppText.displayLg),
              const SizedBox(height: 6),
              const Text(
                'Tap any that apply, then set how bad each one is. Skip if '
                'you\'re feeling fine.',
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final se in kSideEffectCatalog)
                            FilterChip(
                              label: Text(se.label),
                              selected: _selected.containsKey(se.key),
                              onSelected: (_) => _toggle(se.key),
                              selectedColor: AppColors.tealTint,
                              checkmarkColor: AppColors.darkTeal,
                              labelStyle: TextStyle(
                                color: _selected.containsKey(se.key)
                                    ? AppColors.darkTeal
                                    : AppColors.inkBlack,
                                fontWeight: FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.pill,
                                ),
                                side: BorderSide(
                                  color: _selected.containsKey(se.key)
                                      ? AppColors.darkTeal
                                      : AppColors.border,
                                ),
                              ),
                              backgroundColor: AppColors.cardBg,
                            ),
                        ],
                      ),
                      if (_selected.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text('Severity', style: AppText.title),
                        const SizedBox(height: 8),
                        for (final entry in _selected.entries) ...[
                          _SeverityRow(
                            label: kSideEffectCatalog
                                .firstWhere((s) => s.key == entry.key)
                                .label,
                            value: entry.value,
                            onChanged: (v) =>
                                setState(() => _selected[entry.key] = v),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _selected.isEmpty
                            ? 'Skip — feeling fine'
                            : 'Save ${_selected.length} side effect${_selected.length == 1 ? '' : 's'}',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeverityRow extends StatelessWidget {
  const _SeverityRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
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
              Expanded(child: Text(label, style: AppText.body)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.tealTint,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontSize: 13,
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
        ],
      ),
    );
  }
}
