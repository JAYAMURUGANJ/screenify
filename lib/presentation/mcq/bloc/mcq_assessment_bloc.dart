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

  Future<void> submitAssessment() async {
    if (state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true));

    // Calculate score
    int score = 0;
    for (var question in state.questions) {
      if (question.selectedAnswerIndex == question.correctAnswerIndex) {
        score++;
      }
    }

    // Calculate time spent
    final endTime = DateTime.now();
    int timeInSeconds = endTime.difference(startTime!).inSeconds;

    // Create questions data
    List<Map<String, dynamic>> questionsData =
        state.questions.map((question) {
          return {
            'question': question.question,
            'selectedAnswerIndex': question.selectedAnswerIndex,
            'correctAnswerIndex': question.correctAnswerIndex,
            'isCorrect':
                question.selectedAnswerIndex == question.correctAnswerIndex,
          };
        }).toList();

    // Create final result object
    Map<String, dynamic> result = {
      'totalQuestions': state.questions.length,
      'correctCount': score,
      'wrongCount': state.questions.length - score,
      'score': score,
      'scorePercentage': (score / state.questions.length * 100).toStringAsFixed(
        1,
      ),
      'questions': questionsData,
      'timeInSeconds': timeInSeconds,
      'completedAt': DateTime.now().toIso8601String(),
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
        score: score,
        result: result,
        isSubmitting: false,
        isCompleted: true,
      ),
    );
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
