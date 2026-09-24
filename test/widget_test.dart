import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_to_focus/core/platform/native_sensor_service.dart';
import 'package:flip_to_focus/main.dart';
import 'package:flip_to_focus/features/analytics/presentation/analytics_controller.dart';
import 'package:flip_to_focus/features/analytics/domain/analytics_data.dart';
import 'package:flip_to_focus/features/settings/presentation/settings_controller.dart';
import 'package:flip_to_focus/features/settings/domain/settings_state.dart';

class FakeNativeSensorService extends NativeSensorService {
  @override
  Stream<bool> get flipStream => const Stream.empty();

  @override
  void triggerHapticFeedback() {}

  @override
  void triggerAlertHaptic() {}

  @override
  void triggerSuccessHaptic() {}

  @override
  Future<bool> setDndEnabled(bool enabled) async => true;
}

class TestAnalyticsNotifier extends AnalyticsNotifier {
  @override
  Future<AnalyticsData> build() async {
    final now = DateTime(2026, 9, 24);
    return AnalyticsData(
      todayFocusMinutes: 45,
      totalDeepWorkHours: 3,
      currentStreakDays: 5,
      totalSessionsCompleted: 8,
      weeklyHeatmap: [
        HeatmapDay(
          date: now.subtract(const Duration(days: 1)),
          dayLabel: 'M',
          totalMinutes: 25,
          intensityLevel: 1,
          isToday: false,
        ),
        HeatmapDay(
          date: now,
          dayLabel: 'T',
          totalMinutes: 60,
          intensityLevel: 3,
          isToday: true,
        ),
      ],
      recentSessions: const [],
    );
  }
}

class TestSettingsNotifier extends SettingsNotifier {
  final bool initialOnboarding;
  TestSettingsNotifier({this.initialOnboarding = true});

  @override
  SettingsState build() {
    return SettingsState(hasSeenOnboarding: initialOnboarding);
  }
}

void main() {
  testWidgets('New user sees Onboarding screen on first cold start', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nativeSensorServiceProvider.overrideWithValue(FakeNativeSensorService()),
          settingsProvider.overrideWith(() => TestSettingsNotifier(initialOnboarding: false)),
        ],
        child: const FlipToFocusApp(),
      ),
    );

    expect(find.text('THE PHYSICAL GESTURE'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);

    // Tap SKIP to proceed to Cockpit
    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();

    expect(find.text('FLIP SCREEN'), findsOneWidget);
  });

  testWidgets('Returning user boots directly into Cockpit screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nativeSensorServiceProvider.overrideWithValue(FakeNativeSensorService()),
          settingsProvider.overrideWith(() => TestSettingsNotifier(initialOnboarding: true)),
          analyticsProvider.overrideWith(() => TestAnalyticsNotifier()),
        ],
        child: const FlipToFocusApp(),
      ),
    );

    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('FLIP SCREEN'), findsOneWidget);
    expect(find.text('FACE DOWN TO FOCUS'), findsOneWidget);
  });

  testWidgets('Navigation: Cockpit -> Performance & Analytics screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nativeSensorServiceProvider.overrideWithValue(FakeNativeSensorService()),
          settingsProvider.overrideWith(() => TestSettingsNotifier(initialOnboarding: true)),
          analyticsProvider.overrideWith(() => TestAnalyticsNotifier()),
        ],
        child: const FlipToFocusApp(),
      ),
    );

    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();

    expect(find.text('PERFORMANCE'), findsOneWidget);
    expect(find.text('DEEP WORK RHYTHM'), findsOneWidget);
    expect(find.text('DISCIPLINE MILESTONES'), findsOneWidget);
    expect(find.text('SESSION LOGS'), findsOneWidget);
  });

  testWidgets('Navigation: Cockpit -> Settings -> About Manifesto screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nativeSensorServiceProvider.overrideWithValue(FakeNativeSensorService()),
          settingsProvider.overrideWith(() => TestSettingsNotifier(initialOnboarding: true)),
          analyticsProvider.overrideWith(() => TestAnalyticsNotifier()),
        ],
        child: const FlipToFocusApp(),
      ),
    );

    // Tap Settings gear
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('SETTINGS & ERGONOMICS'), findsOneWidget);
    expect(find.text('GRACE PERIOD DURATION'), findsOneWidget);
    expect(find.text('HARDWARE & DISTRACTION SHIELD'), findsOneWidget);

    // Scroll until Manifesto & About is visible, then tap
    await tester.scrollUntilVisible(find.text('Manifesto & About'), 100);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manifesto & About'));
    await tester.pumpAndSettle();

    expect(find.text('MANIFESTO & ABOUT'), findsOneWidget);
    expect(find.text('THE 1% MANIFESTO'), findsOneWidget);
    expect(find.text('LOCAL-FIRST PRIVACY'), findsOneWidget);
  });
}
