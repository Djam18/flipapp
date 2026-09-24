# 🗄️ DATA CONTRACT & DRIFT (SQLITE) SCHEMA
## Module: Offline-First Local Persistence
**Status:** Approved Technical Specification  
**Parent Document:** `SPECIFICATIONS_FLIP_TO_FOCUS.md`  

---

## 1. STORAGE STRATEGY

To honor our promise of **zero latency**, **strict privacy (zero third-party tracking)**, and **100% offline capability**, all data resides in an embedded **SQLite** database, managed via the **Drift** framework in Dart.

---

## 2. TABLES & DRIFT DEFINITIONS (DART)

### 2.1. Table `focus_sessions`

Stores the full chronological history of every attempted, completed, or interrupted deep work session.

```dart
import 'package:drift/drift.dart';

@DataClassName('FocusSessionEntry')
class FocusSessions extends Table {
  // Universal Unique Identifier (UUID v4)
  TextColumn get id => text()();

  // Epoch timestamps in milliseconds (UTC)
  Int64Column get startedAt => int64()();
  Int64Column get endedAt => int64().nullable()();

  // Session configuration
  IntColumn get targetDurationMinutes => integer().nullable()(); // NULL = Open Flow mode
  IntColumn get actualDurationSeconds => integer().withDefault(const Constant(0))();

  // Context & Metadata
  TextColumn get intentionTag => text().nullable()(); // E.g., 'Code', 'Writing', 'Research'
  
  // Status: 'completed', 'interrupted'
  TextColumn get status => text()();

  // Friction tracking metrics
  IntColumn get pauseCount => integer().withDefault(const Constant(0))();
  Int64Column get createdAt => int64()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 2.2. Table `daily_summaries`

Materialized daily cache table to instantly render the Heatmap and weekly analytics without aggregating thousands of raw session rows on every app cold start.

```dart
@DataClassName('DailySummaryEntry')
class DailySummaries extends Table {
  // Key formatted as 'YYYY-MM-DD' (e.g. '2026-09-24')
  TextColumn get dateKey => text()();

  IntColumn get totalDeepWorkSeconds => integer().withDefault(const Constant(0))();
  IntColumn get completedSessionsCount => integer().withDefault(const Constant(0))();
  IntColumn get interruptedSessionsCount => integer().withDefault(const Constant(0))();
  IntColumn get longestSessionSeconds => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {dateKey};
}
```

### 2.3. Table `user_settings`

Stores user ergonomics and behavior preferences (single row, `id = 1`).

```dart
@DataClassName('UserSettingEntry')
class UserSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  
  IntColumn get gracePeriodSeconds => integer().withDefault(const Constant(10))();
  BoolColumn get enableDnd => boolean().withDefault(const Constant(true))();
  BoolColumn get enableHaptics => boolean().withDefault(const Constant(true))();
  IntColumn get defaultTargetMinutes => integer().withDefault(const Constant(25))();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

## 3. INDEXES & QUERY PERFORMANCE

To ensure history lists and weekly heatmaps load in **under 2 milliseconds**:

```sql
-- Chronological index for fast recent history display
CREATE INDEX idx_sessions_started_at ON focus_sessions (started_at DESC);

-- Composite index for status-filtered range calculations
CREATE INDEX idx_sessions_status_date ON focus_sessions (status, started_at);
```

---

## 4. CORE DAO QUERIES

### 4.1. Today's Deep Work Total
```sql
SELECT COALESCE(SUM(actual_duration_seconds), 0) AS total_seconds
FROM focus_sessions
WHERE started_at >= :startOfDayTimestamp AND status = 'completed';
```

### 4.2. Weekly Heatmap Data (Last 7 Days)
```sql
SELECT 
    date(started_at / 1000, 'unixepoch', 'localtime') AS day_date,
    SUM(actual_duration_seconds) AS total_seconds,
    COUNT(id) AS session_count
FROM focus_sessions
WHERE started_at >= :sevenDaysAgoTimestamp
GROUP BY day_date
ORDER BY day_date ASC;
```

---

## 5. MIGRATION & RETENTION POLICIES

* **Version 1 (Initial):** Schema containing the 3 tables above.
* **Migration Strategy:** `drift_dev` generates versioned schema files (`schema_v1.json`). Future migrations are validated through automated tests (`drift_dev test`).
* **Data Portability:** Built-in **JSON / CSV export** feature allowing users to own their deep work productivity records.
