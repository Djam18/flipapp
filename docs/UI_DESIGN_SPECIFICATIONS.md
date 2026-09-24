# 🎨 DESIGN SYSTEM & UI SCREEN SPECIFICATIONS
## Project: Flip to Focus
**Status:** Approved UI Specification & Developer Handoff  
**Target:** Flutter UI (OLED Dark Mode & Mobile Ergonomics)  
**Parent Document:** `SPECIFICATIONS_FLIP_TO_FOCUS.md`  

---

## 📑 TABLE OF CONTENTS

1. [FOUNDATIONS: FLUTTER DESIGN TOKENS](#1-foundations-flutter-design-tokens)
   * 1.1. Color Palette (OLED Contrast & WCAG AAA)
   * 1.2. Mathematical Typography Scale
   * 1.3. 8-Point Spacing Grid
   * 1.4. Border Radii & Elevations
   * 1.5. Motion & Haptic Tokens
2. [DETAILED SCREEN-BY-SCREEN SPECIFICATIONS](#2-detailed-screen-by-screen-specifications)
   * Screen 0: Native Splash Screen (Android 12+ SplashScreen API)
   * Screen 1: Onboarding & DND Permission Gate
   * Screen 2: Main Cockpit (IDLE & Pre-Focus State)
   * Screen 3: Screen-Off Simulation & Persistent Notification
   * Screen 4: 10s Grace Alert Overlay
   * Screen 5: 2-Minute Emergency Pause
   * Screen 6: Celebration & Debrief (Completed Session)
   * Screen 7: Gentle Partial Summary (Interrupted Session)
   * Screen 8: Activity Journal & Weekly Heatmap
   * Screen 9: Weekly Summary & Social Share Card
   * Screen 10: Discipline Milestones & Badges
   * Screen 11: Settings & Ergonomic Preferences
   * Screen 12: About, Manifesto & Open Source Licenses
   * Screen 13: Privacy Policy (Google Play Compliance)
   * Component 14: Android Home Screen Widget
3. [COMPONENT STATE MATRIX](#3-component-state-matrix)
4. [ACCESSIBILITY & EDGE CASES](#4-accessibility--edge-cases)

---

## 1. FOUNDATIONS: FLUTTER DESIGN TOKENS

### 1.1. Color Palette (Dark Mode OLED)

The app utilizes true black (`#000000`) to physically deactivate OLED display diodes, conserving battery and reducing visual strain.

| Token | Hex Code | Contrast Ratio | Role / Usage |
| :--- | :--- | :--- | :--- |
| `colorBackground` | `#000000` | Base background | True OLED Black (pixels off). |
| `colorSurface` | `#121214` | Elevation 1 | Cards, dialogs, containers. |
| `colorSurfaceElevated` | `#1E1E22` | Elevation 2 | Inactive buttons, chips, dividers. |
| `colorTextPrimary` | `#F5F5F7` | 18.5:1 (AAA) | Primary text, timers, strong headers. |
| `colorTextSecondary` | `#8E8E93` | 7.2:1 (AAA) | Subtitles, labels, time units. |
| `colorTextMuted` | `#48484A` | 4.6:1 (AA) | Placeholders, disabled text, borders. |
| `colorAccent` | `#8FA89B` | Sage Green | Active focus indicator, success, heatmap cells. |
| `colorAccentGaze` | `#E0A96D` | Warm Amber | Selected intention tag, open flow timer. |
| `colorWarning` | `#D97706` | Alert Amber | Emergency pause countdown (2 min). |
| `colorDanger` | `#E26D5C` | Terracotta Red | 10s grace alert, abandon button. |

---

### 1.2. Mathematical Typography Scale

Two font families are standard:
* **UI & Body:** `Inter` or Android system Sans-serif.
* **Numbers & Timers:** `JetBrains Mono` or system Monospace.

```dart
abstract class AppTypography {
  // Monospace - Timers and precision counters
  static TextStyle timerDisplay = GoogleFonts.jetBrainsMono(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle timerSub = GoogleFonts.jetBrainsMono(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.5,
    color: AppColors.accent,
  );

  // Sans-serif - Hierarchy
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyRegular = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textMuted,
  );
}
```

---

### 1.3. 8-Point Spacing Grid

```dart
abstract class AppSpacing {
  static const double xxs = 4.0;
  static const double xs  = 8.0;
  static const double sm  = 12.0;
  static const double md  = 16.0;   // Standard screen margin
  static const double lg  = 24.0;   // Section separation
  static const double xl  = 32.0;
  static const double xxl = 48.0;   // Cockpit top/bottom padding
}
```

---

### 1.4. Border Radii & Elevations

* `radiusSmall` : **8.0 px** (Badges, intention tags).
* `radiusMedium` : **16.0 px** (Cards, alert dialogs).
* `radiusLarge` : **28.0 px** (Primary action touch targets).
* `radiusFull` : **999.0 px** (Pills, circular rings).

---

### 1.5. Motion & Haptic Tokens

#### Animations:
* **Quick interaction:** `150 ms` (`Curves.easeOutQuad`).
* **Screen transition / Overlay:** `250 ms` (`Curves.fastOutSlowIn`).
* **Grace pulse:** `1000 ms` repeated breathing cycle.

#### Haptics:
* **Standard button tap:** `10 ms` (`HapticFeedback.lightImpact`).
* **Session start (3s face-down):** `HapticFeedback.mediumImpact()`.
* **Grace period alert:** `HapticFeedback.heavyImpact()`.
* **Session accomplished:** Success vibration pattern.

---

## 2. DETAILED SCREEN-BY-SCREEN SPECIFICATIONS

### Screen 0: Native Splash Screen (Android 12+)
* Vector logo centered on `#000000` background.
* Zero artificial delay; seamlessly transitions into Cockpit once the Dart VM finishes booting.

### Screen 1: Onboarding & DND Permission Gate
* Explains the physical flip ritual and requests Do Not Disturb policy permission.

### Screen 2: Main Cockpit (Home / IDLE)
* Displays today's deep work total, central pulsing target ring, duration chips (Open, 25m, 45m, 90m), and intention tag.

### Screen 3: Screen-Off Simulation & Persistent Notification
* Display stays true black; notification tray shows active deep work time.

### Screen 4: 10s Grace Alert Overlay
* Circular countdown ring with "Emergency Pause (2 min)" and "Abandon session" buttons.

### Screen 5: 2-Minute Emergency Pause
* Freezes focus timer for two minutes to handle 2FA SMS or urgent calls.

### Screen 6: Celebration & Debrief
* Confirms completed session and summarizes deep work minutes.

### Screen 7: Gentle Partial Summary
* Encouraging summary recording actual focused minutes when a session is interrupted.

### Screen 8: Activity Journal & Weekly Heatmap
* 7-day deep work intensity grid (GitHub-style) and chronological session list.

### Screen 9: Weekly Summary & Social Share Card
* Generates a sleek image card for sharing on social networks (LinkedIn, X, Instagram).

### Screen 10: Discipline Milestones & Badges
* Achievements for consistency (e.g., *Iron Week*, *Centurion*, *White Zone*).

### Screen 11: Settings & Ergonomic Preferences
* Grace period slider (5s to 15s), DND toggle, haptic toggle, and CSV/JSON export.

### Screen 12: About, Manifesto & Open Source Licenses
* Creator's story, app version, and `showLicensePage()`.

### Screen 13: Privacy Policy
* Formal declaration of 100% offline-first storage and zero third-party data tracking.

### Component 14: Android Home Screen Widget
* Desk glanceable widget displaying today's progress and prompt to flip.

---

## 3. COMPONENT STATE MATRIX

| Component | Default State | Pressed / Active | Loading State | Disabled State |
| :--- | :--- | :--- | :--- | :--- |
| **Primary Button** | Background `#1E1E22`, text `#F5F5F7` | Background `#2C2C30`, scale `0.98` | 18px Circular indicator | Opacity `0.4`, unclickable |
| **Duration Chip** | Border `#48484A`, transparent fill | Background `#8FA89B`, text `#000000` | N/A | N/A |
| **History Card** | Background `#121214`, padding `16px` | Background `#1E1E22` on tap | Shimmer wave | N/A |

---

## 4. ACCESSIBILITY & EDGE CASES

1. **Dynamic Font Scaling:** Wraps and flex containers prevent overflow when system fonts are enlarged to 200%.
2. **TalkBack Support:** Semantic labels explicitly announce countdowns (`Semantics(label: "8 seconds remaining to place phone face-down", child: ...)`).
3. **Minimum Touch Targets:** All interactive elements respect minimum **48 x 48 dp** bounds.
