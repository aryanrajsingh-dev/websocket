import 'package:flutter/material.dart';

class ModeIndicator extends StatelessWidget {
  final String mode;

  const ModeIndicator({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HexagonalBorderPainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        child: Text(
          'MODE: $mode',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class HexagonalBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const cutSize = 15.0;
    final path = Path();
    
    path.moveTo(0, 0);
    path.lineTo(size.width - cutSize, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - cutSize, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
