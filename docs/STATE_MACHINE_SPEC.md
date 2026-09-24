# ⚙️ FINITE STATE MACHINE (FSM) SPECIFICATION
## Module: Focus Session Lifecycle
**Status:** Approved Technical Specification  
**Parent Document:** `SPECIFICATIONS_FLIP_TO_FOCUS.md`  

---

## 1. ARCHITECTURAL OVERVIEW

The focus session in *Flip to Focus* is governed by a strict, deterministic Finite State Machine (**FSM**). No hybrid or ambiguous states are permitted.

```
                  +-----------------------------------+
                  |               IDLE                |
                  +-----------------------------------+
                                    |
                            EVENT: ON_FLIP_DOWN
                                    |
                                    v
                  +-----------------------------------+
                  |              ARMING               |
                  |         (Duration: 3.0s)          |
                  +-----------------------------------+
                       /                            \
           EVENT: ON_FLIP_UP                 T >= 3.0s elapsed
                     /                                \
                    v                                  v
              Back to IDLE            +-----------------------------------+
                                      |             FOCUSING              |
                                      +-----------------------------------+
                                           /                        \
                               EVENT: ON_FLIP_UP              T >= Target Duration
                                         /                            \
                                        v                              v
                         +-----------------------------+         Transition to COMPLETED
                         |        GRACE_PERIOD         |
                         |       (Duration: 10.0s)     |
                         +-----------------------------+
                            /             |            \
              EVENT: ON_FLIP_DOWN   EVENT: PAUSE_2MIN  T >= 10.0s / ABANDON
                          /               |              \
                         v                v               v
                Back to FOCUSING     +---------+     +-------------------+
                                     | PAUSED  |     |    INTERRUPTED    |
                                     |  (2min) |     +-------------------+
                                     +---------+
```

---

## 2. DETAILED STATES TABLE

| State | Description | Hardware / OS Behavior | UI Displayed |
| :--- | :--- | :--- | :--- |
| **`IDLE`** | Waiting for user physical gesture. | Low-frequency sensor listening. DND OFF. | Cockpit View: visual prompt to flip phone. |
| **`ARMING`** | Phone placed face-down; 3s stabilization delay to prevent false starts. | Internal counter ticking without vibration. | Screen off / blank. |
| **`FOCUSING`** | Deep work session active. | **Foreground Service ON**, Partial WakeLock, **DND ON**. Start haptic pulse confirmed. | Screen off. In background, deep work counter ticks every second. |
| **`GRACE_PERIOD`** | Phone lifted prematurely. 10-second countdown active. | Screen turned on. Pulsing alert vibration. | Grace Alert Overlay: countdown ring, "Emergency Pause (2 min)" and "Abandon" buttons. |
| **`PAUSED`** | Legitimate emergency pause granted (2 min max) for 2FA or urgent call. | Focus timer frozen. Pause countdown visible. | Pause screen with remaining pause time. |
| **`COMPLETED`** | Target focus duration reached successfully. | Success haptic vibration. DND restored. | Celebration screen + intention accomplishment confirmation. |
| **`INTERRUPTED`** | Grace period expired or user tapped "Abandon". | DND restored. Partial session duration saved. | Summary screen showing focus minutes preserved. |

---

## 3. EVENT TRANSITION MATRIX

| Current State | Triggering Event | Target State | Associated Actions |
| :--- | :--- | :--- | :--- |
| `IDLE` | `ON_FLIP_DOWN` | `ARMING` | Start 3-second arming timer. |
| `ARMING` | `ON_FLIP_UP` | `IDLE` | Cancel arming timer (false start). |
| `ARMING` | `TIMER_ARMING_EXPIRED` | `FOCUSING` | Trigger start haptic pulse.<br>Enable Android DND.<br>Start Foreground Service.<br>Create session record (`started_at = now()`). |
| `FOCUSING` | `TARGET_TIME_REACHED` | `COMPLETED` | Trigger success haptic vibration.<br>Disable DND.<br>Stop Foreground Service.<br>Update session record `status = 'completed'`. |
| `FOCUSING` | `ON_FLIP_UP` | `GRACE_PERIOD` | Turn screen on.<br>Start 10s grace countdown.<br>Trigger urgent haptic pulse. |
| `GRACE_PERIOD`| `ON_FLIP_DOWN` | `FOCUSING` | Cancel grace countdown.<br>Turn screen off.<br>Trigger resume haptic pulse.<br>Increment pause count. |
| `GRACE_PERIOD`| `GRACE_EXPIRED` | `INTERRUPTED` | Disable DND.<br>Stop Foreground Service.<br>Compute `actual_duration_seconds`.<br>Save session record `status = 'interrupted'`. |
| `GRACE_PERIOD`| `USER_CLICK_PAUSE` | `PAUSED` | Start 120s pause countdown.<br>Freeze focus timer. |
| `PAUSED` | `ON_FLIP_DOWN` | `FOCUSING` | Resume active session.<br>Restore DND and turn screen off. |
| `PAUSED` | `PAUSE_EXPIRED` | `INTERRUPTED` | If not placed face down within 2 minutes, terminate session. |
| `COMPLETED` | `USER_DISMISS` | `IDLE` | Reset Cockpit for next session. |
| `INTERRUPTED`| `USER_DISMISS` | `IDLE` | Reset Cockpit for next session. |

---

## 4. DART IMPLEMENTATION CONTRACT (RIVERPOD NOTIFIER)

In Dart / Flutter, this FSM is represented by an immutable state model:

```dart
enum SessionStatus {
  idle,
  arming,
  focusing,
  gracePeriod,
  paused,
  completed,
  interrupted,
}

class FocusSessionState {
  final SessionStatus status;
  final DateTime? startedAt;
  final int elapsedSeconds;
  final int? targetMinutes;
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
}
```
