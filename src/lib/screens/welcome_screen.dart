import 'package:flutter/material.dart';

import '../auth/apple_sign_in_button.dart';
import '../auth/google_sign_in_button.dart';

// Layout B palette — file-scope so they're const-usable inside the State class.
const _teal = Color(0xFF234A67);
const _ink = Color(0xFF1C1C1C);
const _muted = Color(0xFF6B7280);

/// Welcome / sign-in screen.
///
/// Single screen the user sees on first launch. After successful sign-in
/// (Apple or Google), the auth token is persisted to secure storage and the
/// app routes directly to the dashboard on subsequent launches — there is no
/// "I have an account" branch.
///
/// Visual spec from the Layout B wireframe (Wireframe.html § 1.1):
///   - Soft white-to-tint vertical gradient background
///   - 96×96 rounded-square brand glyph ("tw") in deep teal
///   - Headline: "See what's working for people like you" — 28/800/-0.02em
///   - Body copy in muted gray
///   - Two stacked auth buttons at the bottom (Apple, Google)
///   - Disclaimer footer
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.onSignInWithApple,
    required this.onSignInWithGoogle,
  });

  /// Called when the user taps "Continue with Apple". Should perform the
  /// sign-in flow and return when complete (success or cancel).
  final Future<void> Function() onSignInWithApple;

  /// Called when the user taps "Continue with Google".
  final Future<void> Function() onSignInWithGoogle;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _busyApple = false;
  bool _busyGoogle = false;

  Future<void> _onApple() async {
    if (_busyApple || _busyGoogle) return;
    setState(() => _busyApple = true);
    try {
      await widget.onSignInWithApple();
    } finally {
      if (mounted) setState(() => _busyApple = false);
    }
  }

  Future<void> _onGoogle() async {
    if (_busyApple || _busyGoogle) return;
    setState(() => _busyGoogle = true);
    try {
      await widget.onSignInWithGoogle();
    } finally {
      if (mounted) setState(() => _busyGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF7FAFD)],
          ),
        ),
        child: Stack(
          children: [
            // Subtle radial bloom in the upper-right
            Positioned(
              top: 60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_teal.withOpacity(0.08), _teal.withOpacity(0.0)],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Brand mark — Lōkahi Therapeutics logo
                    Image.asset(
                      'assets/lokahi_logo.webp',
                      width: 280,
                      cacheWidth: 840, // 3× for HiDPI / retina sharpness
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(height: 24),
                    // Headline
                    const Text(
                      "See what's working\nfor people like you",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        height: 1.2,
                        letterSpacing: -0.56,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Body
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: const Text(
                        'Track your GLP-1 journey and compare your outcomes '
                        'against a cohort of people matched on demographics, '
                        'conditions, and treatment history.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.5,
                          color: _muted,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Auth buttons
                    AppleSignInButton(onPressed: _onApple, loading: _busyApple),
                    const SizedBox(height: 10),
                    GoogleSignInButton(
                      onPressed: _onGoogle,
                      loading: _busyGoogle,
                    ),
                    const SizedBox(height: 14),
                    // Disclaimer
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: const Text(
                        "We'll keep you signed in on this device. Trial Weave "
                        'is for tracking and education — not a substitute for '
                        'medical advice.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          height: 1.5,
                          color: _muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
