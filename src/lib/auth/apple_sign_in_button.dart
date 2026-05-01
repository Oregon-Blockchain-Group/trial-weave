import 'package:flutter/material.dart';

/// Sign in with Apple button.
///
/// Visual spec from the wireframe:
///   - Full-width, height 50, radius 12
///   - Black fill, white Apple glyph + label "Continue with Apple"
///   - Inter 600, 14px
///
/// Wire [onPressed] to your sign-in-with-apple flow (e.g. the
/// `sign_in_with_apple` package). After a successful sign-in, persist the
/// resulting credential token in secure storage so subsequent app opens can
/// auto-login without showing the welcome screen.
class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.black.withOpacity(0.6),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _AppleGlyph(size: 16),
                  SizedBox(width: 10),
                  Text(
                    'Continue with Apple',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Inline Apple logo glyph drawn with a custom painter so the component has
/// no external asset dependency.
class _AppleGlyph extends StatelessWidget {
  const _AppleGlyph({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AppleGlyphPainter()),
    );
  }
}

class _AppleGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Body of the apple — two overlapping ovals make the classic bitten shape.
    final body = Path()
      ..addOval(Rect.fromLTWH(w * 0.10, h * 0.25, w * 0.85, h * 0.70));

    // Bite — subtract a circle on the right edge.
    final bite = Path()
      ..addOval(Rect.fromLTWH(w * 0.78, h * 0.40, w * 0.30, h * 0.30));
    final apple = Path.combine(PathOperation.difference, body, bite);

    // Stem leaf
    final leaf = Path()
      ..moveTo(w * 0.55, h * 0.18)
      ..quadraticBezierTo(w * 0.65, h * 0.05, w * 0.78, h * 0.18)
      ..quadraticBezierTo(w * 0.65, h * 0.30, w * 0.55, h * 0.18)
      ..close();

    canvas.drawPath(apple, paint);
    canvas.drawPath(leaf, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
