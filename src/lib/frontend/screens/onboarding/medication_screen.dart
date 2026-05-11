import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Material, MaterialType, Icons, IconData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/drug.dart';
import '../../../backend/providers/onboarding_provider.dart';
import '../../components/onboarding/continue_bar.dart';
import '../../components/onboarding/onboarding_inputs.dart';
import '../../components/onboarding/onboarding_theme.dart';
import '../../components/onboarding/progress_bar.dart';

class MedicationScreen extends ConsumerStatefulWidget {
  const MedicationScreen({super.key});

  @override
  ConsumerState<MedicationScreen> createState() => _MedicationScreenState();
}

class _Category {
  const _Category({required this.id, required this.name, required this.active});
  final String id;
  final String name;
  final bool active;
}

const _categories = <_Category>[
  _Category(id: 'glp1', name: 'GLP-1s', active: true),
  _Category(id: 'bp', name: 'Blood pressure', active: false),
  _Category(id: 'birth-control', name: 'Birth control', active: false),
  _Category(id: 'mental-health', name: 'Mental health', active: false),
];

const _frequencies = ['Weekly', 'Daily', 'Twice weekly', 'Other'];

class _Lock {
  static const lockBg = Color(0xFFF3F4F6);
  static const lockText = Color(0xFF9CA3AF);
  static const warnBg = Color(0xFFFEF2F2);
  static const warnBorder = Color(0xFFB91C1C);
  static const warnText = Color(0xFF991B1B);
}

class _MedicationScreenState extends ConsumerState<MedicationScreen> {
  String _category = 'glp1';
  String _form = 'injection';
  Drug? _drug;
  String? _dose;
  String? _frequency;
  DateTime? _startedAt;
  String? _indication;
  String? _priorGlp1;
  String? _supply;
  bool? _pregnancyYes;
  bool? _thyroidYes;

  @override
  void initState() {
    super.initState();
    final s = ref.read(onboardingProvider);
    _drug = s.drug;
    _form = s.drug?.form ?? 'injection';
    _dose = s.dose;
    _frequency = s.frequency;
    _startedAt = s.startedAt;
    _indication = s.indication;
    _priorGlp1 = s.priorGlp1;
    _supply = s.supply;
  }

  List<Drug> get _filteredDrugs =>
      kDrugCatalog.where((d) => d.form == _form).toList();

  bool get _hasRedFlag => _pregnancyYes == true || _thyroidYes == true;

  bool get _canContinue =>
      _drug != null &&
      _dose != null &&
      _frequency != null &&
      _startedAt != null &&
      _indication != null &&
      _priorGlp1 != null &&
      _supply != null &&
      _pregnancyYes != null &&
      _thyroidYes != null;

  void _resetDrugFields() {
    _drug = null;
    _dose = null;
    _frequency = null;
    _startedAt = null;
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<String?> _pickFromList(String title, List<String> options, String? current) {
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

  void _onContinue() {
    if (!_canContinue) return;
    ref
        .read(onboardingProvider.notifier)
        .setMedication(
          drug: _drug!,
          dose: _dose!,
          frequency: _frequency!,
          indication: _indication!,
          priorGlp1: _priorGlp1!,
          supply: _supply!,
          startedAt: _startedAt!,
        );
    context.go('/onboarding/baseline');
  }

  void _onBack() => context.go('/onboarding/demographics');

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Column(
            children: [
              OnboardingProgressBar(step: 2, totalSteps: 5, onBack: _onBack),
              const _Header(),
              Expanded(
                child: Container(
                  color: OnboardingColors.bgScroll,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _categorySection(),
                        const SizedBox(height: 20),
                        _formSection(),
                        const SizedBox(height: 20),
                        _medicationPicker(),
                        if (_drug != null) ...[
                          const SizedBox(height: 20),
                          _doseFreqDateCard(),
                          const SizedBox(height: 20),
                          _contextCard(),
                          const SizedBox(height: 20),
                          _safetyCard(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              OnboardingContinueBar(
                enabled: _canContinue,
                onPressed: _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categorySection() => OnboardingSection(
    label: 'Category',
    child: OnboardingGrid2(
      children: _categories
          .map(
            (c) => _LockableTile(
              selected: _category == c.id && c.active,
              disabled: !c.active,
              onTap: c.active ? () => setState(() => _category = c.id) : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!c.active)
                    const Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: _Lock.lockText,
                    ),
                  Text(
                    c.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: c.active ? OnboardingColors.ink : _Lock.lockText,
                    ),
                  ),
                  if (!c.active)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        'COMING SOON',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.6,
                          color: _Lock.lockText,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );

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
              _stringTile('weight', 'Weight', _indication, (v) => _indication = v),
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
              _stringTile('naive', 'First time', _priorGlp1, (v) => _priorGlp1 = v),
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

  Widget _safetyCard() => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Eyebrow(
          eyebrow: 'SAFETY CHECK',
          body:
              'GLP-1s carry a boxed warning for certain conditions. Your answers stay private and help your prescriber flag risks.',
        ),
        const SizedBox(height: 12),
        OnboardingSection(
          label: 'Are you pregnant, trying to become pregnant, or breastfeeding?',
          child: _yesNo((v) => setState(() => _pregnancyYes = v), _pregnancyYes),
        ),
        const SizedBox(height: 16),
        OnboardingSection(
          label:
              'Personal or family history of medullary thyroid carcinoma (MTC) or Multiple Endocrine Neoplasia type 2 (MEN 2)?',
          child: _yesNo((v) => setState(() => _thyroidYes = v), _thyroidYes),
        ),
        if (_hasRedFlag) ...[
          const SizedBox(height: 12),
          _RedFlagBanner(
            pregnancy: _pregnancyYes == true,
            thyroid: _thyroidYes == true,
          ),
        ],
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

  Widget _yesNo(void Function(bool) onPick, bool? current) => OnboardingGrid2(
    children: [
      OnboardingSelectableTile(
        selected: current == false,
        height: 44,
        onTap: () => onPick(false),
        child: Text(
          'No',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: current == false
                ? OnboardingColors.primary
                : OnboardingColors.ink,
          ),
        ),
      ),
      OnboardingSelectableTile(
        selected: current == true,
        height: 44,
        onTap: () => onPick(true),
        child: Text(
          'Yes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: current == true
                ? OnboardingColors.primary
                : OnboardingColors.ink,
          ),
        ),
      ),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you tracking?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: OnboardingColors.ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Pick a category, then choose your medication and dose.',
            style: TextStyle(
              fontSize: 14,
              color: OnboardingColors.sub,
              height: 1.4,
            ),
          ),
        ],
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

class _LockableTile extends StatelessWidget {
  const _LockableTile({
    required this.selected,
    required this.child,
    this.disabled = false,
    this.onTap,
  });

  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bg = disabled
        ? _Lock.lockBg
        : selected
        ? OnboardingColors.selectedBg
        : CupertinoColors.white;
    final border = selected && !disabled
        ? OnboardingColors.primary
        : OnboardingColors.border;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        height: 72,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
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

class _RedFlagBanner extends StatelessWidget {
  const _RedFlagBanner({required this.pregnancy, required this.thyroid});
  final bool pregnancy;
  final bool thyroid;

  @override
  Widget build(BuildContext context) {
    final buf = StringBuffer();
    if (pregnancy) {
      buf.write(
        'GLP-1s are not recommended during pregnancy or breastfeeding. ',
      );
    }
    if (thyroid) {
      buf.write(
        'GLP-1s carry a boxed warning for people with MTC or MEN 2 history. ',
      );
    }
    buf.write(
      'You can still use Trial Weave to track, but please confirm with your clinician that this medication is right for you.',
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _Lock.warnBg,
        border: Border.all(color: _Lock.warnBorder, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2, right: 10),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: _Lock.warnBorder,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Talk to your prescriber before starting',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _Lock.warnText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  buf.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: _Lock.warnText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
