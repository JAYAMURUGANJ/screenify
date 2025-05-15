import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenify/domain/entities/questions_entity.dart';

import '../../../core/local/assessment_database_helper.dart';
import '../../dashboard/bloc/assessment_bloc.dart';
import '../../dashboard/bloc/assessment_event.dart';
import 'mcq_assessment_state.dart';

class McqAssessmentBloc extends Cubit<McqAssessmentState> {
  final AssessmentBloc assessmentBloc;
  final String? candidateId;
  final AssessmentEntity mcqData;
  final PageController pageController = PageController(initialPage: 0);
  DateTime? startTime;

  McqAssessmentBloc({
    required this.assessmentBloc,
    required this.candidateId,
    required this.mcqData,
  }) : super(
         McqAssessmentState(
           currentQuestionIndex: 0,
           questions: mcqData.questions!,
           isSubmitting: false,
         ),
       ) {
    // Initialize start time
    startTime = DateTime.now();

    // Mark assessment as started (pending)
    if (candidateId != null) {
      assessmentBloc.add(
        UpdateAssessmentStatusEvent(
          candidateId: candidateId!,
          assessmentType: mcqData.type,
          status: AssessmentDatabaseHelper.STATUS_PENDING,
        ),
      );
    }
  }

  void changeQuestion(int index) {
    emit(state.copyWith(currentQuestionIndex: index));
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void selectAnswer(int questionIndex, int answerIndex) {
    final updatedQuestions = List<QuestionEntity>.from(state.questions);
    updatedQuestions[questionIndex].selectedAnswerIndex = answerIndex;

    emit(state.copyWith(questions: updatedQuestions));
  }

  Future submitAssessment() async {
    if (state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true));

    // Calculate score and detailed analysis
    int correctCount = 0;
    int errorCount = 0;
    List<Map<String, dynamic>> questionsAnalysis = [];

    for (var question in state.questions) {
      bool isCorrect =
          question.selectedAnswerIndex == question.correctAnswerIndex;
      if (isCorrect) {
        correctCount++;
      } else {
        errorCount++;
      }
      questionsAnalysis.add({
        'question': question.question,
        'selectedAnswerIndex': question.selectedAnswerIndex,
        'correctAnswerIndex': question.correctAnswerIndex,
        'isCorrect': isCorrect,
      });
    }

    // Calculate accuracy and skill level
    int totalQuestions = state.questions.length;
    double accuracy =
        totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0.0;
    accuracy = double.parse(accuracy.toStringAsFixed(1));

    String skillLevel = _assessSkillLevel(accuracy);

    // Pass/fail logic
    bool passed = _determinePassFail(accuracy, errorCount);

    // Feedback generation
    String feedback = _generateFeedback(
      accuracy,
      errorCount,
      passed,
      correctCount,
    );

    // Current timestamp for submission date and completion date
    final currentDateTime = DateTime.now().toIso8601String();

    // Create final result object with the requested structure
    Map<String, dynamic> result = {
      "submissionDate": currentDateTime,
      "completedAt": currentDateTime,
      "skillLevel": skillLevel,
      "score": correctCount,
      "scorePercentage": accuracy.toInt(),
      "passed": passed.toString(),
      "feedback": feedback,
      "details": {
        "totalQuestions": totalQuestions,
        "correctCount": correctCount,
        "wrongCount": errorCount,
        "questions": questionsAnalysis,
      },
    };

    // Save result to database through the AssessmentBloc
    if (candidateId != null) {
      assessmentBloc.add(
        SaveAssessmentResultEvent(
          candidateId: candidateId!,
          assessmentType: mcqData.type,
          result: result,
        ),
      );

      // Mark assessment as completed
      assessmentBloc.add(
        UpdateAssessmentStatusEvent(
          candidateId: candidateId!,
          assessmentType: mcqData.type,
          status: AssessmentDatabaseHelper.STATUS_COMPLETED,
        ),
      );
    }

    emit(
      state.copyWith(
        score: correctCount,
        result: result,
        isSubmitting: false,
        isCompleted: true,
      ),
    );
  }

  // Helper functions
  String _assessSkillLevel(double accuracy) {
    if (accuracy >= 95) return 'Expert';
    if (accuracy >= 85) return 'Advanced';
    if (accuracy >= 70) return 'Intermediate';
    if (accuracy >= 50) return 'Basic';
    return 'Beginner';
  }

  bool _determinePassFail(double accuracy, int errors) {
    const double minimumAccuracy = 70.0;
    const int maximumErrors = 5;
    return accuracy >= minimumAccuracy && errors <= maximumErrors;
  }

  String _generateFeedback(
    double accuracy,
    int errors,
    bool passed,
    int score,
  ) {
    List<String> feedbackPoints = [];
    if (accuracy >= 95) {
      feedbackPoints.add('Outstanding MCQ performance!');
    } else if (accuracy >= 85) {
      feedbackPoints.add('Very good MCQ performance.');
    } else if (accuracy >= 70) {
      feedbackPoints.add('Satisfactory MCQ performance.');
    } else if (accuracy >= 50) {
      feedbackPoints.add('Needs improvement in MCQ answers.');
    } else {
      feedbackPoints.add('Significant improvement needed in MCQ performance.');
    }
    if (errors > 0) {
      if (errors <= 2) {
        feedbackPoints.add('Only a few mistakes.');
      } else if (errors <= 5) {
        feedbackPoints.add('Several mistakes to address.');
      } else {
        feedbackPoints.add('Many mistakes affected your score.');
      }
    }
    if (accuracy == 100) {
      return 'Perfect score! All answers correct. You passed!';
    }
    if (passed) {
      feedbackPoints.add('You passed the MCQ test with a score of $score!');
    } else {
      feedbackPoints.add(
        'You did not pass. Score: $score. Please review and try again.',
      );
    }
    return feedbackPoints.join(' ');
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
