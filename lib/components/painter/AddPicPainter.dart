import 'package:flutter/cupertino.dart';

class AddPicPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {

    double width = size.width / 40;

    var paint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = Color.fromRGBO(232, 234, 235, 1);
    canvas.drawRect(Offset.zero & size, paint);
    
    paint
      ..color = Color.fromRGBO(165, 166, 167, 1)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(size.width / 2, size.height / 3), Offset(size.width / 2, size.height * 2 / 3), paint);
    canvas.drawLine(Offset(size.width / 3, size.height / 2), Offset(size.width * 2 / 3, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}