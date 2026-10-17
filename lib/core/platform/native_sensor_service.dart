import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nativeSensorServiceProvider = Provider<NativeSensorService>((ref) {
  return NativeSensorService();
});

/// Dart service bridging with Android native Platform Channels (Kotlin).
class NativeSensorService {
  static const EventChannel _sensorChannel =
      EventChannel('com.fliptofocus.app/flip_sensor');
  static const MethodChannel _dndChannel =
      MethodChannel('com.fliptofocus.app/dnd');
  static const MethodChannel _vibrationChannel =
      MethodChannel('com.fliptofocus.app/vibration');
  static const MethodChannel _notificationChannel =
      MethodChannel('com.fliptofocus.app/notifications');

  /// Continuous stream emitting `true` when phone rests face-down on a desk,
  /// and `false` when lifted.
  Stream<bool> get flipStream {
    return _sensorChannel.receiveBroadcastStream().map((event) {
      if (event == 'FLIP_DOWN') {
        return true;
      } else if (event == 'FLIP_UP') {
        return false;
      }
      return false;
    });
  }

  /// Verifies whether the app holds Do Not Disturb access policy permission
  Future<bool> isDndGranted() async {
    try {
      final bool? isGranted = await _dndChannel.invokeMethod<bool>('isDndGranted');
      return isGranted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Directs user to Android system settings to grant DND access permission
  Future<void> requestDndPermission() async {
    try {
      await _dndChannel.invokeMethod('requestDndPermission');
    } catch (_) {}
  }

  /// Toggles Do Not Disturb mode on or off
  Future<bool> setDndEnabled(bool enable) async {
    try {
      final bool? success = await _dndChannel.invokeMethod<bool>(
        'setDndEnabled',
        {'enable': enable},
      );
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Gentle haptic pulse for tactile confirmation (native hardware vibration + fallback)
  void triggerHapticFeedback() {
    try {
      _vibrationChannel.invokeMethod('vibrate', {'type': 'light'});
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }

  /// Medium haptic impact for session start and target completion
  void triggerSuccessHaptic() {
    try {
      _vibrationChannel.invokeMethod('vibrate', {'type': 'success'});
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Urgent haptic alert for grace period countdown
  void triggerAlertHaptic() {
    try {
      _vibrationChannel.invokeMethod('vibrate', {'type': 'alert'});
    } catch (_) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Displays an immediate notification when user enters emergency pause
  Future<void> showPauseNotification({
    required String title,
    required String message,
  }) async {
    try {
      await _notificationChannel.invokeMethod('showPauseNotification', {
        'title': title,
        'message': message,
      });
    } catch (_) {}
  }

  /// Schedules native background reminders for 60s warning and 120s expiration
  Future<void> schedulePauseReminder({
    int firstReminderSeconds = 60,
    required String reminderTitle,
    required String reminderMessage,
    int expireSeconds = 120,
    required String expireTitle,
    required String expireMessage,
  }) async {
    try {
      await _notificationChannel.invokeMethod('schedulePauseReminder', {
        'firstReminderSeconds': firstReminderSeconds,
        'reminderTitle': reminderTitle,
        'reminderMessage': reminderMessage,
        'expireSeconds': expireSeconds,
        'expireTitle': expireTitle,
        'expireMessage': expireMessage,
      });
    } catch (_) {}
  }

  /// Cancels all active and scheduled pause notifications
  Future<void> cancelNotifications() async {
    try {
      await _notificationChannel.invokeMethod('cancelNotifications');
    } catch (_) {}
  }
}
