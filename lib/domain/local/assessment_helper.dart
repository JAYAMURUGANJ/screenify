import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AssessmentDatabaseHelper {
  static final AssessmentDatabaseHelper _instance =
      AssessmentDatabaseHelper._internal();
  static Database? _database;

  // Stream controller for status updates
  final _statusUpdateController = StreamController<String>.broadcast();
  Stream<String> get statusUpdates => _statusUpdateController.stream;

  // Method to notify listeners about status updates
  void notifyStatusUpdate(String candidateId) {
    _statusUpdateController.add(candidateId);
  }

  factory AssessmentDatabaseHelper() => _instance;

  AssessmentDatabaseHelper._internal();

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
      final dbDirectory = await getApplicationDocumentsDirectory();
      final dbPath = join(dbDirectory.path, 'assessment_database.db');

      // Debug info
      debugPrint('Assessment Database path: $dbPath');

      // Ensure the directory exists
      await Directory(dirname(dbPath)).create(recursive: true);

      return await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDb,
          onOpen: (db) => debugPrint('Assessment Database opened successfully'),
        ),
      );
    } catch (e) {
      debugPrint('Assessment Database initialization error: $e');
      rethrow;
    }
  }

  Future<void> _createDb(Database db, int version) async {
    // Table for assessment statuses
    await db.execute('''
      CREATE TABLE assessment_statuses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        candidate_id TEXT NOT NULL,
        assessment_type TEXT NOT NULL,
        status TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(candidate_id, assessment_type)
      )
    ''');

    // Table for assessment results
    await db.execute('''
      CREATE TABLE assessment_results(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        candidate_id TEXT NOT NULL,
        assessment_type TEXT NOT NULL,
        result_data TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        UNIQUE(candidate_id, assessment_type)
      )
    ''');
  }

  // Method to notify listeners that status has changed
  void _notifyStatusUpdate(String candidateId) {
    _statusUpdateController.add(candidateId);
  }

  // Status constants
  static const String STATUS_NOT_OPENED = 'not_opened';
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_COMPLETED = 'completed';

  // Get assessment status for a specific candidate
  Future<String> getAssessmentStatus(
    String candidateId,
    String assessmentType,
  ) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'assessment_statuses',
      columns: ['status'],
      where: 'candidate_id = ? AND assessment_type = ?',
      whereArgs: [candidateId, assessmentType],
    );

    return result.isNotEmpty ? result.first['status'] : STATUS_NOT_OPENED;
  }

  // Update assessment status
  Future<bool> updateAssessmentStatus(
    String candidateId,
    String assessmentType,
    String status,
  ) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    try {
      await db.insert('assessment_statuses', {
        'candidate_id': candidateId,
        'assessment_type': assessmentType,
        'status': status,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Notify listeners that a status was updated
      _notifyStatusUpdate(candidateId);
      return true;
    } catch (e) {
      debugPrint('Error updating assessment status: $e');
      return false;
    }
  }

  // Get all assessment statuses for a candidate
  Future<Map<String, String>> getAllAssessmentStatuses(
    String candidateId,
  ) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'assessment_statuses',
      columns: ['assessment_type', 'status'],
      where: 'candidate_id = ?',
      whereArgs: [candidateId],
    );

    final Map<String, String> statusMap = {};
    for (var row in results) {
      statusMap[row['assessment_type']] = row['status'];
    }
    return statusMap;
  }

  // Save assessment result
  Future<bool> saveAssessmentResult(
    String candidateId,
    String assessmentType,
    Map<String, dynamic> result,
  ) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    try {
      await db.insert('assessment_results', {
        'candidate_id': candidateId,
        'assessment_type': assessmentType,
        'result_data': jsonEncode(result),
        'completed_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Notify listeners when a result is saved (as it often changes status too)
      _notifyStatusUpdate(candidateId);
      return true;
    } catch (e) {
      debugPrint('Error saving assessment result: $e');
      return false;
    }
  }

  // Get assessment result
  Future<Map<String, dynamic>?> getAssessmentResult(
    String candidateId,
    String assessmentType,
  ) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'assessment_results',
      columns: ['result_data'],
      where: 'candidate_id = ? AND assessment_type = ?',
      whereArgs: [candidateId, assessmentType],
    );

    if (results.isNotEmpty) {
      return jsonDecode(results.first['result_data']) as Map<String, dynamic>;
    }
    return null;
  }

  // Get all assessment results for a candidate
  Future<Map<String, dynamic>> getAllAssessmentResults(
    String candidateId,
  ) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'assessment_results',
      columns: ['assessment_type', 'result_data'],
      where: 'candidate_id = ?',
      whereArgs: [candidateId],
    );

    final Map<String, dynamic> resultsMap = {};
    for (var row in results) {
      resultsMap[row['assessment_type']] = jsonDecode(row['result_data']);
    }

    return {
      "candidateId": candidateId,
      "date_time": DateTime.now().toIso8601String(),
      "status": await getAllAssessmentStatuses(candidateId),
      "assessment": resultsMap,
    };
  }

  // Clear all assessment data for a candidate (for logout or reset)
  Future<bool> clearCandidateAssessmentData(String candidateId) async {
    final db = await database;

    try {
      await db.delete(
        'assessment_statuses',
        where: 'candidate_id = ?',
        whereArgs: [candidateId],
      );
      await db.delete(
        'assessment_results',
        where: 'candidate_id = ?',
        whereArgs: [candidateId],
      );

      // Notify listeners after cleanup
      _notifyStatusUpdate(candidateId);
      return true;
    } catch (e) {
      debugPrint('Error clearing candidate assessment data: $e');
      return false;
    }
  }

  // Mark assessment as started (pending)
  Future<bool> markAssessmentAsStarted(
    String candidateId,
    String assessmentType,
  ) async {
    return await updateAssessmentStatus(
      candidateId,
      assessmentType,
      STATUS_PENDING,
    );
  }

  // Mark assessment as completed
  Future<bool> markAssessmentAsCompleted(
    String candidateId,
    String assessmentType,
  ) async {
    return await updateAssessmentStatus(
      candidateId,
      assessmentType,
      STATUS_COMPLETED,
    );
  }

  // Check if assessment is completed
  Future<bool> isAssessmentCompleted(
    String candidateId,
    String assessmentType,
  ) async {
    return await getAssessmentStatus(candidateId, assessmentType) ==
        STATUS_COMPLETED;
  }

  // Reset the database completely (for testing or recovery)
  Future<bool> resetDatabase() async {
    try {
      final dbDirectory = await getApplicationDocumentsDirectory();
      final dbPath = join(dbDirectory.path, 'assessment_database.db');

      // Close the database connection
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Delete the database file
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Assessment database reset successfully');
      }

      // Re-initialize the database
      _database = await _initDatabase();

      // Notify listeners about the reset
      _statusUpdateController.add("reset");
      return true;
    } catch (e) {
      debugPrint('Error resetting database: $e');
      return false;
    }
  }

  // Close the stream when no longer needed
  void dispose() {
    _statusUpdateController.close();
  }
}
