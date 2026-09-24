import 'package:flutter/material.dart';
import 'analytics_data.dart';

/// Representation of a discipline milestone badge.
class MilestoneBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final String progressText;

  const MilestoneBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.progressText,
  });
}

/// Evaluates milestone unlocks based on current analytics data.
List<MilestoneBadge> evaluateMilestones(AnalyticsData data) {
  return [
    MilestoneBadge(
      id: 'first_dive',
      title: 'First Dive',
      description: 'Complete your first deep work session',
      icon: Icons.flag_outlined,
      isUnlocked: data.totalSessionsCompleted >= 1,
      progressText: data.totalSessionsCompleted >= 1 ? '1/1' : '0/1',
    ),
    MilestoneBadge(
      id: 'streak_3',
      title: 'Consistency',
      description: 'Maintain a 3-day deep work streak',
      icon: Icons.local_fire_department_outlined,
      isUnlocked: data.currentStreakDays >= 3,
      progressText: '${data.currentStreakDays.clamp(0, 3)}/3 days',
    ),
    MilestoneBadge(
      id: 'focus_5h',
      title: 'Apprentice',
      description: 'Reach 5 total hours of deep work',
      icon: Icons.hourglass_top_rounded,
      isUnlocked: data.totalDeepWorkHours >= 5,
      progressText: '${data.totalDeepWorkHours.clamp(0, 5)}/5 hrs',
    ),
    MilestoneBadge(
      id: 'streak_7',
      title: 'Unbreakable',
      description: 'Maintain a 7-day continuous streak',
      icon: Icons.shield_outlined,
      isUnlocked: data.currentStreakDays >= 7,
      progressText: '${data.currentStreakDays.clamp(0, 7)}/7 days',
    ),
    MilestoneBadge(
      id: 'monk_25h',
      title: 'Monk Depth',
      description: 'Achieve 25 cumulative hours of focus',
      icon: Icons.self_improvement_rounded,
      isUnlocked: data.totalDeepWorkHours >= 25,
      progressText: '${data.totalDeepWorkHours.clamp(0, 25)}/25 hrs',
    ),
    MilestoneBadge(
      id: 'centurion',
      title: 'Centurion',
      description: '100 cumulative hours of uninterrupted focus',
      icon: Icons.military_tech_outlined,
      isUnlocked: data.totalDeepWorkHours >= 100,
      progressText: '${data.totalDeepWorkHours.clamp(0, 100)}/100 hrs',
    ),
  ];
}
