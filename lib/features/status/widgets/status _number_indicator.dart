import 'dart:math';

import 'package:flutter/material.dart';

class StatusAvatar extends StatelessWidget {
  final String imageUrl;
  final int totalStatuses;

  const StatusAvatar({super.key, required this.imageUrl,required this.totalStatuses});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(imageUrl),
        ),
        CustomPaint(
          size: const Size(60, 60), // Adjust as needed
          painter: StatusIndicatorPainter(totalStatuses: totalStatuses, color: Colors.green), // Adjust color as needed
        ),
      ],
    );
  }
}


class StatusIndicatorPainter extends CustomPainter {
  final int totalStatuses;
  final Color color;

  StatusIndicatorPainter({required this.totalStatuses, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    var center = Offset(size.width / 2, size.height / 2);
    var radius = min(size.width / 2, size.height / 2);

    var angle = 2 * pi / totalStatuses;
    var gapAngle = angle / 50; // Adjust this value to change the size of the gap
    var statusAngle = angle - gapAngle;

    for (var i = 0; i < totalStatuses; i++) {
      var startAngle = i * angle;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, statusAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}