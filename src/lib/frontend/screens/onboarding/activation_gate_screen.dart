import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/onboarding_provider.dart';
import '../../../backend/providers/repositories_providers.dart';
import '../../../core/theme.dart';

/// Final step after the 4-step wizard: confirms the User has taken their
/// first dose. Logging the first dose anchors every subsequent measurement to
/// a known start date.
class ActivationGateScreen extends ConsumerStatefulWidget {
  const ActivationGateScreen({super.key});

  @override
  ConsumerState<ActivationGateScreen> createState() =>
      _ActivationGateScreenState();
}

class _ActivationGateScreenState extends ConsumerState<ActivationGateScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _logFirstDose() async {
    final regimen = ref.read(onboardingProvider).committedRegimen;
    if (regimen == null) {
      setState(
        () => _error =
            'No active regimen — restart onboarding from Profile → Regimen.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(doseLogsRepositoryProvider).log(regimenId: regimen.id);
      if (mounted) context.go('/home');
    } on Exception catch (e) {
      if (mounted) setState(() => _error = 'Couldn\'t log the first dose: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _skipForNow() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final regimen = ref.watch(onboardingProvider).committedRegimen;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(
                child: Icon(
                  Icons.verified,
                  size: 64,
                  color: AppColors.darkTeal,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Have you taken your first dose?',
                style: AppText.displayLg,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                regimen != null
                    ? 'We\'ll log it now and use it as the start of your '
                          '${regimen.brand} regimen.'
                    : 'We\'ll log it now and use it as your regimen start date.',
                style: AppText.bodyMuted,
                textAlign: TextAlign.center,
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
                onPressed: _busy ? null : _logFirstDose,
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
                    : const Text("Yes — log it now"),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy ? null : _skipForNow,
                child: const Text("Not yet — I'll log it later"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
