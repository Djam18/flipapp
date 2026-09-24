import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_to_focus/features/focus_session/presentation/session_summary_screen.dart';

void main() {
  testWidgets('SessionSummaryScreen displays correct metrics, intention, and action buttons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SessionSummaryScreen(
            durationMinutes: 25,
            intentionTag: '#code',
            isCompleted: true,
          ),
        ),
      ),
    );

    // Verify key titles and values
    expect(find.text('SESSION FORGED'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('MINUTES DEEP WORK'), findsOneWidget);
    expect(find.text('#code'), findsOneWidget);
    expect(find.text('RETURN TO COCKPIT'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);

    // Verify reflection text field is present
    expect(find.byType(TextField), findsOneWidget);
  });
}
