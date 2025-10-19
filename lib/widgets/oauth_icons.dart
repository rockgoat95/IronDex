import 'package:flutter/material.dart';

class KakaoIcon extends StatelessWidget {
  const KakaoIcon({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.black;
    return CustomPaint(
      size: Size.square(size),
      painter: _KakaoIconPainter(effectiveColor),
    );
  }
}

class NaverIcon extends StatelessWidget {
  const NaverIcon({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.black;
    return CustomPaint(
      size: Size.square(size),
      painter: _NaverIconPainter(effectiveColor),
    );
  }
}

class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _GoogleIconPainter(),
    );
  }
}

class _KakaoIconPainter extends CustomPainter {
  _KakaoIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 24;
    final scaleY = size.height / 24;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    final path = Path()
      ..moveTo(12, 3)
      ..cubicTo(6.477, 3, 2, 6.477, 2, 10.8)
      ..cubicTo(2, 13.386, 3.521, 15.685, 5.865, 17.088)
      ..lineTo(4.891, 20.715)
      ..cubicTo(4.814, 21.015, 5.14, 21.246, 5.399, 21.066)
      ..lineTo(9.652, 18.332)
      ..cubicTo(10.408, 18.444, 11.195, 18.6, 12, 18.6)
      ..cubicTo(17.523, 18.6, 22, 15.123, 22, 10.8)
      ..cubicTo(22, 6.477, 17.523, 3, 12, 3)
      ..close();

    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintFill);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KakaoIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _NaverIconPainter extends CustomPainter {
  _NaverIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 24;
    final scaleY = size.height / 24;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    final path = Path()
      ..moveTo(16.273, 12.845)
      ..lineTo(7.376, 0)
      ..lineTo(0, 0)
      ..lineTo(0, 24)
      ..lineTo(7.727, 24)
      ..lineTo(7.727, 11.155)
      ..lineTo(16.624, 24)
      ..lineTo(24, 24)
      ..lineTo(24, 0)
      ..lineTo(16.273, 0)
      ..lineTo(16.273, 12.845)
      ..close();

    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintFill);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NaverIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _GoogleIconPainter extends CustomPainter {
  const _GoogleIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 24;
    final scaleY = size.height / 24;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    final pathBlue = Path()
      ..moveTo(22.56, 12.25)
      ..cubicTo(22.56, 11.47, 22.49, 10.72, 22.36, 10)
      ..lineTo(12, 10)
      ..lineTo(12, 14.255)
      ..lineTo(17.92, 14.255)
      ..cubicTo(17.665, 15.63, 16.89, 16.795, 15.725, 17.575)
      ..lineTo(15.725, 20.335)
      ..lineTo(19.28, 20.335)
      ..cubicTo(21.36, 18.42, 22.56, 15.6, 22.56, 12.25)
      ..close();

    final pathGreen = Path()
      ..moveTo(12, 23)
      ..cubicTo(14.97, 23, 17.46, 22.015, 19.28, 20.335)
      ..lineTo(15.725, 17.575)
      ..cubicTo(14.74, 18.235, 13.48, 18.625, 12, 18.625)
      ..cubicTo(9.13498, 18.625, 6.70998, 16.69, 5.84498, 14.09)
      ..lineTo(2.16998, 14.09)
      ..lineTo(2.16998, 16.94)
      ..cubicTo(3.97998, 20.535, 7.69998, 23, 12, 23)
      ..close();

    final pathYellow = Path()
      ..moveTo(5.845, 14.09)
      ..cubicTo(5.625, 13.43, 5.5, 12.725, 5.5, 12)
      ..cubicTo(5.5, 11.275, 5.625, 10.57, 5.845, 9.91)
      ..lineTo(5.845, 7.06)
      ..lineTo(2.17, 7.06)
      ..cubicTo(1.4, 8.59, 1, 10.245, 1, 12)
      ..cubicTo(1, 13.755, 1.4, 15.41, 2.17, 16.94)
      ..lineTo(5.845, 14.09)
      ..close();

    final pathRed = Path()
      ..moveTo(12, 5.375)
      ..cubicTo(13.615, 5.375, 15.065, 5.93, 16.205, 7.02)
      ..lineTo(19.36, 3.865)
      ..cubicTo(17.455, 2.09, 14.965, 1, 12, 1)
      ..cubicTo(7.69998, 1, 3.97998, 3.465, 2.16998, 7.06)
      ..lineTo(5.84498, 9.91)
      ..cubicTo(6.70998, 7.31, 9.13498, 5.375, 12, 5.375)
      ..close();

    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pathBlue, paintBlue);

    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pathGreen, paintGreen);

    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pathYellow, paintYellow);

    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pathRed, paintRed);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GoogleIconPainter oldDelegate) => false;
}
