import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/models/drug.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';

/// Mirrors onboarding's MedicationScreen but writes directly to the
/// regimens table instead of going through OnboardingNotifier. The active
/// regimen is auto-deactivated by RegimensRepository.startNew.
class SwitchDrugScreen extends ConsumerStatefulWidget {
  const SwitchDrugScreen({super.key});

  @override
  ConsumerState<SwitchDrugScreen> createState() => _SwitchDrugScreenState();
}

class _SwitchDrugScreenState extends ConsumerState<SwitchDrugScreen> {
  Drug? _drug;
  String? _dose;
  String? _frequency;
  String? _indication;
  String? _priorGlp1;
  String? _supply;
  bool _busy = false;
  String? _error;

  bool get _isComplete =>
      _drug != null &&
      _dose != null &&
      _frequency != null &&
      _indication != null &&
      _priorGlp1 != null &&
      _supply != null;

  Future<void> _save() async {
    if (!_isComplete) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(regimensRepositoryProvider)
          .startNew(
            brand: _drug!.brand,
            generic: _drug!.generic,
            dose: _dose,
            form: _drug!.form,
            frequency: _frequency,
            indication: _indication,
            priorGlp1: _priorGlp1,
            supply: _supply,
          );
      ref.invalidate(activeRegimenProvider);
      ref.invalidate(allRegimensProvider);
      if (mounted) context.go('/profile/regimen');
    } on Exception catch (e) {
      if (mounted) setState(() => _error = 'Couldn\'t switch: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doses = _drug?.doses ?? const <String>[];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.inkBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile/regimen'),
        ),
        title: const Text('Switch drug', style: AppText.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Your current regimen ends and a new one starts. Past logs '
                'stay attached to the old regimen.',
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: 16),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: (_isComplete && !_busy) ? _save : null,
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
                    : const Text('Switch to this'),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: AppText.bodyMuted),
  );
}
