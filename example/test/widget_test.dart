// Widget test for the Analog Timer Example app.

import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/analog_timer.dart';

import 'package:analog_timer_example/main.dart';

void main() {
  testWidgets('Analog Timer Example app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AnalogTimerExampleApp());

    // Verify that the app loads with the correct title
    expect(find.text('Analog Timer Demo'), findsOneWidget);
    
    // Verify that we have timer sections
    expect(find.text('Simple 60-Second Timer'), findsOneWidget);
    expect(find.text('2-Minute Custom Timer'), findsOneWidget);
    expect(find.text('Static Examples'), findsOneWidget);
    
    // Verify that analog timer widgets are present
    expect(find.byType(AnalogTimer), findsWidgets);
    
    // Verify control buttons are present
    expect(find.text('Start'), findsAtLeastNWidgets(2));
    expect(find.text('Reset'), findsAtLeastNWidgets(2));
  });
  
  testWidgets('Timer buttons are tappable', (WidgetTester tester) async {
    await tester.pumpWidget(const AnalogTimerExampleApp());
    
    // Wait for initial build
    await tester.pump();
    
    // Find and tap the first Start button - should not throw
    final startButtons = find.text('Start');
    expect(startButtons, findsAtLeastNWidgets(1));
    await tester.tap(startButtons.first);
    await tester.pump();
    
    // Find and tap Reset button - should not throw
    final resetButtons = find.text('Reset');
    expect(resetButtons, findsAtLeastNWidgets(1));
    await tester.tap(resetButtons.first);
    await tester.pump();
    
    // Verify static timers are displayed correctly
    expect(find.text('Full'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Warning'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Empty'), findsOneWidget);
  });
}
