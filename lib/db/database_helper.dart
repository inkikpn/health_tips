import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'health_tips.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        height REAL,
        weight REAL,
        date TEXT
      )
    ''');
  }

  // 插入一條記錄
  Future<int> insertRecord(double height, double weight, String date) async {
    final db = await database;
    return await db.insert('records', {
      'height': height,
      'weight': weight,
      'date': date,
    });
  }

  // 查詢所有記錄
  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final db = await database;
    return await db.query('records');
  }
}
