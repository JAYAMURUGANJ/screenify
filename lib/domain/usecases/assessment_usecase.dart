import '../repositories/assessment_local_repository.dart';

/// Use case for getting assessment status
class GetAssessmentStatusUseCase {
  final AssessmentLocalRepository repository;

  GetAssessmentStatusUseCase({required this.repository});

  Future<String> execute(String candidateId, String assessmentType) {
    return repository.getAssessmentStatus(candidateId, assessmentType);
  }
}

/// Use case for updating assessment status
class UpdateAssessmentStatusUseCase {
  final AssessmentLocalRepository repository;

  UpdateAssessmentStatusUseCase({required this.repository});

  Future<bool> execute(
    String candidateId,
    String assessmentType,
    String status,
  ) {
    return repository.updateAssessmentStatus(
      candidateId,
      assessmentType,
      status,
    );
  }
}

/// Use case for getting all assessment statuses
class GetAllAssessmentStatusesUseCase {
  final AssessmentLocalRepository repository;

  GetAllAssessmentStatusesUseCase({required this.repository});

  Future<Map<String, String>> execute(String candidateId) {
    return repository.getAllAssessmentStatuses(candidateId);
  }
}

/// Use case for saving assessment result
class SaveAssessmentResultUseCase {
  final AssessmentLocalRepository repository;

  SaveAssessmentResultUseCase({required this.repository});

  Future<bool> execute(
    String candidateId,
    String assessmentType,
    Map<String, dynamic> result,
  ) {
    return repository.saveAssessmentResult(candidateId, assessmentType, result);
  }
}

/// Use case for getting assessment result
class GetAssessmentResultUseCase {
  final AssessmentLocalRepository repository;

  GetAssessmentResultUseCase({required this.repository});

  Future<Map<String, dynamic>?> execute(
    String candidateId,
    String assessmentType,
  ) {
    return repository.getAssessmentResult(candidateId, assessmentType);
  }
}

/// Use case for getting all assessment results
class GetAllAssessmentResultsUseCase {
  final AssessmentLocalRepository repository;

  GetAllAssessmentResultsUseCase({required this.repository});

  Future<Map<String, dynamic>> execute(String candidateId) {
    return repository.getAllAssessmentResults(candidateId);
  }
}

/// Use case for clearing candidate assessment data
class ClearCandidateAssessmentDataUseCase {
  final AssessmentLocalRepository repository;

  ClearCandidateAssessmentDataUseCase({required this.repository});

  Future<bool> execute(String candidateId) {
    return repository.clearCandidateAssessmentData(candidateId);
  }
}

/// Use case for marking assessment as started
class MarkAssessmentAsStartedUseCase {
  final AssessmentLocalRepository repository;

  MarkAssessmentAsStartedUseCase({required this.repository});

  Future<bool> execute(String candidateId, String assessmentType) {
    return repository.markAssessmentAsStarted(candidateId, assessmentType);
  }
}

/// Use case for marking assessment as completed
class MarkAssessmentAsCompletedUseCase {
  final AssessmentLocalRepository repository;

  MarkAssessmentAsCompletedUseCase({required this.repository});

  Future<bool> execute(String candidateId, String assessmentType) {
    return repository.markAssessmentAsCompleted(candidateId, assessmentType);
  }
}

/// Use case for checking if assessment is completed
class IsAssessmentCompletedUseCase {
  final AssessmentLocalRepository repository;

  IsAssessmentCompletedUseCase({required this.repository});

  Future<bool> execute(String candidateId, String assessmentType) {
    return repository.isAssessmentCompleted(candidateId, assessmentType);
  }
}
