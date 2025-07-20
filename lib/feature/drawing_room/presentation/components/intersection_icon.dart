import 'package:flutter/material.dart';

class IntersectingCirclesIcon extends StatelessWidget {
  const IntersectingCirclesIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(100, 100),
      painter: _CleanCirclePainter(),
    );
  }
}

class _CleanCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 =
        Paint()
          ..color = Colors.red.withOpacity(0.5)
          ..style = PaintingStyle.fill;

    final paint2 =
        Paint()
          ..color = Colors.green.withOpacity(0.5)
          ..style = PaintingStyle.fill;

    final paint3 =
        Paint()
          ..color = Colors.blue.withOpacity(0.5)
          ..style = PaintingStyle.fill;

    double radius = size.width * 0.25;

    final center1 = Offset(size.width * 0.3, size.height / 2);
    final center2 = Offset(size.width * 0.5, size.height / 2);
    final center3 = Offset(size.width * 0.7, size.height / 2);

    canvas.drawCircle(center1, radius, paint1);
    canvas.drawCircle(center2, radius, paint2);
    canvas.drawCircle(center3, radius, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 =
        Paint()
          ..color = Colors.red.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    final paint2 =
        Paint()
          ..color = Colors.green.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    final paint3 =
        Paint()
          ..color = Colors.blue.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    double radius = size.width * 0.3;

    final center1 = Offset(size.width * 0.33, size.height / 2);
    final center2 = Offset(size.width * 0.5, size.height / 2);
    final center3 = Offset(size.width * 0.67, size.height / 2);

    canvas.drawCircle(center1, radius, paint1);
    canvas.drawCircle(center2, radius, paint2);
    canvas.drawCircle(center3, radius, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
