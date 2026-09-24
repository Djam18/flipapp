# 📚 TECHNICAL DOCUMENTATION INDEX
## Flip to Focus — Mobile Architecture & Engineering Docs

This directory contains the software engineering documentation for the **Flip to Focus** project, serving as the bridge between product vision and application source code.

---

### 📑 Documentation Navigation

1. **[SPECIFICATIONS_FLIP_TO_FOCUS.md](../SPECIFICATIONS_FLIP_TO_FOCUS.md)** *(Root)*  
   *Master Document: Product thesis, behavioral psychology, business rules, user journeys, and engineering roadmap.*

2. **[FICHE_DE_LECTURE_DEV_MOBILE.md](./FICHE_DE_LECTURE_DEV_MOBILE.md)** *(Guide d'apprentissage - FR)*  
   *Developer Study Guide & Cognitive Memo: Full Android & Flutter terminology, project directory tree, file responsibilities, and active recall flashcards.*

3. **[ARCHITECTURE_DECISIONS.md](./ARCHITECTURE_DECISIONS.md)**  
   *Architecture Decision Records (ADRs): In-depth justifications for each engineering choice (Why Drift? Why Riverpod? Why native Kotlin for hardware sensors?).*

4. **[brand_identity_showcase.html](./brand_identity_showcase.html)**  
   *Interactive Brand Identity HTML Showcase: Live visualizer for 3 color palettes, vector rendering of 5 logo variations, and smartphone Cockpit simulation.*

5. **[UI_DESIGN_SPECIFICATIONS.md](./UI_DESIGN_SPECIFICATIONS.md)**  
   *Design System & UI Screen Specifications: OLED color palette, mathematical typography, 8pt spacing grid, detailed specifications for 14 screens and components, state matrix, and accessibility (A11y).*

6. **[SYSTEM_MODELING_SPEC.md](./SYSTEM_MODELING_SPEC.md)**  
   *End-to-End System Modeling (A to Z - Requirements to Play Store): 7 core diagrams (Use Case, Activity, Component, Class, Sequence, State Machine FSM, CI/CD Play Store pipeline).*

7. **[STATE_MACHINE_SPEC.md](./STATE_MACHINE_SPEC.md)**  
   *Finite State Machine (FSM) Specification: Transition matrix, strict state diagrams (Idle, Arming, Focusing, Grace Period, Paused, Completed, Interrupted), and Riverpod Notifier contract.*

8. **[DATA_SCHEMA_SPEC.md](./DATA_SCHEMA_SPEC.md)**  
   *Data Contract & SQLite Drift Schema: Tables `focus_sessions`, `daily_summaries`, `user_settings`, performance indexes, and DAO queries.*

9. **[HARDWARE_SENSORS_SPEC.md](./HARDWARE_SENSORS_SPEC.md)**  
   *Android Native Sensors Specification: Proximity + Gravity Z sensor fusion algorithm, pocket anti-false-trigger filter in Kotlin, and Doze Mode management via Foreground Service.*
