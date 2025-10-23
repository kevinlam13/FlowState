import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDb {
  AppDb._(); static final instance = AppDb._();
  Database? _db;
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'fitness.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, v) async {
      // Tables created in Commit 5; placeholder here so app runs
    });
  }
  Database get db => _db!;
}
