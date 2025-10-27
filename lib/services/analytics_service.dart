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

  /// 7 days, 1 bar per day (Mon..Sun style labels).
  Future<List<DayAgg>> last7Days() async {
    final now = DateTime.now();
    // Start = today at 00:00 minus 6 days
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final endExclusive = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    // Fetch all rows once, then aggregate in Dart to avoid label/date math in SQL
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
      final k = DateTime(d.year, d.month, d.day).toIso8601String().substring(0,10);
      counts[k] = (counts[k] ?? 0) + 1;
    }

    final fmt = DateFormat('E'); // Mon, Tue...
    return List.generate(7, (i) {
      final d = start.add(Duration(days: i));
      final key = DateTime(d.year, d.month, d.day).toIso8601String().substring(0,10);
      return DayAgg(fmt.format(d), counts[key] ?? 0);
    });
  }

  /// 30 days shown as ~5 weekly buckets (week starts on Monday).
  /// Returns 5 bars labeled "Wk of Oct 1" etc. (most recent week last).
  Future<List<DayAgg>> last30DaysAsWeeks() async {
    final now = DateTime.now();
    final today0 = DateTime(now.year, now.month, now.day);
    final start30 = today0.subtract(const Duration(days: 29)); // 30 days inclusive
    final endExclusive = today0.add(const Duration(days: 1));

    // Pull once
    final rows = await AppDb.instance.db.rawQuery('''
      SELECT date
      FROM workouts
      WHERE date >= ? AND date < ?
      ORDER BY date ASC
    ''', [start30.toIso8601String(), endExclusive.toIso8601String()]);

    // Convert to DateTimes
    final dates = rows.map((r) => DateTime.parse(r['date'] as String)).toList();

    // Helper to get Monday of a given day
    DateTime mondayOf(DateTime d) {
      final weekday = d.weekday; // Mon=1..Sun=7
      return DateTime(d.year, d.month, d.day).subtract(Duration(days: weekday - 1));
    }

    // Build 5 week buckets (covering ~35 days to fully include 30d window edges)
    // Newest week is the one containing 'today0'. We go back 4 more.
    final weekStarts = List.generate(5, (i) => mondayOf(today0).subtract(Duration(days: 7 * (4 - i))));
    final weekEndsExclusive = weekStarts.map((ws) => ws.add(const Duration(days: 7))).toList();

    // Count workouts in each week (bounded by our 30-day window)
    final fmt = DateFormat('MMM d');
    final results = <DayAgg>[];
    for (var i = 0; i < weekStarts.length; i++) {
      final ws = weekStarts[i];
      final we = weekEndsExclusive[i];
      // Intersect with 30-day window to avoid counting outside
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
}
