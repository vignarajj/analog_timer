import 'dart:math';
import 'package:flutter/material.dart';

/// Direction for timer progress
enum AnalogTimerDirection {
  /// Progress moves clockwise (standard)
  clockwise,

  /// Progress moves anti-clockwise (reverse)
  antiClockwise,
}

/// Configuration for warning colors at different time thresholds
class AnalogTimerWarningConfig {
  /// Color when time is normal (> warningThreshold)
  final Color normalColor;

  /// Color when time is in warning state (between warningThreshold and criticalThreshold)
  final Color warningColor;

  /// Color when time is critical (< criticalThreshold)
  final Color criticalColor;

  /// Threshold for warning state (0.0 to 1.0, e.g., 0.5 = 50%)
  final double warningThreshold;

  /// Threshold for critical state (0.0 to 1.0, e.g., 0.2 = 20%)
  final double criticalThreshold;

  const AnalogTimerWarningConfig({
    this.normalColor = const Color(0xFF2ECC71), // Green
    this.warningColor = const Color(0xFFF39C12), // Orange
    this.criticalColor = const Color(0xFFE74C3C), // Red
    this.warningThreshold = 0.5,
    this.criticalThreshold = 0.2,
  });
}

/// Custom painter for the enhanced analog timer
///
/// This painter handles all the visual rendering of the analog timer including:
/// - Circular progress visualization
/// - Warning color transitions
/// - Interval marks around the clock face
/// - Time text display in the center
/// - Glow effects during warning states
class AnalogTimerPainter extends CustomPainter {
  /// Current progress (1.0 = full time, 0.0 = time's up)
  final double progress;

  /// Whether the timer is currently running
  final bool isRunning;

  /// Animation value for glowing effect (0.0 to 1.0)
  final double animationValue;

  /// Time warning level (0 = normal, 1 = warning, 2 = critical)
  final int warningLevel;

  /// Direction of timer progress
  final AnalogTimerDirection direction;

  /// Remaining time to display inside the clock
  final String? remainingTimeText;

  /// Color of the outer circle (remains constant)
  final Color circleColor;

  /// Color of the progress fill (overrides warning colors if specified)
  final Color? progressColor;

  /// Color of interval marks around the timer
  final Color intervalColor;

  /// Color of major interval marks (every 5 seconds/units)
  final Color majorIntervalColor;

  /// Color of the remaining time text inside the clock
  final Color timeTextColor;

  /// Font size for the remaining time text
  final double timeTextSize;

  /// Warning color configuration
  final AnalogTimerWarningConfig warningColors;

  /// Whether to show warning colors when time is running low
  final bool enableWarningColors;

  /// Creates an analog timer painter
  ///
  /// All required parameters must be provided for proper rendering
  AnalogTimerPainter({
    required this.progress,
    required this.direction,
    required this.circleColor,
    required this.intervalColor,
    required this.majorIntervalColor,
    required this.timeTextColor,
    required this.warningColors,
    this.isRunning = false,
    this.animationValue = 0.0,
    this.warningLevel = 0,
    this.remainingTimeText,
    this.progressColor,
    this.timeTextSize = 24.0,
    this.enableWarningColors = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15; // Leave space for interval marks

    // Draw interval marks (time indicators)
    _drawIntervalMarks(canvas, center, radius + 10);

    // Draw the outer circle (constant color)
    final circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, circlePaint);

    // Calculate the fill area (inside circle)
    final fillRadius = radius - 3; // Slightly smaller than the outer circle

    // Get the progress color based on warning level
    final fillColor = _getProgressColor(progress);

    // Draw the progress fill (inner area)
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Calculate sweep angle based on progress and direction
    final sweepAngle = _calculateSweepAngle(progress);
    final startAngle = _getStartAngle();

    // Only draw progress if there's something to show
    if (progress > 0) {
      // Define the inner path for filling
      final innerPath = Path()
        ..moveTo(center.dx, center.dy) // Start at center
        ..lineTo(
          center.dx + fillRadius * cos(startAngle),
          center.dy + fillRadius * sin(startAngle),
        ) // Move to start position
        ..addArc(
          Rect.fromCircle(center: center, radius: fillRadius),
          startAngle,
          sweepAngle,
        )
        ..lineTo(center.dx, center.dy) // Return to center
        ..close();

      // Draw the inner fill path
      canvas.drawPath(innerPath, fillPaint);
    }

    // Add glow effect when running and in warning state
    if (isRunning && warningLevel > 0) {
      final glowPaint = Paint()
        ..color = fillColor.withValues(alpha: 0.3 + 0.3 * animationValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(center, radius, glowPaint);
    }

    // Draw a thin inner circle for better definition
    final innerCirclePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, fillRadius, innerCirclePaint);

    // Draw remaining time text inside the clock
    if (remainingTimeText != null && remainingTimeText!.isNotEmpty) {
      _drawTimeText(canvas, center, remainingTimeText!);
    }

    // Add a center dot for aesthetics (only if no text)
    if (remainingTimeText == null || remainingTimeText!.isEmpty) {
      final centerDotPaint = Paint()
        ..color = circleColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, 4, centerDotPaint);
    }
  }

  /// Calculate the sweep angle based on direction
  double _calculateSweepAngle(double progress) {
    final angle = 2 * pi * progress;
    return direction == AnalogTimerDirection.clockwise ? angle : -angle;
  }

  /// Get the starting angle based on direction
  double _getStartAngle() {
    // Always start from top (12 o'clock position)
    return -pi / 2;
  }

  /// Draw the remaining time text in the center of the clock
  void _drawTimeText(Canvas canvas, Offset center, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: timeTextColor,
          fontSize: timeTextSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Center the text
    final offset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);
  }

  /// Get the appropriate progress color based on remaining time
  Color _getProgressColor(double progress) {
    // Use provided color if specified (overrides warning colors)
    if (progressColor != null) return progressColor!;

    // If warning colors are disabled, use the normal color
    if (!enableWarningColors) return warningColors.normalColor;

    if (progress < warningColors.criticalThreshold) {
      // Critical state
      return warningColors.criticalColor;
    } else if (progress < warningColors.warningThreshold) {
      // Warning state - interpolate between critical and warning colors
      final t =
          (progress - warningColors.criticalThreshold) /
          (warningColors.warningThreshold - warningColors.criticalThreshold);
      return Color.lerp(
        warningColors.criticalColor,
        warningColors.warningColor,
        t,
      )!;
    } else {
      // Normal state - interpolate between warning and normal colors
      final t =
          (progress - warningColors.warningThreshold) /
          (1.0 - warningColors.warningThreshold);
      return Color.lerp(
        warningColors.warningColor,
        warningColors.normalColor,
        t,
      )!;
    }
  }

  /// Draw the interval marks around the timer
  void _drawIntervalMarks(Canvas canvas, Offset center, double radius) {
    final markPaint = Paint()
      ..color = intervalColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final majorMarkPaint = Paint()
      ..color = majorIntervalColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Draw 60 interval marks (for second-based timing)
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * pi / 180; // 6 degrees per mark
      final isMajorMark = i % 5 == 0; // Every 5th mark is major

      final paint = isMajorMark ? majorMarkPaint : markPaint;
      final markLength = isMajorMark ? 8.0 : 4.0;

      final startX = center.dx + (radius - markLength) * cos(angle - pi / 2);
      final startY = center.dy + (radius - markLength) * sin(angle - pi / 2);
      final endX = center.dx + radius * cos(angle - pi / 2);
      final endY = center.dy + radius * sin(angle - pi / 2);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is AnalogTimerPainter) {
      return progress != oldDelegate.progress ||
          isRunning != oldDelegate.isRunning ||
          warningLevel != oldDelegate.warningLevel ||
          animationValue != oldDelegate.animationValue ||
          remainingTimeText != oldDelegate.remainingTimeText ||
          direction != oldDelegate.direction;
    }
    return true;
  }
}
