import 'package:sqflite/sqflite.dart';
import '../models/workout.dart';
import 'db.dart';

class WorkoutService {
  WorkoutService._();
  static final WorkoutService instance = WorkoutService._();

  Database get _db => AppDb.instance.db;

  Future<List<Workout>> getAll() async {
    final rows = await _db.query('workouts', orderBy: 'date DESC');
    return rows.map(Workout.fromRow).toList();
  }

  Future<int> insert(Workout w) async =>
      _db.insert('workouts', w.toRow()..remove('id'));

  Future<int> update(Workout w) async =>
      _db.update('workouts', w.toRow()..remove('id'),
          where: 'id = ?', whereArgs: [w.id]);

  Future<int> delete(int id) async =>
      _db.delete('workouts', where: 'id = ?', whereArgs: [id]);

  /// Insert a preset routine for today
  Future<void> insertRoutine(String level) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Simple presets (feel free to tweak)
    List<Workout> plan;
    switch (level) {
      case 'Beginner':
        plan = [
          Workout(type: 'Walk', durationMin: 20, date: today),
          Workout(type: 'Light Bench', sets: 3, reps: 10, date: today),
          Workout(type: 'Run', durationMin: 10, date: today),
        ];
        break;
      case 'Intermediate':
        plan = [
          Workout(type: 'Run', durationMin: 25, date: today),
          Workout(type: 'Heavy Barbell Squat', sets: 4, reps: 8, date: today),
          Workout(type: 'Volleyball', durationMin: 20, date: today),
        ];
        break;
      case 'Advanced':
      default:
        plan = [
          Workout(type: 'Run', durationMin: 60, date: today),
          Workout(type: 'Lift -deadlift MAX', sets: 8, reps: 5, date: today),
          Workout(type: 'Swim', durationMin: 30, date: today),
        ];
        break;
    }

    final batch = _db.batch();
    for (final w in plan) {
      final row = w.toRow()..remove('id');
      batch.insert('workouts', row);
    }
    await batch.commit(noResult: true);
  }
}
