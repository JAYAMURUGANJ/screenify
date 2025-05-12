import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenify/domain/entities/questions_entity.dart';

import '../../../core/local/assessment_database_helper.dart';
import '../../dashboard/bloc/assessment_bloc.dart';
import '../../dashboard/bloc/assessment_event.dart';
import 'email_assessment_state.dart';

// EmailAssessmentBloc
class EmailAssessmentBloc extends Cubit<EmailAssessmentState> {
  final AssessmentBloc assessmentBloc;
  final String candidateId;
  final AssessmentEntity emailData;
  DateTime? startTime;

  EmailAssessmentBloc({
    required this.assessmentBloc,
    required this.candidateId,
    required this.emailData,
  }) : super(
         EmailAssessmentState(
           to: '',
           cc: '',
           subject: '',
           body: '',
           isSubmitting: false,
           scenario: EmailScenario(
             title: emailData.title,
             description: emailData.description,
             instruction: emailData.instructions,
             expectedTo: emailData.expectedTo ?? "",
             expectedCc: emailData.expectedCc ?? "",
             expectedSubject: emailData.expectedSubject ?? "",
             expectedKeywords: emailData.expectedKeywords ?? [],
             hints: emailData.hints ?? [],
           ),
         ),
       ) {
    // Initialize start time
    startTime = DateTime.now();

    // Mark assessment as started (pending)
    assessmentBloc.add(
      UpdateAssessmentStatusEvent(
        candidateId: candidateId,
        assessmentType: emailData.type,
        status: AssessmentDatabaseHelper.STATUS_PENDING,
      ),
    );
  }

  void updateTo(String to) {
    emit(state.copyWith(to: to));
  }

  void updateCc(String cc) {
    emit(state.copyWith(cc: cc));
  }

  void updateSubject(String subject) {
    emit(state.copyWith(subject: subject));
  }

  void updateBody(String body) {
    emit(state.copyWith(body: body));
  }

  void resetTest() {
    startTime = DateTime.now();
    emit(
      state.copyWith(
        to: '',
        cc: '',
        subject: '',
        body: '',
        isSubmitting: false,
      ),
    );
  }

  Map<String, dynamic> calculateScore() {
    int errors = 0;
    int totalPoints = 0;
    int earnedPoints = 0;

    final scenario = state.scenario;

    // Check recipient (3 points)
    totalPoints += 3;
    if (state.to.trim().toLowerCase() == scenario.expectedTo.toLowerCase()) {
      earnedPoints += 3;
    } else {
      errors++;
    }

    // Check CC if expected (2 points)
    if (scenario.expectedCc.isNotEmpty) {
      totalPoints += 2;
      if (state.cc.trim().toLowerCase() == scenario.expectedCc.toLowerCase()) {
        earnedPoints += 2;
      } else {
        errors++;
      }
    }

    // Check subject (5 points)
    totalPoints += 5;
    final String normalizedSubject = state.subject.trim().toLowerCase();
    final String expectedSubject = scenario.expectedSubject.toLowerCase();
    if (normalizedSubject == expectedSubject) {
      earnedPoints += 5;
    } else if (normalizedSubject.contains(
          expectedSubject.split(" - ")[0].toLowerCase(),
        ) ||
        normalizedSubject.contains(
          expectedSubject.split(" - ").last.toLowerCase(),
        )) {
      // Partial match - contains at least part of expected subject
      earnedPoints += 2;
      errors++;
    } else {
      errors++;
    }

    // Check for keywords in body (10 points)
    totalPoints += scenario.expectedKeywords.length * 2;
    for (String keyword in scenario.expectedKeywords) {
      if (state.body.toLowerCase().contains(keyword.toLowerCase())) {
        earnedPoints += 2;
      } else {
        errors++;
      }
    }

    // Check for proper email format (5 points)
    totalPoints += 5;
    bool hasGreeting =
        state.body.toLowerCase().contains("dear") ||
        state.body.toLowerCase().contains("hello") ||
        state.body.toLowerCase().contains("hi");
    bool hasSignature =
        state.body.toLowerCase().contains("sincerely") ||
        state.body.toLowerCase().contains("regards") ||
        state.body.toLowerCase().contains("thank you");

    if (hasGreeting) {
      earnedPoints += 2;
    } else {
      errors++;
    }

    if (hasSignature) {
      earnedPoints += 3;
    } else {
      errors++;
    }

    // Calculate final accuracy
    double accuracy = (earnedPoints / totalPoints) * 100;

    // Calculate time spent
    final endTime = DateTime.now();
    int timeInSeconds = endTime.difference(startTime!).inSeconds;

    // Prepare result JSON
    Map<String, dynamic> results = {
      'accuracy': accuracy,
      'timeInSeconds': timeInSeconds,
      'errorCount': errors,
      'totalPoints': totalPoints,
      'earnedPoints': earnedPoints,
      'submittedTo': state.to,
      'submittedCc': state.cc,
      'submittedSubject': state.subject,
      'submittedBody': state.body,
      'expectedTo': scenario.expectedTo,
      'expectedCc': scenario.expectedCc,
      'expectedSubject': scenario.expectedSubject,
      'expectedKeywords': scenario.expectedKeywords,
      'hasGreeting': hasGreeting,
      'hasSignature': hasSignature,
      'completedAt': DateTime.now().toIso8601String(),
    };

    return results;
  }

  void startSubmission() {
    emit(state.copyWith(isSubmitting: true));
  }

  Future<void> submitAssessment(Map<String, dynamic> results) async {
    emit(state.copyWith(isSubmitting: true, isCompleted: false));

    try {
      // Update assessment status to completed
      assessmentBloc.add(
        UpdateAssessmentStatusEvent(
          candidateId: candidateId,
          assessmentType: emailData.type,
          status: AssessmentDatabaseHelper.STATUS_COMPLETED,
        ),
      );

      // Save assessment results
      assessmentBloc.add(
        SaveAssessmentResultEvent(
          candidateId: candidateId,
          assessmentType: emailData.type,
          result: results,
        ),
      );

      emit(
        state.copyWith(
          isSubmitting: false,
          isCompleted: true,
          results: results,
        ),
      );
    } catch (e) {
      debugPrint('Error saving assessment results: $e');
      emit(
        state.copyWith(
          isSubmitting: false,
          error: 'Failed to save results: ${e.toString()}',
        ),
      );
    }
  }
}
