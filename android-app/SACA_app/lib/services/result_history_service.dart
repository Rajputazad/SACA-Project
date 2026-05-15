import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class ResultHistoryItem {
  final int id;
  final String createdAt;
  final String inputText;
  final String predictedSeverity;
  final String symptoms;
  final Map<String, dynamic> rawResult;

  const ResultHistoryItem({
    required this.id,
    required this.createdAt,
    required this.inputText,
    required this.predictedSeverity,
    required this.symptoms,
    required this.rawResult,
  });

  factory ResultHistoryItem.fromMap(Map<String, Object?> map) {
    return ResultHistoryItem(
      id: map['id'] as int,
      createdAt: map['created_at'].toString(),
      inputText: map['input_text'].toString(),
      predictedSeverity: map['predicted_severity'].toString(),
      symptoms: map['symptoms'].toString(),
      rawResult:
          jsonDecode(map['raw_result'].toString()) as Map<String, dynamic>,
    );
  }
}

class ResultHistoryService {
  static const _databaseName = 'saca_results.db';
  static const _tableName = 'results';

  static Database? _database;

  static Future<Database> get _db async {
    final existing = _database;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final database = await openDatabase(
      path.join(dbPath, _databaseName),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            created_at TEXT NOT NULL,
            input_text TEXT NOT NULL,
            predicted_severity TEXT NOT NULL,
            symptoms TEXT NOT NULL,
            raw_result TEXT NOT NULL
          )
        ''');
      },
    );

    _database = database;
    return database;
  }

  static Future<int> save(Map<String, dynamic> result) async {
    final db = await _db;
    final inputSymptoms = result['input_symptoms'];
    final symptoms = inputSymptoms is List
        ? inputSymptoms.map((item) => item.toString()).join(', ')
        : '';

    return db.insert(_tableName, {
      'created_at': DateTime.now().toIso8601String(),
      'input_text': (result['input_text'] ?? result['processed_text'] ?? '')
          .toString(),
      'predicted_severity': (result['predicted_severity'] ?? 'Unknown')
          .toString(),
      'symptoms': symptoms,
      'raw_result': jsonEncode(result),
    });
  }

  static Future<List<ResultHistoryItem>> all() async {
    final db = await _db;
    final rows = await db.query(_tableName, orderBy: 'id DESC');
    return rows.map(ResultHistoryItem.fromMap).toList();
  }

  static Future<void> delete(int id) async {
    final db = await _db;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
