import 'package:flutter/material.dart';

class ParkingBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final double opacity;

  ParkingBackgroundPainter({
    required this.primaryColor,
    this.opacity = 0.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = primaryColor.withValues(alpha: opacity * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Background gradient
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withValues(alpha: opacity * 0.1),
        primaryColor.withValues(alpha: opacity * 0.05),
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // Draw parking pattern
    _drawParkingPattern(canvas, size, paint, strokePaint);

    // Draw cars
    _drawCars(canvas, size, paint, strokePaint);

    // Draw parking signs
    _drawParkingSigns(canvas, size, paint, strokePaint);

    // Draw urban elements
    _drawUrbanElements(canvas, size, paint, strokePaint);

    // Draw parking lines
    _drawParkingLines(canvas, size, strokePaint);
  }

  void _drawParkingPattern(
      Canvas canvas, Size size, Paint paint, Paint strokePaint) {
    const patternSize = 80.0;
    final rows = (size.height / patternSize).ceil();
    final cols = (size.width / patternSize).ceil();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final x = col * patternSize;
        final y = row * patternSize;

        // Subtle parking symbol pattern
        final centerX = x + patternSize / 2;
        final centerY = y + patternSize / 2;

        canvas.drawCircle(
          Offset(centerX, centerY),
          patternSize / 3,
          strokePaint..color = primaryColor.withValues(alpha: opacity * 0.1),
        );
      }
    }
  }

  void _drawCars(Canvas canvas, Size size, Paint paint, Paint strokePaint) {
    // Car 1 (top right)
    _drawCar(canvas, Offset(size.width * 0.8, size.height * 0.1), 0.8, paint,
        strokePaint);

    // Car 2 (middle left)
    _drawCar(canvas, Offset(size.width * 0.15, size.height * 0.4), 0.6, paint,
        strokePaint);

    // Car 3 (bottom area)
    _drawCar(canvas, Offset(size.width * 0.7, size.height * 0.7), 0.7, paint,
        strokePaint);

    // Car 4 (bottom left)
    _drawCar(canvas, Offset(size.width * 0.25, size.height * 0.8), 0.5, paint,
        strokePaint);
  }

  void _drawCar(Canvas canvas, Offset position, double scale, Paint paint,
      Paint strokePaint) {
    final carWidth = 40.0 * scale;
    final carHeight = 20.0 * scale;

    // Car body
    final carRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position,
        width: carWidth,
        height: carHeight,
      ),
      Radius.circular(carHeight / 2),
    );
    canvas.drawRRect(carRect, paint);

    // Car top
    final topRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(position.dx, position.dy - carHeight / 3),
        width: carWidth * 0.8,
        height: carHeight * 0.6,
      ),
      Radius.circular(carHeight / 3),
    );
    canvas.drawRRect(topRect, paint);

    // Wheels
    final wheelRadius = carHeight / 4;
    canvas.drawCircle(
      Offset(position.dx - carWidth / 3, position.dy + carHeight / 2),
      wheelRadius,
      paint..color = primaryColor.withValues(alpha: opacity * 0.4),
    );
    canvas.drawCircle(
      Offset(position.dx + carWidth / 3, position.dy + carHeight / 2),
      wheelRadius,
      paint..color = primaryColor.withValues(alpha: opacity * 0.4),
    );
  }

  void _drawParkingSigns(
      Canvas canvas, Size size, Paint paint, Paint strokePaint) {
    // Large parking sign (top left)
    _drawParkingSign(canvas, Offset(size.width * 0.1, size.height * 0.08), 1.2,
        paint, strokePaint);

    // Medium parking sign (middle)
    _drawParkingSign(canvas, Offset(size.width * 0.5, size.height * 0.3), 0.8,
        paint, strokePaint);

    // Small parking sign (bottom right)
    _drawParkingSign(canvas, Offset(size.width * 0.85, size.height * 0.6), 0.6,
        paint, strokePaint);
  }

  void _drawParkingSign(Canvas canvas, Offset position, double scale,
      Paint paint, Paint strokePaint) {
    final radius = 25.0 * scale;

    // Sign background
    canvas.drawCircle(position, radius, paint);

    // Sign border
    canvas.drawCircle(position, radius, strokePaint);

    // Parking "P" symbol
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'P',
        style: TextStyle(
          color: Colors.white.withValues(alpha: opacity * 0.8),
          fontSize: radius * 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawUrbanElements(
      Canvas canvas, Size size, Paint paint, Paint strokePaint) {
    // Trees
    _drawTree(canvas, Offset(size.width * 0.05, size.height * 0.2), 0.8, paint,
        strokePaint);
    _drawTree(canvas, Offset(size.width * 0.95, size.height * 0.15), 0.6, paint,
        strokePaint);

    // Buildings
    _drawBuilding(canvas, Offset(size.width * 0.1, size.height * 0.6), 0.7,
        paint, strokePaint);
    _drawBuilding(canvas, Offset(size.width * 0.9, size.height * 0.5), 0.9,
        paint, strokePaint);
  }

  void _drawTree(Canvas canvas, Offset position, double scale, Paint paint,
      Paint strokePaint) {
    final trunkHeight = 30.0 * scale;
    final trunkWidth = 8.0 * scale;
    final leavesRadius = 20.0 * scale;

    // Trunk
    final trunkRect = Rect.fromCenter(
      center: Offset(position.dx, position.dy + trunkHeight / 2),
      width: trunkWidth,
      height: trunkHeight,
    );
    canvas.drawRect(trunkRect, paint);

    // Leaves
    canvas.drawCircle(
      Offset(position.dx, position.dy - leavesRadius / 2),
      leavesRadius,
      paint..color = primaryColor.withValues(alpha: opacity * 0.2),
    );
  }

  void _drawBuilding(Canvas canvas, Offset position, double scale, Paint paint,
      Paint strokePaint) {
    final width = 35.0 * scale;
    final height = 60.0 * scale;

    final buildingRect = Rect.fromCenter(
      center: position,
      width: width,
      height: height,
    );
    canvas.drawRect(buildingRect, paint);

    // Windows
    final windowSize = 6.0 * scale;
    final windowSpacing = 12.0 * scale;

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 2; col++) {
        final windowX = position.dx - width / 3 + col * windowSpacing;
        final windowY = position.dy - height / 3 + row * windowSpacing;

        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(windowX, windowY),
            width: windowSize,
            height: windowSize,
          ),
          paint..color = primaryColor.withValues(alpha: opacity * 0.3),
        );
      }
    }
  }

  void _drawParkingLines(Canvas canvas, Size size, Paint strokePaint) {
    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: opacity * 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Horizontal parking lines
    final lineY1 = size.height * 0.75;
    final lineY2 = size.height * 0.85;
    final lineY3 = size.height * 0.95;

    canvas.drawLine(
      Offset(size.width * 0.05, lineY1),
      Offset(size.width * 0.95, lineY1),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.05, lineY2),
      Offset(size.width * 0.95, lineY2),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.05, lineY3),
      Offset(size.width * 0.95, lineY3),
      linePaint,
    );

    // Vertical parking spaces
    final spaceX1 = size.width * 0.25;
    final spaceX2 = size.width * 0.5;
    final spaceX3 = size.width * 0.75;

    canvas.drawLine(
      Offset(spaceX1, lineY1 - 20),
      Offset(spaceX1, lineY3 + 20),
      linePaint,
    );
    canvas.drawLine(
      Offset(spaceX2, lineY1 - 20),
      Offset(spaceX2, lineY3 + 20),
      linePaint,
    );
    canvas.drawLine(
      Offset(spaceX3, lineY1 - 20),
      Offset(spaceX3, lineY3 + 20),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
