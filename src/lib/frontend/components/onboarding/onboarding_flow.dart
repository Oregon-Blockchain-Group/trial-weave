import 'package:flutter/cupertino.dart';

import 'onboarding_baselines.dart';
import 'onboarding_complete.dart';
import 'onboarding_consent.dart';
import 'onboarding_demographics.dart';
import 'onboarding_medication.dart';

enum _Step { demographics, medication, baselines, consent, complete, dashboard }

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  _Step _step = _Step.demographics;

  void _go(_Step s) => setState(() => _step = s);

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _Step.demographics:
        return OnboardingDemographicsScreen(
          onContinue: () => _go(_Step.medication),
        );
      case _Step.medication:
        return OnboardingTwoScreen(
          onBack: () => _go(_Step.demographics),
          onContinue: () => _go(_Step.baselines),
        );
      case _Step.baselines:
        return OnboardingBaselinesScreen(
          onBack: () => _go(_Step.medication),
          onContinue: () => _go(_Step.consent),
        );
      case _Step.consent:
        return OnboardingConsentScreen(
          onBack: () => _go(_Step.baselines),
          onContinue: () => _go(_Step.complete),
        );
      case _Step.complete:
        return OnboardingCompleteScreen(
          onGoToDashboard: () => _go(_Step.dashboard),
        );
      case _Step.dashboard:
        return const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('Trial Weave')),
          child: Center(child: Text('Dashboard goes here')),
        );
    }
  }
}
