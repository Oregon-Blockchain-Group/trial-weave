import 'package:flutter/material.dart';

/// Continue with Google button.
///
/// Visual spec from the wireframe:
///   - Full-width, height 50, radius 12
///   - White fill, 1.5px hairline border (#e5e7eb)
///   - Multi-color "G" mark + ink label "Continue with Google"
///   - Inter 600, 14px
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
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
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1C1C1C),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF234A67)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _GoogleGlyph(size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Inline Google "G" mark drawn with a custom painter so the component has
/// no external asset dependency. Uses the four official brand colors.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGlyphPainter()),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final inner = r * 0.42;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.45
      ..strokeCap = StrokeCap.butt;

    Path arc(double start, double sweep) {
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78);
      return Path()..addArc(rect, start, sweep);
    }

    // Blue arc — top-right quadrant + into bottom-right (for the "tail")
    canvas.drawPath(arc(-0.26, 1.05), stroke..color = _blue);
    // Green arc — bottom
    canvas.drawPath(arc(0.85, 1.10), stroke..color = _green);
    // Yellow arc — bottom-left
    canvas.drawPath(arc(2.00, 1.10), stroke..color = _yellow);
    // Red arc — top-left
    canvas.drawPath(arc(3.15, 1.10), stroke..color = _red);

    // Horizontal bar on the right side that forms the "G" crossbar.
    final barPaint = Paint()..color = _blue;
    final barRect = Rect.fromLTWH(
      cx + inner * 0.05,
      cy - r * 0.10,
      r * 0.55,
      r * 0.20,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
