# 🏛️ ARCHITECTURE DECISION RECORDS (ADR)
## Project: Flip to Focus
**Last Updated:** 2026-09-24  
**Status:** Approved  

This document records the major technical architecture decisions for the project, their rationale ("Why this over that"), and their direct consequences on code, in alignment with the product vision defined in `SPECIFICATIONS_FLIP_TO_FOCUS.md`.

---

### TABLE OF CONTENTS (ADRs)

* [ADR-001: Flutter with Feature-First Clean Architecture](#adr-001-flutter-with-feature-first-clean-architecture)
* [ADR-002: State Management with Riverpod 3.x](#adr-002-state-management-with-riverpod-3x)
* [ADR-003: Local Persistence with Drift (Typed SQLite) vs NoSQL](#adr-003-local-persistence-with-drift-typed-sqlite-vs-nosql)
* [ADR-004: Hardware Sensor Fusion (Accelerometer + Proximity in Native Kotlin)](#adr-004-hardware-sensor-fusion-accelerometer--proximity-in-native-kotlin)
* [ADR-005: Process Preservation via Android Foreground Service](#adr-005-process-preservation-via-android-foreground-service)
* [ADR-006: Do Not Disturb (DND) Policy Management without External Servers](#adr-006-do-not-disturb-dnd-policy-management-without-external-servers)

---

### ADR-001: Flutter with Feature-First Clean Architecture

#### Context
We are developing a mobile application that must deliver 60/120 fps animations, feature an OLED black minimalist design, communicate closely with Android hardware sensors, and remain easily portable to iOS in the future.

#### Decision
We adopt **Flutter** with a **Feature-First Clean Architecture** approach (modular organization by feature: `focus_session`, `analytics`, `settings`), rather than a monolithic layer-first directory structure (`controllers/`, `views/`, `models/`).

#### Rationale
1. **Domain Isolation:** The business logic of deep work sessions (`features/focus_session`) is completely independent of the UI layer. Changing the visuals does not alter the FSM logic.
2. **Team Scalability:** In a lean 2-person team, feature isolation avoids merge conflicts and spaghetti coupling.

---

### ADR-002: State Management with Riverpod 3.x

#### Context
The app must manage continuous asynchronous streams: physical sensor events, timer intervals, and strict session state transitions.

#### Evaluated Options
* **Provider:** Lacks compile-time safety, prone to runtime `ProviderNotFoundException`.
* **Bloc / Cubit:** Robust but excessively verbose, requires significant boilerplate for simple states.
* **Riverpod 3.x (`NotifierProvider` / `Notifier<T>`):** Compile-time safe, native support for streams and auto-disposal, zero dependency on `BuildContext` for core logic.

#### Decision
We adopt **Riverpod 3.x (`NotifierProvider`)**.

#### Rationale
The focus session state machine must be triggered or paused from background services and native events without requiring a widget tree `BuildContext`.

---

### ADR-003: Local Persistence with Drift (Typed SQLite) vs NoSQL

#### Context
The application is **100% Offline-First**. Every session must be stored reliably to compute analytics: daily deep work totals, weekly trends, average session duration, and tag filtering.

#### Evaluated Options
* **SharedPreferences:** Unsuitable for relational lists and time-series data.
* **Hive / Isar (NoSQL key-value):** Fast for simple key reads, but limited for complex relational aggregations (e.g. `SUM(actual_duration_seconds) GROUP BY date`).
* **Drift (Typed SQLite for Dart):** Compile-time verified queries, schema migrations, and high-performance native SQLite execution.

#### Decision
We adopt **Drift (SQLite)**.

#### Rationale
A professional productivity tool relies on the integrity of its metrics. SQLite is the most battle-tested database engine in computing history. Drift brings type-safety to SQLite without blocking the UI thread.

---

### ADR-004: Hardware Sensor Fusion (Accelerometer + Proximity in Native Kotlin)

#### Context
Detecting that the phone is resting face-down on a desk must be instantaneous, free of false positives (e.g., walking with phone in pocket), and consume negligible battery.

#### Pitfall of Generic Flutter Packages
Generic sensor packages stream hundreds of raw coordinate events per second across the `MethodChannel` to Dart, overloading the bridge and draining CPU power.

#### Decision
Sensor fusion and noise filtering are performed **directly on the Android native side in Kotlin**. Kotlin emits an event to Flutter only when the state truly toggles:
* `FLIP_DOWN` (phone stabilized face-down on a surface)
* `FLIP_UP` (phone lifted)

#### Kotlin Decision Formula:
```kotlin
val isFacingDown = (zGravity < -8.8f) && (abs(xGravity) < 2.0f) && (abs(yGravity) < 2.0f)
val isProximityCovered = (proximityDistance < 1.0f)
val isMotionLow = (accelerationDelta < 0.15f)

val isTrulyFlipped = isFacingDown && isProximityCovered && isMotionLow
```

---

### ADR-005: Process Preservation via Android Foreground Service

#### Context
When the user places the smartphone face-down, the screen turns off. After several minutes, Android's **Doze Mode** puts the app into deep sleep to preserve battery. If the app is frozen, the focus timer pauses and the sensor stops detecting when the phone is picked up.

#### Decision
We implement an **Android Foreground Service** with a minimal silent persistent notification and a **`PARTIAL_WAKE_LOCK`** active only while in `FOCUSING` state.

#### Rationale
This is the only Google-certified method to ensure critical background execution without OS-level termination.

---

### ADR-006: Do Not Disturb (DND) Policy Management without External Servers

#### Context
The core product promise is to silence external distractions the moment the phone is flipped.

#### Decision
We leverage Android's native `android.permission.ACCESS_NOTIFICATION_POLICY`.
* On focus entry: The app remembers the user's current audio profile, then activates `INTERRUPTION_FILTER_PRIORITY`.
* On exit: The app restores the original audio profile.

#### Rationale
Zero accounts, zero external servers, strict user privacy (Privacy by Design).
