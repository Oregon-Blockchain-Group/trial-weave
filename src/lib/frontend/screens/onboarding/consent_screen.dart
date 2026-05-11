import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, MaterialType, Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/providers/onboarding_provider.dart';
import '../../components/onboarding/continue_bar.dart';
import '../../components/onboarding/onboarding_theme.dart';
import '../../components/onboarding/progress_bar.dart';

class _RequiredItem {
  const _RequiredItem({
    required this.key,
    required this.title,
    required this.body,
    required this.link,
  });
  final String key;
  final String title;
  final String body;
  final String link;
}

class _OptionalItem {
  const _OptionalItem({
    required this.key,
    required this.title,
    required this.body,
    required this.defaultOn,
  });
  final String key;
  final String title;
  final String body;
  final bool defaultOn;
}

const _required = <_RequiredItem>[
  _RequiredItem(
    key: 'terms',
    title: 'Terms of Service',
    body: 'I agree to the Terms of Service governing my use of Trial Weave.',
    link: 'View terms',
  ),
  _RequiredItem(
    key: 'privacy',
    title: 'Privacy Policy',
    body:
        'I have read the Privacy Policy describing how my data is collected, stored, and used.',
    link: 'View privacy policy',
  ),
  _RequiredItem(
    key: 'hipaa',
    title: 'HIPAA Authorization',
    body:
        'I authorize Lōkahi Therapeutics to collect, store, and process my health information in compliance with HIPAA.',
    link: 'View HIPAA notice',
  ),
];

const _optional = <_OptionalItem>[
  _OptionalItem(
    key: 'research',
    title: 'Contribute de-identified data to research',
    body:
        'Allow your anonymized outcomes to improve cohort comparisons and clinical insights for others.',
    defaultOn: true,
  ),
  _OptionalItem(
    key: 'sell',
    title: 'Allow sale of my data to third parties',
    body:
        'Permit Lōkahi to sell or share your personal information with third parties for compensation. Off by default — you may opt in if you choose.',
    defaultOn: false,
  ),
  _OptionalItem(
    key: 'marketing',
    title: 'Marketing communications',
    body:
        'Receive product updates, surveys, and educational content by email.',
    defaultOn: false,
  ),
];

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  late Map<String, bool> _requiredChecked;
  late Map<String, bool> _optionalOn;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = ref.read(onboardingProvider);
    _requiredChecked = {
      'terms': s.consentTerms,
      'privacy': s.consentPrivacy,
      'hipaa': s.consentHipaa,
    };
    _optionalOn = {
      'research': s.consentResearch,
      'sell': s.consentSell,
      'marketing': s.consentMarketing,
    };
  }

  bool get _canContinue => _required.every((r) => _requiredChecked[r.key]!);

  Future<void> _onContinue() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setConsent(
      terms: _requiredChecked['terms']!,
      privacy: _requiredChecked['privacy']!,
      hipaa: _requiredChecked['hipaa']!,
      research: _optionalOn['research']!,
      sell: _optionalOn['sell']!,
      marketing: _optionalOn['marketing']!,
    );
    try {
      await notifier.commit();
      if (mounted) context.go('/onboarding/complete');
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _error = 'Couldn\'t save your onboarding: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onBack() => context.go('/onboarding/baseline');

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Column(
            children: [
              OnboardingProgressBar(step: 4, totalSteps: 5, onBack: _onBack),
              const _Header(),
              Expanded(
                child: Container(
                  color: OnboardingColors.bgScroll,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _eyebrow('REQUIRED'),
                        const SizedBox(height: 8),
                        for (final item in _required) ...[
                          _requiredCard(item),
                          const SizedBox(height: 8),
                        ],
                        const SizedBox(height: 12),
                        _eyebrow('OPTIONAL · YOU CONTROL THESE'),
                        const SizedBox(height: 8),
                        for (final item in _optional) ...[
                          _optionalCard(item),
                          const SizedBox(height: 8),
                        ],
                        const SizedBox(height: 8),
                        const Text(
                          "You can change these preferences any time in Profile → Privacy. To delete your account and all associated data, contact privacy@lokahi.health.",
                          style: TextStyle(
                            fontSize: 11,
                            color: OnboardingColors.sub,
                            height: 1.5,
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              border: Border.all(color: const Color(0xFFB91C1C)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Color(0xFF991B1B),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              OnboardingContinueBar(
                enabled: _canContinue && !_busy,
                label: 'Agree & continue',
                onPressed: _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eyebrow(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: OnboardingColors.sub,
    ),
  );

  Widget _requiredCard(_RequiredItem item) {
    final checked = _requiredChecked[item.key]!;
    return GestureDetector(
      onTap: () => setState(() => _requiredChecked[item.key] = !checked),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          border: Border.all(
            color: checked ? OnboardingColors.primary : OnboardingColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2, right: 12),
                  decoration: BoxDecoration(
                    color: checked
                        ? OnboardingColors.primary
                        : CupertinoColors.white,
                    border: Border.all(
                      color: checked
                          ? OnboardingColors.primary
                          : OnboardingColors.border,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: checked
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: CupertinoColors.white,
                        )
                      : null,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: OnboardingColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.body,
                        style: const TextStyle(
                          fontSize: 12,
                          color: OnboardingColors.sub,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 6),
              child: Text(
                item.link,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: OnboardingColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionalCard(_OptionalItem item) {
    final on = _optionalOn[item.key]!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border.all(color: OnboardingColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: OnboardingColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: OnboardingColors.sub,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: on,
            activeTrackColor: OnboardingColors.primary,
            onChanged: (v) => setState(() => _optionalOn[item.key] = v),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your consent',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: OnboardingColors.ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Review and agree before we collect any health information.',
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
