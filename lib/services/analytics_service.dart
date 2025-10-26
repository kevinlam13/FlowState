import 'package:intl/intl.dart';
import 'db.dart';

/// Holds aggregated workout data per day.
class DayAgg {
  final String label;
  final int workouts;
  DayAgg(this.label, this.workouts);
}

class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();

  /// Returns workout counts for the last [n] days (default 7 or 30)
  Future<List<DayAgg>> lastNDays(int n) async {
    final now = DateTime.now();
    final start =
    DateTime(now.year, now.month, now.day).subtract(Duration(days: n - 1));

    // Query SQLite for all workouts between start and now
    final rows = await AppDb.instance.db.rawQuery('''
      SELECT substr(date,1,10) as d, COUNT(*) as c
      FROM workouts
      WHERE date BETWEEN ? AND ?
      GROUP BY d
      ORDER BY d ASC
    ''', [
      start.toIso8601String(),
      now.add(const Duration(days: 1)).toIso8601String(),
    ]);

    // Map results to a dictionary { 'YYYY-MM-DD': count }
    final map = {for (final r in rows) r['d'] as String: r['c'] as int};

    // Label format (weekday abbreviations)
    final fmt = DateFormat('E');

    // Fill gaps with 0-count days
    return List.generate(n, (i) {
      final d = start.add(Duration(days: i));
      final key =
      DateTime(d.year, d.month, d.day).toIso8601String().substring(0, 10);
      return DayAgg(fmt.format(d), map[key] ?? 0);
    });
  }
}
