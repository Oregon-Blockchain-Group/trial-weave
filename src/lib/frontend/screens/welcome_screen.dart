import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';

/// Marketing splash. Routes to /sign-up (primary CTA) or /sign-in
/// (secondary "I have an account" link). Auth itself happens on those
/// screens — welcome doesn't trigger Apple/Google directly.
///
/// Visual continuity from the prior OAuth-first design:
///   - Soft white-to-tint vertical gradient background
///   - Lokahi wordmark image
///   - Headline: "See what's working for people like you" — 28/800/-0.02em
///   - Body copy in muted gray
///   - "Get started" button + "I already have an account" text link
///   - Disclaimer footer
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
            Positioned(
              top: 60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.darkTeal.withValues(alpha: 0.08),
                      AppColors.darkTeal.withValues(alpha: 0.0),
                    ],
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
                    Image.asset(
                      'assets/lokahi_logo.webp',
                      width: 260,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "See what's working\nfor people like you",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        height: 1.2,
                        letterSpacing: -0.56,
                        color: AppColors.inkBlack,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/sign-up'),
                        child: const Text('Get started'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/sign-in'),
                      child: const Text('I already have an account'),
                    ),
                    const SizedBox(height: 14),
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
                          color: AppColors.muted,
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