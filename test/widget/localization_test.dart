import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_to_focus/core/platform/native_sensor_service.dart';
import 'package:flip_to_focus/main.dart';
import 'package:flip_to_focus/features/analytics/presentation/analytics_controller.dart';
import 'package:flip_to_focus/features/analytics/domain/analytics_data.dart';
import 'package:flip_to_focus/features/settings/presentation/settings_controller.dart';
import 'package:flip_to_focus/features/settings/domain/settings_state.dart';
import '../mocks/fake_native_sensor_service.dart';

class LocalizedSettingsNotifier extends SettingsNotifier {
  final String initialLang;
  LocalizedSettingsNotifier({this.initialLang = 'en'});

  @override
  SettingsState build() {
    return SettingsState(
      hasSeenOnboarding: true,
      languageCode: initialLang,
    );
  }
}

class LocalizedAnalyticsNotifier extends AnalyticsNotifier {
  @override
  Future<AnalyticsData> build() async {
    return const AnalyticsData(
      todayFocusMinutes: 45,
      totalDeepWorkHours: 2,
      currentStreakDays: 3,
      totalSessionsCompleted: 5,
      weeklyHeatmap: [],
      recentSessions: [],
    );
  }
}

void main() {
  testWidgets('Interface renders in English by default and switches instantly to French', (WidgetTester tester) async {
    final fakeSensor = FakeNativeSensorService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nativeSensorServiceProvider.overrideWithValue(fakeSensor),
          settingsProvider.overrideWith(() => LocalizedSettingsNotifier()),
          analyticsProvider.overrideWith(() => LocalizedAnalyticsNotifier()),
        ],
        child: const FlipToFocusApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Initial State: Cockpit screen in English
    expect(find.text('FLIP SCREEN'), findsOneWidget);
    expect(find.text('FACE DOWN TO FOCUS'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('45m Deep Work'), findsOneWidget);

    // 2. Navigate to Settings screen in English
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('SETTINGS & ERGONOMICS'), findsOneWidget);
    expect(find.text('GRACE PERIOD DURATION'), findsOneWidget);
    expect(find.text('Pickup Tolerance'), findsOneWidget);
    expect(find.text('HARDWARE & DISTRACTION SHIELD'), findsOneWidget);
    expect(find.text('Auto Do Not Disturb (DND)'), findsOneWidget);
    expect(find.text('Haptic Pulses'), findsOneWidget);
    expect(find.text('OLED True Blackout'), findsOneWidget);
    expect(find.text('SYSTEM PERMISSIONS'), findsOneWidget);
    expect(find.text('DATA PRIVACY & STORAGE'), findsOneWidget);
    expect(find.text('Manifesto & About'), findsOneWidget);
    expect(find.text('Wipe All Historical Data'), findsOneWidget);

    // 3. Switch Language to Français
    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pumpAndSettle();

    // Dialog title in English before switch
    expect(find.text('Select interface language'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);

    // Tap Français option
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    // 4. Verify Settings screen is now fully in French
    expect(find.text('RÉGLAGES & ERGONOMIE'), findsOneWidget);
    expect(find.text('DÉLAI DE GRÂCE'), findsOneWidget);
    expect(find.text('Tolérance de reprise'), findsOneWidget);
    expect(find.text('LANGUE'), findsOneWidget);
    expect(find.text('BOUCLIER MATÉRIEL & DISTRACTIONS'), findsOneWidget);
    expect(find.text('Ne Pas Déranger Automatique (DND)'), findsOneWidget);
    expect(find.text('Impulsions Haptiques'), findsOneWidget);
    expect(find.text('Noir Absolu OLED'), findsOneWidget);
    expect(find.text('AUTORISATIONS SYSTÈME'), findsOneWidget);
    expect(find.text('Accès au mode Ne Pas Déranger'), findsOneWidget);
    expect(find.text('Gérer'), findsOneWidget);
    expect(find.text('CONFIDENTIALITÉ & DONNÉES'), findsOneWidget);
    expect(find.text('Manifeste & À propos'), findsOneWidget);
    expect(find.text('Effacer toutes les données'), findsOneWidget);

    // 5. Navigate back to Cockpit and verify it is in French
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text("RETOURNEZ L'ÉCRAN"), findsOneWidget);
    expect(find.text('FACE CONTRE TABLE POUR VOUS CONCENTRER'), findsOneWidget);
    expect(find.text("AUJOURD'HUI"), findsOneWidget);
    expect(find.text('45m Deep Work'), findsOneWidget);

    // 6. Navigate to Performance (Analytics) screen and verify it is in French
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();

    expect(find.text('PERFORMANCES'), findsOneWidget);
    expect(find.text("AUJOURD'HUI"), findsOneWidget);
    expect(find.text('SÉRIE'), findsOneWidget);
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('RYTHME DE FOCUS'), findsOneWidget);
    expect(find.text('7 DERNIERS JOURS'), findsOneWidget);
    expect(find.text('PALIERS DE DISCIPLINE'), findsOneWidget);
    expect(find.text('JOURNAL DE SESSIONS'), findsOneWidget);

    fakeSensor.dispose();
  });
}
