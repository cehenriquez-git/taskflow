import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Insignia circular con anillo de progreso (usada para el 60% de la cabecera).
class ProgressBadge extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final double size;

  const ProgressBadge({
    super.key,
    required this.progress,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size - 12,
          height: size - 12,
          child: CustomPaint(
            painter: _RingPainter(progress: progress),
            child: Center(
              child: Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final center = (Offset.zero & size).center;
    final radius = (size.width - stroke) / 2;

    final track = Paint()
      ..color = AppColors.chipBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final arc = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // empieza arriba
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
