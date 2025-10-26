import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDb {
  AppDb._();
  static final instance = AppDb._();

  Database? _db;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'fitness.db');

    _db = await openDatabase(
      path,
      version: 2, // bump to 2 so users who already ran v1 get the tables
      onCreate: (db, v) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldV, newV) async {
        // Ensure tables exist if coming from an older version
        if (oldV < 2) {
          await _createSchema(db);
        }
      },
    );
  }

  Database get db => _db!;

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        sets INTEGER,
        reps INTEGER,
        durationMin INTEGER,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        kcal INTEGER NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // Helpful indexes for analytics & today lookups
    await db.execute('CREATE INDEX IF NOT EXISTS idx_workouts_date ON workouts(date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_meals_date ON meals(date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_meals_category ON meals(category)');
  }
}
