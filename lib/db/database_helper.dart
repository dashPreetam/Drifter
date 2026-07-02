import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/daily_entry.dart';
import '../models/drift_log_entry.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get _database async {
    final existing = _db;
    if (existing != null) return existing;
    final opened = await _open();
    _db = opened;
    return opened;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'drifter.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE daily_entries (
            date TEXT PRIMARY KEY,
            identity TEXT,
            google_deep_work_minutes INTEGER,
            google_win TEXT,
            fitness_workout INTEGER,
            fitness_walk INTEGER,
            fitness_weight REAL,
            fitness_energy INTEGER,
            sleep_time TEXT,
            wake_time TEXT,
            sleep_quality INTEGER,
            music_opened_daw INTEGER,
            music_minutes INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE drift_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            text TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_drift_log_date ON drift_log(date)',
        );
      },
    );
  }

  Future<DailyEntry> getEntryForDate(String date) async {
    final db = await _database;
    final rows = await db.query(
      'daily_entries',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (rows.isEmpty) return DailyEntry.empty(date);
    return DailyEntry.fromMap(rows.first);
  }

  Future<void> saveEntry(DailyEntry entry) async {
    final db = await _database;
    await db.insert(
      'daily_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DailyEntry>> getEntriesForRange(
    String startDate,
    String endDateInclusive,
  ) async {
    final db = await _database;
    final rows = await db.query(
      'daily_entries',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDateInclusive],
      orderBy: 'date ASC',
    );
    return rows.map(DailyEntry.fromMap).toList();
  }

  Future<void> addDriftLogEntry(DriftLogEntry entry) async {
    final db = await _database;
    await db.insert('drift_log', entry.toMap());
  }

  Future<List<DriftLogEntry>> getDriftLogForDate(String date) async {
    final db = await _database;
    final rows = await db.query(
      'drift_log',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );
    return rows.map(DriftLogEntry.fromMap).toList();
  }

  Future<List<DriftLogEntry>> getDriftLogForRange(
    String startDate,
    String endDateInclusive,
  ) async {
    final db = await _database;
    final rows = await db.query(
      'drift_log',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDateInclusive],
      orderBy: 'date ASC, id ASC',
    );
    return rows.map(DriftLogEntry.fromMap).toList();
  }
}
