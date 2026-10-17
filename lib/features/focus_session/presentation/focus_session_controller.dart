import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/platform/native_sensor_service.dart';
import '../../analytics/presentation/analytics_controller.dart';
import '../data/focus_session_repository.dart';
import '../domain/focus_session_state.dart';

final focusSessionProvider =
    NotifierProvider<FocusSessionNotifier, FocusSessionState>(() {
  return FocusSessionNotifier();
});

/// Riverpod 3.x controller orchestrating the Finite State Machine (FSM) and physical sensors.
class FocusSessionNotifier extends Notifier<FocusSessionState> {
  Timer? _sessionTimer;
  Timer? _graceTimer;
  Timer? _armingTimer;
  Timer? _pauseTimer;
  DateTime? _pauseExpiresAt;
  StreamSubscription<bool>? _sensorSubscription;

  late NativeSensorService _sensorService;
  late FocusSessionRepository _repository;

  @override
  FocusSessionState build() {
    _sensorService = ref.read(nativeSensorServiceProvider);
    _repository = ref.read(focusSessionRepositoryProvider);

    // Listen to real-time events from the Android native Platform Channel
    _listenToSensors();

    // Clean up timers and sensor streams when provider is destroyed
    ref.onDispose(() {
      _sessionTimer?.cancel();
      _graceTimer?.cancel();
      _armingTimer?.cancel();
      _pauseTimer?.cancel();
      _sensorSubscription?.cancel();
      _sensorService.cancelNotifications();
    });

    return FocusSessionState.initial();
  }

  /// Subscribes to Android native EventChannel
  void _listenToSensors() {
    _sensorSubscription = _sensorService.flipStream.listen(
      (isFlippedDown) {
        if (isFlippedDown) {
          onFlipDown();
        } else {
          onFlipUp();
        }
      },
      onError: (_) {
        // Silently ignore if running on an emulator without physical sensors
      },
    );
  }

  /// Sets target focus duration in minutes (null = open flow)
  void setTargetDuration(int? minutes) {
    if (state.isIdle) {
      _sensorService.triggerHapticFeedback();
      state = state.copyWith(targetMinutes: minutes);
    }
  }

  /// Sets task intention tag (e.g., "Code", "Writing")
  void setIntention(String tag) {
    state = state.copyWith(intentionTag: tag);
  }

  /// HARDWARE EVENT: Phone placed face down on desk
  void onFlipDown() {
    if (state.status == SessionStatus.idle) {
      // 3-second arming delay to prevent accidental triggers
      state = state.copyWith(status: SessionStatus.arming);
      _armingTimer?.cancel();
      _armingTimer = Timer(const Duration(seconds: 3), () {
        _startFocusing();
      });
    } else if (state.status == SessionStatus.gracePeriod ||
        state.status == SessionStatus.paused) {
      // Phone put back down before countdown expires: session saved!
      _graceTimer?.cancel();
      _pauseTimer?.cancel();
      _pauseExpiresAt = null;
      _sensorService.cancelNotifications();
      _sensorService.triggerHapticFeedback();
      state = state.copyWith(
        status: SessionStatus.focusing,
        remainingGraceSeconds: 10,
        remainingPauseSeconds: 120,
      );
      _resumeSessionTimer();
    }
  }

  /// HARDWARE EVENT: Phone lifted from desk
  void onFlipUp() {
    if (state.status == SessionStatus.arming) {
      // False start cancelled before 3-second arming threshold
      _armingTimer?.cancel();
      state = state.copyWith(status: SessionStatus.idle);
    } else if (state.status == SessionStatus.focusing) {
      // Interruption: trigger 10-second grace period
      _sessionTimer?.cancel();
      _sensorService.triggerAlertHaptic();
      state = state.copyWith(
        status: SessionStatus.gracePeriod,
        remainingGraceSeconds: 10,
      );
      _startGraceCountdown();
    }
  }

  /// Commences active focus session
  void _startFocusing() {
    _sensorService.triggerSuccessHaptic();
    _sensorService.setDndEnabled(true);

    state = state.copyWith(
      status: SessionStatus.focusing,
      startedAt: DateTime.now(),
      elapsedSeconds: 0,
      remainingGraceSeconds: 10,
    );
    _resumeSessionTimer();
  }

  void _resumeSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newElapsed = state.elapsedSeconds + 1;

      // Check if target duration reached
      if (state.targetMinutes != null &&
          newElapsed >= (state.targetMinutes! * 60)) {
        timer.cancel();
        _sensorService.triggerSuccessHaptic();
        _sensorService.setDndEnabled(false);
        state = state.copyWith(
          status: SessionStatus.completed,
          elapsedSeconds: newElapsed,
        );
        _persistSession(status: 'completed', elapsed: newElapsed);
      } else {
        state = state.copyWith(elapsedSeconds: newElapsed);
      }
    });
  }

  /// Countdown for 10-second grace period
  void _startGraceCountdown() {
    _graceTimer?.cancel();
    _graceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingGraceSeconds > 1) {
        state = state.copyWith(
          remainingGraceSeconds: state.remainingGraceSeconds - 1,
        );
      } else {
        timer.cancel();
        // Grace period expired -> Session interrupted
        _sensorService.setDndEnabled(false);
        state = state.copyWith(
          status: SessionStatus.interrupted,
          remainingGraceSeconds: 0,
        );
        _persistSession(status: 'interrupted', elapsed: state.elapsedSeconds);
      }
    });
  }

  /// Persists session record into SQLite and refreshes analytics
  void _persistSession({required String status, required int elapsed}) {
    if (elapsed < 5) return; // Don't persist micro-sessions under 5 seconds
    final now = DateTime.now();
    final started = state.startedAt ?? now.subtract(Duration(seconds: elapsed));
    final id = now.millisecondsSinceEpoch.toString();

    _repository.saveSession(
      id: id,
      startedAt: started,
      endedAt: now,
      targetDurationMinutes: state.targetMinutes,
      actualDurationSeconds: elapsed,
      intentionTag: state.intentionTag,
      status: status,
      pauseCount: state.pauseCount,
    ).then((_) {
      ref.invalidate(analyticsProvider);
    });
  }

  /// Activates 2-minute emergency pause
  void pauseEmergency() {
    if (state.status == SessionStatus.gracePeriod) {
      _graceTimer?.cancel();
      _pauseTimer?.cancel();
      _sensorService.triggerHapticFeedback();

      _pauseExpiresAt = DateTime.now().add(const Duration(seconds: 120));

      // Schedule native background notifications for immediate status, 60s reminder, and 120s timeout
      _sensorService.showPauseNotification(
        title: 'Pause d\'urgence active (2:00)',
        message: 'Placez votre téléphone face contre table pour reprendre votre session.',
      );

      _sensorService.schedulePauseReminder(
        firstReminderSeconds: 60,
        reminderTitle: 'Plus qu\'une minute de pause !',
        reminderMessage: 'Reprenez votre session de Deep Work avant que le temps ne soit écoulé.',
        expireSeconds: 120,
        expireTitle: 'Pause de 2 minutes expirée',
        expireMessage: 'Votre session a été interrompue et sauvegardée.',
      );

      state = state.copyWith(
        status: SessionStatus.paused,
        pauseCount: state.pauseCount + 1,
        remainingPauseSeconds: 120,
      );

      _startPauseCountdown();
    }
  }

  void _startPauseCountdown() {
    _pauseTimer?.cancel();
    _pauseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_pauseExpiresAt == null) {
        timer.cancel();
        return;
      }

      final remaining = _pauseExpiresAt!.difference(DateTime.now()).inSeconds;
      if (remaining > 0) {
        state = state.copyWith(remainingPauseSeconds: remaining);
      } else {
        timer.cancel();
        _expirePauseSession();
      }
    });
  }

  void _expirePauseSession() {
    _pauseTimer?.cancel();
    _pauseExpiresAt = null;
    _sensorService.setDndEnabled(false);
    _sensorService.cancelNotifications();
    _persistSession(status: 'interrupted', elapsed: state.elapsedSeconds);
    state = state.copyWith(
      status: SessionStatus.interrupted,
      remainingPauseSeconds: 0,
    );
  }

  /// Synchronizes elapsed time when returning from out-of-app background
  void syncLifecycle(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed &&
        state.status == SessionStatus.paused &&
        _pauseExpiresAt != null) {
      final remaining = _pauseExpiresAt!.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        _expirePauseSession();
      } else {
        state = state.copyWith(remainingPauseSeconds: remaining);
      }
    }
  }

  /// Voluntarily gives up the session
  void abandonSession() {
    _sessionTimer?.cancel();
    _graceTimer?.cancel();
    _pauseTimer?.cancel();
    _pauseExpiresAt = null;
    _sensorService.cancelNotifications();
    _sensorService.setDndEnabled(false);
    _persistSession(status: 'interrupted', elapsed: state.elapsedSeconds);
    state = state.copyWith(status: SessionStatus.interrupted);
  }

  /// Resets back to idle state
  void resetToIdle() {
    _sessionTimer?.cancel();
    _graceTimer?.cancel();
    _armingTimer?.cancel();
    _pauseTimer?.cancel();
    _pauseExpiresAt = null;
    _sensorService.cancelNotifications();
    _sensorService.setDndEnabled(false);
    state = FocusSessionState.initial();
  }
}
