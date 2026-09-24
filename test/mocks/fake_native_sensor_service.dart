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

  void dispose() {
    _controller.close();
  }
}
