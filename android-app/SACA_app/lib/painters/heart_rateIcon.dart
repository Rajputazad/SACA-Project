// ignore_for_file: file_names

import 'package:flutter/material.dart';


const Color kBackground = Color(0xFFE8D9C8);
const Color kBrown = Color(0xFF8B4513);
const Color kBrownLight = Color(0xFFD4956A);
const Color kCardBg = Color(0xFFF5EDE0);
const Color kDot = Color(0xFFC4A882);
const Color kTextDark = Color(0xFF2A1A08);
const Color kTextGrey = Color(0xFF999080);
// ─── Heart Rate Icon ───────────────────────────────────────────────────────────
class HeartRateIcon extends StatelessWidget {
  final double size;
  const HeartRateIcon({super.key, required this.size});

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
