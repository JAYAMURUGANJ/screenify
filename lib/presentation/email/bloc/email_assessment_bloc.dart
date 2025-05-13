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
    final int keywordsPoints = 2;
    totalPoints += scenario.expectedKeywords.length * keywordsPoints;

    List<Map<String, dynamic>> keywordAnalysis = [];
    for (String keyword in scenario.expectedKeywords) {
      bool found = state.body.toLowerCase().contains(keyword.toLowerCase());

      keywordAnalysis.add({
        'keyword': keyword,
        'found': found,
        'points': found ? keywordsPoints : 0,
      });

      if (found) {
        earnedPoints += keywordsPoints;
      } else {
        errors++;
      }
    }

    // Check for proper email format (5 points)
    totalPoints += 5;

    // Check for greeting (2 points)
    bool hasGreeting =
        state.body.toLowerCase().contains("dear") ||
        state.body.toLowerCase().contains("hello") ||
        state.body.toLowerCase().contains("hi");

    if (hasGreeting) {
      earnedPoints += 2;
    } else {
      errors++;
    }

    // Check for signature (3 points)
    bool hasSignature =
        state.body.toLowerCase().contains("sincerely") ||
        state.body.toLowerCase().contains("regards") ||
        state.body.toLowerCase().contains("thank you") ||
        state.body.toLowerCase().contains("faithfully");

    if (hasSignature) {
      earnedPoints += 3;
    } else {
      errors++;
    }

    // Calculate accuracy percentage
    double accuracy =
        totalPoints > 0 ? (earnedPoints / totalPoints) * 100 : 0.0;

    // Calculate time spent
    final endTime = DateTime.now();
    int timeInSeconds = endTime.difference(startTime!).inSeconds;

    // Calculate score out of 100
    double score = (accuracy).clamp(0.0, 100.0);
    score = double.parse(score.toStringAsFixed(1));

    // Determine pass/fail status
    bool passed = _determinePassFail(accuracy, errors);

    // Generate feedback
    String feedback = _generateFeedback(accuracy, errors, passed, score);

    // Generate skill level
    String skillLevel = _assessSkillLevel(accuracy);

    // Get current date time
    final now = DateTime.now();
    String submissionDate = now.toIso8601String();
    String completedAt = now.toIso8601String();

    // Prepare simplified result map according to the specified requirements
    final Map<String, dynamic> results = {
      "submissionDate": submissionDate,
      "completedAt": completedAt,
      "skillLevel": skillLevel,
      "score": score,
      "scorePercentage": score,
      "passed": passed,
      "timeInSeconds": timeInSeconds,
      "feedback": feedback,
      "details": {
        "accuracy": double.parse(accuracy.toStringAsFixed(2)),
        "errorCount": errors,
        "totalPoints": totalPoints,
        "earnedPoints": earnedPoints,
        "submittedTo": state.to,
        "submittedCc": state.cc,
        "submittedSubject": state.subject,
        "submittedBody": state.body,
        "keywordAnalysis": keywordAnalysis,
      },
    };

    return results;
  }

  // Helper function to assess skill level
  String _assessSkillLevel(double accuracy) {
    if (accuracy >= 95) {
      return 'Expert';
    } else if (accuracy >= 85) {
      return 'Advanced';
    } else if (accuracy >= 70) {
      return 'Intermediate';
    } else if (accuracy >= 50) {
      return 'Basic';
    } else {
      return 'Beginner';
    }
  }

  // Helper function to determine pass/fail status
  bool _determinePassFail(double accuracy, int errors) {
    // Configurable thresholds
    const double minimumAccuracy = 70.0; // Minimum accuracy percentage to pass
    const int maximumErrors = 5; // Maximum number of errors allowed

    return accuracy >= minimumAccuracy && errors <= maximumErrors;
  }

  // Helper function to generate feedback based on performance
  String _generateFeedback(
    double accuracy,
    int errors,
    bool passed,
    double score,
  ) {
    List<String> feedbackPoints = [];

    // Accuracy feedback
    if (accuracy >= 95) {
      feedbackPoints.add('Your email composition skills are excellent!');
    } else if (accuracy >= 85) {
      feedbackPoints.add('Your email composition is very good.');
    } else if (accuracy >= 70) {
      feedbackPoints.add('Your email composition skills are satisfactory.');
    } else if (accuracy >= 50) {
      feedbackPoints.add('Your email composition needs some improvement.');
    } else {
      feedbackPoints.add(
        'Focus on improving your email composition with more practice.',
      );
    }

    // Error feedback
    if (errors > 0) {
      if (errors <= 2) {
        feedbackPoints.add('You made only a few minor errors.');
      } else if (errors <= 5) {
        feedbackPoints.add('You made several errors that should be addressed.');
      } else {
        feedbackPoints.add(
          'You made multiple errors that significantly affected your score.',
        );
      }
    }

    // Special case for perfect performance
    if (accuracy == 100) {
      return 'Perfect email composition! Score: $score. All required elements were included correctly. You passed!';
    }

    // Add pass/fail result to feedback
    if (passed) {
      feedbackPoints.add(
        'You passed the email composition test with a score of $score!',
      );
    } else {
      feedbackPoints.add(
        'You did not pass the test. Your score is $score. Please try again and ensure you include all required elements.',
      );
    }

    return feedbackPoints.join(' ');
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
