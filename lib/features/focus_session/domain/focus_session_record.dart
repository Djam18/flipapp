/// Immutable representation of a persisted deep work session.
class FocusSessionRecord {
  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final int? targetDurationMinutes;
  final int actualDurationSeconds;
  final String? intentionTag;
  final String status; // 'completed' | 'interrupted'
  final int pauseCount;

  const FocusSessionRecord({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    this.targetDurationMinutes,
    required this.actualDurationSeconds,
    this.intentionTag,
    required this.status,
    required this.pauseCount,
  });

  factory FocusSessionRecord.fromMap(Map<String, dynamic> map) {
    return FocusSessionRecord(
      id: map['id'] as String,
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int),
      endedAt: DateTime.fromMillisecondsSinceEpoch(map['ended_at'] as int),
      targetDurationMinutes: map['target_duration_minutes'] as int?,
      actualDurationSeconds: map['actual_duration_seconds'] as int,
      intentionTag: map['intention_tag'] as String?,
      status: map['status'] as String,
      pauseCount: map['pause_count'] as int,
    );
  }

  bool get isCompleted => status == 'completed';
}
