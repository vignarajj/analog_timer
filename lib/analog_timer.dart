/// A Flutter plugin for beautiful, customizable analog timer widgets.
///
/// This library provides a comprehensive analog timer widget with features like:
/// - Inside-circle progress visualization
/// - Customizable warning colors
/// - Remaining time display inside the clock
/// - Clockwise/Anti-clockwise progress direction
/// - Full color customization
/// - Interval marks for better time visualization
/// - Timer functionality (start, stop, pause, reset)
///
/// ## Usage
///
/// Simple usage with just a progress value:
/// ```dart
/// AnalogTimer(
///   progress: 0.75, // 75% time remaining
/// )
/// ```
///
/// Advanced usage with a timer controller:
/// ```dart
/// final controller = AnalogTimerController(
///   duration: Duration(minutes: 5),
/// );
///
/// AnalogTimer(
///   progress: controller.progress,
///   isRunning: controller.isRunning,
///   animationValue: controller.animationValue,
///   warningLevel: controller.warningLevel,
///   remainingTimeText: controller.formattedTime,
/// )
/// ```
library;

export 'src/analog_timer_controller.dart';
export 'src/analog_timer_widget.dart';
export 'src/analog_timer_painter.dart';
