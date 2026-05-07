// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BgDecorationPainter extends CustomPainter {
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

    final topRightDots = [
      Offset(w * 0.72, h * 0.04),
      Offset(w * 0.82, h * 0.035),
      Offset(w * 0.91, h * 0.055),
      Offset(w * 0.78, h * 0.065),
    ];

    for (final d in topRightDots) {
      canvas.drawCircle(d, 5, dotPaint);
    }

    final arcPath = Path()
      ..moveTo(w * 0.55, h * 0.10)
      ..quadraticBezierTo(w * 0.80, h * 0.13, w, h * 0.09);
    canvas.drawPath(arcPath, linePaint);

    final arcPath2 = Path()
      ..moveTo(w * 0.60, h * 0.125)
      ..quadraticBezierTo(w * 0.82, h * 0.155, w, h * 0.115);
    canvas.drawPath(
      arcPath2,
      Paint()
        ..color = kDot.withOpacity(0.3)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final bottomDots = [
      Offset(w * 0.05, h * 0.80),
      Offset(w * 0.10, h * 0.83),
      Offset(w * 0.03, h * 0.86),
      Offset(w * 0.88, h * 0.84),
      Offset(w * 0.93, h * 0.87),
    ];

    final bottomDotPaint = Paint()..color = kDot.withOpacity(0.45);

    for (final d in bottomDots) {
      canvas.drawCircle(d, 5, bottomDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BgDecorationPainter oldDelegate) => false;
}