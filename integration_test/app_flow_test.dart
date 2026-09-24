import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flip_to_focus/main.dart';
import 'package:flip_to_focus/core/platform/native_sensor_service.dart';
import '../test/mocks/fake_native_sensor_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete End-to-End User Journey: Cockpit -> Analytics -> Settings', (tester) async {
    final fakeSensor = FakeNativeSensorService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nativeSensorServiceProvider.overrideWithValue(fakeSensor),
        ],
        child: const FlipToFocusApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app starts in either Onboarding or Cockpit
    final hasSkip = find.text('SKIP');
    if (hasSkip.evaluate().isNotEmpty) {
      await tester.tap(hasSkip);
      await tester.pumpAndSettle();
    }

    // Now in Cockpit
    expect(find.text('FLIP SCREEN'), findsOneWidget);

    // Select 45 min duration
    final duration45 = find.text('45 min');
    if (duration45.evaluate().isNotEmpty) {
      await tester.tap(duration45);
      await tester.pumpAndSettle();
      expect(find.text('45:00'), findsOneWidget);
    }

    // Open Performance & Analytics screen
    final analyticsIcon = find.byIcon(Icons.bar_chart_outlined);
    expect(analyticsIcon, findsOneWidget);
    await tester.tap(analyticsIcon);
    await tester.pumpAndSettle();

    // Verify Analytics screen
    expect(find.text('PERFORMANCE'), findsOneWidget);

    // Return to Cockpit
    final backIcon = find.byIcon(Icons.arrow_back_ios_new_rounded);
    await tester.tap(backIcon);
    await tester.pumpAndSettle();

    // Open Settings
    final settingsIcon = find.byIcon(Icons.settings_outlined);
    expect(settingsIcon, findsOneWidget);
    await tester.tap(settingsIcon);
    await tester.pumpAndSettle();

    // Verify Settings screen
    expect(find.text('SETTINGS & ERGONOMICS'), findsOneWidget);

    // Return to Cockpit
    final settingsBack = find.byIcon(Icons.arrow_back_ios_rounded);
    await tester.tap(settingsBack);
    await tester.pumpAndSettle();

    expect(find.text('FLIP SCREEN'), findsOneWidget);

    fakeSensor.dispose();
  });
}
