/// Abstract repository interface for local assessment operations
abstract class AssessmentLocalRepository {
  /// Get assessment status for a specific candidate
  Future<String> getAssessmentStatus(String candidateId, String assessmentType);

  /// Update assessment status
  Future<bool> updateAssessmentStatus(
    String candidateId,
    String assessmentType,
    String status,
  );

  /// Get all assessment statuses for a candidate
  Future<Map<String, String>> getAllAssessmentStatuses(String candidateId);

  /// Save assessment result
  Future<bool> saveAssessmentResult(
    String candidateId,
    String assessmentType,
    Map<String, dynamic> result,
  );

  /// Get assessment result for a specific assessment
  Future<Map<String, dynamic>?> getAssessmentResult(
    String candidateId,
    String assessmentType,
  );

  /// Get all assessment results for a candidate
  Future<Map<String, dynamic>> getAllAssessmentResults(String candidateId);

  /// Clear all assessment data for a candidate (for logout or reset)
  Future<bool> clearCandidateAssessmentData(String candidateId);

  /// Mark assessment as started (pending)
  Future<bool> markAssessmentAsStarted(
    String candidateId,
    String assessmentType,
  );

  /// Mark assessment as completed
  Future<bool> markAssessmentAsCompleted(
    String candidateId,
    String assessmentType,
  );

  /// Check if assessment is completed
  Future<bool> isAssessmentCompleted(String candidateId, String assessmentType);

  Future<String> submitAssessmentToApi(dynamic result);
}
