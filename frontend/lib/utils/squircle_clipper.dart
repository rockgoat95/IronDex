import 'package:flutter/material.dart';

class SquircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final r = 20.0; // 둥글기 조절

    final path = Path()
      ..moveTo(r, 0)
      ..quadraticBezierTo(0, 0, 0, r)
      ..lineTo(0, height - r)
      ..quadraticBezierTo(0, height, r, height)
      ..lineTo(width - r, height)
      ..quadraticBezierTo(width, height, width, height - r)
      ..lineTo(width, r)
      ..quadraticBezierTo(width, 0, width - r, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
