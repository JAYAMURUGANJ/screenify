// File: lib/domain/services/assessment_preferences_manager.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/assessment_data.dart';

class AssessmentPreferencesManager {
  // Singleton pattern
  static final AssessmentPreferencesManager _instance =
      AssessmentPreferencesManager._internal();
  factory AssessmentPreferencesManager() => _instance;
  AssessmentPreferencesManager._internal();

  // Keys for SharedPreferences
  static const String _assessmentStatusKey = 'assessment_status';
  static const String _assessmentResultsKey = 'assessment_results';

  // Status constants
  // ignore: constant_identifier_names
  static const String STATUS_NOT_OPENED = 'not_opened';
  // ignore: constant_identifier_names
  static const String STATUS_PENDING = 'pending';
  // ignore: constant_identifier_names
  static const String STATUS_COMPLETED = 'completed';

  // Get assessment status
  Future<String> getAssessmentStatus(String assessmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final statusMap =
        jsonDecode(prefs.getString(_assessmentStatusKey) ?? '{}')
            as Map<String, dynamic>;
    return statusMap[assessmentId] ?? STATUS_NOT_OPENED;
  }

  // Update assessment status
  Future<bool> updateAssessmentStatus(
    String assessmentId,
    String status,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final statusMap =
        jsonDecode(prefs.getString(_assessmentStatusKey) ?? '{}')
            as Map<String, dynamic>;
    statusMap[assessmentId] = status;
    return await prefs.setString(_assessmentStatusKey, jsonEncode(statusMap));
  }

  // Get all assessment statuses
  Future<Map<String, String>> getAllAssessmentStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    final statusMap =
        jsonDecode(prefs.getString(_assessmentStatusKey) ?? '{}')
            as Map<String, dynamic>;
    return statusMap.map((key, value) => MapEntry(key, value.toString()));
  }

  // Save assessment result
  Future<bool> saveAssessmentResult(
    String assessmentId,
    Map<String, dynamic> result,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final resultsMap =
        jsonDecode(prefs.getString(_assessmentResultsKey) ?? '{}')
            as Map<String, dynamic>;
    resultsMap[assessmentId] = result;
    return await prefs.setString(_assessmentResultsKey, jsonEncode(resultsMap));
  }

  // Get assessment result
  Future<Map<String, dynamic>?> getAssessmentResult(String assessmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final resultsMap =
        jsonDecode(prefs.getString(_assessmentResultsKey) ?? '{}')
            as Map<String, dynamic>;
    return resultsMap[assessmentId] as Map<String, dynamic>?;
  }

  // Get all assessment results
  Future<Map<String, dynamic>> getAllAssessmentResults() async {
    final prefs = await SharedPreferences.getInstance();
    return jsonDecode(prefs.getString(_assessmentResultsKey) ?? '{}')
        as Map<String, dynamic>;
  }

  // Clear all assessment data (for logout or reset)
  Future<bool> clearAllAssessmentData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_assessmentStatusKey);
    return await prefs.remove(_assessmentResultsKey);
  }

  // Mark assessment as started (pending)
  Future<bool> markAssessmentAsStarted(String assessmentId) async {
    return await updateAssessmentStatus(assessmentId, STATUS_PENDING);
  }

  // Mark assessment as completed
  Future<bool> markAssessmentAsCompleted(String assessmentId) async {
    return await updateAssessmentStatus(assessmentId, STATUS_COMPLETED);
  }

  // Check if assessment is completed
  Future<bool> isAssessmentCompleted(String assessmentId) async {
    return await getAssessmentStatus(assessmentId) == STATUS_COMPLETED;
  }

  // Helper method to save MCQ assessment result with a specific format
  Future<bool> saveMCQAssessmentResult(
    String assessmentId,
    List<Question> questions,
    int correctCount,
    int wrongCount,
  ) async {
    // Create a map for all questions with their selected answers
    List<Map<String, dynamic>> questionsData =
        questions.map((question) {
          return {
            'question': question.question,
            'selectedAnswerIndex': question.selectedAnswerIndex,
            'correctAnswerIndex': question.correctAnswerIndex,
            'isCorrect':
                question.selectedAnswerIndex == question.correctAnswerIndex,
          };
        }).toList();

    // Create the final result object
    Map<String, dynamic> result = {
      'totalQuestions': questions.length,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'score': correctCount,
      'scorePercentage': (correctCount / questions.length * 100)
          .toStringAsFixed(1),
      'questions': questionsData,
      'completedAt': DateTime.now().toIso8601String(),
    };

    // Save the result and mark as completed
    await saveAssessmentResult(assessmentId, result);
    return await markAssessmentAsCompleted(assessmentId);
  }
}
