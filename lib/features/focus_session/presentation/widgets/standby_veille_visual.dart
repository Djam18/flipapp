import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 1 (VEILLE): Concentric Sage Green wave rings with isometric phone.
class StandbyVeilleVisual extends StatelessWidget {
  final VoidCallback? onTap;

  const StandbyVeilleVisual({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: const Size(210, 170),
        painter: _StandbyWavesPainter(
          accentColor: AppColors.accent,
        ),
      ),
    );
  }
}

class _StandbyWavesPainter extends CustomPainter {
  final Color accentColor;

  _StandbyWavesPainter({
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Sage Green Concentric Expanding Wave Rings
    final waveRings = [
      (radius: 80.0, opacity: 0.20, strokeWidth: 1.5),
      (radius: 60.0, opacity: 0.40, strokeWidth: 1.8),
      (radius: 42.0, opacity: 0.70, strokeWidth: 2.2),
    ];

    for (final ring in waveRings) {
      final wavePaint = Paint()
        ..color = accentColor.withValues(alpha: ring.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.strokeWidth;

      // Draw slightly elliptical rings for isometric depth
      final rect = Rect.fromCenter(
        center: center,
        width: ring.radius * 2.1,
        height: ring.radius * 1.85,
      );
      canvas.drawOval(rect, wavePaint);
    }

    // 2. Isometric / Perspective Angled Smartphone
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 16); // Sleek perspective tilt

    const phoneWidth = 42.0;
    const phoneHeight = 74.0;
    const phoneRadius = 10.0;

    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: phoneWidth, height: phoneHeight),
      const Radius.circular(phoneRadius),
    );

    // Subtle drop shadow / glow behind phone
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(phoneRect, glowPaint);

    // Phone body fill (Titanium OLED dark surface)
    final bodyPaint = Paint()
      ..color = AppColors.surfaceElevated
      ..style = PaintingStyle.fill;
    canvas.drawRRect(phoneRect, bodyPaint);

    // Phone bezel border (Sage green)
    final borderPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(phoneRect, borderPaint);

    // Top speaker bar
    final speakerPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;
    canvas.drawLine(
      const Offset(-8, -phoneHeight / 2 + 8),
      const Offset(8, -phoneHeight / 2 + 8),
      speakerPaint,
    );

    // Bottom gesture pill / indicator
    final indicatorPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(0, phoneHeight / 2 - 9), 2.8, indicatorPaint);

    // Inner subtle screen reflection / zen arc
    final reflectionPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final innerRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: phoneWidth - 8, height: phoneHeight - 20),
      const Radius.circular(5.0),
    );
    canvas.drawRRect(innerRRect, reflectionPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StandbyWavesPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor;
  }
}
