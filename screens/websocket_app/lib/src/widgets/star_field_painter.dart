import 'package:flutter/material.dart';

class StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.08);
    final random = DateTime.now().millisecondsSinceEpoch % 10000;

    for (int i = 0; i < 120; i++) {
      final x = (random + i * 37) % size.width;
      final y = (random + i * 53) % size.height;
      final radius = 0.7 + (i % 3) * 0.5;
      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
