import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';
import 'log_success_view.dart';

const _kgPerLb = 0.45359237;

enum _Unit { lb, kg }

class LogWeightScreen extends ConsumerStatefulWidget {
  const LogWeightScreen({super.key});

  @override
  ConsumerState<LogWeightScreen> createState() => _LogWeightScreenState();
}

class _LogWeightScreenState extends ConsumerState<LogWeightScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weight = TextEditingController();
  _Unit _unit = _Unit.lb;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _busy = false;
  bool _success = false;
  String? _error;

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  void _onUnitChanged(_Unit next) {
    if (next == _unit) return;
    final parsed = double.tryParse(_weight.text);
    setState(() {
      _unit = next;
      if (parsed != null && parsed > 0) {
        final converted = next == _Unit.kg ? parsed * _kgPerLb : parsed / _kgPerLb;
        _weight.text = converted.toStringAsFixed(1);
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final entered = double.parse(_weight.text);
    final weightLb = _unit == _Unit.kg ? entered / _kgPerLb : entered;
    final when = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(weightLogsRepositoryProvider)
          .insert(loggedAt: when, weightLb: weightLb);
      ref.invalidate(recentWeightLogsProvider);
      ref.invalidate(progressWeightLogsProvider);
      if (!mounted) return;
      setState(() => _success = true);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) context.go('/home');
    } on Exception catch (e) {
      if (mounted) setState(() => _error = 'Couldn\'t save the weight: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return const Scaffold(
        body: SafeArea(
          child: LogSuccessView(title: 'Weight recorded'),
        ),
      );
    }
    final dateLabel =
        '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';
    final unitLabel = _unit == _Unit.lb ? 'lb' : 'kg';
    final wheelInitial = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
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
        title: const Text('Log weight', style: AppText.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Weight', style: AppText.bodyMuted),
                    _UnitToggle(unit: _unit, onChanged: _onUnitChanged),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: _unit == _Unit.lb ? '170.8' : '77.5',
                    hintStyle: const TextStyle(
                      color: Color(0xFFBFC4CC),
                      fontWeight: FontWeight.w400,
                    ),
                    suffixText: unitLabel,
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Enter a weight';
                    final lb = _unit == _Unit.kg ? n / _kgPerLb : n;
                    if (lb < 50 || lb > 700) {
                      return 'Enter a weight between 50 and 700 lb';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Date', style: AppText.bodyMuted),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: _pickDate,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(dateLabel),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Time', style: AppText.bodyMuted),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  height: 160,
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontFamily: AppText.fontFamily,
                          fontSize: 20,
                          color: AppColors.inkBlack,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: wheelInitial,
                      use24hFormat: false,
                      minuteInterval: 1,
                      onDateTimeChanged: (dt) {
                        setState(() {
                          _time = TimeOfDay(hour: dt.hour, minute: dt.minute);
                        });
                      },
                    ),
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

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.unit, required this.onChanged});

  final _Unit unit;
  final ValueChanged<_Unit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.borderSubtle,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment('LB', unit == _Unit.lb, () => onChanged(_Unit.lb)),
          _segment('KG', unit == _Unit.kg, () => onChanged(_Unit.kg)),
        ],
      ),
    );
  }

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        constraints: const BoxConstraints(minWidth: 40),
        height: 28,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.darkTeal : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
