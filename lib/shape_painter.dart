import 'package:flutter/material.dart';

class ShapePainterScreen extends StatefulWidget {
  const ShapePainterScreen({Key? key}) : super(key: key);

  @override
  State<ShapePainterScreen> createState() => _ShapePainterScreenState();
}

class _ShapePainterScreenState extends State<ShapePainterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: ShapePainter(),
        child: Container(),
      ),
    );
  }
}



class ShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    Offset startingPoint = Offset(0, size.height / 2);
    Offset endingPoint = Offset(size.width, size.height / 2);

    canvas.drawLine(startingPoint, endingPoint, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}


