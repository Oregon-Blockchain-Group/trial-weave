import 'package:flutter/cupertino.dart';

// ---------------------------------------------------------------------------
// Domain (mirrors wireframe-v1 src/data/factors.ts → BASELINE_FACTORS)
// ---------------------------------------------------------------------------

class _Factor {
  final String key;
  final String label;
  final String low;
  final String high;
  const _Factor({
    required this.key,
    required this.label,
    required this.low,
    required this.high,
  });
}

const _baselineFactors = <_Factor>[
  _Factor(key: 'energy', label: 'Energy', low: 'Drained', high: 'Energized'),
  _Factor(key: 'appetite', label: 'Appetite', low: 'Slight', high: 'Strong'),
  _Factor(key: 'mood', label: 'Mood', low: 'Glum', high: 'Cheerful'),
  _Factor(key: 'sleep', label: 'Sleep', low: 'Restless', high: 'Restful'),
  _Factor(key: 'activity', label: 'Activity', low: 'Sedentary', high: 'Active'),
  _Factor(key: 'digestion', label: 'Stomach discomfort', low: 'Mild', high: 'Severe'),
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

class OnboardingBaselinesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const OnboardingBaselinesScreen({super.key, this.onBack, this.onContinue});

  @override
  State<OnboardingBaselinesScreen> createState() => _OnboardingBaselinesScreenState();
}

class _OnboardingBaselinesScreenState extends State<OnboardingBaselinesScreen> {
  final Map<String, int> _ratings = {};

  bool get _canContinue =>
      _baselineFactors.every((f) => _ratings[f.key] != null);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Column(
          children: [
            _ProgressBar(step: 3, totalSteps: 5, onBack: widget.onBack),
            _Header(),
            Expanded(
              child: Container(
                color: _T.bgScroll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < _baselineFactors.length; i++) ...[
                        _factorRow(_baselineFactors[i]),
                        if (i < _baselineFactors.length - 1)
                          const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _ContinueBar(
              enabled: _canContinue,
              label: 'Continue',
              onPressed: widget.onContinue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _factorRow(_Factor factor) {
    final selected = _ratings[factor.key];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(factor.label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: _T.ink)),
        ),
        Row(
          children: [
            for (var n = 1; n <= 5; n++) ...[
              Expanded(child: _ratingButton(factor.key, n, selected == n)),
              if (n < 5) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(factor.low,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: _T.primary,
                  )),
            ),
            Expanded(
              child: Text(factor.high,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: _T.primary,
                  )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ratingButton(String key, int n, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _ratings[key] = n),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _T.primary : CupertinoColors.white,
          border: Border.all(
            color: selected ? _T.primary : _T.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$n',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: selected ? CupertinoColors.white : _T.ink,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared bits (kept private; mirrors onboarding_medication.dart style)
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
          Text('Set your baselines',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _T.ink)),
          SizedBox(height: 6),
          Text('Rate each factor 1–5 so we can track how things change over time.',
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
