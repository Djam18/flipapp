import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_to_focus/features/analytics/presentation/session_history_screen.dart';
import 'package:flip_to_focus/features/analytics/presentation/analytics_controller.dart';
import 'package:flip_to_focus/features/analytics/domain/analytics_data.dart';
import 'package:flip_to_focus/features/focus_session/domain/focus_session_record.dart';
import 'package:flip_to_focus/l10n/app_localizations.dart';

class MockAnalyticsNotifier extends AnalyticsNotifier {
  @override
  Future<AnalyticsData> build() async {
    final now = DateTime.now();
    return AnalyticsData(
      todayFocusMinutes: 50,
      totalDeepWorkHours: 5,
      currentStreakDays: 3,
      totalSessionsCompleted: 2,
      weeklyHeatmap: const [],
      recentSessions: [
        FocusSessionRecord(
          id: 'test-1',
          startedAt: now.subtract(const Duration(hours: 2)),
          endedAt: now.subtract(const Duration(hours: 1, minutes: 35)),
          targetDurationMinutes: 25,
          actualDurationSeconds: 1500,
          intentionTag: '#writing',
          status: 'completed',
          pauseCount: 0,
        ),
        FocusSessionRecord(
          id: 'test-2',
          startedAt: now.subtract(const Duration(hours: 5)),
          endedAt: now.subtract(const Duration(hours: 4, minutes: 50)),
          targetDurationMinutes: 25,
          actualDurationSeconds: 600,
          intentionTag: '#code',
          status: 'interrupted',
          pauseCount: 1,
        ),
      ],
    );
  }
}

void main() {
  testWidgets('SessionHistoryScreen renders list of sessions with filter chips', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsProvider.overrideWith(() => MockAnalyticsNotifier()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SessionHistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify filter chips and session card tags
    expect(find.text('ALL'), findsOneWidget);
    expect(find.text('#writing'), findsOneWidget);
    expect(find.text('#code'), findsOneWidget);
    expect(find.text('COMPLETED'), findsNWidgets(2));
    expect(find.text('INTERRUPTED'), findsNWidgets(2));
  });
}
