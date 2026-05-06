import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/drug.dart';
import '../../../backend/providers/onboarding_provider.dart';
import '../../../core/theme.dart';
import '../../components/onboarding/step_indicator.dart';

class MedicationScreen extends ConsumerStatefulWidget {
  const MedicationScreen({super.key});

  @override
  ConsumerState<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends ConsumerState<MedicationScreen> {
  Drug? _drug;
  String? _dose;
  String? _frequency;
  String? _indication;
  String? _priorGlp1;
  String? _supply;

  @override
  void initState() {
    super.initState();
    final s = ref.read(onboardingProvider);
    _drug = s.drug;
    _dose = s.dose;
    _frequency = s.frequency;
    _indication = s.indication;
    _priorGlp1 = s.priorGlp1;
    _supply = s.supply;
  }

  bool get _isComplete =>
      _drug != null &&
      _dose != null &&
      _frequency != null &&
      _indication != null &&
      _priorGlp1 != null &&
      _supply != null;

  void _onContinue() {
    if (!_isComplete) return;
    ref
        .read(onboardingProvider.notifier)
        .setMedication(
          drug: _drug!,
          dose: _dose!,
          frequency: _frequency!,
          indication: _indication!,
          priorGlp1: _priorGlp1!,
          supply: _supply!,
        );
    context.go('/onboarding/demographics');
  }

  @override
  Widget build(BuildContext context) {
    final doses = _drug?.doses ?? const <String>[];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepIndicator(step: 1),
              const SizedBox(height: 20),
              const Text('Your medication', style: AppText.displayLg),
              const SizedBox(height: 6),
              const Text(
                'Tell us what you\'re taking. You can switch drugs later '
                'from the Regimen screen.',
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Label('Drug'),
                      DropdownButtonFormField<Drug>(
                        initialValue: _drug,
                        items: [
                          for (final d in kDrugCatalog)
                            DropdownMenuItem(
                              value: d,
                              child: Text('${d.brand} (${d.generic})'),
                            ),
                        ],
                        onChanged: (d) => setState(() {
                          _drug = d;
                          _dose = null;
                          _frequency = d?.defaultFrequency;
                          _indication ??= d?.defaultIndication;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _Label('Dose'),
                      DropdownButtonFormField<String>(
                        initialValue: doses.contains(_dose) ? _dose : null,
                        items: [
                          for (final d in doses)
                            DropdownMenuItem(value: d, child: Text(d)),
                        ],
                        onChanged: (v) => setState(() => _dose = v),
                      ),
                      const SizedBox(height: 16),
                      _Label('Frequency'),
                      DropdownButtonFormField<String>(
                        initialValue: _frequency,
                        items: const [
                          DropdownMenuItem(
                            value: 'weekly',
                            child: Text('Weekly'),
                          ),
                          DropdownMenuItem(
                            value: 'daily',
                            child: Text('Daily'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _frequency = v),
                      ),
                      const SizedBox(height: 16),
                      _Label('Reason for taking it'),
                      DropdownButtonFormField<String>(
                        initialValue: _indication,
                        items: const [
                          DropdownMenuItem(
                            value: 'weight',
                            child: Text('Weight loss'),
                          ),
                          DropdownMenuItem(
                            value: 't2d',
                            child: Text('Type 2 diabetes'),
                          ),
                          DropdownMenuItem(value: 'both', child: Text('Both')),
                        ],
                        onChanged: (v) => setState(() => _indication = v),
                      ),
                      const SizedBox(height: 16),
                      _Label('Have you been on a GLP-1 before?'),
                      DropdownButtonFormField<String>(
                        initialValue: _priorGlp1,
                        items: const [
                          DropdownMenuItem(
                            value: 'naive',
                            child: Text('No, this is my first'),
                          ),
                          DropdownMenuItem(
                            value: 'switched',
                            child: Text('Yes — switched from another'),
                          ),
                          DropdownMenuItem(
                            value: 'restarted',
                            child: Text('Yes — restarted after a break'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _priorGlp1 = v),
                      ),
                      const SizedBox(height: 16),
                      _Label('Source'),
                      DropdownButtonFormField<String>(
                        initialValue: _supply,
                        items: const [
                          DropdownMenuItem(
                            value: 'branded',
                            child: Text('Branded (pharmacy)'),
                          ),
                          DropdownMenuItem(
                            value: 'compounded',
                            child: Text('Compounded'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _supply = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isComplete ? _onContinue : null,
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
