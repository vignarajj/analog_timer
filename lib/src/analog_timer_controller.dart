import 'dart:async';
import 'package:flutter/material.dart';

/// Callback functions for analog timer events
typedef AnalogTimerCallback = void Function();
typedef AnalogTimerTickCallback = void Function(Duration remainingTime);

/// A controller for analog timers with countdown functionality and customizable callbacks
///
/// This controller manages timer state and provides callbacks for various timer events
/// such as ticks, warnings, critical states, and expiration. It uses pure Flutter/Dart
/// without any external state management dependencies.
///
/// Example:
/// ```dart
/// final controller = AnalogTimerController(
///   duration: const Duration(minutes: 5),
///   warningThreshold: 0.3, // Warning at 30% remaining
///   criticalThreshold: 0.1, // Critical at 10% remaining
/// );
///
/// controller.onTick = (remaining) => print('Time left: $remaining');
/// controller.onWarning = () => print('Warning: Time running low!');
/// controller.onCritical = () => print('Critical: Very little time left!');
/// controller.onExpired = () => print('Time expired!');
///
/// controller.start();
/// ```
class AnalogTimerController extends ChangeNotifier {
  /// Total duration for the timer
  Duration _totalDuration;

  /// Current remaining time
  Duration _remaining;

  /// Whether the timer is currently running
  bool _isRunning = false;

  /// Whether the timer is paused
  bool _isPaused = false;

  /// Current warning level (0 = normal, 1 = warning, 2 = critical)
  int _warningLevel = 0;

  /// Animation controller for visual effects
  AnimationController? _animationController;

  /// Timer instance for countdown
  Timer? _timer;

  /// Threshold for warning state (0.0 to 1.0, e.g., 0.5 = 50% remaining)
  final double warningThreshold;

  /// Threshold for critical state (0.0 to 1.0, e.g., 0.2 = 20% remaining)
  final double criticalThreshold;

  // Callback functions
  AnalogTimerCallback? onTick;
  AnalogTimerCallback? onWarning;
  AnalogTimerCallback? onCritical;
  AnalogTimerCallback? onExpired;
  AnalogTimerTickCallback? onTickWithTime;

  /// Creates a new analog timer controller
  ///
  /// [duration] - The total countdown duration
  /// [warningThreshold] - Progress level (0.0-1.0) at which warning state is triggered
  /// [criticalThreshold] - Progress level (0.0-1.0) at which critical state is triggered
  AnalogTimerController({
    required Duration duration,
    this.warningThreshold = 0.5,
    this.criticalThreshold = 0.2,
  }) : _totalDuration = duration,
       _remaining = duration,
       assert(
         warningThreshold > 0.0 && warningThreshold <= 1.0,
         'Warning threshold must be between 0.0 and 1.0',
       ),
       assert(
         criticalThreshold > 0.0 && criticalThreshold <= 1.0,
         'Critical threshold must be between 0.0 and 1.0',
       ),
       assert(
         criticalThreshold < warningThreshold,
         'Critical threshold must be less than warning threshold',
       );

  /// Initialize animation controller for visual effects
  void initializeAnimation(TickerProvider tickerProvider) {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: tickerProvider,
    );
    _animationController!.repeat(reverse: true);
  }

  /// Get the total duration of the timer
  Duration get totalDuration => _totalDuration;

  /// Get the remaining time
  Duration get remaining => _remaining;

  /// Check if the timer is currently running (and not paused)
  bool get isRunning => _isRunning && !_isPaused;

  /// Check if the timer is paused
  bool get isPaused => _isPaused;

  /// Get current warning level (0 = normal, 1 = warning, 2 = critical)
  int get warningLevel => _warningLevel;

  /// Get current progress as a value from 0.0 to 1.0
  /// 1.0 = full time remaining, 0.0 = no time remaining
  double get progress =>
      _remaining.inMilliseconds / _totalDuration.inMilliseconds;

  /// Get animation value for visual effects (0.0 to 1.0)
  double get animationValue => _animationController?.value ?? 0.0;

  /// Check if the timer has expired (remaining time is zero)
  bool get hasExpired => _remaining.inMilliseconds <= 0;

  /// Get formatted time string for display
  /// For durations < 60 seconds: shows "43"
  /// For durations >= 60 seconds: shows "01:30"
  String get formattedTime {
    final totalSeconds = _remaining.inSeconds;

    // If the total duration is less than 60 seconds, show only seconds
    if (_totalDuration.inSeconds < 60) {
      return totalSeconds.toString();
    }

    // Otherwise, show the full MM:SS format
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Start the timer countdown
  void start() {
    if (_isRunning && !_isPaused) return;

    _isRunning = true;
    _isPaused = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        _remaining = Duration(seconds: _remaining.inSeconds - 1);
        _checkWarningLevel();
        onTick?.call();
        onTickWithTime?.call(_remaining);
        notifyListeners();
      } else {
        _handleTimeExpired();
      }
    });

    notifyListeners();
  }

  /// Pause the timer
  void pause() {
    if (!_isRunning || _isPaused) return;

    _timer?.cancel();
    _isPaused = true;
    notifyListeners();
  }

  /// Resume the paused timer
  void resume() {
    if (!_isPaused) return;

    start(); // This will handle the resume logic
  }

  /// Stop the timer completely
  void stop() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    notifyListeners();
  }

  /// Reset the timer to its original duration
  /// If [newDuration] is provided, the timer will be reset to that duration
  void reset([Duration? newDuration]) {
    _timer?.cancel();

    if (newDuration != null) {
      _totalDuration = newDuration;
    }

    _remaining = _totalDuration;
    _isRunning = false;
    _isPaused = false;
    _warningLevel = 0;

    notifyListeners();
  }

  /// Add extra time to the current timer
  void addTime(Duration extraTime) {
    _remaining = Duration(seconds: _remaining.inSeconds + extraTime.inSeconds);

    // Ensure we don't exceed reasonable limits
    if (_remaining > _totalDuration * 2) {
      _remaining = _totalDuration * 2;
    }

    _checkWarningLevel();
    notifyListeners();
  }

  /// Subtract time from the current timer
  void subtractTime(Duration timeToSubtract) {
    final newRemainingSeconds = _remaining.inSeconds - timeToSubtract.inSeconds;

    if (newRemainingSeconds <= 0) {
      _remaining = Duration.zero;
      _handleTimeExpired();
    } else {
      _remaining = Duration(seconds: newRemainingSeconds);
      _checkWarningLevel();
      notifyListeners();
    }
  }

  /// Handle when time expires
  void _handleTimeExpired() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _remaining = Duration.zero;
    onExpired?.call();
    notifyListeners();
  }

  /// Check and update warning level based on remaining time
  void _checkWarningLevel() {
    final currentProgress = progress;

    if (currentProgress <= criticalThreshold) {
      // Critical: at or below critical threshold
      if (_warningLevel != 2) {
        _warningLevel = 2;
        onCritical?.call();
      }
    } else if (currentProgress <= warningThreshold) {
      // Warning: at or below warning threshold
      if (_warningLevel != 1) {
        _warningLevel = 1;
        onWarning?.call();
      }
    } else {
      // Normal: above warning threshold
      if (_warningLevel != 0) {
        _warningLevel = 0;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }
}
