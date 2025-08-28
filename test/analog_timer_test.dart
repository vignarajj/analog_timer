import 'package:analog_timer/analog_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalogTimerController Tests', () {
    late AnalogTimerController controller;

    setUp(() {
      controller = AnalogTimerController(
        duration: const Duration(seconds: 60),
        warningThreshold: 0.5,
        criticalThreshold: 0.2,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('initializes with correct values', () {
      expect(controller.totalDuration, equals(const Duration(seconds: 60)));
      expect(controller.remaining, equals(const Duration(seconds: 60)));
      expect(controller.progress, equals(1.0));
      expect(controller.isRunning, isFalse);
      expect(controller.isPaused, isFalse);
      expect(controller.warningLevel, equals(0));
    });

    test('progress calculation works correctly', () {
      expect(controller.progress, equals(1.0));

      // Manually set remaining time for testing
      controller.reset(const Duration(seconds: 30));
      expect(controller.progress, equals(1.0));
    });

    test('formatted time works correctly', () {
      // Test for seconds-only format
      final shortController = AnalogTimerController(
        duration: const Duration(seconds: 45),
      );
      expect(shortController.formattedTime, equals('45'));
      shortController.dispose();

      // Test for MM:SS format
      final longController = AnalogTimerController(
        duration: const Duration(minutes: 2, seconds: 30),
      );
      expect(longController.formattedTime, equals('02:30'));
      longController.dispose();
    });

    test('warning thresholds are validated', () {
      expect(
        () => AnalogTimerController(
          duration: const Duration(seconds: 60),
          warningThreshold: 0.1,
          criticalThreshold: 0.2, // Critical > Warning should fail
        ),
        throwsAssertionError,
      );
    });

    test('timer state changes correctly', () {
      expect(controller.isRunning, isFalse);
      expect(controller.isPaused, isFalse);

      controller.start();
      expect(controller.isRunning, isTrue);
      expect(controller.isPaused, isFalse);

      controller.pause();
      expect(controller.isRunning, isFalse);
      expect(controller.isPaused, isTrue);

      controller.stop();
      expect(controller.isRunning, isFalse);
      expect(controller.isPaused, isFalse);
    });

    test('reset functionality works', () {
      controller.reset(const Duration(seconds: 30));
      expect(controller.totalDuration, equals(const Duration(seconds: 30)));
      expect(controller.remaining, equals(const Duration(seconds: 30)));
      expect(controller.progress, equals(1.0));
      expect(controller.isRunning, isFalse);
    });
  });

  group('AnalogTimerWarningConfig Tests', () {
    test('creates with default values', () {
      const config = AnalogTimerWarningConfig();
      expect(config.normalColor, equals(const Color(0xFF2ECC71)));
      expect(config.warningColor, equals(const Color(0xFFF39C12)));
      expect(config.criticalColor, equals(const Color(0xFFE74C3C)));
      expect(config.warningThreshold, equals(0.5));
      expect(config.criticalThreshold, equals(0.2));
    });

    test('creates with custom values', () {
      const config = AnalogTimerWarningConfig(
        normalColor: Color(0xFF00FF00),
        warningColor: Color(0xFFFFFF00),
        criticalColor: Color(0xFFFF0000),
        warningThreshold: 0.7,
        criticalThreshold: 0.3,
      );
      expect(config.normalColor, equals(const Color(0xFF00FF00)));
      expect(config.warningColor, equals(const Color(0xFFFFFF00)));
      expect(config.criticalColor, equals(const Color(0xFFFF0000)));
      expect(config.warningThreshold, equals(0.7));
      expect(config.criticalThreshold, equals(0.3));
    });
  });
}
