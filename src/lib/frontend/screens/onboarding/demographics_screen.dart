import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/onboarding_provider.dart';
import '../../../core/theme.dart';
import '../../components/onboarding/step_indicator.dart';

class DemographicsScreen extends ConsumerStatefulWidget {
  const DemographicsScreen({super.key});

  @override
  ConsumerState<DemographicsScreen> createState() => _DemographicsScreenState();
}

class _DemographicsScreenState extends ConsumerState<DemographicsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _age = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _heightFt = TextEditingController();
  final _heightIn = TextEditingController();
  final _weight = TextEditingController();
  String? _sex;
  String? _race;

  @override
  void initState() {
    super.initState();
    final s = ref.read(onboardingProvider);
    if (s.age != null) _age.text = '${s.age}';
    if (s.city != null) _city.text = s.city!;
    if (s.stateRegion != null) _state.text = s.stateRegion!;
    if (s.heightFeet != null) _heightFt.text = '${s.heightFeet}';
    if (s.heightInches != null) _heightIn.text = '${s.heightInches}';
    if (s.startingWeightLb != null) _weight.text = '${s.startingWeightLb}';
    _sex = s.sex;
    _race = s.raceEthnicity;
  }

  @override
  void dispose() {
    _age.dispose();
    _city.dispose();
    _state.dispose();
    _heightFt.dispose();
    _heightIn.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_sex == null || _race == null) return;
    ref
        .read(onboardingProvider.notifier)
        .setDemographics(
          age: int.parse(_age.text),
          sex: _sex!,
          raceEthnicity: _race!,
          city: _city.text.trim().isEmpty ? null : _city.text.trim(),
          stateRegion: _state.text.trim().isEmpty ? null : _state.text.trim(),
          heightFeet: int.parse(_heightFt.text),
          heightInches: int.parse(_heightIn.text),
          startingWeightLb: double.parse(_weight.text),
        );
    context.go('/onboarding/baseline');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding/medication'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepIndicator(step: 2),
              const SizedBox(height: 20),
              const Text('About you', style: AppText.displayLg),
              const SizedBox(height: 6),
              const Text(
                'These help us match you with comparable users in the cohort. '
                'City and state are optional.',
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Label('Age'),
                        TextFormField(
                          controller: _age,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 13 || n > 100) {
                              return 'Enter an age between 13 and 100';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _Label('Sex'),
                        DropdownButtonFormField<String>(
                          initialValue: _sex,
                          items: const [
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'intersex',
                              child: Text('Intersex'),
                            ),
                            DropdownMenuItem(
                              value: 'prefer_not_to_say',
                              child: Text('Prefer not to say'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _sex = v),
                        ),
                        const SizedBox(height: 16),
                        _Label('Race / ethnicity'),
                        DropdownButtonFormField<String>(
                          initialValue: _race,
                          items: const [
                            DropdownMenuItem(
                              value: 'asian',
                              child: Text('Asian'),
                            ),
                            DropdownMenuItem(
                              value: 'black',
                              child: Text('Black or African American'),
                            ),
                            DropdownMenuItem(
                              value: 'hispanic',
                              child: Text('Hispanic or Latino'),
                            ),
                            DropdownMenuItem(
                              value: 'native',
                              child: Text('Native American or Alaska Native'),
                            ),
                            DropdownMenuItem(
                              value: 'pacific_islander',
                              child: Text(
                                'Native Hawaiian or Pacific Islander',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'white',
                              child: Text('White'),
                            ),
                            DropdownMenuItem(
                              value: 'multiple',
                              child: Text('Two or more'),
                            ),
                            DropdownMenuItem(
                              value: 'prefer_not_to_say',
                              child: Text('Prefer not to say'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _race = v),
                        ),
                        const SizedBox(height: 16),
                        _Label('Height'),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _heightFt,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'ft',
                                ),
                                validator: (v) {
                                  final n = int.tryParse(v ?? '');
                                  if (n == null || n < 3 || n > 8) {
                                    return '3-8';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _heightIn,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'in',
                                ),
                                validator: (v) {
                                  final n = int.tryParse(v ?? '');
                                  if (n == null || n < 0 || n > 11) {
                                    return '0-11';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _Label('Starting weight (lb)'),
                        TextFormField(
                          controller: _weight,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n <= 0) {
                              return 'Enter a starting weight';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _Label('City (optional)'),
                        TextFormField(controller: _city),
                        const SizedBox(height: 16),
                        _Label('State (optional)'),
                        TextFormField(controller: _state),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _onContinue,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppText.bodyMuted),
    );
  }
}
