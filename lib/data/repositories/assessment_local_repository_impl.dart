import '../../core/local/assessment_database_helper.dart';
import '../../domain/repositories/assessment_local_repository.dart';

/// Implementation of the AssessmentLocalRepository that works with the
/// AssessmentDatabaseHelper
class AssessmentLocalRepositoryImpl implements AssessmentLocalRepository {
  final AssessmentDatabaseHelper _dbHelper;

  /// Constructor that takes the database helper instance
  AssessmentLocalRepositoryImpl({AssessmentDatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? AssessmentDatabaseHelper();

  @override
  Future<String> getAssessmentStatus(
    String candidateId,
    String assessmentType,
  ) async {
    return await _dbHelper.getAssessmentStatus(candidateId, assessmentType);
  }

  @override
  Future<bool> updateAssessmentStatus(
    String candidateId,
    String assessmentType,
    String status,
  ) async {
    return await _dbHelper.updateAssessmentStatus(
      candidateId,
      assessmentType,
      status,
    );
  }

  @override
  Future<Map<String, String>> getAllAssessmentStatuses(
    String candidateId,
  ) async {
    return await _dbHelper.getAllAssessmentStatuses(candidateId);
  }

  @override
  Future<bool> saveAssessmentResult(
    String candidateId,
    String assessmentType,
    Map<String, dynamic> result,
  ) async {
    return await _dbHelper.saveAssessmentResult(
      candidateId,
      assessmentType,
      result,
    );
  }

  @override
  Future<Map<String, dynamic>?> getAssessmentResult(
    String candidateId,
    String assessmentType,
  ) async {
    return await _dbHelper.getAssessmentResult(candidateId, assessmentType);
  }

  @override
  Future<Map<String, dynamic>> getAllAssessmentResults(
    String candidateId,
  ) async {
    return await _dbHelper.getAllAssessmentResults(candidateId);
  }

  @override
  Future<bool> clearCandidateAssessmentData(String candidateId) async {
    return await _dbHelper.clearCandidateAssessmentData(candidateId);
  }

  @override
  Future<bool> markAssessmentAsStarted(
    String candidateId,
    String assessmentType,
  ) async {
    return await _dbHelper.markAssessmentAsStarted(candidateId, assessmentType);
  }

  @override
  Future<bool> markAssessmentAsCompleted(
    String candidateId,
    String assessmentType,
  ) async {
    return await _dbHelper.markAssessmentAsCompleted(
      candidateId,
      assessmentType,
    );
  }

  @override
  Future<bool> isAssessmentCompleted(
    String candidateId,
    String assessmentType,
  ) async {
    return await _dbHelper.isAssessmentCompleted(candidateId, assessmentType);
  }

  /// Reset the database (for testing or debugging)
  Future<bool> resetDatabase() async {
    return await _dbHelper.resetDatabase();
  }

  /// Get the status update stream
  Stream<String> getStatusUpdates() {
    return _dbHelper.statusUpdates;
  }
}
