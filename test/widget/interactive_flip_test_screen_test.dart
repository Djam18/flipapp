import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_to_focus/features/settings/presentation/interactive_flip_test_screen.dart';
import 'package:flip_to_focus/core/platform/native_sensor_service.dart';
import '../mocks/fake_native_sensor_service.dart';

void main() {
  testWidgets('InteractiveFlipTestScreen toggles between face up and face down simulation', (tester) async {
    final fakeSensor = FakeNativeSensorService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nativeSensorServiceProvider.overrideWithValue(fakeSensor),
        ],
        child: const MaterialApp(
          home: InteractiveFlipTestScreen(),
        ),
      ),
    );

    // Initial state: Face up
    expect(find.text('HARDWARE CALIBRATION'), findsOneWidget);
    expect(find.text('STATUS: FACE UP (WAITING)'), findsOneWidget);
    expect(find.text('Simulate Flip Down'), findsOneWidget);

    // Tap Simulate Flip Down
    await tester.tap(find.text('Simulate Flip Down'));
    await tester.pumpAndSettle();

    // Now state should be Face Down
    expect(find.text('STATUS: FACE DOWN (ARMED)'), findsOneWidget);
    expect(find.text('Simulate Flip Up'), findsOneWidget);
    expect(find.text('Successful Flips: 1'), findsOneWidget);

    fakeSensor.dispose();
  });
}
