import 'package:flutter/material.dart';
import 'dart:math' as math;

// ─── Colour palette ────────────────────────────────────────────────────────────
const Color kBackground = Color(0xFFE8D9C8);
const Color kBrown = Color(0xFF8B4513);
const Color kBrownMid = Color(0xFFC4722A);
const Color kBrownLight = Color(0xFFD4956A);
const Color kCardBg = Color(0xFFF5EDE0);
const Color kDot = Color(0xFFC4A882);
const Color kTextDark = Color(0xFF2A1A08);
const Color kTextGrey = Color(0xFF999080);

// ─── Home Screen ───────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _HomeBgPainter(),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),

                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'How are you\nfeeling today?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kBrown,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Mic button with pulse rings
                GestureDetector(
                  onTap: () => setState(() => _isListening = !_isListening),
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: kBrownLight.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Mid ring
                          Transform.scale(
                            scale: _isListening ? _pulse.value : 1.0,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: kBrownLight.withOpacity(0.28),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Inner button
                          Transform.scale(
                            scale: _isListening ? _pulse.value * 0.95 : 1.0,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: kBrown,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: kBrown.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_none_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  _isListening ? 'Listening...' : 'Tap to speak your symptoms',
                  style: const TextStyle(
                    color: kTextDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 28),

                // Divider OR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(color: kDot.withOpacity(0.6), thickness: 1),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: kTextGrey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: kDot.withOpacity(0.6), thickness: 1),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Type symptoms
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    decoration: BoxDecoration(
                      color: kCardBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.keyboard_outlined, color: kTextGrey, size: 24),
                        const SizedBox(width: 14),
                        Text(
                          'Type your symptoms',
                          style: TextStyle(color: kTextGrey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Select symptoms button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BodyMapScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      decoration: BoxDecoration(
                        color: kCardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBrown, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline_rounded,
                              color: kBrown, size: 24),
                          const SizedBox(width: 14),
                          Text(
                            'Select symptoms',
                            style: TextStyle(
                              color: kBrown,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _SacaBottomNav(currentIndex: 0),
    );
  }
}

// ─── Body Map Screen ───────────────────────────────────────────────────────────
class BodyMapScreen extends StatefulWidget {
  const BodyMapScreen({super.key});

  @override
  State<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends State<BodyMapScreen> {
  final Set<String> _selected = {};
  final _searchCtrl = TextEditingController();

  // Body part hit areas (normalized 0-1 relative to body image box)
  static const Map<String, Rect> _bodyParts = {
    'Head': Rect.fromLTWH(0.38, 0.02, 0.24, 0.12),
    'Neck': Rect.fromLTWH(0.42, 0.14, 0.16, 0.06),
    'Chest': Rect.fromLTWH(0.30, 0.20, 0.40, 0.15),
    'Abdomen': Rect.fromLTWH(0.32, 0.35, 0.36, 0.14),
    'Left Arm': Rect.fromLTWH(0.10, 0.20, 0.20, 0.32),
    'Right Arm': Rect.fromLTWH(0.70, 0.20, 0.20, 0.32),
    'Left Leg': Rect.fromLTWH(0.28, 0.55, 0.20, 0.42),
    'Right Leg': Rect.fromLTWH(0.52, 0.55, 0.20, 0.42),
    'Lower Back': Rect.fromLTWH(0.32, 0.48, 0.36, 0.08),
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onBodyTap(TapDownDetails details, BoxConstraints constraints) {
    final size = Size(constraints.maxWidth, constraints.maxHeight);
    final norm = Offset(
      details.localPosition.dx / size.width,
      details.localPosition.dy / size.height,
    );
    for (final entry in _bodyParts.entries) {
      if (entry.value.contains(norm)) {
        setState(() {
          if (_selected.contains(entry.key)) {
            _selected.remove(entry.key);
          } else {
            _selected.add(entry.key);
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _HomeBgPainter(),
          ),
          Column(
            children: [
              // Search bar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: kTextGrey, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Headache',
                              hintStyle: TextStyle(color: kTextGrey),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.fromLTRB(32, 24, 32, 4),
                child: Text(
                  'Where do you feel\npain?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kBrown,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              ),

              const Text(
                'Select the body areas below',
                style: TextStyle(color: kTextDark, fontSize: 15),
              ),

              const SizedBox(height: 16),

              // Selected chips
              if (_selected.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    children: _selected
                        .map((part) => Chip(
                              label: Text(part,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                              backgroundColor: kBrown,
                              deleteIcon: const Icon(Icons.close,
                                  size: 16, color: Colors.white70),
                              onDeleted: () =>
                                  setState(() => _selected.remove(part)),
                            ))
                        .toList(),
                  ),
                ),

              // Body diagram
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapDown: (d) => _onBodyTap(d, constraints),
                        child: CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _BodyFigurePainter(selected: _selected),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const _SacaBottomNav(currentIndex: 0),
    );
  }
}

// ─── Body Figure Painter ───────────────────────────────────────────────────────
class _BodyFigurePainter extends CustomPainter {
  final Set<String> selected;
  _BodyFigurePainter({required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void drawBodyPart(Path path, String partName, Color baseColor) {
      final isSelected = selected.contains(partName);
      final paint = Paint()
        ..color = isSelected ? const Color(0xFFFF6B35) : baseColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      if (isSelected) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawPath(path, borderPaint);
      }
    }

    // ── Head ─────────────────────────────────────────────────────────────────
    final headPath = Path()
      ..addOval(Rect.fromCenter(
          center: Offset(w * 0.50, h * 0.075),
          width: w * 0.22,
          height: h * 0.10));
    drawBodyPart(headPath, 'Head', const Color(0xFFB5622A));

    // ── Neck ─────────────────────────────────────────────────────────────────
    final neckPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.44, h * 0.125, w * 0.12, h * 0.05),
          const Radius.circular(4)));
    drawBodyPart(neckPath, 'Neck', const Color(0xFFA0521E));

    // ── Chest / Torso ─────────────────────────────────────────────────────────
    final chestPath = Path()
      ..moveTo(w * 0.32, h * 0.175)
      ..lineTo(w * 0.68, h * 0.175)
      ..lineTo(w * 0.65, h * 0.38)
      ..quadraticBezierTo(w * 0.50, h * 0.40, w * 0.35, h * 0.38)
      ..close();
    drawBodyPart(chestPath, 'Chest', const Color(0xFF8B3A10));

    // ── Abdomen ───────────────────────────────────────────────────────────────
    final abdPath = Path()
      ..moveTo(w * 0.35, h * 0.38)
      ..quadraticBezierTo(w * 0.50, h * 0.40, w * 0.65, h * 0.38)
      ..lineTo(w * 0.62, h * 0.52)
      ..quadraticBezierTo(w * 0.50, h * 0.54, w * 0.38, h * 0.52)
      ..close();
    drawBodyPart(abdPath, 'Abdomen', const Color(0xFFD4884A));

    // ── Lower Back / Hips ─────────────────────────────────────────────────────
    final hipPath = Path()
      ..moveTo(w * 0.38, h * 0.52)
      ..quadraticBezierTo(w * 0.50, h * 0.54, w * 0.62, h * 0.52)
      ..lineTo(w * 0.63, h * 0.60)
      ..quadraticBezierTo(w * 0.50, h * 0.63, w * 0.37, h * 0.60)
      ..close();
    drawBodyPart(hipPath, 'Lower Back', const Color(0xFFBE6830));

    // ── Left Arm ──────────────────────────────────────────────────────────────
    final leftArmPath = Path()
      ..moveTo(w * 0.32, h * 0.175)
      ..quadraticBezierTo(w * 0.20, h * 0.20, w * 0.16, h * 0.28)
      ..lineTo(w * 0.13, h * 0.52)
      ..quadraticBezierTo(w * 0.14, h * 0.54, w * 0.18, h * 0.52)
      ..lineTo(w * 0.22, h * 0.30)
      ..quadraticBezierTo(w * 0.26, h * 0.22, w * 0.35, h * 0.20)
      ..close();
    drawBodyPart(leftArmPath, 'Left Arm', const Color(0xFFA04820));

    // ── Right Arm ─────────────────────────────────────────────────────────────
    final rightArmPath = Path()
      ..moveTo(w * 0.68, h * 0.175)
      ..quadraticBezierTo(w * 0.80, h * 0.20, w * 0.84, h * 0.28)
      ..lineTo(w * 0.87, h * 0.52)
      ..quadraticBezierTo(w * 0.86, h * 0.54, w * 0.82, h * 0.52)
      ..lineTo(w * 0.78, h * 0.30)
      ..quadraticBezierTo(w * 0.74, h * 0.22, w * 0.65, h * 0.20)
      ..close();
    drawBodyPart(rightArmPath, 'Right Arm', const Color(0xFFA04820));

    // ── Left Hand ─────────────────────────────────────────────────────────────
    final leftHandPath = Path()
      ..addOval(Rect.fromCenter(
          center: Offset(w * 0.155, h * 0.555),
          width: w * 0.10,
          height: h * 0.05));
    drawBodyPart(leftHandPath, 'Left Arm', const Color(0xFF8B3A10));

    // ── Right Hand ────────────────────────────────────────────────────────────
    final rightHandPath = Path()
      ..addOval(Rect.fromCenter(
          center: Offset(w * 0.845, h * 0.555),
          width: w * 0.10,
          height: h * 0.05));
    drawBodyPart(rightHandPath, 'Right Arm', const Color(0xFF8B3A10));

    // ── Left Leg ──────────────────────────────────────────────────────────────
    final leftLegPath = Path()
      ..moveTo(w * 0.37, h * 0.60)
      ..quadraticBezierTo(w * 0.44, h * 0.62, w * 0.48, h * 0.60)
      ..lineTo(w * 0.46, h * 0.88)
      ..quadraticBezierTo(w * 0.44, h * 0.90, w * 0.38, h * 0.88)
      ..lineTo(w * 0.36, h * 0.62)
      ..close();
    drawBodyPart(leftLegPath, 'Left Leg', const Color(0xFF9B4418));

    // ── Right Leg ─────────────────────────────────────────────────────────────
    final rightLegPath = Path()
      ..moveTo(w * 0.52, h * 0.60)
      ..quadraticBezierTo(w * 0.56, h * 0.62, w * 0.63, h * 0.60)
      ..lineTo(w * 0.64, h * 0.62)
      ..lineTo(w * 0.62, h * 0.88)
      ..quadraticBezierTo(w * 0.56, h * 0.90, w * 0.54, h * 0.88)
      ..lineTo(w * 0.52, h * 0.62)
      ..close();
    drawBodyPart(rightLegPath, 'Right Leg', const Color(0xFF9B4418));

    // ── Feet ──────────────────────────────────────────────────────────────────
    final leftFootPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.36, h * 0.88, w * 0.12, h * 0.055),
          const Radius.circular(6)));
    drawBodyPart(leftFootPath, 'Left Leg', const Color(0xFF7A3010));

    final rightFootPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.52, h * 0.88, w * 0.12, h * 0.055),
          const Radius.circular(6)));
    drawBodyPart(rightFootPath, 'Right Leg', const Color(0xFF7A3010));

    // ── Aboriginal stripe lines across body ───────────────────────────────────
    final stripePaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (int i = 0; i < 6; i++) {
      final yOffset = h * (0.20 + i * 0.08);
      final path = Path()
        ..moveTo(w * 0.28, yOffset)
        ..quadraticBezierTo(
            w * 0.50, yOffset + h * 0.03, w * 0.72, yOffset - h * 0.01);
      canvas.drawPath(path, stripePaint);
    }

    // ── Dot spine line ────────────────────────────────────────────────────────
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.55);
    for (int i = 0; i < 14; i++) {
      canvas.drawCircle(
          Offset(w * 0.50, h * (0.18 + i * 0.055)), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_BodyFigurePainter old) => old.selected != selected;
}

// ─── Background Painter ────────────────────────────────────────────────────────
class _HomeBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final dotPaint = Paint()..color = kDot.withOpacity(0.55);
    final linePaint = Paint()
      ..color = kDot.withOpacity(0.4)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-right dots
    for (final d in [
      Offset(w * 0.72, h * 0.035),
      Offset(w * 0.82, h * 0.030),
      Offset(w * 0.90, h * 0.048),
      Offset(w * 0.78, h * 0.058),
    ]) {
      canvas.drawCircle(d, 5, dotPaint);
    }

    // Wavy arcs top right
    final arc1 = Path()
      ..moveTo(w * 0.55, h * 0.07)
      ..quadraticBezierTo(w * 0.78, h * 0.10, w, h * 0.06);
    canvas.drawPath(arc1, linePaint);

    final arc2 = Path()
      ..moveTo(w * 0.58, h * 0.09)
      ..quadraticBezierTo(w * 0.80, h * 0.125, w, h * 0.085);
    canvas.drawPath(arc2, linePaint..color = kDot.withOpacity(0.25));

    // Bottom wavy arcs
    final arc3 = Path()
      ..moveTo(0, h * 0.92)
      ..quadraticBezierTo(w * 0.30, h * 0.90, w * 0.55, h * 0.93);
    canvas.drawPath(arc3, linePaint..color = kDot.withOpacity(0.35));

    final arc4 = Path()
      ..moveTo(0, h * 0.945)
      ..quadraticBezierTo(w * 0.28, h * 0.925, w * 0.52, h * 0.955);
    canvas.drawPath(arc4, linePaint..color = kDot.withOpacity(0.22));

    // Bottom dots
    for (final d in [
      Offset(w * 0.06, h * 0.82),
      Offset(w * 0.12, h * 0.855),
      Offset(w * 0.04, h * 0.875),
      Offset(w * 0.88, h * 0.86),
      Offset(w * 0.94, h * 0.88),
    ]) {
      canvas.drawCircle(d, 5, dotPaint..color = kDot.withOpacity(0.40));
    }
  }

  @override
  bool shouldRepaint(_HomeBgPainter old) => false;
}

// ─── Bottom Navigation Bar ─────────────────────────────────────────────────────
class _SacaBottomNav extends StatelessWidget {
  final int currentIndex;
  const _SacaBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  active: currentIndex == 0),
              _NavItem(
                  icon: Icons.description_outlined,
                  label: 'Results',
                  active: currentIndex == 1),
              _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  active: currentIndex == 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavItem(
      {required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? kBrown : kTextGrey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}