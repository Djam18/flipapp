import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_to_focus/features/focus_session/presentation/blackout_screen.dart';
import 'package:flip_to_focus/features/focus_session/presentation/focus_session_controller.dart';

import 'package:flip_to_focus/l10n/app_localizations.dart';

void main() {
  testWidgets('BlackoutScreen renders OLED blackout screen with elapsed counter', (tester) async {
    final container = ProviderContainer();
    // Simulate focusing state
    container.read(focusSessionProvider.notifier).onFlipDown(); // arming
    // Wait or set state
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlackoutScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 4));

    expect(find.text('RESTING FACE DOWN'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    container.read(focusSessionProvider.notifier).resetToIdle();
    container.dispose();
  });
}
