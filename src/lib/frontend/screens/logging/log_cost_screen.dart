import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import 'log_success_view.dart';

class LogCostScreen extends ConsumerStatefulWidget {
  const LogCostScreen({super.key});

  @override
  ConsumerState<LogCostScreen> createState() => _LogCostScreenState();
}

class _LogCostScreenState extends ConsumerState<LogCostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _busy = false;
  bool _success = false;
  bool _hydrated = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime.now(),
      // The picker still shows days; we normalize to first-of-month on save.
      helpText: 'Select any day in the target month',
    );
    if (picked != null && mounted) {
      setState(() => _month = DateTime(picked.year, picked.month, 1));
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(costLogsRepositoryProvider)
          .upsertForMonth(month: _month, amountUsd: int.parse(_amount.text));
      ref.invalidate(currentMonthCostProvider);
      ref.invalidate(filteredCohortCostProvider);
      if (!mounted) return;
      setState(() => _success = true);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) context.go('/home');
    } on Exception catch (e) {
      if (mounted) setState(() => _error = 'Couldn\'t save the cost: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return const Scaffold(
        body: SafeArea(
          child: LogSuccessView(title: 'Cost recorded'),
        ),
      );
    }
    final monthLabel =
        '${_month.year}-${_month.month.toString().padLeft(2, '0')}';
    final isCurrentMonth =
        _month.year == DateTime.now().year &&
        _month.month == DateTime.now().month;

    // Hydrate the amount field from currentMonthCostProvider so editing the
    // current month shows the existing value instead of a blank field.
    if (!_hydrated && isCurrentMonth) {
      final existing = ref.watch(currentMonthCostProvider).valueOrNull;
      if (existing != null) {
        _amount.text = '${existing.amountUsd}';
        _hydrated = true;
      }
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
        title: const Text('Log monthly cost', style: AppText.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'What you paid out-of-pocket this month for your medication. '
                  'One row per (you, month) — re-saving overwrites.',
                  style: AppText.bodyMuted,
                ),
                const SizedBox(height: 20),
                const Text('Amount (USD)', style: AppText.bodyMuted),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: '\$ ',
                    hintText: 'e.g., 1099',
                  ),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n < 0)
                      return 'Enter a non-negative integer';
                    if (n > 100000) return 'Too large — sanity check this';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Month', style: AppText.bodyMuted),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: _pickMonth,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(monthLabel),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
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
                const Spacer(),
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
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
