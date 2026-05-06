import 'package:flutter/cupertino.dart';

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

const _genderOptions = ['Female', 'Male', 'Non-binary', 'Prefer not to say'];

const _raceOptions = [
  'American Indian or Alaska Native',
  'Asian',
  'Black or African American',
  'Hispanic or Latino',
  'Middle Eastern or North African',
  'Native Hawaiian or Pacific Islander',
  'White',
  'Other',
  'Prefer not to say',
];

const _comorbidities = [
  'Type 2 diabetes',
  'PCOS',
  'Hypertension',
  'Cardiovascular disease',
  'GI / IBS history',
  'Pancreatitis history',
  'Thyroid disease',
  'None',
];

// ---------------------------------------------------------------------------
// Theme tokens
// ---------------------------------------------------------------------------

class _T {
  static const primary = Color(0xFF234A67);
  static const selectedBg = Color(0xFFE8F4F8);
  static const ink = Color(0xFF1C1C1C);
  static const sub = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const bgScroll = Color(0xFFFAFAFA);
  static const placeholder = Color(0xFFD1D5DB);
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OnboardingDemographicsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const OnboardingDemographicsScreen({super.key, this.onBack, this.onContinue});

  @override
  State<OnboardingDemographicsScreen> createState() =>
      _OnboardingDemographicsScreenState();
}

class _OnboardingDemographicsScreenState
    extends State<OnboardingDemographicsScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightFtController = TextEditingController();
  final _heightInController = TextEditingController();
  final _weightController = TextEditingController();

  String _gender = '';
  List<String> _races = [];
  List<String> _comorbiditySelections = [];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _ageController.text.isNotEmpty &&
      _gender.isNotEmpty &&
      _heightFtController.text.isNotEmpty &&
      _heightInController.text.isNotEmpty &&
      _weightController.text.isNotEmpty &&
      _comorbiditySelections.isNotEmpty;

  void _toggleRace(String option) {
    setState(() {
      if (option == 'Prefer not to say') {
        _races = _races.contains(option) ? [] : [option];
        return;
      }
      final next = _races.where((r) => r != 'Prefer not to say').toList();
      if (next.contains(option)) {
        next.remove(option);
      } else {
        next.add(option);
      }
      _races = next;
    });
  }

  void _toggleComorbidity(String option) {
    setState(() {
      if (option == 'None') {
        _comorbiditySelections =
            _comorbiditySelections.contains(option) ? [] : [option];
        return;
      }
      final next =
          _comorbiditySelections.where((c) => c != 'None').toList();
      if (next.contains(option)) {
        next.remove(option);
      } else {
        next.add(option);
      }
      _comorbiditySelections = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Column(
          children: [
            _ProgressBar(step: 1, totalSteps: 4, onBack: widget.onBack),
            _buildHeader(),
            Expanded(
              child: Container(
                color: _T.bgScroll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _displayNameField(),
                      const SizedBox(height: 20),
                      _ageField(),
                      const SizedBox(height: 20),
                      _genderSection(),
                      const SizedBox(height: 20),
                      _raceSection(),
                      const SizedBox(height: 20),
                      _heightSection(),
                      const SizedBox(height: 20),
                      _weightSection(),
                      const SizedBox(height: 20),
                      _healthHistorySection(),
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

  // ---- header ------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about you',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: _T.ink),
          ),
          SizedBox(height: 6),
          Text(
            'Demographics help us compare your progress with people like you.',
            style: TextStyle(fontSize: 14, color: _T.sub, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ---- fields ------------------------------------------------------------

  Widget _displayNameField() {
    return _Section(
      label: 'Display name',
      trailing: const Text('Optional',
          style: TextStyle(fontSize: 12, color: _T.sub)),
      child: _TextField(
        controller: _nameController,
        placeholder: 'e.g., Alex — used in greetings only',
        keyboardType: TextInputType.name,
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _ageField() {
    return _Section(
      label: 'Age',
      child: _TextField(
        controller: _ageController,
        placeholder: 'e.g., 34',
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _genderSection() {
    return _Section(
      label: 'Gender',
      child: _Grid2(
        children: _genderOptions
            .map((option) => _SelectableTile(
                  selected: _gender == option,
                  height: 48,
                  onTap: () => setState(() => _gender = option),
                  child: Text(
                    option,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _gender == option ? _T.primary : _T.ink,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _raceSection() {
    return _Section(
      label: 'Race / Ethnicity',
      trailing: const Text('Select all that apply',
          style: TextStyle(fontSize: 12, color: _T.sub)),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _raceOptions.map((option) {
          final selected = _races.contains(option);
          return _ChipTile(
            label: option,
            selected: selected,
            onTap: () => _toggleRace(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _heightSection() {
    return _Section(
      label: 'Starting height',
      child: Row(
        children: [
          Expanded(
            child: _TextField(
              controller: _heightFtController,
              placeholder: '5',
              keyboardType: TextInputType.number,
              suffix: 'ft',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TextField(
              controller: _heightInController,
              placeholder: '8',
              keyboardType: TextInputType.number,
              suffix: 'in',
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightSection() {
    return _Section(
      label: 'Starting weight',
      child: _TextField(
        controller: _weightController,
        placeholder: '185',
        keyboardType: TextInputType.number,
        suffix: 'lbs',
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _healthHistorySection() {
    return _Section(
      label: 'Health history',
      trailing: const Text('Select all that apply',
          style: TextStyle(fontSize: 12, color: _T.sub)),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _comorbidities.map((option) {
          final selected = _comorbiditySelections.contains(option);
          return _ChipTile(
            label: option,
            selected: selected,
            onTap: () => _toggleComorbidity(option),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared primitives
// ---------------------------------------------------------------------------

class _ProgressBar extends StatelessWidget {
  final int step;
  final int totalSteps;
  final VoidCallback? onBack;
  const _ProgressBar(
      {required this.step, required this.totalSteps, this.onBack});

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
                    margin:
                        EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 4),
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
          disabledColor: Color.fromRGBO(35, 74, 103, 0.4),
          borderRadius: BorderRadius.circular(12),
          onPressed: enabled ? onPressed : null,
          child: const Text(
            'Continue',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final Widget child;
  const _Section({required this.label, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _T.ink)),
              ?trailing,
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final TextInputType keyboardType;
  final String? suffix;
  final ValueChanged<String>? onChanged;

  const _TextField({
    required this.controller,
    required this.placeholder,
    required this.keyboardType,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border.all(color: _T.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              placeholderStyle:
                  const TextStyle(fontSize: 14, color: _T.placeholder),
              style: const TextStyle(fontSize: 14, color: _T.ink),
              keyboardType: keyboardType,
              decoration: null,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onChanged: onChanged,
            ),
          ),
          if (suffix != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(suffix!,
                  style: const TextStyle(fontSize: 14, color: _T.sub)),
            ),
        ],
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final bool selected;
  final double height;
  final VoidCallback? onTap;
  final Widget child;

  const _SelectableTile({
    required this.selected,
    required this.height,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _T.selectedBg : CupertinoColors.white,
          border: Border.all(
              color: selected ? _T.primary : _T.border, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class _ChipTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChipTile(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _T.selectedBg : CupertinoColors.white,
          border: Border.all(
              color: selected ? _T.primary : _T.border, width: 2),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? _T.primary : _T.ink,
          ),
        ),
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
      final right =
          i + 1 < children.length ? children[i + 1] : const SizedBox();
      rows.add(Padding(
        padding:
            EdgeInsets.only(bottom: i + 2 < children.length ? 8 : 0),
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
