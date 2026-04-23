import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:casa_app/select_option.dart';

void main() {
  runApp(const SacaApp());
}

class SacaApp extends StatelessWidget {
  const SacaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SACA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const LanguageScreen(),
    );
  }
}

// ─── Colour palette ────────────────────────────────────────────────────────────
const Color kBackground = Color(0xFFE8D9C8);
const Color kBrown = Color(0xFF8B4513);
const Color kBrownLight = Color(0xFFD4956A);
const Color kCardSelected = Color(0xFFF0E6D8);
const Color kCardUnselected = Color(0xFFF7F0E8);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextGrey = Color(0xFF888888);
const Color kDot = Color(0xFFC4A882);

// ─── Language Selection Screen ─────────────────────────────────────────────────
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  String _selectedLanguage = 'English';
  bool _agreeToShare = true;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            // Decorative background elements
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _BgDecorationPainter(),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 28),

                    // ── Logo ──────────────────────────────────────────────
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: kBrown,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: kBrown.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(child: _HeartRateIcon(size: 38)),
                    ),

                    const SizedBox(height: 12),

                    // ── App name ──────────────────────────────────────────
                    Text(
                      'SACA',
                      style: TextStyle(
                        color: kBrown,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Title ─────────────────────────────────────────────
                    const Text(
                      'Choose language /\nDhäruk nhirrpan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kTextDark,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── English option ────────────────────────────────────
                    _LanguageCard(
                      label: 'English',
                      sublabel: 'Easy to read',
                      icon: Icons.chat_bubble_outline_rounded,
                      isSelected: _selectedLanguage == 'English',
                      onTap: () =>
                          setState(() => _selectedLanguage = 'English'),
                    ),

                    const SizedBox(height: 14),

                    // ── Yolngu option ─────────────────────────────────────
                    _LanguageCard(
                      label: 'Yolngu',
                      sublabel: 'Local language',
                      icon: Icons.people_outline_rounded,
                      isSelected: _selectedLanguage == 'Yolngu',
                      onTap: () => setState(() => _selectedLanguage = 'Yolngu'),
                    ),

                    const SizedBox(height: 36),

                    // ── Consent checkbox ──────────────────────────────────
                    GestureDetector(
                      onTap: () =>
                          setState(() => _agreeToShare = !_agreeToShare),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _agreeToShare
                                  ? kBrown
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _agreeToShare ? kBrown : kBrownLight,
                                width: 2,
                              ),
                            ),
                            child: _agreeToShare
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'I agree to share my health information',
                              style: TextStyle(
                                color: kTextDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Continue button ───────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _agreeToShare
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                );
                                // Navigate to next screen
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrown,
                          disabledBackgroundColor: kBrownLight.withOpacity(0.5),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: kBrown.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded, size: 22),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
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

// ─── Language Card ─────────────────────────────────────────────────────────────
class _LanguageCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? kCardSelected : kCardUnselected,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? kBrown : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? kBrown : const Color(0xFFDDD0C0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : kTextGrey,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: kTextDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sublabel,
                    style: const TextStyle(color: kTextGrey, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? kBrown : const Color(0xFFE0D0BC),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: kBrown.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Heart Rate Icon ───────────────────────────────────────────────────────────
class _HeartRateIcon extends StatelessWidget {
  final double size;
  const _HeartRateIcon({required this.size});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _HeartRatePainter());
}

class _HeartRatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Heart
    final path = Path()
      ..moveTo(w * 0.5, h * 0.78)
      ..cubicTo(w * 0.1, h * 0.55, 0, h * 0.3, w * 0.18, h * 0.18)
      ..cubicTo(w * 0.32, h * 0.06, w * 0.5, h * 0.18, w * 0.5, h * 0.28)
      ..cubicTo(w * 0.5, h * 0.18, w * 0.68, h * 0.06, w * 0.82, h * 0.18)
      ..cubicTo(w, h * 0.3, w * 0.9, h * 0.55, w * 0.5, h * 0.78)
      ..close();
    canvas.drawPath(path, paint);

    // ECG line
    final ecg = Paint()
      ..color = kBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final ecgPath = Path()
      ..moveTo(w * 0.12, h * 0.50)
      ..lineTo(w * 0.28, h * 0.50)
      ..lineTo(w * 0.36, h * 0.34)
      ..lineTo(w * 0.44, h * 0.62)
      ..lineTo(w * 0.52, h * 0.42)
      ..lineTo(w * 0.58, h * 0.50)
      ..lineTo(w * 0.88, h * 0.50);
    canvas.drawPath(ecgPath, ecg);
  }

  @override
  bool shouldRepaint(_HeartRatePainter old) => false;
}

// ─── Background Decoration Painter ────────────────────────────────────────────
class _BgDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final dotPaint = Paint()..color = kDot.withOpacity(0.6);
    final linePaint = Paint()
      ..color = kDot.withOpacity(0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-right dots
    final topRightDots = [
      Offset(w * 0.72, h * 0.04),
      Offset(w * 0.82, h * 0.035),
      Offset(w * 0.91, h * 0.055),
      Offset(w * 0.78, h * 0.065),
    ];
    for (final d in topRightDots) {
      canvas.drawCircle(d, 5, dotPaint);
    }

    // Wavy arc top-right
    final arcPath = Path()
      ..moveTo(w * 0.55, h * 0.10)
      ..quadraticBezierTo(w * 0.80, h * 0.13, w * 1.0, h * 0.09);
    canvas.drawPath(arcPath, linePaint);

    final arcPath2 = Path()
      ..moveTo(w * 0.60, h * 0.125)
      ..quadraticBezierTo(w * 0.82, h * 0.155, w * 1.0, h * 0.115);
    canvas.drawPath(arcPath2, linePaint..color = kDot.withOpacity(0.3));

    // Bottom-left dots
    final bottomDots = [
      Offset(w * 0.05, h * 0.80),
      Offset(w * 0.10, h * 0.83),
      Offset(w * 0.03, h * 0.86),
    ];
    for (final d in bottomDots) {
      canvas.drawCircle(d, 5, dotPaint..color = kDot.withOpacity(0.45));
    }

    // Bottom-right dots
    final br = [Offset(w * 0.88, h * 0.84), Offset(w * 0.93, h * 0.87)];
    for (final d in br) {
      canvas.drawCircle(d, 5, dotPaint..color = kDot.withOpacity(0.45));
    }
  }

  @override
  bool shouldRepaint(_BgDecorationPainter old) => false;
}
