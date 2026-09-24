import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_to_focus/core/platform/native_sensor_service.dart';
import 'package:flip_to_focus/features/focus_session/domain/focus_session_state.dart';
import 'package:flip_to_focus/features/focus_session/presentation/focus_session_controller.dart';

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

void main() {
  group('FocusSessionNotifier Finite State Machine Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          nativeSensorServiceProvider.overrideWithValue(FakeNativeSensorService()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state should be idle with 25 minutes target', () {
      final state = container.read(focusSessionProvider);
      expect(state.status, equals(SessionStatus.idle));
      expect(state.targetMinutes, equals(25));
      expect(state.elapsedSeconds, equals(0));
      expect(state.pauseCount, equals(0));
    });

    test('onFlipDown transitions status from idle to arming', () {
      final notifier = container.read(focusSessionProvider.notifier);
      notifier.onFlipDown();

      final state = container.read(focusSessionProvider);
      expect(state.status, equals(SessionStatus.arming));
    });

    test('onFlipUp during arming cancels stabilization and resets to idle', () {
      final notifier = container.read(focusSessionProvider.notifier);
      notifier.onFlipDown();
      expect(container.read(focusSessionProvider).status, equals(SessionStatus.arming));

      notifier.onFlipUp();
      expect(container.read(focusSessionProvider).status, equals(SessionStatus.idle));
    });

    test('setTargetDuration updates targetMinutes', () {
      final notifier = container.read(focusSessionProvider.notifier);
      notifier.setTargetDuration(45);

      final state = container.read(focusSessionProvider);
      expect(state.targetMinutes, equals(45));
    });

    test('setIntention updates intentionTag', () {
      final notifier = container.read(focusSessionProvider.notifier);
      notifier.setIntention('Deep Writing');

      final state = container.read(focusSessionProvider);
      expect(state.intentionTag, equals('Deep Writing'));
    });

    test('abandonSession transitions to interrupted', () {
      final notifier = container.read(focusSessionProvider.notifier);
      notifier.abandonSession();

      final state = container.read(focusSessionProvider);
      expect(state.status, equals(SessionStatus.interrupted));
    });

    test('resetToIdle brings state back to initial', () {
      final notifier = container.read(focusSessionProvider.notifier);
      notifier.abandonSession();
      notifier.resetToIdle();

      final state = container.read(focusSessionProvider);
      expect(state.status, equals(SessionStatus.idle));
      expect(state.elapsedSeconds, equals(0));
    });
  });
}
