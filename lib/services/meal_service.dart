import 'package:sqflite/sqflite.dart';
import '../models/meal.dart';
import 'db.dart';

class MealService {
  MealService._();
  static final MealService instance = MealService._();

  Database get _db => AppDb.instance.db;

  /// Return today's meals (00:00 → 23:59)
  Future<List<Meal>> today() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final rows = await _db.query(
      'meals',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return rows.map(Meal.fromRow).toList();
  }

  /// Insert a new meal for "now"
  Future<int> insert(String name, int kcal, String category) async {
    final meal = Meal(
      name: name,
      kcal: kcal,
      category: category,
      date: DateTime.now(),
    );
    return _db.insert('meals', meal.toRow()..remove('id'));
  }

  Future<int> delete(int id) async =>
      _db.delete('meals', where: 'id = ?', whereArgs: [id]);
}
