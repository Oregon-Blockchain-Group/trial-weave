import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

// ---------------------------------------------------------------------------
// Domain
// ---------------------------------------------------------------------------

class _RequiredItem {
  final String key;
  final String title;
  final String body;
  final String link;
  const _RequiredItem({
    required this.key,
    required this.title,
    required this.body,
    required this.link,
  });
}

class _OptionalItem {
  final String key;
  final String title;
  final String body;
  final bool defaultOn;
  const _OptionalItem({
    required this.key,
    required this.title,
    required this.body,
    required this.defaultOn,
  });
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
    body: 'Receive product updates, surveys, and educational content by email.',
    defaultOn: false,
  ),
];

// ---------------------------------------------------------------------------
// Theme tokens
// ---------------------------------------------------------------------------

class _T {
  static const primary = Color(0xFF234A67);
  static const ink = Color(0xFF1C1C1C);
  static const sub = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const bgScroll = Color(0xFFFAFAFA);
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OnboardingConsentScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const OnboardingConsentScreen({super.key, this.onBack, this.onContinue});

  @override
  State<OnboardingConsentScreen> createState() => _OnboardingConsentScreenState();
}

class _OnboardingConsentScreenState extends State<OnboardingConsentScreen> {
  final Map<String, bool> _requiredChecked = {
    for (final r in _required) r.key: false,
  };
  late final Map<String, bool> _optionalOn = {
    for (final o in _optional) o.key: o.defaultOn,
  };

  bool get _canContinue => _required.every((r) => _requiredChecked[r.key]!);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Column(
          children: [
            _ProgressBar(step: 4, totalSteps: 5, onBack: widget.onBack),
            _Header(),
            Expanded(
              child: Container(
                color: _T.bgScroll,
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
                        style: TextStyle(fontSize: 11, color: _T.sub, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _ContinueBar(
              enabled: _canContinue,
              label: 'Agree & continue',
              onPressed: widget.onContinue,
            ),
          ],
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
          color: _T.sub,
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
            color: checked ? _T.primary : _T.border,
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
                    color: checked ? _T.primary : CupertinoColors.white,
                    border: Border.all(
                      color: checked ? _T.primary : _T.border,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: checked
                      ? const Icon(Icons.check, size: 14, color: CupertinoColors.white)
                      : null,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _T.ink)),
                      const SizedBox(height: 2),
                      Text(item.body,
                          style: const TextStyle(
                              fontSize: 12, color: _T.sub, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 6),
              child: Text(item.link,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _T.primary,
                      decoration: TextDecoration.underline)),
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
        border: Border.all(color: _T.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _T.ink)),
                const SizedBox(height: 2),
                Text(item.body,
                    style: const TextStyle(
                        fontSize: 12, color: _T.sub, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: on,
            activeTrackColor: _T.primary,
            onChanged: (v) => setState(() => _optionalOn[item.key] = v),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared bits
// ---------------------------------------------------------------------------

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
          Text('Your consent',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _T.ink)),
          SizedBox(height: 6),
          Text('Review and agree before we collect any health information.',
              style: TextStyle(fontSize: 14, color: _T.sub, height: 1.4)),
        ],
      ),
    );
  }
}

class _ContinueBar extends StatelessWidget {
  final bool enabled;
  final String label;
  final VoidCallback? onPressed;
  const _ContinueBar({required this.enabled, required this.label, this.onPressed});

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
          child: Text(label,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.white)),
        ),
      ),
    );
  }
}
