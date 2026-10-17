import 'dart:async';
import 'package:flip_to_focus/core/platform/native_sensor_service.dart';

/// Reusable fake implementation of NativeSensorService for tests.
class FakeNativeSensorService extends NativeSensorService {
  final _controller = StreamController<bool>.broadcast();
  bool dndEnabled = false;
  int hapticCount = 0;
  int successHapticCount = 0;
  int alertHapticCount = 0;

  @override
  Stream<bool> get flipStream => _controller.stream;

  void emitFlip(bool isFlipped) {
    _controller.add(isFlipped);
  }

  @override
  void triggerHapticFeedback() {
    hapticCount++;
  }

  @override
  void triggerAlertHaptic() {
    alertHapticCount++;
  }

  @override
  void triggerSuccessHaptic() {
    successHapticCount++;
  }

  @override
  Future<bool> setDndEnabled(bool enabled) async {
    dndEnabled = enabled;
    return true;
  }

  @override
  Future<bool> isDndGranted() async => true;

  @override
  Future<void> requestDndPermission() async {}

  int pauseNotificationCount = 0;
  int cancelNotificationCount = 0;

  @override
  Future<void> showPauseNotification({required String title, required String message}) async {
    pauseNotificationCount++;
  }

  @override
  Future<void> schedulePauseReminder({
    int firstReminderSeconds = 60,
    required String reminderTitle,
    required String reminderMessage,
    int expireSeconds = 120,
    required String expireTitle,
    required String expireMessage,
  }) async {
    pauseNotificationCount++;
  }

  @override
  Future<void> cancelNotifications() async {
    cancelNotificationCount++;
  }

  void dispose() {
    _controller.close();
  }
}
