# 📐 END-TO-END SYSTEM MODELING (A TO Z: GESTURE TO PLAY STORE)
## Project: Flip to Focus
**Status:** Approved Engineering Specification  
**Scope:** From Requirements Analysis (A) to Google Play Store Release (Z)  

---

## 📑 TABLE OF CONTENTS

1. [ARCHITECTURAL OVERVIEW: FLUTTER & NATIVE KOTLIN](#1-architectural-overview-flutter--native-kotlin)
2. [THE 7 CORE SYSTEM DIAGRAMS (A -> Z)](#2-the-7-core-system-diagrams-a---z)
3. [DIAGRAM 1: USE CASE DIAGRAM](#diagram-1-use-case-diagram)
4. [DIAGRAM 2: ACTIVITY / USER FLOW DIAGRAM](#diagram-2-activity--user-flow-diagram)
5. [DIAGRAM 3: COMPONENT DIAGRAM](#diagram-3-component-diagram)
6. [DIAGRAM 4: DOMAIN & CLASS DIAGRAM](#diagram-4-domain--class-diagram)
7. [DIAGRAM 5: SEQUENCE DIAGRAM](#diagram-5-sequence-diagram)
8. [DIAGRAM 6: FINITE STATE MACHINE (FSM) DIAGRAM](#diagram-6-finite-state-machine-fsm-diagram)
9. [DIAGRAM 7: CI/CD & PLAY STORE DEPLOYMENT PIPELINE](#diagram-7-cicd--play-store-deployment-pipeline)

---

## 1. ARCHITECTURAL OVERVIEW: FLUTTER & NATIVE KOTLIN

* **95% Dart / Flutter:** All UI components, animations, Riverpod state, and Drift database queries.
* **5% Native Android Kotlin:** Hardware sensor listeners (proximity & gravity) and DND policy management via Platform Channels.

```
+--------------------------------------------------------------+
|                     FLUTTER CODE (DART) 95%                  |
|   UI (Screens, Theme, Animations) + State (Riverpod) + DB   |
+--------------------------------------------------------------+
                               |
                   [ Method / Event Channel ]
                               |
+--------------------------------------------------------------+
|             NATIVE ANDROID LAYER (KOTLIN) 5%                 |
|   Proximity Sensor | Gravity Sensor | Do Not Disturb        |
+--------------------------------------------------------------+
```

---

## 2. THE 7 CORE SYSTEM DIAGRAMS (A -> Z)

| Phase | Diagram Name | Purpose |
| :--- | :--- | :--- |
| **A. Requirements** | **1. Use Case Diagram** | User roles and core capabilities. |
| **B. User Flow** | **2. Activity Diagram** | Step-by-step user decision paths. |
| **C. Architecture**| **3. Component Diagram** | Clean Architecture module boundaries. |
| **D. Data Models** | **4. Class Diagram** | Domain entities and methods. |
| **E. Dynamics** | **5. Sequence Diagram** | Chronological messaging across subsystems. |
| **F. Lifecycles** | **6. State Machine Diagram**| Exact FSM state transitions. |
| **Z. Release** | **7. CI/CD & Play Store** | From compilation to production Play Store release. |

---

## DIAGRAM 1: USE CASE DIAGRAM

```mermaid
flowchart LR
    User((👤 User))
    OS((⚙️ Android OS))

    subgraph App [" Flip to Focus App "]
        UC1[Start session via physical phone flip]
        UC2[Set task intention]
        UC3[10s grace period rescue]
        UC4[Activate 2-minute emergency pause]
        UC5[View Weekly Deep Work Heatmap]
        UC6[Export data to CSV/JSON]
        
        SYS1[Toggle Do Not Disturb Policy]
        SYS2[Maintain Foreground Service & Wakelock]
        SYS3[Emit tactile haptic pulses]
    end

    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6

    UC1 -.-> SYS1
    UC1 -.-> SYS2
    UC1 -.-> SYS3
    SYS1 --> OS
    SYS2 --> OS
    SYS3 --> OS
```

---

## DIAGRAM 2: ACTIVITY / USER FLOW DIAGRAM

```mermaid
flowchart TD
    Start([Launch App]) --> CheckPerm{DND Permission Granted?}
    CheckPerm -- No --> Onboarding[Onboarding: Request DND Access]
    Onboarding --> CheckPerm
    CheckPerm -- Yes --> Cockpit[Cockpit View: Waiting for Flip]

    Cockpit --> FlipDown[User flips smartphone face-down on desk]
    FlipDown --> WaitArming[3-second stabilization threshold]
    WaitArming --> IsStillDown{Still face-down?}
    IsStillDown -- No --> Cockpit
    IsStillDown -- Yes --> StartFocus[Haptic Pulse + DND ON + Foreground Service Started]

    StartFocus --> InSession[/Active Deep Work - Screen Black/]
    InSession --> UserAction{Event Occurs}

    UserAction -- Target Duration Reached --> TargetSuccess[Success Haptic + DND OFF + Session 'Completed']
    TargetSuccess --> Celebration[Celebration & Debrief Screen]
    Celebration --> Cockpit

    UserAction -- Phone Picked Up Early --> Lifted[Screen Turns On: 10s Grace Alert]
    Lifted --> GraceChoice{User Action within 10s}
    
    GraceChoice -- Place Face-Down --> Resume[Gentle Haptic: Session Resumed Cleanly]
    Resume --> InSession

    GraceChoice -- Tap Emergency Pause --> Pause2Min[Timer frozen for up to 2 minutes]
    Pause2Min --> ReposeApresPause[Place Face-Down] --> InSession

    GraceChoice -- 10s Expired or Tap Abandon --> Interrupted[DND OFF + Session 'Interrupted' Saved]
    Interrupted --> Cockpit
```

---

## DIAGRAM 3: COMPONENT DIAGRAM

```mermaid
flowchart TB
    subgraph UI_Layer [" Presentation Layer (Flutter) "]
        CockpitView[CockpitScreen]
        AlertView[GraceAlertOverlay]
        StatsView[StatsHeatmapScreen]
        SettingsView[SettingsScreen]
    end

    subgraph State_Layer [" State Management (Riverpod) "]
        SessionNotifier[FocusSessionNotifier]
        StatsNotifier[DailyStatsNotifier]
        SettingsNotifier[UserSettingsNotifier]
    end

    subgraph Domain_Layer [" Domain & Business Logic (Pure Dart) "]
        SessionFSM[FocusStateMachine]
        MetricsCalculator[DeepWorkCalculator]
        SessionEntity[FocusSession Model]
    end

    subgraph Data_Layer [" Local Data (Drift SQLite) "]
        SessionRepo[SessionRepository]
        AppDatabase[(AppDatabase SQLite)]
        Daos[SessionsDao / StatsDao]
    end

    subgraph Native_Bridge [" Hardware Bridge (Platform Channels) "]
        SensorBridge[SensorEventChannel]
        DndBridge[DndMethodChannel]
        HapticBridge[HapticFeedbackChannel]
    end

    UI_Layer --> State_Layer
    State_Layer --> Domain_Layer
    State_Layer --> Data_Layer
    Domain_Layer --> Data_Layer
    State_Layer --> Native_Bridge
    Data_Layer --> AppDatabase
```

---

## DIAGRAM 4: DOMAIN & CLASS DIAGRAM

```mermaid
classDiagram
    class FocusSession {
        +String id
        +DateTime startedAt
        +DateTime? endedAt
        +int? targetMinutes
        +int actualDurationSeconds
        +String? intentionTag
        +SessionStatus status
        +int pauseCount
        +bool isSuccess()
        +double completionRate()
    }

    class SessionStatus {
        <<enumeration>>
        IDLE
        ARMING
        FOCUSING
        GRACE_PERIOD
        PAUSED
        COMPLETED
        INTERRUPTED
    }

    class DailySummary {
        +String dateKey
        +int totalDeepWorkSeconds
        +int completedCount
        +int interruptedCount
        +int longestSessionSeconds
    }

    class UserSettings {
        +int gracePeriodSeconds
        +bool enableDnd
        +bool enableHaptics
        +int defaultTargetMinutes
    }

    FocusSession --> SessionStatus
    DailySummary "1" o-- "*" FocusSession : aggregates
```

---

## DIAGRAM 5: SEQUENCE DIAGRAM

```mermaid
sequenceDiagram
    autonumber
    actor User as 👤 User
    participant Sensors as 📱 Android Hardware
    participant Kotlin as ⚙️ Native Filter (Kotlin)
    participant Riverpod as 🧠 FocusSessionNotifier
    participant OS as 🔕 Android System (DND/Haptics)
    participant Drift as 💾 SQLite (Drift)

    User->>Sensors: Places phone face-down on desk
    Sensors->>Kotlin: Gravity Z < -8.8 & Proximity = 0cm
    Kotlin->>Kotlin: 3-second stabilization timer
    Kotlin->>Riverpod: Event: onFlipDetected()
    
    Riverpod->>OS: setDndEnabled(true)
    Riverpod->>OS: triggerHapticPulse(DOUBLE_TAP)
    OS-->>User: Feels start haptic pulse
    Riverpod->>Drift: insertSession(startedAt, status='focusing')

    loop Every second of deep work
        Riverpod->>Riverpod: tickElapsedSeconds()
    end

    User->>Sensors: Lifts phone prematurely
    Sensors->>Kotlin: Gravity normal & Proximity released
    Kotlin->>Riverpod: Event: onFlipReleased()
    Riverpod->>User: Screen turns on with GraceAlert (10s)
    
    opt User places phone back down within 10s
        User->>Sensors: Places phone face-down
        Sensors->>Kotlin: Event: onFlipDetected()
        Kotlin->>Riverpod: Cancel grace countdown
        Riverpod-->>User: Screen black, session preserved
    end
```

---

## DIAGRAM 6: FINITE STATE MACHINE (FSM) DIAGRAM

```mermaid
stateDiagram-v2
    [*] --> IDLE : App Boot

    IDLE --> ARMING : Physical Flip (Z < -8.8 & Prox=0)
    ARMING --> IDLE : Lifted before 3s (False start)
    ARMING --> FOCUSING : 3s elapsed without motion (Haptic OK + DND ON)

    FOCUSING --> GRACE_PERIOD : Phone lifted prematurely
    FOCUSING --> COMPLETED : Target duration reached (Success)

    GRACE_PERIOD --> FOCUSING : Re-flipped face-down < 10s
    GRACE_PERIOD --> PAUSED : Tap "Emergency Pause (2 min)"
    GRACE_PERIOD --> INTERRUPTED : 10s expired OR Tap "Abandon"

    PAUSED --> FOCUSING : Re-flipped before 2 min
    PAUSED --> INTERRUPTED : 2 min elapsed without action

    COMPLETED --> IDLE : Dismiss celebration
    INTERRUPTED --> IDLE : Return to Cockpit
```

---

## DIAGRAM 7: CI/CD & PLAY STORE DEPLOYMENT PIPELINE

```mermaid
flowchart TD
    subgraph Dev [" 💻 Development & Tests "]
        Code[Dart & Kotlin Source Code] --> Lint[flutter analyze / format]
        Lint --> Tests[Unit & Widget Tests]
    end

    subgraph Build [" 🏗️ Compilation & Security "]
        Tests --> Obfuscation[R8 / ProGuard Obfuscation]
        Obfuscation --> Keystore[Cryptographic Signature via Release Keystore]
        Keystore --> AAB[Android App Bundle Generation - .aab]
    end

    subgraph Store [" 🚀 Google Play Console (Z) "]
        AAB --> PlayConsole[Google Play Console]
        PlayConsole --> Fastlane[Verify DND Privacy Policy]
        Fastlane --> InternalTrack[Internal Testing Track - 20 testers]
        InternalTrack --> ProductionTrack[Global Production Release - Google Play Store]
    end
```
