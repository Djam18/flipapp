import 'package:flutter_test/flutter_test.dart';
import 'package:flip_to_focus/features/settings/domain/settings_state.dart';

void main() {
  group('SettingsState Tests', () {
    test('Default values follow ergonomic specifications', () {
      const state = SettingsState();
      expect(state.gracePeriodSeconds, equals(10));
      expect(state.hapticsEnabled, isTrue);
      expect(state.autoDndEnabled, isTrue);
      expect(state.screenOffSimulation, isTrue);
      expect(state.hasSeenOnboarding, isFalse);
    });

    test('copyWith updates fields accurately without mutation', () {
      const state = SettingsState();
      final updated = state.copyWith(
        gracePeriodSeconds: 20,
        hapticsEnabled: false,
        hasSeenOnboarding: true,
      );

      expect(updated.gracePeriodSeconds, equals(20));
      expect(updated.hapticsEnabled, isFalse);
      expect(updated.hasSeenOnboarding, isTrue);
      expect(updated.autoDndEnabled, isTrue); // Unchanged
    });
  });
}
