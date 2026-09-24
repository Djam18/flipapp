import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Database manager for Flip to Focus.
/// Provides offline-first persistence for all deep work sessions and daily summaries.
class AppDatabase {
  static const String _databaseName = 'flip_to_focus.db';
  static const int _databaseVersion = 1;

  Database? _db;

  /// Singleton access
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  /// Returns the singleton Database instance, initializing it if necessary.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, _databaseName);

    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table: focus_sessions
    await db.execute('''
      CREATE TABLE focus_sessions (
        id TEXT PRIMARY KEY,
        started_at INTEGER NOT NULL,
        ended_at INTEGER,
        target_duration_minutes INTEGER,
        actual_duration_seconds INTEGER NOT NULL DEFAULT 0,
        intention_tag TEXT,
        status TEXT NOT NULL,
        pause_count INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    // Index for fast chronological queries
    await db.execute('''
      CREATE INDEX idx_focus_sessions_started_at ON focus_sessions(started_at DESC)
    ''');

    // Table: daily_summaries (materialized cache for instant heatmap rendering)
    await db.execute('''
      CREATE TABLE daily_summaries (
        date_key TEXT PRIMARY KEY,
        total_deep_work_seconds INTEGER NOT NULL DEFAULT 0,
        completed_sessions_count INTEGER NOT NULL DEFAULT 0,
        interrupted_sessions_count INTEGER NOT NULL DEFAULT 0,
        longest_session_seconds INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  /// Inserts a newly finished session and updates the corresponding daily summary atomically.
  Future<void> recordSession({
    required String id,
    required DateTime startedAt,
    required DateTime endedAt,
    int? targetDurationMinutes,
    required int actualDurationSeconds,
    String? intentionTag,
    required String status,
    required int pauseCount,
  }) async {
    final db = await database;
    final now = DateTime.now();

    await db.transaction((txn) async {
      // 1. Insert session record
      await txn.insert(
        'focus_sessions',
        {
          'id': id,
          'started_at': startedAt.millisecondsSinceEpoch,
          'ended_at': endedAt.millisecondsSinceEpoch,
          'target_duration_minutes': targetDurationMinutes,
          'actual_duration_seconds': actualDurationSeconds,
          'intention_tag': intentionTag,
          'status': status,
          'pause_count': pauseCount,
          'created_at': now.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Compute date key: 'YYYY-MM-DD'
      final dateKey = _formatDateKey(startedAt);

      // 3. Query existing daily summary or create new
      final existingRows = await txn.query(
        'daily_summaries',
        where: 'date_key = ?',
        whereArgs: [dateKey],
        limit: 1,
      );

      final isCompleted = status == 'completed';
      final isInterrupted = status == 'interrupted';

      if (existingRows.isEmpty) {
        await txn.insert('daily_summaries', {
          'date_key': dateKey,
          'total_deep_work_seconds': actualDurationSeconds,
          'completed_sessions_count': isCompleted ? 1 : 0,
          'interrupted_sessions_count': isInterrupted ? 1 : 0,
          'longest_session_seconds': actualDurationSeconds,
        });
      } else {
        final row = existingRows.first;
        final currentTotal = (row['total_deep_work_seconds'] as int?) ?? 0;
        final currentCompleted = (row['completed_sessions_count'] as int?) ?? 0;
        final currentInterrupted = (row['interrupted_sessions_count'] as int?) ?? 0;
        final currentLongest = (row['longest_session_seconds'] as int?) ?? 0;

        await txn.update(
          'daily_summaries',
          {
            'total_deep_work_seconds': currentTotal + actualDurationSeconds,
            'completed_sessions_count': currentCompleted + (isCompleted ? 1 : 0),
            'interrupted_sessions_count': currentInterrupted + (isInterrupted ? 1 : 0),
            'longest_session_seconds':
                actualDurationSeconds > currentLongest ? actualDurationSeconds : currentLongest,
          },
          where: 'date_key = ?',
          whereArgs: [dateKey],
        );
      }
    });
  }

  /// Fetches recent sessions ordered by start time descending.
  Future<List<Map<String, dynamic>>> getRecentSessions({int limit = 50}) async {
    final db = await database;
    return await db.query(
      'focus_sessions',
      orderBy: 'started_at DESC',
      limit: limit,
    );
  }

  /// Fetches daily summaries for the past [days] days.
  Future<List<Map<String, dynamic>>> getDailySummaries({int days = 14}) async {
    final db = await database;
    return await db.query(
      'daily_summaries',
      orderBy: 'date_key DESC',
      limit: days,
    );
  }

  /// Fetches aggregate all-time stats: total seconds, total completed sessions, and current streak.
  Future<Map<String, dynamic>> getAggregateStats() async {
    final db = await database;

    final totalResult = await db.rawQuery(
      'SELECT SUM(actual_duration_seconds) as total_seconds, COUNT(*) as total_count FROM focus_sessions WHERE status = "completed"',
    );

    final totalSeconds = (totalResult.first['total_seconds'] as int?) ?? 0;
    final totalCompleted = (totalResult.first['total_count'] as int?) ?? 0;

    // Calculate active streak
    final summaries = await db.query(
      'daily_summaries',
      where: 'completed_sessions_count > 0',
      orderBy: 'date_key DESC',
    );

    int streak = 0;
    if (summaries.isNotEmpty) {
      DateTime checkDate = DateTime.now();
      String checkKey = _formatDateKey(checkDate);

      // Check if today has a session; if not, check yesterday to keep streak active
      final todayMatches = summaries.any((s) => s['date_key'] == checkKey);
      if (!todayMatches) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        checkKey = _formatDateKey(checkDate);
      }

      for (final summary in summaries) {
        final dateKey = summary['date_key'] as String;
        if (dateKey == checkKey) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
          checkKey = _formatDateKey(checkDate);
        } else {
          break;
        }
      }
    }

    return {
      'totalSeconds': totalSeconds,
      'totalCompleted': totalCompleted,
      'streak': streak,
    };
  }

  static String _formatDateKey(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
