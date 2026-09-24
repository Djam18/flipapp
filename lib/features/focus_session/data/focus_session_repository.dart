import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../domain/focus_session_record.dart';

final focusSessionRepositoryProvider = Provider<FocusSessionRepository>((ref) {
  return FocusSessionRepository(AppDatabase.instance);
});

/// Repository managing storage and retrieval of focus session records.
class FocusSessionRepository {
  final AppDatabase _db;

  FocusSessionRepository(this._db);

  /// Saves a session record to SQLite and updates daily metrics.
  Future<void> saveSession({
    required String id,
    required DateTime startedAt,
    required DateTime endedAt,
    int? targetDurationMinutes,
    required int actualDurationSeconds,
    String? intentionTag,
    required String status,
    required int pauseCount,
  }) async {
    await _db.recordSession(
      id: id,
      startedAt: startedAt,
      endedAt: endedAt,
      targetDurationMinutes: targetDurationMinutes,
      actualDurationSeconds: actualDurationSeconds,
      intentionTag: intentionTag,
      status: status,
      pauseCount: pauseCount,
    );
  }

  /// Retrieves chronological history of completed and interrupted sessions.
  Future<List<FocusSessionRecord>> getRecentSessions({int limit = 50}) async {
    final rows = await _db.getRecentSessions(limit: limit);
    return rows.map((r) => FocusSessionRecord.fromMap(r)).toList();
  }

  /// Retrieves aggregated stats (all-time duration, streak, count).
  Future<Map<String, dynamic>> getAggregateStats() async {
    return await _db.getAggregateStats();
  }

  /// Retrieves daily summaries for heatmap visualization.
  Future<List<Map<String, dynamic>>> getDailySummaries({int days = 14}) async {
    return await _db.getDailySummaries(days: days);
  }
}
