import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../model/candidate.dart';

class CandidateDatabaseHelper {
  static final CandidateDatabaseHelper _instance =
      CandidateDatabaseHelper._internal();
  static Database? _database;

  factory CandidateDatabaseHelper() => _instance;

  CandidateDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    try {
      // Use a more reliable directory path
      final dbDirectory =
          await getApplicationDocumentsDirectory(); // From path_provider package
      final dbPath = join(dbDirectory.path, 'candidate_database.db');

      // Debug info
      debugPrint('Database path: $dbPath');

      // Ensure the directory exists
      await Directory(dirname(dbPath)).create(recursive: true);

      return await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDb,
          onOpen: (db) => debugPrint('Database opened successfully'),
        ),
      );
    } catch (e) {
      debugPrint('Database initialization error: $e');
      rethrow;
    }
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE candidates(
        id TEXT PRIMARY KEY,
        aadhar TEXT UNIQUE,
        name TEXT,
        email TEXT,
        phone TEXT,
        dob TEXT,
        gender TEXT
      )
    ''');
  }

  // Generate a unique candidate ID
  String _generateCandidateId() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    final year = DateTime.now().year.toString();

    String randomPart = '';
    for (int i = 0; i < 6; i++) {
      randomPart += chars[random.nextInt(chars.length)];
    }

    return 'CAND-$year-$randomPart';
  }

  // Register a new candidate
  Future<String> registerCandidate(Candidate candidate) async {
    final db = await database;

    // Generate a unique candidate ID
    final String candidateId = _generateCandidateId();
    candidate.id = candidateId;

    // Insert the candidate into the database
    await db.insert(
      'candidates',
      candidate.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort, // Prevent duplicates
    );

    return candidateId;
  }

  // Login validation
  Future<Candidate?> validateLogin(String candidateId, String dob) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'candidates',
      where: 'id = ? AND dob = ?',
      whereArgs: [candidateId, dob],
    );

    if (maps.isNotEmpty) {
      return Candidate.fromMap(maps.first);
    }
    return null;
  }

  // Check if Aadhar already exists
  Future<bool> isAadharRegistered(String aadhar) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'candidates',
      where: 'aadhar = ?',
      whereArgs: [aadhar],
    );

    return maps.isNotEmpty;
  }
}
