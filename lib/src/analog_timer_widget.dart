import 'package:flutter/material.dart';
import 'analog_timer_painter.dart';

/// A comprehensive analog timer widget with full customization options
///
/// This widget provides a circular timer with features like:
/// - Inside-circle progress visualization
/// - Customizable warning colors
/// - Remaining time display inside the clock
/// - Clockwise/Anti-clockwise progress direction
/// - Full color customization
/// - Interval marks for better time visualization
class AnalogTimer extends StatelessWidget {
  /// Current progress value (1.0 = full time, 0.0 = time's up)
  final double progress;

  /// Whether the timer is currently running
  final bool isRunning;

  /// Animation value for visual effects (0.0 to 1.0)
  final double animationValue;

  /// Warning level (0 = normal, 1 = warning, 2 = critical)
  final int warningLevel;

  /// Direction of timer progress (clockwise or anti-clockwise)
  final AnalogTimerDirection direction;

  /// Remaining time to display inside the clock (e.g., "01:30")
  final String? remainingTimeText;

  /// Size of the timer widget
  final double size;

  /// Color of the outer circle
  final Color circleColor;

  /// Color of the progress fill (overrides warning colors if specified)
  final Color? progressColor;

  /// Color of small interval marks
  final Color intervalColor;

  /// Color of major interval marks (every 5th mark)
  final Color majorIntervalColor;

  /// Color of the remaining time text inside the clock
  final Color timeTextColor;

  /// Font size for the remaining time text
  final double timeTextSize;

  /// Warning color configuration for different time states
  final AnalogTimerWarningConfig warningColors;

  /// Whether to show warning colors when time is running low
  final bool enableWarningColors;

  /// Creates an analog timer widget
  ///
  /// [progress] must be between 0.0 and 1.0 where:
  /// - 1.0 = full time remaining
  /// - 0.0 = no time remaining
  ///
  /// [direction] determines whether progress moves clockwise or anti-clockwise
  ///
  /// [remainingTimeText] is displayed in the center of the clock
  ///
  /// Warning colors automatically change based on [progress] unless [progressColor] is specified
  const AnalogTimer({
    super.key,
    required this.progress,
    this.isRunning = false,
    this.animationValue = 0.0,
    this.warningLevel = 0,
    this.direction = AnalogTimerDirection.clockwise,
    this.remainingTimeText,
    this.size = 200,
    this.circleColor = const Color(0xFF34495E),
    this.progressColor,
    this.intervalColor = const Color(0xFF7F8C8D),
    this.majorIntervalColor = const Color(0xFF2C3E50),
    this.timeTextColor = const Color(0xFF2C3E50),
    this.timeTextSize = 24.0,
    this.warningColors = const AnalogTimerWarningConfig(),
    this.enableWarningColors = true,
  }) : assert(
         progress >= 0.0 && progress <= 1.0,
         'Progress must be between 0.0 and 1.0',
       ),
       assert(size > 0, 'Size must be greater than 0'),
       assert(timeTextSize > 0, 'Time text size must be greater than 0');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: AnalogTimerPainter(
          progress: progress,
          isRunning: isRunning,
          animationValue: animationValue,
          warningLevel: warningLevel,
          direction: direction,
          remainingTimeText: remainingTimeText,
          circleColor: circleColor,
          progressColor: progressColor,
          intervalColor: intervalColor,
          majorIntervalColor: majorIntervalColor,
          timeTextColor: timeTextColor,
          timeTextSize: timeTextSize,
          warningColors: warningColors,
          enableWarningColors: enableWarningColors,
        ),
      ),
    );
  }
}
