import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/onboarding_provider.dart';
import '../../../core/theme.dart';
import '../../components/onboarding/step_indicator.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _research = false;
  bool _cohortShare = true;
  bool _marketing = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = ref.read(onboardingProvider);
    _research = s.consentResearch;
    _cohortShare = s.consentCohortShare;
    _marketing = s.consentMarketing;
  }

  Future<void> _onContinue() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setConsent(
      research: _research,
      cohortShare: _cohortShare,
      marketing: _marketing,
    );
    try {
      await notifier.commit();
      if (mounted) context.go('/onboarding/activation-gate');
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _error = 'Couldn\'t save your onboarding: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
          onPressed: () => context.go('/onboarding/baseline'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepIndicator(step: 4),
              const SizedBox(height: 20),
              const Text('Your data, your choice', style: AppText.displayLg),
              const SizedBox(height: 6),
              const Text(
                'You can change these any time from Profile → Data & Privacy.',
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _ConsentTile(
                        title: 'Cohort comparison',
                        body:
                            'Let us include your anonymized outcomes in the '
                            'cohort that other users compare themselves to. '
                            'Cohorts smaller than 20 people are never shown.',
                        value: _cohortShare,
                        onChanged: (v) => setState(() => _cohortShare = v),
                      ),
                      const SizedBox(height: 12),
                      _ConsentTile(
                        title: 'Research',
                        body:
                            'Allow de-identified data to be used in '
                            'aggregated GLP-1 outcomes research published by '
                            'Lokahi. No personal identifiers leave the app.',
                        value: _research,
                        onChanged: (v) => setState(() => _research = v),
                      ),
                      const SizedBox(height: 12),
                      _ConsentTile(
                        title: 'Product updates',
                        body:
                            'Email me occasionally about new features and '
                            'study results. No clinical or marketing partner '
                            'sharing.',
                        value: _marketing,
                        onChanged: (v) => setState(() => _marketing = v),
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
                onPressed: _busy ? null : _onContinue,
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
                    : const Text('Save and continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String body;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.title),
                const SizedBox(height: 4),
                Text(body, style: AppText.bodyMuted),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            activeThumbColor: AppColors.darkTeal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
