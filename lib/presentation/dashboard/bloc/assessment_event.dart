// assessment_event.dart
import 'package:equatable/equatable.dart';

import '../../../domain/entities/questions_entity.dart';

abstract class AssessmentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAssessments extends AssessmentEvent {
  final String candidateId;
  LoadAssessments({required this.candidateId});

  @override
  List<Object?> get props => [candidateId];
}

class UpdateAssessmentStatusEvent extends AssessmentEvent {
  final String candidateId;
  final String assessmentType;
  final String status;

  UpdateAssessmentStatusEvent({
    required this.candidateId,
    required this.assessmentType,
    required this.status,
  });

  @override
  List<Object?> get props => [candidateId, assessmentType, status];
}

class SaveAssessmentResultEvent extends AssessmentEvent {
  final String candidateId;
  final String assessmentType;
  final Map<String, dynamic> result;

  SaveAssessmentResultEvent({
    required this.candidateId,
    required this.assessmentType,
    required this.result,
  });

  @override
  List<Object?> get props => [candidateId, assessmentType, result];
}

class MarkAssessmentStartedEvent extends AssessmentEvent {
  final String candidateId;
  final String assessmentType;

  MarkAssessmentStartedEvent({
    required this.candidateId,
    required this.assessmentType,
  });

  @override
  List<Object?> get props => [candidateId, assessmentType];
}

class MarkAssessmentCompletedEvent extends AssessmentEvent {
  final String candidateId;
  final String assessmentType;

  MarkAssessmentCompletedEvent({
    required this.candidateId,
    required this.assessmentType,
  });

  @override
  List<Object?> get props => [candidateId, assessmentType];
}

class RefreshAssessmentStatusesEvent extends AssessmentEvent {
  final String candidateId;
  final List<AssessmentEntity> assessments;

  RefreshAssessmentStatusesEvent({
    required this.candidateId,
    required this.assessments,
  });

  @override
  List<Object?> get props => [candidateId, assessments];
}

class ChangeTabEvent extends AssessmentEvent {
  final int tabIndex;

  ChangeTabEvent({required this.tabIndex});

  @override
  List<Object?> get props => [tabIndex];
}

class ResetDatabaseEvent extends AssessmentEvent {}

class SubmitAssessmentToApiEvent extends AssessmentEvent {
  final dynamic restult;

  SubmitAssessmentToApiEvent({required this.restult});

  @override
  List<Object?> get props => [restult];
}
