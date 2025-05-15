import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/local/assessment_database_helper.dart';
import '../../../domain/entities/questions_entity.dart';
import '../../../domain/usecases/assessment_usecase.dart';
import 'assessment_event.dart';
import 'assessment_state.dart';

class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  final GetAllAssessmentStatusesUseCase getAllAssessmentStatusesUseCase;
  final UpdateAssessmentStatusUseCase updateAssessmentStatusUseCase;
  final SaveAssessmentResultUseCase saveAssessmentResultUseCase;
  final MarkAssessmentAsStartedUseCase markAssessmentAsStartedUseCase;
  final MarkAssessmentAsCompletedUseCase markAssessmentAsCompletedUseCase;
  final SubmitAssessmetToApiUseCase submitAssessmetToApiUseCase;
  final StreamSubscription? _statusSubscription;

  AssessmentBloc({
    required this.getAllAssessmentStatusesUseCase,
    required this.updateAssessmentStatusUseCase,
    required this.saveAssessmentResultUseCase,
    required this.markAssessmentAsStartedUseCase,
    required this.markAssessmentAsCompletedUseCase,
    required this.submitAssessmetToApiUseCase,
    StreamSubscription? statusSubscription,
  }) : _statusSubscription = statusSubscription,
       super(AssessmentInitial()) {
    on<LoadAssessments>(_onLoadAssessments);
    on<UpdateAssessmentStatusEvent>(_onUpdateAssessmentStatus);
    on<SaveAssessmentResultEvent>(_onSaveAssessmentResult);
    on<MarkAssessmentStartedEvent>(_onMarkAssessmentStarted);
    on<MarkAssessmentCompletedEvent>(_onMarkAssessmentCompleted);
    on<RefreshAssessmentStatusesEvent>(_onRefreshAssessmentStatuses);
    on<ResetDatabaseEvent>(_onResetDatabase);
    on<ChangeTabEvent>(onChangeTab);
    on<SubmitAssessmentToApiEvent>(onSubmitAssessmentToApi);
  }

  Future<void> _onLoadAssessments(
    LoadAssessments event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(AssessmentLoading());
    try {
      // In a real implementation, this would load from a repository
      // For now, we're assuming the assessments are passed in from somewhere else
      // Like from the widget.assessmentDetails.assessments
      // You would replace this with proper loading logic

      // This is placeholder logic
      emit(
        AssessmentsLoaded(
          assessments: [], // Replace with actual loaded assessments
          filteredAssessments: [], // Replace with filtered assessments
        ),
      );
    } catch (e) {
      emit(AssessmentError(message: 'Failed to load assessments: $e'));
    }
  }

  Future<void> _onUpdateAssessmentStatus(
    UpdateAssessmentStatusEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    try {
      final success = await updateAssessmentStatusUseCase.execute(
        event.candidateId,
        event.assessmentType,
        event.status,
      );

      if (success) {
        emit(
          AssessmentStatusUpdated(
            assessmentType: event.assessmentType,
            status: event.status,
          ),
        );

        // If we had a loaded state, update it as well
        if (state is AssessmentsLoaded) {
          final loadedState = state as AssessmentsLoaded;
          final updatedAssessments =
              loadedState.assessments.map((assessment) {
                if (assessment.type == event.assessmentType) {
                  return assessment.copyWith(status: event.status);
                }
                return assessment;
              }).toList();

          final updatedFilteredAssessments = _filterAssessments(
            updatedAssessments,
            loadedState.selectedTabIndex,
          );

          emit(
            loadedState.copyWith(
              assessments: updatedAssessments,
              filteredAssessments: updatedFilteredAssessments,
            ),
          );
        }
      } else {
        emit(AssessmentError(message: 'Failed to update assessment status'));
      }
    } catch (e) {
      emit(AssessmentError(message: 'Error updating assessment status: $e'));
    }
  }

  Future<void> _onSaveAssessmentResult(
    SaveAssessmentResultEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    try {
      final success = await saveAssessmentResultUseCase.execute(
        event.candidateId,
        event.assessmentType,
        event.result,
      );

      if (success) {
        emit(AssessmentResultSaved(assessmentType: event.assessmentType));
      } else {
        emit(AssessmentError(message: 'Failed to save assessment result'));
      }
    } catch (e) {
      emit(AssessmentError(message: 'Error saving assessment result: $e'));
    }
  }

  Future<void> _onMarkAssessmentStarted(
    MarkAssessmentStartedEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    try {
      final success = await markAssessmentAsStartedUseCase.execute(
        event.candidateId,
        event.assessmentType,
      );

      if (success) {
        emit(
          AssessmentStatusUpdated(
            assessmentType: event.assessmentType,
            status: 'pending',
          ),
        );

        // Update loaded state if available
        if (state is AssessmentsLoaded) {
          await _updateLoadedState(event.assessmentType, 'pending', emit);
        }
      } else {
        emit(AssessmentError(message: 'Failed to mark assessment as started'));
      }
    } catch (e) {
      emit(AssessmentError(message: 'Error marking assessment as started: $e'));
    }
  }

  Future<void> _onMarkAssessmentCompleted(
    MarkAssessmentCompletedEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    try {
      final success = await markAssessmentAsCompletedUseCase.execute(
        event.candidateId,
        event.assessmentType,
      );

      if (success) {
        emit(
          AssessmentStatusUpdated(
            assessmentType: event.assessmentType,
            status: 'completed',
          ),
        );

        // Update loaded state if available
        if (state is AssessmentsLoaded) {
          await _updateLoadedState(event.assessmentType, 'completed', emit);
        }
      } else {
        emit(
          AssessmentError(message: 'Failed to mark assessment as completed'),
        );
      }
    } catch (e) {
      emit(
        AssessmentError(message: 'Error marking assessment as completed: $e'),
      );
    }
  }

  Future<void> _onRefreshAssessmentStatuses(
    RefreshAssessmentStatusesEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    try {
      final statuses = await getAllAssessmentStatusesUseCase.execute(
        event.candidateId,
      );

      // Update assessment statuses based on the retrieved data
      final updatedAssessments =
          event.assessments.map((assessment) {
            final status = statuses[assessment.type];
            if (status != null) {
              return assessment.copyWith(status: status);
            }
            return assessment;
          }).toList();

      // If we are in the loaded state, update it
      if (state is AssessmentsLoaded) {
        final loadedState = state as AssessmentsLoaded;
        final filteredAssessments = _filterAssessments(
          updatedAssessments,
          loadedState.selectedTabIndex,
        );

        emit(
          loadedState.copyWith(
            assessments: updatedAssessments,
            filteredAssessments: filteredAssessments,
          ),
        );
      } else {
        // Otherwise create a new loaded state
        emit(
          AssessmentsLoaded(
            assessments: updatedAssessments,
            filteredAssessments: _filterAssessments(updatedAssessments, 0),
          ),
        );
      }
    } catch (e) {
      emit(
        AssessmentError(message: 'Error refreshing assessment statuses: $e'),
      );
    }
  }

  Future<void> _onResetDatabase(
    ResetDatabaseEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    try {
      // Implement database reset logic here
      // This might be a call to a repository method

      emit(DatabaseReset());
      emit(AssessmentInitial());
    } catch (e) {
      emit(AssessmentError(message: 'Error resetting database: $e'));
    }
  }

  // Helper method to update the loaded state
  Future<void> _updateLoadedState(
    String assessmentType,
    String status,
    Emitter<AssessmentState> emit,
  ) async {
    final loadedState = state as AssessmentsLoaded;
    final updatedAssessments =
        loadedState.assessments.map((assessment) {
          if (assessment.type == assessmentType) {
            return assessment.copyWith(status: status);
          }
          return assessment;
        }).toList();

    final updatedFilteredAssessments = _filterAssessments(
      updatedAssessments,
      loadedState.selectedTabIndex,
    );

    emit(
      loadedState.copyWith(
        assessments: updatedAssessments,
        filteredAssessments: updatedFilteredAssessments,
      ),
    );
  }

  // Helper method to filter assessments based on selected tab
  List<AssessmentEntity> _filterAssessments(
    List<AssessmentEntity> assessments,
    int tabIndex,
  ) {
    switch (tabIndex) {
      case 0: // All
        return assessments;
      case 1: // Not Started
        return assessments
            .where((a) => a.status == AssessmentDatabaseHelper.STATUS_COMPLETED)
            .toList();
      case 2: // In Progress
        return assessments
            .where((a) => a.status == AssessmentDatabaseHelper.STATUS_PENDING)
            .toList();
      case 3: // Completed
        return assessments
            .where(
              (a) => a.status == AssessmentDatabaseHelper.STATUS_NOT_OPENED,
            )
            .toList();
      default:
        return assessments;
    }
  }

  void onChangeTab(ChangeTabEvent event, Emitter<AssessmentState> emit) {
    debugPrint('Tab changed to index: ${event.tabIndex}');

    if (state is AssessmentsLoaded) {
      final loadedState = state as AssessmentsLoaded;

      // debugPrint status values to debug
      debugPrint(
        'Status values in list: ${loadedState.assessments.map((a) => a.status).toSet()}',
      );

      final filteredAssessments = _filterAssessments(
        loadedState.assessments,
        event.tabIndex,
      );

      debugPrint('Filtered count: ${filteredAssessments.length}');

      emit(
        loadedState.copyWith(
          selectedTabIndex: event.tabIndex,
          filteredAssessments: filteredAssessments,
        ),
      );
    }
  }

  Map<String, bool> checkAllAssessmentsCompleted(
    List<AssessmentEntity> assessments,
  ) {
    // Group by assessment_type
    final Map<String, List<AssessmentEntity>> grouped = {};
    for (final assessment in assessments) {
      grouped.putIfAbsent(assessment.type, () => []).add(assessment);
    }

    // Check completion for each type
    final Map<String, bool> result = {};
    grouped.forEach((type, list) {
      final total = list.length;
      final completed =
          list
              .where(
                (a) => a.status == AssessmentDatabaseHelper.STATUS_COMPLETED,
              )
              .length;
      result[type] = (completed == total && total > 0);
      debugPrint(
        'Type: $type, Completed: $completed/$total, All Completed: ${result[type]}',
      );
    });

    return result;
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }

  Future<void> onSubmitAssessmentToApi(
    SubmitAssessmentToApiEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(AssessmentLoading());
    try {
      final submittedState = await submitAssessmetToApiUseCase(event.restult);
      emit(AssessmentSubmitted(message: submittedState));
    } catch (e) {
      emit(AssessmentNotSubmitted(error: e.toString()));
    }
  }
}
