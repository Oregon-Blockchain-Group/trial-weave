import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        AppBar,
        IconButton,
        Icons,
        IconData,
        Material,
        MaterialType,
        Scaffold;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/drug.dart';
import '../../../backend/models/regimen.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../components/dialogs/reason_dialog.dart';
import '../../components/onboarding/onboarding_inputs.dart';
import '../../components/onboarding/onboarding_theme.dart';
import '../logging/log_success_view.dart';

const _frequencies = ['Weekly', 'Daily', 'Twice weekly', 'Other'];

class SwitchDrugScreen extends ConsumerStatefulWidget {
  const SwitchDrugScreen({super.key});

  @override
  ConsumerState<SwitchDrugScreen> createState() => _SwitchDrugScreenState();
}

class _SwitchDrugScreenState extends ConsumerState<SwitchDrugScreen> {
  String _form = 'injection';
  Drug? _drug;
  String? _dose;
  String? _frequency;
  DateTime? _startedAt;
  String? _indication;
  String? _priorGlp1;
  String? _supply;
  bool _hydrated = false;
  bool _busy = false;
  bool _success = false;
  String? _error;

  void _hydrate(Regimen r) {
    if (_hydrated) return;
    _hydrated = true;
    final match = kDrugCatalog.firstWhere(
      (d) => d.brand == r.brand,
      orElse: () => kDrugCatalog.first,
    );
    setState(() {
      _drug = match;
      _form = r.form ?? match.form;
      _dose = r.dose;
      _frequency = r.frequency;
      _startedAt = r.startedAt;
      _indication = r.indication;
      _priorGlp1 = r.priorGlp1;
      _supply = r.supply;
    });
  }

  List<Drug> get _filteredDrugs =>
      kDrugCatalog.where((d) => d.form == _form).toList();

  bool get _canSubmit =>
      _drug != null &&
      _dose != null &&
      _frequency != null &&
      _startedAt != null &&
      _indication != null &&
      _priorGlp1 != null &&
      _supply != null;

  void _resetDrugFields() {
    _drug = null;
    _dose = null;
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<String?> _pickFromList(
    String title,
    List<String> options,
    String? current,
  ) {
    return showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(title),
        actions: options
            .map(
              (o) => CupertinoActionSheetAction(
                isDefaultAction: o == current,
                onPressed: () => Navigator.pop(ctx, o),
                child: Text(o),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<Drug?> _pickDrug() {
    return showCupertinoModalPopup<Drug>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Medication'),
        actions: _filteredDrugs
            .map(
              (d) => CupertinoActionSheetAction(
                isDefaultAction: d.brand == _drug?.brand,
                onPressed: () => Navigator.pop(ctx, d),
                child: Text('${d.brand} (${d.generic})'),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime temp = _startedAt ?? DateTime.now();
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: CupertinoColors.white,
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: temp,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (d) => temp = d,
              ),
            ),
            CupertinoButton(
              onPressed: () {
                setState(() => _startedAt = temp);
                Navigator.pop(ctx);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_canSubmit) return;
    final reason = await showReasonDialog(
      context,
      title: 'Why are you switching?',
      hint: 'e.g. side effects, dose change, switching insurance',
    );
    if (reason == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(regimensRepositoryProvider);
      await repo.stopActive(reason: reason);
      await repo.startNew(
        brand: _drug!.brand,
        generic: _drug!.generic,
        dose: _dose,
        form: _drug!.form,
        frequency: _frequency,
        indication: _indication,
        priorGlp1: _priorGlp1,
        supply: _supply,
        startedAt: _startedAt,
      );
      ref.invalidate(activeRegimenProvider);
      ref.invalidate(allRegimensProvider);
      if (!mounted) return;
      setState(() => _success = true);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) context.go('/profile/regimen');
    } on Exception catch (e) {
      if (mounted) setState(() => _error = 'Couldn\'t switch: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return const Scaffold(
        body: SafeArea(
          child: LogSuccessView(eyebrow: 'Switched', title: 'Regimen updated'),
        ),
      );
    }
    final activeAsync = ref.watch(activeRegimenProvider);
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        backgroundColor: CupertinoColors.white,
        elevation: 0,
        foregroundColor: OnboardingColors.ink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile/regimen'),
        ),
        title: const Text(
          'Switch drug',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: OnboardingColors.ink,
          ),
        ),
      ),
      body: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: activeAsync.when(
            loading: () =>
                const Center(child: CupertinoActivityIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('$e'),
            ),
            data: (active) {
              if (active != null) _hydrate(active);
              return Column(
                children: [
                  const _Header(),
                  Expanded(
                    child: Container(
                      color: OnboardingColors.bgScroll,
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.fromLTRB(24, 20, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _formSection(),
                            const SizedBox(height: 20),
                            _medicationPicker(),
                            if (_drug != null) ...[
                              const SizedBox(height: 20),
                              _doseFreqDateCard(),
                              const SizedBox(height: 20),
                              _contextCard(),
                            ],
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  border: Border.all(
                                    color: const Color(0xFFB91C1C),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFF991B1B),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  _SwitchBar(
                    enabled: _canSubmit && !_busy,
                    busy: _busy,
                    onPressed: _save,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _formSection() => OnboardingSection(
    label: 'Form',
    child: OnboardingGrid2(
      children: [
        OnboardingSelectableTile(
          selected: _form == 'injection',
          height: 56,
          onTap: () => setState(() {
            _form = 'injection';
            _resetDrugFields();
          }),
          child: const _IconLabel(
            icon: Icons.vaccines_outlined,
            label: 'Injection',
          ),
        ),
        OnboardingSelectableTile(
          selected: _form == 'pill',
          height: 56,
          onTap: () => setState(() {
            _form = 'pill';
            _resetDrugFields();
          }),
          child: const _IconLabel(
            icon: Icons.medication_outlined,
            label: 'Pill',
          ),
        ),
      ],
    ),
  );

  Widget _medicationPicker() => OnboardingSection(
    label: 'Medication',
    child: _PickerButton(
      placeholder: 'Select a medication',
      value: _drug == null ? null : '${_drug!.brand} (${_drug!.generic})',
      onTap: () async {
        final picked = await _pickDrug();
        if (picked != null) {
          setState(() {
            _drug = picked;
            _dose = null;
            _frequency ??= picked.defaultFrequency == 'weekly'
                ? 'Weekly'
                : 'Daily';
            _indication ??= picked.defaultIndication;
          });
        }
      },
    ),
  );

  Widget _doseFreqDateCard() => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnboardingSection(
          label: 'Dose amount',
          child: _PickerButton(
            placeholder: 'Select dose',
            value: _dose,
            onTap: () async {
              final picked = await _pickFromList(
                'Dose amount',
                _drug!.doses,
                _dose,
              );
              if (picked != null) setState(() => _dose = picked);
            },
          ),
        ),
        const SizedBox(height: 16),
        OnboardingSection(
          label: 'Frequency',
          child: OnboardingGrid2(
            children: _frequencies
                .map(
                  (f) => OnboardingSelectableTile(
                    selected: _frequency == f,
                    height: 44,
                    onTap: () => setState(() => _frequency = f),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _frequency == f
                            ? OnboardingColors.primary
                            : OnboardingColors.ink,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        OnboardingSection(
          label: 'Date started',
          child: _PickerButton(
            placeholder: 'Select date',
            value: _startedAt == null ? null : _formatDate(_startedAt!),
            onTap: _pickDate,
          ),
        ),
      ],
    ),
  );

  Widget _contextCard() => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Eyebrow(
          eyebrow: 'CONTEXT',
          body: 'These inputs shape your cohort match.',
        ),
        const SizedBox(height: 12),
        OnboardingSection(
          label: 'Source',
          child: OnboardingGrid2(
            children: [
              _stringTile('branded', 'Branded', _supply, (v) => _supply = v),
              _stringTile(
                'compounded',
                'Compounded',
                _supply,
                (v) => _supply = v,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OnboardingSection(
          label: 'Reason for taking',
          child: _Grid3(
            children: [
              _stringTile(
                'weight',
                'Weight',
                _indication,
                (v) => _indication = v,
              ),
              _stringTile('t2d', 'T2D', _indication, (v) => _indication = v),
              _stringTile('both', 'Both', _indication, (v) => _indication = v),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OnboardingSection(
          label: 'Prior GLP-1 experience',
          child: _Grid3(
            children: [
              _stringTile(
                'naive',
                'First time',
                _priorGlp1,
                (v) => _priorGlp1 = v,
              ),
              _stringTile(
                'switched',
                'Switched',
                _priorGlp1,
                (v) => _priorGlp1 = v,
              ),
              _stringTile(
                'restarted',
                'Restarted',
                _priorGlp1,
                (v) => _priorGlp1 = v,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _stringTile(
    String value,
    String label,
    String? current,
    void Function(String) setter,
  ) => OnboardingSelectableTile(
    selected: current == value,
    height: 44,
    onTap: () => setState(() => setter(value)),
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: current == value
            ? OnboardingColors.primary
            : OnboardingColors.ink,
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: const Text(
        'Your current regimen ends and a new one starts. Past logs stay attached to the old regimen.',
        style: TextStyle(
          fontSize: 14,
          color: OnboardingColors.sub,
          height: 1.4,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: CupertinoColors.white,
      border: Border.all(color: OnboardingColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.eyebrow, required this.body});
  final String eyebrow;
  final String body;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: OnboardingColors.sub,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        body,
        style: const TextStyle(
          fontSize: 12,
          color: OnboardingColors.sub,
          height: 1.4,
        ),
      ),
    ],
  );
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 18, color: OnboardingColors.ink),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: OnboardingColors.ink,
        ),
      ),
    ],
  );
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.placeholder,
    required this.onTap,
    this.value,
  });
  final String placeholder;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          border: Border.all(color: OnboardingColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? placeholder,
                style: TextStyle(
                  fontSize: 14,
                  color: value == null
                      ? OnboardingColors.sub
                      : OnboardingColors.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: OnboardingColors.sub,
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid3 extends StatelessWidget {
  const _Grid3({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _SwitchBar extends StatelessWidget {
  const _SwitchBar({
    required this.enabled,
    required this.busy,
    required this.onPressed,
  });
  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: CupertinoButton(
        color: OnboardingColors.primary,
        disabledColor: OnboardingColors.border,
        onPressed: enabled ? onPressed : null,
        child: busy
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : const Text(
                'Switch to this',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
      ),
    );
  }
}
