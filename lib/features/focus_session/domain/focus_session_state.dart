/// Strict and deterministic states of the Finite State Machine (FSM).
enum SessionStatus {
  idle, // Waiting for phone flip (Cockpit view)
  arming, // 3-second stabilization threshold (phone resting face-down)
  focusing, // Deep focus active (screen off, DND ON)
  gracePeriod, // Phone picked up prematurely (10-second countdown)
  paused, // Emergency 2-minute legitimate pause
  completed, // Target duration accomplished successfully
  interrupted, // Session aborted or grace timer expired
}

/// Immutable focus session state managed by Riverpod.
class FocusSessionState {
  final SessionStatus status;
  final DateTime? startedAt;
  final int elapsedSeconds;
  final int? targetMinutes; // null = Open flow / free timer
  final int remainingGraceSeconds;
  final int remainingPauseSeconds;
  final String? intentionTag;
  final int pauseCount;

  const FocusSessionState({
    required this.status,
    this.startedAt,
    this.elapsedSeconds = 0,
    this.targetMinutes = 25,
    this.remainingGraceSeconds = 10,
    this.remainingPauseSeconds = 120,
    this.intentionTag,
    this.pauseCount = 0,
  });

  /// Initial state on app cold start
  factory FocusSessionState.initial() {
    return const FocusSessionState(
      status: SessionStatus.idle,
      targetMinutes: 25,
    );
  }

  FocusSessionState copyWith({
    SessionStatus? status,
    DateTime? startedAt,
    int? elapsedSeconds,
    int? targetMinutes,
    int? remainingGraceSeconds,
    int? remainingPauseSeconds,
    String? intentionTag,
    int? pauseCount,
  }) {
    return FocusSessionState(
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      remainingGraceSeconds: remainingGraceSeconds ?? this.remainingGraceSeconds,
      remainingPauseSeconds: remainingPauseSeconds ?? this.remainingPauseSeconds,
      intentionTag: intentionTag ?? this.intentionTag,
      pauseCount: pauseCount ?? this.pauseCount,
    );
  }

  bool get isFocusing => status == SessionStatus.focusing;
  bool get isGracePeriod => status == SessionStatus.gracePeriod;
  bool get isPaused => status == SessionStatus.paused;
  bool get isIdle => status == SessionStatus.idle;
}
