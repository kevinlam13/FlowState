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
}
