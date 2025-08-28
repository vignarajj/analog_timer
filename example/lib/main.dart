import 'package:flutter/material.dart';
import 'package:analog_timer/analog_timer.dart';

void main() {
  runApp(const AnalogTimerExampleApp());
}

class AnalogTimerExampleApp extends StatelessWidget {
  const AnalogTimerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analog Timer Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AnalogTimerDemo(),
    );
  }
}

class AnalogTimerDemo extends StatefulWidget {
  const AnalogTimerDemo({super.key});

  @override
  State<AnalogTimerDemo> createState() => _AnalogTimerDemoState();
}

class _AnalogTimerDemoState extends State<AnalogTimerDemo>
    with TickerProviderStateMixin {
  // Controllers for different timers
  late AnalogTimerController _simpleController;
  late AnalogTimerController _customController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize simple 60-second timer
    _simpleController = AnalogTimerController(
      duration: const Duration(seconds: 60),
      warningThreshold: 0.5,
      criticalThreshold: 0.2,
    );

    // Initialize custom 2-minute timer with different thresholds
    _customController = AnalogTimerController(
      duration: const Duration(minutes: 2),
      warningThreshold: 0.3,
      criticalThreshold: 0.1,
    );

    // Animation controller for visual effects
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationController.repeat(reverse: true);

    // Initialize animations for both controllers
    _simpleController.initializeAnimation(this);
    _customController.initializeAnimation(this);

    // Set up callbacks
    _setupCallbacks(_simpleController, 'Simple Timer');
    _setupCallbacks(_customController, 'Custom Timer');
  }

  void _setupCallbacks(AnalogTimerController controller, String timerName) {
    controller.onWarning = () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ $timerName: Warning - Time running low!'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    };

    controller.onCritical = () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚨 $timerName: Critical - Very little time left!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    };

    controller.onExpired = () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏰ $timerName: Time\'s up!'),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 3),
        ),
      );
    };
  }

  @override
  void dispose() {
    _simpleController.dispose();
    _customController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analog Timer Demo'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Simple Timer Section
              _buildTimerSection(
                title: 'Simple 60-Second Timer',
                subtitle: 'Basic functionality with default styling',
                controller: _simpleController,
                timerWidget: AnimatedBuilder(
                  animation: _simpleController,
                  builder: (context, child) {
                    return AnalogTimer(
                      progress: _simpleController.progress,
                      isRunning: _simpleController.isRunning,
                      animationValue: _simpleController.animationValue,
                      warningLevel: _simpleController.warningLevel,
                      remainingTimeText: _simpleController.formattedTime,
                      size: 200,
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Custom Timer Section
              _buildTimerSection(
                title: '2-Minute Custom Timer',
                subtitle: 'Custom colors, thresholds, and counter-clockwise',
                controller: _customController,
                timerWidget: AnimatedBuilder(
                  animation: _customController,
                  builder: (context, child) {
                    return AnalogTimer(
                      progress: _customController.progress,
                      isRunning: _customController.isRunning,
                      animationValue: _customController.animationValue,
                      warningLevel: _customController.warningLevel,
                      remainingTimeText: _customController.formattedTime,
                      direction: AnalogTimerDirection.antiClockwise,
                      size: 220,
                      circleColor: const Color(0xFF2C3E50),
                      intervalColor: const Color(0xFF95A5A6),
                      majorIntervalColor: const Color(0xFF34495E),
                      timeTextColor: const Color(0xFF2C3E50),
                      timeTextSize: 28,
                      warningColors: const AnalogTimerWarningConfig(
                        normalColor: Color(0xFF3498DB), // Blue
                        warningColor: Color(0xFFE67E22), // Orange
                        criticalColor: Color(0xFFE74C3C), // Red
                        warningThreshold: 0.3,
                        criticalThreshold: 0.1,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Static Examples Section
              _buildStaticExamplesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection({
    required String title,
    required String subtitle,
    required AnalogTimerController controller,
    required Widget timerWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Timer Widget
          timerWidget,

          const SizedBox(height: 30),

          // Control Buttons
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: controller.isRunning
                        ? Icons.pause
                        : controller.isPaused
                        ? Icons.play_arrow
                        : Icons.play_arrow,
                    label: controller.isRunning
                        ? 'Pause'
                        : controller.isPaused
                        ? 'Resume'
                        : 'Start',
                    color: controller.isRunning ? Colors.orange : Colors.green,
                    onPressed: () {
                      if (controller.isRunning) {
                        controller.pause();
                      } else if (controller.isPaused) {
                        controller.resume();
                      } else {
                        controller.start();
                      }
                    },
                  ),
                  _buildControlButton(
                    icon: Icons.stop,
                    label: 'Stop',
                    color: Colors.red,
                    onPressed: () {
                      controller.stop();
                    },
                  ),
                  _buildControlButton(
                    icon: Icons.refresh,
                    label: 'Reset',
                    color: Colors.blue,
                    onPressed: () {
                      controller.reset();
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Quick Set Buttons
          _buildQuickSetButtons(controller),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(30),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSetButtons(AnalogTimerController controller) {
    final presets = controller.totalDuration.inSeconds == 60
        ? [('10s', 10), ('30s', 30), ('45s', 45), ('60s', 60)]
        : [('30s', 30), ('1m', 60), ('2m', 120), ('5m', 300)];

    return Column(
      children: [
        const Text(
          'Quick Set',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7F8C8D),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: presets.map((preset) {
                final isSelected =
                    controller.totalDuration.inSeconds == preset.$2;
                return _buildPresetButton(
                  label: preset.$1,
                  seconds: preset.$2,
                  isSelected: isSelected,
                  onPressed: () {
                    controller.reset(Duration(seconds: preset.$2));
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPresetButton({
    required String label,
    required int seconds,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF3498DB) : const Color(0xFFBDC3C7),
          width: 2,
        ),
      ),
      child: Material(
        color: isSelected
            ? const Color(0xFF3498DB).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF3498DB)
                    : const Color(0xFF7F8C8D),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaticExamplesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Static Examples',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Different progress states and styles',
            style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
          ),
          const SizedBox(height: 30),

          // Row of static timers showing different states
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildStaticTimer('Full', 1.0, Colors.green),
              _buildStaticTimer('75%', 0.75, Colors.blue),
              _buildStaticTimer('Warning', 0.4, Colors.orange),
              _buildStaticTimer('Critical', 0.15, Colors.red),
              _buildStaticTimer('Empty', 0.0, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaticTimer(String label, double progress, Color color) {
    return Column(
      children: [
        AnalogTimer(
          progress: progress,
          size: 120,
          remainingTimeText: label,
          timeTextSize: 16,
          progressColor: color,
          enableWarningColors: false,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }
}
