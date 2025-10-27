import 'package:intl/intl.dart';
import 'db.dart';

/// Aggregated value with a short label for the X-axis.
class DayAgg {
  final String label;
  final int workouts;
  DayAgg(this.label, this.workouts);
}

class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();

  /// 7 days, 1 bar per day (Mon..Sun-style labels).
  Future<List<DayAgg>> last7Days() async {
    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, now.day);
    final start = startDay.subtract(const Duration(days: 6));
    final endExclusive = startDay.add(const Duration(days: 1));

    // Pull only the rows we need
    final rows = await AppDb.instance.db.rawQuery('''
      SELECT date
      FROM workouts
      WHERE date >= ? AND date < ?
      ORDER BY date ASC
    ''', [start.toIso8601String(), endExclusive.toIso8601String()]);

    // Count by yyyy-mm-dd
    final counts = <String, int>{};
    for (final r in rows) {
      final d = DateTime.parse(r['date'] as String);
      final k = DateTime(d.year, d.month, d.day).toIso8601String().substring(0, 10);
      counts[k] = (counts[k] ?? 0) + 1;
    }

    final fmt = DateFormat('E'); // Mon, Tue...
    return List.generate(7, (i) {
      final d = start.add(Duration(days: i));
      final key = DateTime(d.year, d.month, d.day).toIso8601String().substring(0, 10);
      return DayAgg(fmt.format(d), counts[key] ?? 0);
    });
  }

  /// 30 days shown as ~5 weekly buckets (week starts on Monday).
  /// Returns 5 bars labeled "Wk of Oct 1" etc. (most recent week last).
  Future<List<DayAgg>> last30DaysAsWeeks() async {
    final now = DateTime.now();
    final today0 = DateTime(now.year, now.month, now.day);
    final start30 = today0.subtract(const Duration(days: 29)); // inclusive 30d window
    final endExclusive = today0.add(const Duration(days: 1));

    final rows = await AppDb.instance.db.rawQuery('''
      SELECT date
      FROM workouts
      WHERE date >= ? AND date < ?
      ORDER BY date ASC
    ''', [start30.toIso8601String(), endExclusive.toIso8601String()]);

    final dates = rows.map((r) => DateTime.parse(r['date'] as String)).toList();

    DateTime mondayOf(DateTime d) {
      final wd = d.weekday; // Mon=1..Sun=7
      return DateTime(d.year, d.month, d.day).subtract(Duration(days: wd - 1));
    }

    // Build 5 week buckets, newest week is the one containing 'today0'
    final newestMonday = mondayOf(today0);
    final weekStarts = List.generate(5, (i) => newestMonday.subtract(Duration(days: 7 * (4 - i))));
    final weekEndsExclusive = weekStarts.map((ws) => ws.add(const Duration(days: 7))).toList();

    final fmt = DateFormat('MMM d');
    final results = <DayAgg>[];
    for (var i = 0; i < weekStarts.length; i++) {
      final ws = weekStarts[i];
      final we = weekEndsExclusive[i];
      // Intersect with 30d window to avoid counting outside
      final from = ws.isBefore(start30) ? start30 : ws;
      final to = we.isAfter(endExclusive) ? endExclusive : we;

      int count = 0;
      for (final d in dates) {
        if (!d.isBefore(from) && d.isBefore(to)) count++;
      }
      results.add(DayAgg('Wk of ${fmt.format(ws)}', count));
    }
    return results;
  }

  /// Current streak in days (consecutive days up to today).
  Future<int> currentStreakDays() async {
    final now = DateTime.now();
    final today0 = DateTime(now.year, now.month, now.day);
    final start = today0.subtract(const Duration(days: 59));
    final endExclusive = today0.add(const Duration(days: 1));

    final rows = await AppDb.instance.db.rawQuery('''
      SELECT substr(date,1,10) as d
      FROM workouts
      WHERE date >= ? AND date < ?
      GROUP BY d
      ORDER BY d DESC
    ''', [start.toIso8601String(), endExclusive.toIso8601String()]);

    final daysWithWorkouts = rows
        .map((r) => DateTime.parse('${r['d']}'))
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    int streak = 0;
    for (int i = 0; i < 60; i++) {
      final day = today0.subtract(Duration(days: i));
      if (daysWithWorkouts.contains(day)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Total workouts this week (Mon–Sun).
  Future<int> workoutsThisWeek() async {
    final now = DateTime.now();
    final today0 = DateTime(now.year, now.month, now.day);
    final monday = today0.subtract(Duration(days: today0.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));

    final rows = await AppDb.instance.db.rawQuery('''
      SELECT COUNT(*) as c
      FROM workouts
      WHERE date >= ? AND date < ?
    ''', [monday.toIso8601String(), nextMonday.toIso8601String()]);

    final c = rows.isNotEmpty ? (rows.first['c'] as int) : 0;
    return c;
  }
}
