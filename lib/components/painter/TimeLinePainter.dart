import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeLinePainter extends CustomPainter {
  TimeLinePainter({@required this.num});

  final int num;

  @override
  void paint(Canvas canvas, Size size) {
    double pos = 5;
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color.fromRGBO(14, 103, 171, 1)
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(10, 5), 5, paint);
    if (num > 1) {
      for (int i = 0; i < num - 1; i++) {
        pos += 5;
        paint
          ..color = Color.fromRGBO(0, 0, 0, 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawLine(Offset(10, pos), Offset(10, pos + 45), paint);
        pos += 50;
        paint
          ..style = PaintingStyle.stroke
          ..color = Color.fromRGBO(14, 103, 171, 1)
          ..strokeWidth = 1.0;
        canvas.drawCircle(Offset(10, pos), 5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}