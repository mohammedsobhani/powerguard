import 'dart:math' as math;
import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double waveAnimation;
  final double fillLevel;

  WavePainter({required this.waveAnimation, required this.fillLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final double viewHeight = size.height;
    final double viewWidth = size.width;

    // Calculate fluid waterline baseline height based on current level
    final double fillTargetHeight = viewHeight * (1.0 - fillLevel);

    const double waveAmplitude = 8.0;  // Height of wave peaks
    const double waveFrequency = 1.8;  // Density of the waves across the width

    // 🌊 Back Wave Layer
    final Paint backPaint = Paint()
    // ✅ FIXED: Updated to modern non-deprecated .withValues architecture
      ..color = const Color(0xFF00BFA5).withValues(alpha: 0.35)
    // ✅ FIXED: Changed PaintStyle to PaintingStyle
      ..style = PaintingStyle.fill;

    final Path backPath = Path()..moveTo(0, fillTargetHeight);

    // 🌊 Front Wave Layer
    final Paint frontPaint = Paint()
      ..color = const Color(0xFF00E676)
    // ✅ FIXED: Changed PaintStyle to PaintingStyle
      ..style = PaintingStyle.fill;

    final Path frontPath = Path()..moveTo(0, fillTargetHeight);

    // Plot trigonometric curves across horizontal coordinate vectors
    for (double x = 0; x <= viewWidth; x++) {
      final double backY = fillTargetHeight +
          math.sin((waveAnimation * 360 * math.pi / 180) + (x * waveFrequency * math.pi / viewWidth)) * waveAmplitude;
      backPath.lineTo(x, backY);

      final double frontY = fillTargetHeight +
          math.cos((waveAnimation * 360 * math.pi / 180) + (x * waveFrequency * math.pi / viewWidth)) * waveAmplitude;
      frontPath.lineTo(x, frontY);
    }

    // Close the shapes to fill the bottom area of the circle completely
    backPath.lineTo(viewWidth, viewHeight);
    backPath.lineTo(0, viewHeight);
    backPath.close();

    frontPath.lineTo(viewWidth, viewHeight);
    frontPath.lineTo(0, viewHeight);
    frontPath.close();

    canvas.drawPath(backPath, backPaint);
    canvas.drawPath(frontPath, frontPaint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
}