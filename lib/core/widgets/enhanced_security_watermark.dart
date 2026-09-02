import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class EnhancedSecurityWatermark extends StatelessWidget {
  final Widget child;
  final String userId;
  final String userName;
  final bool isEnabled;

  const EnhancedSecurityWatermark({
    super.key,
    required this.child,
    required this.userId,
    required this.userName,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final watermarkColor = isDark ? AppColors.watermarkDark : AppColors.watermarkLight;
    final nowStr = DateTime.now().toIso8601String().substring(0, 10);
    final text = '$userName\nUID: ${userId.isNotEmpty ? userId : "Guest"}\n$nowStr';

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _WatermarkPainter(
                text: text,
                color: watermarkColor,
                rows: 8,
                cols: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  final String text;
  final Color color;
  final int rows;
  final int cols;

  _WatermarkPainter({
    required this.text,
    required this.color,
    required this.rows,
    required this.cols,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          height: 1.3,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final rowSpacing = size.height / rows;
    final colSpacing = size.width / cols;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = c * colSpacing + colSpacing / 2;
        final y = r * rowSpacing + rowSpacing / 2;

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(-math.pi / 4); // 45 度傾斜
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WatermarkPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.color != color ||
        oldDelegate.rows != rows ||
        oldDelegate.cols != cols;
  }
}
