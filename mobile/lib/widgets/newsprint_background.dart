import 'package:flutter/material.dart';

import '../theme/newsprint_theme.dart';

class NewsprintBackground extends StatelessWidget {
  const NewsprintBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: NewsprintColors.background),
      child: CustomPaint(painter: _NewsprintTexturePainter(), child: child),
    );
  }
}

class _NewsprintTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = NewsprintColors.ink.withAlpha(10)
      ..style = PaintingStyle.fill;
    for (double y = 2; y < size.height; y += 4) {
      for (double x = 2; x < size.width; x += 4) {
        if ((x + y).round().isEven) {
          canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), dotPaint);
        }
      }
    }

    final linePaint = Paint()
      ..color = NewsprintColors.ink.withAlpha(5)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
