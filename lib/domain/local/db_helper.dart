import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../model/candidate.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Get an appropriate directory path for the database
    String path = join(await getDatabasesPath(), 'candidate_database.db');

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE candidates(
        id TEXT PRIMARY KEY,
        aadhar TEXT UNIQUE,
        name TEXT,
        email TEXT,
        phone TEXT,
        dob TEXT
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
