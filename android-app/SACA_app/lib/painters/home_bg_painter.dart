// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class HomeBgPainter extends CustomPainter {
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

    for (final d in [
      Offset(w * 0.72, h * 0.035),
      Offset(w * 0.82, h * 0.030),
      Offset(w * 0.90, h * 0.048),
      Offset(w * 0.78, h * 0.058),
    ]) {
      canvas.drawCircle(d, 5, dotPaint);
    }

    final arc1 = Path()
      ..moveTo(w * 0.55, h * 0.07)
      ..quadraticBezierTo(w * 0.78, h * 0.10, w, h * 0.06);
    canvas.drawPath(arc1, linePaint);

    final arc2 = Path()
      ..moveTo(w * 0.58, h * 0.09)
      ..quadraticBezierTo(w * 0.80, h * 0.125, w, h * 0.085);

    canvas.drawPath(
      arc2,
      Paint()
        ..color = kDot.withOpacity(0.25)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final arc3 = Path()
      ..moveTo(0, h * 0.92)
      ..quadraticBezierTo(w * 0.30, h * 0.90, w * 0.55, h * 0.93);

    canvas.drawPath(
      arc3,
      Paint()
        ..color = kDot.withOpacity(0.35)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final arc4 = Path()
      ..moveTo(0, h * 0.945)
      ..quadraticBezierTo(w * 0.28, h * 0.925, w * 0.52, h * 0.955);

    canvas.drawPath(
      arc4,
      Paint()
        ..color = kDot.withOpacity(0.22)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (final d in [
      Offset(w * 0.06, h * 0.82),
      Offset(w * 0.12, h * 0.855),
      Offset(w * 0.04, h * 0.875),
      Offset(w * 0.88, h * 0.86),
      Offset(w * 0.94, h * 0.88),
    ]) {
      canvas.drawCircle(
        d,
        5,
        Paint()..color = kDot.withOpacity(0.40),
      );
    }
  }

  @override
  bool shouldRepaint(covariant HomeBgPainter oldDelegate) => false;
}