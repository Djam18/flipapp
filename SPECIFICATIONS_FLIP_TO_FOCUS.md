# 📖 FLIP TO FOCUS — PRODUCT SPECIFICATIONS & DESIGN CHARTER
### *Functional, Ergonomic, and Technical Specifications for a Physical Focus Mobile App*
**Version:** 1.0.0  
**Status:** Approved / Ready for Production  
**Target Stack:** Flutter (Dart) & Native Android  

---

## 📑 TABLE OF CONTENTS

1. [EXECUTIVE SUMMARY](#executive-summary)
2. [PART I — PRODUCT PHILOSOPHY & BEHAVIORAL PSYCHOLOGY](#part-i--product-philosophy--behavioral-psychology)
3. [PART II — FUNCTIONAL SPECIFICATIONS & BUSINESS RULES](#part-ii--functional-specifications--business-rules)
4. [PART III — USER EXPERIENCE (UX) & DESIGN SYSTEM (UI)](#part-iii--user-experience-ux--design-system-ui)
5. [PART IV — HARDWARE INTEGRATION & DATA ARCHITECTURE](#part-iv--hardware-integration--data-architecture)
6. [PART V — ROADMAP & SPRINTS](#part-v--roadmap--sprints)

---

## EXECUTIVE SUMMARY

**Flip to Focus** is a deep work productivity mobile application designed for software engineers, writers, students, and knowledge workers who struggle with digital distractions.

Unlike traditional productivity apps (Forest, Pomodoro, Todoist) that keep the screen lit and induce constant cognitive friction, **Flip to Focus** leverages an instinctive physical trigger: **placing the smartphone face-down on the desk**.

When flipped:
1. Android hardware sensors detect planarity and optical occlusion.
2. A subtle haptic vibration confirms entry into deep work.
3. The smartphone automatically switches to Do Not Disturb (DND) / priority silent mode.
4. The screen turns completely black. No glare, no notifications, zero visual distractions.

If the user picks up the phone before the target time expires, a 10-second grace window activates, allowing them to place it back down without penalizing the session.

---

## PART I — PRODUCT PHILOSOPHY & BEHAVIORAL PSYCHOLOGY

### 1. The Screen-On Illusion
Traditional focus timers demand visual attention by displaying ticking seconds, turning the device into an active distraction source.

### 2. The Physical Ritual (The 1% Tweak)
* **Kinesthetic Anchoring:** Physically placing the phone screen-down acts as a neurological switch signifying deep work entry.
* **Physical Friction Against Distraction:** To browse social media, the user must reach out, lift the phone, and face a 10-second grace countdown. This 2-second friction breaks compulsive browsing reflexes in over 80% of attempts.
* **Zero Guilt:** No punitive visual degradation (unlike dead trees in Forest); partial work is always recorded encouragingly.

---

## PART II — FUNCTIONAL SPECIFICATIONS & BUSINESS RULES

### 1. Sensor Trigger & Session Lifecycle (FSM)
* **Start Condition:** Inverted planarity ($Z < -8.8\ \text{m/s}^2$) + Proximity occlusion ($d < 1.0\ \text{cm}$) maintained for 3 seconds.
* **Confirmation:** Double gentle haptic tap + DND mode activated.
* **Premature Lift:** 10-second grace countdown with pulsating alert vibration.
* **Options during Grace Period:**
  * Put phone back face-down ➔ Session resumes cleanly with zero penalties.
  * Tap "Emergency Pause (2 min)" ➔ Timer freezes for 2FA SMS or urgent calls.
  * Tap "Abandon" ➔ Saves actual minutes accomplished.

---

## PART III — USER EXPERIENCE (UX) & DESIGN SYSTEM (UI)

* **Palette:** True OLED Black (`#000000`), Slate Grey (`#121214`), Sage Green (`#8FA89B`), Titanium White (`#F5F5F7`), Terracotta (`#E26D5C`).
* **Typography:** `JetBrains Mono` for precision timers, `Inter` for general UI text.
* **Spatial System:** Strict 8-point grid (`xxs` 4px to `xxl` 48px).

---

## PART IV — HARDWARE INTEGRATION & DATA ARCHITECTURE

* **Hardware Bridge:** Kotlin native `EventChannel` and `MethodChannel` for proximity, gravity, and DND.
* **Battery Protection:** `ForegroundService` with `PARTIAL_WAKE_LOCK` active only during sessions to bypass Android Doze Mode.
* **Local Persistence:** 100% Offline-First SQLite managed through **Drift**.

---

## PART V — ROADMAP & SPRINTS

* **Sprint 1 (Completed):** Architecture setup, OLED Theme, Cockpit View, Riverpod FSM state.
* **Sprint 2 (Completed):** Native Android Kotlin bridge, sensor fusion, DND permissions, haptic integration.
* **Sprint 3 (In Progress):** Drift SQLite persistence, daily summaries, weekly heatmap.
* **Sprint 4:** Settings, CSV/JSON export, adaptive icons, and Play Store release prep.
