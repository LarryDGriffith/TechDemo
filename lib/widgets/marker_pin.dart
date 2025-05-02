import 'package:flutter/material.dart';

class MarkerPin extends StatelessWidget {
  final Color color;
  final double size;
  final ImageProvider image;

  const MarkerPin({
    super.key,
    required this.color,
    required this.image,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.6,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Pin shape (triangle + circle)
          CustomPaint(
            size: Size(size, size * 1.6),
            painter: _MarkerPinPainter(color),
          ),

          // Image inside the circle
          Positioned(
            top: size * 0.05, // slight nudge down for visual balance
            child: ClipOval(
              child: Image(
                image: image,
                width: size * 0.9,
                height: size * 0.9,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerPinPainter extends CustomPainter {
  final Color color;

  _MarkerPinPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;

    final double circleRadius = size.width / 2;
    final double circleCenterY = circleRadius;

    // Circle head
    canvas.drawCircle(
      Offset(size.width / 2, circleCenterY),
      circleRadius,
      paint,
    );

    // Triangle tail
    final Path trianglePath = Path()
      ..moveTo(0, circleCenterY)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, circleCenterY)
      ..close();

    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
