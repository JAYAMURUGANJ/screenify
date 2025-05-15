import 'package:equatable/equatable.dart';

import '../../../domain/entities/questions_entity.dart';

abstract class AssessmentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AssessmentInitial extends AssessmentState {}

class AssessmentLoading extends AssessmentState {}

class AssessmentsLoaded extends AssessmentState {
  final List<AssessmentEntity> assessments;
  final List<AssessmentEntity> filteredAssessments;
  final int selectedTabIndex;

  AssessmentsLoaded({
    required this.assessments,
    required this.filteredAssessments,
    this.selectedTabIndex = 0,
  });

  AssessmentsLoaded copyWith({
    List<AssessmentEntity>? assessments,
    List<AssessmentEntity>? filteredAssessments,
    int? selectedTabIndex,
  }) {
    return AssessmentsLoaded(
      assessments: assessments ?? this.assessments,
      filteredAssessments: filteredAssessments ?? this.filteredAssessments,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object?> get props => [
    assessments,
    filteredAssessments,
    selectedTabIndex,
  ];
}

class AssessmentError extends AssessmentState {
  final String message;
  AssessmentError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AssessmentStatusUpdated extends AssessmentState {
  final String assessmentType;
  final String status;
  AssessmentStatusUpdated({required this.assessmentType, required this.status});

  @override
  List<Object?> get props => [assessmentType, status];
}

class AssessmentResultSaved extends AssessmentState {
  final String assessmentType;
  AssessmentResultSaved({required this.assessmentType});

  @override
  List<Object?> get props => [assessmentType];
}

class DatabaseReset extends AssessmentState {}

class AssessmentSubmitted extends AssessmentState {
  final String message;

  AssessmentSubmitted({required this.message});

  @override
  List<Object?> get props => [message];
}

class AssessmentNotSubmitted extends AssessmentState {
  final String error;

  AssessmentNotSubmitted({required this.error});
  @override
  List<Object?> get props => [error];
}
