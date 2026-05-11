import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

// ---------------------------------------------------------------------------
// Domain types & data (mirrors wireframe-v1 src/data/drugs.ts)
// ---------------------------------------------------------------------------

enum DrugForm { injection, pill }

enum Supply { branded, compounded }

enum Indication { weight, t2d, both }

enum PriorGlp1 { naive, switched, restarted }

class Drug {
  final String brand;
  final String generic;
  final List<String> doses;
  final DrugForm form;
  final bool comingSoon;

  const Drug({
    required this.brand,
    required this.generic,
    required this.doses,
    required this.form,
    this.comingSoon = false,
  });
}

class MedCategory {
  final String id;
  final String name;
  final bool active;

  const MedCategory({required this.id, required this.name, required this.active});
}

const _categories = <MedCategory>[
  MedCategory(id: 'glp1', name: 'GLP-1s', active: true),
  MedCategory(id: 'bp', name: 'Blood pressure', active: false),
  MedCategory(id: 'birth-control', name: 'Birth control', active: false),
  MedCategory(id: 'mental-health', name: 'Mental health', active: false),
];

const _frequencies = ['Weekly', 'Daily', 'Twice weekly', 'Other'];

const _drugs = <Drug>[
  Drug(brand: 'Ozempic', generic: 'semaglutide', doses: ['0.25 mg', '0.5 mg', '1.0 mg', '2.0 mg'], form: DrugForm.injection),
  Drug(brand: 'Wegovy', generic: 'semaglutide', doses: ['0.25 mg', '0.5 mg', '1.0 mg', '1.7 mg', '2.4 mg'], form: DrugForm.injection),
  Drug(brand: 'Mounjaro', generic: 'tirzepatide', doses: ['2.5 mg', '5 mg', '7.5 mg', '10 mg', '12.5 mg', '15 mg'], form: DrugForm.injection),
  Drug(brand: 'Zepbound', generic: 'tirzepatide', doses: ['2.5 mg', '5 mg', '7.5 mg', '10 mg', '12.5 mg', '15 mg'], form: DrugForm.injection),
  Drug(brand: 'Trulicity', generic: 'dulaglutide', doses: ['0.75 mg', '1.5 mg', '3 mg', '4.5 mg'], form: DrugForm.injection),
  Drug(brand: 'Saxenda', generic: 'liraglutide', doses: ['0.6 mg', '1.2 mg', '1.8 mg', '2.4 mg', '3.0 mg'], form: DrugForm.injection),
  Drug(brand: 'Rybelsus', generic: 'semaglutide', doses: ['3 mg', '7 mg', '14 mg', '25 mg'], form: DrugForm.pill),
  Drug(brand: 'Retatrutide', generic: 'retatrutide', doses: ['Coming 2026'], form: DrugForm.injection, comingSoon: true),
  Drug(brand: 'Orforglipron', generic: 'orforglipron', doses: ['Coming 2026'], form: DrugForm.pill, comingSoon: true),
];

// ---------------------------------------------------------------------------
// Theme tokens (matches wireframe palette)
// ---------------------------------------------------------------------------

class _T {
  static const primary = Color(0xFF234A67);
  static const selectedBg = Color(0xFFE8F4F8);
  static const ink = Color(0xFF1C1C1C);
  static const sub = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const bgScroll = Color(0xFFFAFAFA);
  static const lockBg = Color(0xFFF3F4F6);
  static const lockText = Color(0xFF9CA3AF);
  static const warnBg = Color(0xFFFEF2F2);
  static const warnBorder = Color(0xFFB91C1C);
  static const warnText = Color(0xFF991B1B);
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OnboardingTwoScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const OnboardingTwoScreen({super.key, this.onBack, this.onContinue});

  @override
  State<OnboardingTwoScreen> createState() => _OnboardingTwoScreenState();
}

class _OnboardingTwoScreenState extends State<OnboardingTwoScreen> {
  String _category = 'glp1';
  DrugForm _form = DrugForm.injection;
  Supply _supply = Supply.branded;
  String? _drugBrand;
  String? _dose;
  String? _frequency;
  DateTime? _startDate;
  Indication? _indication;
  PriorGlp1? _priorGlp1;
  bool? _pregnancyYes;
  bool? _thyroidYes;

  List<Drug> get _filteredDrugs =>
      _drugs.where((d) => d.form == _form && !d.comingSoon).toList();

  Drug? get _selectedDrug {
    if (_drugBrand == null) return null;
    for (final d in _filteredDrugs) {
      if (d.brand == _drugBrand) return d;
    }
    return null;
  }

  bool get _hasRedFlag => _pregnancyYes == true || _thyroidYes == true;

  bool get _canContinue =>
      _drugBrand != null &&
      _dose != null &&
      _frequency != null &&
      _startDate != null &&
      _indication != null &&
      _priorGlp1 != null &&
      _pregnancyYes != null &&
      _thyroidYes != null;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Column(
          children: [
            _ProgressBar(step: 2, totalSteps: 4, onBack: widget.onBack),
            _Header(),
            Expanded(
              child: Container(
                color: _T.bgScroll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _categorySection(),
                      const SizedBox(height: 20),
                      _formSection(),
                      const SizedBox(height: 20),
                      _medicationDropdown(),
                      if (_selectedDrug != null) ...[
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
            _ContinueBar(
              enabled: _canContinue,
              onPressed: widget.onContinue,
            ),
          ],
        ),
      ),
    );
  }

  // ---- sections ---------------------------------------------------------

  Widget _categorySection() => _Section(
        label: 'Category',
        child: Column(
          children: [
            _Grid2(
              children: _categories
                  .map((c) => _SelectableTile(
                        selected: _category == c.id && c.active,
                        disabled: !c.active,
                        height: 72,
                        onTap: c.active ? () => setState(() => _category = c.id) : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!c.active)
                              const Icon(Icons.lock_outline, size: 14, color: _T.lockText),
                            Text(c.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: c.active ? _T.ink : _T.lockText,
                                )),
                            if (!c.active)
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Text('COMING SOON',
                                    style: TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 0.6,
                                      color: _T.lockText,
                                    )),
                              ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            _DashedTile(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, size: 16, color: _T.sub),
                  SizedBox(width: 8),
                  Text('Suggest another category',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500, color: _T.sub)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _formSection() => _Section(
        label: 'Form',
        child: _Grid2(
          children: [
            _SelectableTile(
              selected: _form == DrugForm.injection,
              height: 56,
              onTap: () => setState(() {
                _form = DrugForm.injection;
                _resetDrugFields();
              }),
              child: const _IconLabel(icon: Icons.vaccines_outlined, label: 'Injection'),
            ),
            _SelectableTile(
              selected: _form == DrugForm.pill,
              height: 56,
              onTap: () => setState(() {
                _form = DrugForm.pill;
                _resetDrugFields();
              }),
              child: const _IconLabel(icon: Icons.medication_outlined, label: 'Pill'),
            ),
          ],
        ),
      );

  Widget _medicationDropdown() => _Section(
        label: 'Medication',
        child: _PickerButton(
          placeholder: 'Select a medication',
          value: _drugBrand == null
              ? null
              : '$_drugBrand (${_selectedDrug?.generic ?? ''})',
          onTap: () async {
            final picked = await _showOptionPicker<String>(
              title: 'Medication',
              options: _filteredDrugs
                  .map((d) => _PickerOption(value: d.brand, label: '${d.brand} (${d.generic})'))
                  .toList(),
              current: _drugBrand,
            );
            if (picked != null) {
              setState(() {
                _drugBrand = picked;
                _dose = null;
              });
            }
          },
        ),
      );

  Widget _doseFreqDateCard() => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Section(
              label: 'Dose amount',
              child: _PickerButton(
                placeholder: 'Select dose',
                value: _dose,
                onTap: () async {
                  final picked = await _showOptionPicker<String>(
                    title: 'Dose amount',
                    options: _selectedDrug!.doses
                        .map((d) => _PickerOption(value: d, label: d))
                        .toList(),
                    current: _dose,
                  );
                  if (picked != null) setState(() => _dose = picked);
                },
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              label: 'Frequency',
              child: _Grid2(
                children: _frequencies
                    .map((f) => _SelectableTile(
                          selected: _frequency == f,
                          height: 44,
                          onTap: () => setState(() => _frequency = f),
                          child: Text(f,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _frequency == f ? _T.primary : _T.ink,
                              )),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              label: 'Date started',
              child: _PickerButton(
                placeholder: 'Select date',
                value: _startDate == null ? null : _formatDate(_startDate!),
                onTap: _showDatePicker,
              ),
            ),
          ],
        ),
      );

  Widget _contextCard() => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Eyebrow(eyebrow: 'CONTEXT', body: 'These inputs shape your cohort match.'),
            const SizedBox(height: 12),
            _Section(
              label: 'Source',
              child: _Grid2(
                children: [
                  _supplyTile(Supply.branded, 'Branded'),
                  _supplyTile(Supply.compounded, 'Compounded'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              label: 'Reason for taking',
              child: _Grid3(
                children: [
                  _indicationTile(Indication.weight, 'Weight'),
                  _indicationTile(Indication.t2d, 'T2D'),
                  _indicationTile(Indication.both, 'Both'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              label: 'Prior GLP-1 experience',
              child: _Grid3(
                children: [
                  _priorTile(PriorGlp1.naive, 'First time'),
                  _priorTile(PriorGlp1.switched, 'Switched'),
                  _priorTile(PriorGlp1.restarted, 'Restarted'),
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
            _Section(
              label: 'Are you pregnant, trying to become pregnant, or breastfeeding?',
              child: _yesNo((v) => setState(() => _pregnancyYes = v), _pregnancyYes),
            ),
            const SizedBox(height: 16),
            _Section(
              label:
                  'Personal or family history of medullary thyroid carcinoma (MTC) or Multiple Endocrine Neoplasia type 2 (MEN 2)?',
              child: _yesNo((v) => setState(() => _thyroidYes = v), _thyroidYes),
            ),
            if (_hasRedFlag) ...[
              const SizedBox(height: 12),
              _RedFlagBanner(pregnancy: _pregnancyYes == true, thyroid: _thyroidYes == true),
            ],
          ],
        ),
      );

  // ---- tile builders ----------------------------------------------------

  Widget _supplyTile(Supply s, String label) => _SelectableTile(
        selected: _supply == s,
        height: 44,
        onTap: () => setState(() => _supply = s),
        child: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _supply == s ? _T.primary : _T.ink)),
      );

  Widget _indicationTile(Indication i, String label) => _SelectableTile(
        selected: _indication == i,
        height: 44,
        onTap: () => setState(() => _indication = i),
        child: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _indication == i ? _T.primary : _T.ink)),
      );

  Widget _priorTile(PriorGlp1 p, String label) => _SelectableTile(
        selected: _priorGlp1 == p,
        height: 44,
        onTap: () => setState(() => _priorGlp1 = p),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _priorGlp1 == p ? _T.primary : _T.ink)),
      );

  Widget _yesNo(void Function(bool) onPick, bool? current) => _Grid2(
        children: [
          _SelectableTile(
            selected: current == false,
            height: 44,
            onTap: () => onPick(false),
            child: Text('No',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: current == false ? _T.primary : _T.ink)),
          ),
          _SelectableTile(
            selected: current == true,
            height: 44,
            onTap: () => onPick(true),
            child: Text('Yes',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: current == true ? _T.primary : _T.ink)),
          ),
        ],
      );

  // ---- helpers ----------------------------------------------------------

  void _resetDrugFields() {
    _drugBrand = null;
    _dose = null;
    _frequency = null;
    _startDate = null;
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<T?> _showOptionPicker<T>({
    required String title,
    required List<_PickerOption<T>> options,
    T? current,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(title),
        actions: options
            .map((o) => CupertinoActionSheetAction(
                  isDefaultAction: o.value == current,
                  onPressed: () => Navigator.pop(ctx, o.value),
                  child: Text(o.label),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    DateTime temp = _startDate ?? DateTime.now();
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
                setState(() => _startDate = temp);
                Navigator.pop(ctx);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable bits
// ---------------------------------------------------------------------------

class _PickerOption<T> {
  final T value;
  final String label;
  const _PickerOption({required this.value, required this.label});
}

class _ProgressBar extends StatelessWidget {
  final int step;
  final int totalSteps;
  final VoidCallback? onBack;
  const _ProgressBar({required this.step, required this.totalSteps, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(CupertinoIcons.back, size: 24, color: _T.ink),
            ),
          ),
          Expanded(
            child: Row(
              children: List.generate(totalSteps, (i) {
                final filled = i < step;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 4),
                    decoration: BoxDecoration(
                      color: filled ? _T.primary : _T.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text('$step of $totalSteps',
                style: const TextStyle(fontSize: 12, color: _T.sub)),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('What are you tracking?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _T.ink)),
          SizedBox(height: 6),
          Text('Pick a category, then choose your medication and dose.',
              style: TextStyle(fontSize: 14, color: _T.sub, height: 1.4)),
        ],
      ),
    );
  }
}

class _ContinueBar extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;
  const _ContinueBar({required this.enabled, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(top: BorderSide(color: _T.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: _T.primary,
          disabledColor: _T.primary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          onPressed: enabled ? onPressed : null,
          child: const Text('Continue',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.white)),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  const _Section({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _T.ink)),
        ),
        child,
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border.all(color: _T.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String eyebrow;
  final String body;
  const _Eyebrow({required this.eyebrow, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: _T.sub,
            )),
        const SizedBox(height: 4),
        Text(body, style: const TextStyle(fontSize: 12, color: _T.sub, height: 1.4)),
      ],
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final bool selected;
  final bool disabled;
  final double height;
  final VoidCallback? onTap;
  final Widget child;

  const _SelectableTile({
    required this.selected,
    required this.height,
    this.disabled = false,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bg = disabled
        ? _T.lockBg
        : selected
            ? _T.selectedBg
            : CupertinoColors.white;
    final border = selected && !disabled ? _T.primary : _T.border;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        height: height,
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

class _DashedTile extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _DashedTile({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    // Flutter has no built-in dashed border; use a subtle solid border as fallback.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: _T.border, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class _Grid2 extends StatelessWidget {
  final List<Widget> children;
  const _Grid2({required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      final left = children[i];
      final right = i + 1 < children.length ? children[i + 1] : const SizedBox();
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: i + 2 < children.length ? 8 : 0),
        child: Row(children: [
          Expanded(child: left),
          const SizedBox(width: 8),
          Expanded(child: right),
        ]),
      ));
    }
    return Column(children: rows);
  }
}

class _Grid3 extends StatelessWidget {
  final List<Widget> children;
  const _Grid3({required this.children});

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

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _IconLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: _T.ink),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _T.ink)),
      ],
    );
  }
}

class _PickerButton extends StatelessWidget {
  final String placeholder;
  final String? value;
  final VoidCallback onTap;
  const _PickerButton({required this.placeholder, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          border: Border.all(color: _T.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? placeholder,
                style: TextStyle(
                  fontSize: 14,
                  color: value == null ? _T.sub : _T.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(CupertinoIcons.chevron_down, size: 16, color: _T.sub),
          ],
        ),
      ),
    );
  }
}

class _RedFlagBanner extends StatelessWidget {
  final bool pregnancy;
  final bool thyroid;
  const _RedFlagBanner({required this.pregnancy, required this.thyroid});

  @override
  Widget build(BuildContext context) {
    final buf = StringBuffer();
    if (pregnancy) buf.write('GLP-1s are not recommended during pregnancy or breastfeeding. ');
    if (thyroid) buf.write('GLP-1s carry a boxed warning for people with MTC or MEN 2 history. ');
    buf.write(
        'You can still use Trial Weave to track, but please confirm with your clinician that this medication is right for you.');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _T.warnBg,
        border: Border.all(color: _T.warnBorder, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2, right: 10),
            child: Icon(Icons.warning_amber_rounded, size: 20, color: _T.warnBorder),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Talk to your prescriber before starting',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: _T.warnText)),
                const SizedBox(height: 4),
                Text(buf.toString(),
                    style: const TextStyle(fontSize: 12, color: _T.warnText, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
