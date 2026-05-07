import 'package:flutter/material.dart';

class BodyFigurePainter extends CustomPainter {
  final Set<String> selected;

  BodyFigurePainter({required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void drawPart(Path path, String name, Color color) {
      final paint = Paint()
        ..color = selected.contains(name)
            ? const Color(0xFFFF6B35)
            : color;

      canvas.drawPath(path, paint);

      if (selected.contains(name)) {
        final border = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawPath(path, border);
      }
    }

    // HEAD
    drawPart(
      Path()
        ..addOval(Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.08),
            width: w * 0.22,
            height: h * 0.1)),
      "Head",
      Colors.brown,
    );

    // CHEST
    drawPart(
      Path()
        ..moveTo(w * 0.3, h * 0.2)
        ..lineTo(w * 0.7, h * 0.2)
        ..lineTo(w * 0.65, h * 0.4)
        ..lineTo(w * 0.35, h * 0.4)
        ..close(),
      "Chest",
      Colors.brown.shade700,
    );

    // LEGS
    drawPart(
      Path()
        ..moveTo(w * 0.4, h * 0.6)
        ..lineTo(w * 0.48, h * 0.9)
        ..lineTo(w * 0.35, h * 0.9)
        ..close(),
      "Left Leg",
      Colors.brown.shade800,
    );

    drawPart(
      Path()
        ..moveTo(w * 0.52, h * 0.6)
        ..lineTo(w * 0.65, h * 0.9)
        ..lineTo(w * 0.52, h * 0.9)
        ..close(),
      "Right Leg",
      Colors.brown.shade800,
    );
  }

  @override
  bool shouldRepaint(covariant BodyFigurePainter oldDelegate) {
    return oldDelegate.selected != selected;
  }
}