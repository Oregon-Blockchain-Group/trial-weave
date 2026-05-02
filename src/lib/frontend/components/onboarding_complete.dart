import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, IconData;

// ---------------------------------------------------------------------------
// Domain
// ---------------------------------------------------------------------------

class _MatchFactor {
  final IconData icon;
  final String label;
  final String detail;
  const _MatchFactor({required this.icon, required this.label, required this.detail});
}

const _matchFactors = <_MatchFactor>[
  _MatchFactor(
    icon: Icons.medication_outlined,
    label: 'Same medication & dose stage',
    detail: 'Semaglutide, weeks 0–8 of titration',
  ),
  _MatchFactor(
    icon: Icons.person_outline,
    label: 'Similar age & sex',
    detail: 'Female, 30–39',
  ),
  _MatchFactor(
    icon: Icons.monitor_weight_outlined,
    label: 'Comparable starting BMI',
    detail: 'BMI 28–32 at start of therapy',
  ),
  _MatchFactor(
    icon: Icons.favorite_border,
    label: 'Overlapping health history',
    detail: 'PCOS · no GI or pancreatitis history',
  ),
];

// ---------------------------------------------------------------------------
// Theme tokens
// ---------------------------------------------------------------------------

class _T {
  static const primary = Color(0xFF234A67);
  static const tintBg = Color(0xFFE8F4F8);
  static const ink = Color(0xFF1C1C1C);
  static const sub = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const bgScroll = Color(0xFFFAFAFA);
  static const noteAmber = Color(0xFFB45309);
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OnboardingCompleteScreen extends StatelessWidget {
  final VoidCallback? onGoToDashboard;

  const OnboardingCompleteScreen({super.key, this.onGoToDashboard});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Column(
          children: [
            const _ProgressBar(step: 5, totalSteps: 5),
            Expanded(
              child: Container(
                color: _T.bgScroll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _hero(),
                      const SizedBox(height: 16),
                      _cohortCard(),
                      const SizedBox(height: 16),
                      _previewCard(),
                    ],
                  ),
                ),
              ),
            ),
            _GoBar(onPressed: onGoToDashboard),
          ],
        ),
      ),
    );
  }

  Widget _hero() => Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _T.tintBg,
            ),
            child: const Icon(Icons.check, size: 32, color: _T.primary),
          ),
          const SizedBox(height: 16),
          const Text("You're all set!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _T.ink)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 14, color: _T.sub, height: 1.5),
                children: [
                  TextSpan(text: 'We matched you to '),
                  TextSpan(
                      text: '1,247',
                      style: TextStyle(
                          color: _T.primary, fontWeight: FontWeight.w700)),
                  TextSpan(
                      text:
                          ' people on Trial Weave whose profile lines up with yours.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );

  Widget _cohortCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          border: Border.all(color: _T.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HOW WE BUILT YOUR COHORT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: _T.primary,
                )),
            const SizedBox(height: 12),
            const Text(
              'We grouped you with members who share the four factors that most shape GLP-1 outcomes. Stricter matches as you log more.',
              style: TextStyle(fontSize: 12, color: _T.sub, height: 1.5),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < _matchFactors.length; i++) ...[
              _factorRow(_matchFactors[i]),
              if (i < _matchFactors.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            Container(height: 1, color: _T.border),
            const SizedBox(height: 12),
            const Text(
              "Race, ethnicity, and other demographics are stored privately and used only when you opt in to a sub-analysis — they don't drive your default cohort.",
              style: TextStyle(fontSize: 11, color: _T.sub, height: 1.5),
            ),
          ],
        ),
      );

  Widget _factorRow(_MatchFactor f) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _T.tintBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(f.icon, size: 18, color: _T.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500, color: _T.ink)),
                const SizedBox(height: 2),
                Text(f.detail,
                    style: const TextStyle(
                        fontSize: 12, color: _T.sub, height: 1.4)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 8),
            child: Icon(Icons.check, size: 16, color: _T.primary),
          ),
        ],
      );

  Widget _previewCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _T.tintBg,
          border: Border.all(color: _T.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('YOUR COHORT PREVIEW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: _T.primary,
                )),
            SizedBox(height: 6),
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 14, color: _T.ink, height: 1.5),
                children: [
                  TextSpan(text: 'At '),
                  TextSpan(
                      text: '12 weeks',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(
                      text:
                          ', members matched to you reported a median weight change of '),
                  TextSpan(
                      text: '−11.8 lb',
                      style: TextStyle(
                          color: _T.primary, fontWeight: FontWeight.w700)),
                  TextSpan(
                      text:
                          ' (middle 80% range: −4 to −21 lb). Your own number replaces this once you start logging weight.'),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text('ILLUSTRATIVE DEMO DATA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _T.noteAmber,
                )),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// Shared bits
// ---------------------------------------------------------------------------

class _ProgressBar extends StatelessWidget {
  final int step;
  final int totalSteps;
  const _ProgressBar({required this.step, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Row(
        children: [
          // No back button on the completion screen.
          const SizedBox(width: 36),
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

class _GoBar extends StatelessWidget {
  final VoidCallback? onPressed;
  const _GoBar({this.onPressed});

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
          borderRadius: BorderRadius.circular(12),
          onPressed: onPressed,
          child: const Text('Go to my dashboard',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.white)),
        ),
      ),
    );
  }
}
