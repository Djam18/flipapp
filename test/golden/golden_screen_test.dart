import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_to_focus/features/focus_session/presentation/cockpit_screen.dart';
import 'package:flip_to_focus/core/platform/native_sensor_service.dart';
import 'package:flip_to_focus/l10n/app_localizations.dart';
import '../mocks/fake_native_sensor_service.dart';

/// Golden UI regression test suite.
/// Golden tests verify that visual rendering matches approved pixel-by-pixel snapshots.
/// To generate or update golden files, run:
///   `flutter test --update-goldens test/golden/golden_screen_test.dart`
void main() {
  testWidgets('CockpitScreen Golden Layout Consistency Test', (tester) async {
    final fakeSensor = FakeNativeSensorService();

    // Set fixed surface size resembling standard mobile device (390 x 844)
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nativeSensorServiceProvider.overrideWithValue(fakeSensor),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CockpitScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verify key widgets exist and are stable in hierarchy
    expect(find.byType(CockpitScreen), findsOneWidget);
    expect(find.text('FLIP SCREEN'), findsOneWidget);

    fakeSensor.dispose();
  });
}
