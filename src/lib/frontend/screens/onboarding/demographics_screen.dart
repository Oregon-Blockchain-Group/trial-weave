import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/onboarding_provider.dart';
import '../../components/onboarding/continue_bar.dart';
import '../../components/onboarding/onboarding_inputs.dart';
import '../../components/onboarding/onboarding_theme.dart';
import '../../components/onboarding/progress_bar.dart';

const _genderOptions = <_Option>[
  _Option(value: 'female', label: 'Female'),
  _Option(value: 'male', label: 'Male'),
  _Option(value: 'other', label: 'Other'),
  _Option(value: 'prefer_not_to_say', label: 'Prefer not to say'),
];

const _raceOptions = <String>[
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

const _comorbidities = <String>[
  'Type 2 diabetes',
  'PCOS',
  'Hypertension',
  'Cardiovascular disease',
  'GI / IBS history',
  'Pancreatitis history',
  'Thyroid disease',
  'None',
];

class _Option {
  const _Option({required this.value, required this.label});
  final String value;
  final String label;
}

class DemographicsScreen extends ConsumerStatefulWidget {
  const DemographicsScreen({super.key});

  @override
  ConsumerState<DemographicsScreen> createState() => _DemographicsScreenState();
}

class _DemographicsScreenState extends ConsumerState<DemographicsScreen> {
  final _ageController = TextEditingController();
  final _heightFtController = TextEditingController();
  final _heightInController = TextEditingController();
  final _weightController = TextEditingController();

  String _sex = '';
  List<String> _races = [];
  List<String> _otherConditions = [];

  @override
  void initState() {
    super.initState();
    final s = ref.read(onboardingProvider);
    if (s.age != null) _ageController.text = '${s.age}';
    if (s.heightFeet != null) _heightFtController.text = '${s.heightFeet}';
    if (s.heightInches != null) _heightInController.text = '${s.heightInches}';
    if (s.startingWeightLb != null) {
      _weightController.text = '${s.startingWeightLb}';
    }
    _sex = s.sex ?? '';
    _races = List<String>.from(s.races);
    _otherConditions = List<String>.from(s.otherConditions);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    final age = int.tryParse(_ageController.text);
    final ft = int.tryParse(_heightFtController.text);
    final inches = int.tryParse(_heightInController.text);
    final lb = double.tryParse(_weightController.text);
    return age != null &&
        age >= 13 &&
        age <= 100 &&
        _sex.isNotEmpty &&
        _races.isNotEmpty &&
        ft != null &&
        ft >= 3 &&
        ft <= 8 &&
        inches != null &&
        inches >= 0 &&
        inches <= 11 &&
        lb != null &&
        lb > 0 &&
        _otherConditions.isNotEmpty;
  }

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

  void _toggleCondition(String option) {
    setState(() {
      if (option == 'None') {
        _otherConditions =
            _otherConditions.contains(option) ? [] : [option];
        return;
      }
      final next = _otherConditions.where((c) => c != 'None').toList();
      if (next.contains(option)) {
        next.remove(option);
      } else {
        next.add(option);
      }
      _otherConditions = next;
    });
  }

  void _onContinue() {
    ref
        .read(onboardingProvider.notifier)
        .setDemographics(
          age: int.parse(_ageController.text),
          sex: _sex,
          races: _races,
          otherConditions: _otherConditions,
          heightFeet: int.parse(_heightFtController.text),
          heightInches: int.parse(_heightInController.text),
          startingWeightLb: double.parse(_weightController.text),
        );
    context.go('/onboarding/medication');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Column(
            children: [
              const OnboardingProgressBar(step: 1, totalSteps: 5),
              const _Header(),
              Expanded(
                child: Container(
                  color: OnboardingColors.bgScroll,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OnboardingSection(
                          label: 'Age',
                          child: OnboardingTextField(
                            controller: _ageController,
                            placeholder: 'e.g., 34',
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 20),
                        OnboardingSection(
                          label: 'Gender',
                          child: OnboardingGrid2(
                            children: _genderOptions
                                .map(
                                  (o) => OnboardingSelectableTile(
                                    selected: _sex == o.value,
                                    onTap: () =>
                                        setState(() => _sex = o.value),
                                    child: Text(
                                      o.label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: _sex == o.value
                                            ? OnboardingColors.primary
                                            : OnboardingColors.ink,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        OnboardingSection(
                          label: 'Race / Ethnicity',
                          trailing: const Text(
                            'Select all that apply',
                            style: TextStyle(
                              fontSize: 12,
                              color: OnboardingColors.sub,
                            ),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _raceOptions
                                .map(
                                  (o) => OnboardingChipTile(
                                    label: o,
                                    selected: _races.contains(o),
                                    onTap: () => _toggleRace(o),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        OnboardingSection(
                          label: 'Starting height',
                          child: Row(
                            children: [
                              Expanded(
                                child: OnboardingTextField(
                                  controller: _heightFtController,
                                  placeholder: '5',
                                  keyboardType: TextInputType.number,
                                  suffix: 'ft',
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OnboardingTextField(
                                  controller: _heightInController,
                                  placeholder: '8',
                                  keyboardType: TextInputType.number,
                                  suffix: 'in',
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        OnboardingSection(
                          label: 'Starting weight',
                          child: OnboardingTextField(
                            controller: _weightController,
                            placeholder: '185',
                            keyboardType: TextInputType.number,
                            suffix: 'lbs',
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 20),
                        OnboardingSection(
                          label: 'Health history',
                          trailing: const Text(
                            'Select all that apply',
                            style: TextStyle(
                              fontSize: 12,
                              color: OnboardingColors.sub,
                            ),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _comorbidities
                                .map(
                                  (o) => OnboardingChipTile(
                                    label: o,
                                    selected: _otherConditions.contains(o),
                                    onTap: () => _toggleCondition(o),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
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
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: OnboardingColors.ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Demographics help us compare your progress with people like you.',
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
