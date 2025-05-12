import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenify/domain/entities/questions_entity.dart';

import '../../../core/local/assessment_database_helper.dart';
import '../../dashboard/bloc/assessment_bloc.dart';
import '../../dashboard/bloc/assessment_event.dart';
import 'typing_assessment_state.dart';

// TypingAssessmentBloc
class TypingAssessmentBloc extends Cubit<TypingAssessmentState> {
  final AssessmentBloc assessmentBloc;
  final String candidateId;
  final AssessmentEntity typingData;
  DateTime? startTime;

  TypingAssessmentBloc({
    required this.assessmentBloc,
    required this.candidateId,
    required this.typingData,
  }) : super(
         TypingAssessmentState(
           typedText: '',
           isSubmitting: false,
           sampleText: typingData.paragraph ?? '',
           instructions: typingData.instructions,
           description: typingData.description,
           title: typingData.title,
         ),
       ) {
    // Initialize start time
    startTime = DateTime.now();

    // Mark assessment as started (pending)
    assessmentBloc.add(
      UpdateAssessmentStatusEvent(
        candidateId: candidateId,
        assessmentType: typingData.type,
        status: AssessmentDatabaseHelper.STATUS_PENDING,
      ),
    );
  }

  void updateTypedText(String text) {
    emit(state.copyWith(typedText: text));
  }

  void resetTest() {
    startTime = DateTime.now();
    emit(state.copyWith(typedText: '', isSubmitting: false));
  }

  void startSubmission() {
    emit(state.copyWith(isSubmitting: true));
  }

  Map<String, dynamic> calculateScore() {
    final String userTypedText = state.typedText.trim();
    final String sampleText = state.sampleText.trim();

    // Split texts into lines and words for multi-level comparison
    final List<String> typedLines = userTypedText.split('\n');
    final List<String> referenceLines = sampleText.split('\n');

    final List<String> typedWords = userTypedText.split(' ');
    final List<String> referenceWords = sampleText.split(' ');

    int correctWords = 0;
    int errorCount = 0;
    final int minWordCount =
        typedWords.length < referenceWords.length
            ? typedWords.length
            : referenceWords.length;

    // Compare words
    for (int i = 0; i < minWordCount; i++) {
      if (typedWords[i] == referenceWords[i]) {
        correctWords++;
      } else {
        errorCount++;
      }
    }

    // Count missing or extra words as errors
    final int missingWords = referenceWords.length - minWordCount;
    errorCount += missingWords;

    // Calculate missing lines
    int missingLines = 0;
    if (referenceLines.length > typedLines.length) {
      missingLines = referenceLines.length - typedLines.length;
      errorCount += missingLines * 5; // Add penalty for each missing line
    }

    // Calculate task completion status
    final bool taskCompleted =
        typedWords.length >= referenceWords.length &&
        typedLines.length >= referenceLines.length;

    // Calculate accuracy based on correctly spelled words
    final double accuracy =
        referenceWords.isEmpty
            ? 0.0
            : (correctWords / referenceWords.length) * 100;

    // Calculate typing speed (WPM)
    final endTime = DateTime.now();
    final int timeInSeconds = endTime.difference(startTime!).inSeconds;

    // Calculate WPM based on actual words typed
    final int typingSpeed =
        timeInSeconds > 0
            ? ((typedWords.length * 60) / timeInSeconds).round()
            : 0;

    // Prepare result JSON
    final Map<String, dynamic> results = {
      'accuracy': accuracy,
      'timeInSeconds': timeInSeconds,
      'typingSpeed': typingSpeed,
      'errorCount': errorCount,
      'correctWords': correctWords,
      'totalWords': referenceWords.length,
      'typedWords': typedWords.length,
      'submittedText': userTypedText,
      'referenceText': sampleText,
      'taskCompleted': taskCompleted,
      'completedAt': DateTime.now().toIso8601String(),
    };

    return results;
  }

  Future<void> submitAssessment(Map<String, dynamic> results) async {
    emit(state.copyWith(isSubmitting: true, isCompleted: false));

    try {
      // Update assessment status to completed
      assessmentBloc.add(
        UpdateAssessmentStatusEvent(
          candidateId: candidateId,
          assessmentType: typingData.type,
          status: AssessmentDatabaseHelper.STATUS_COMPLETED,
        ),
      );

      // Save assessment results
      assessmentBloc.add(
        SaveAssessmentResultEvent(
          candidateId: candidateId,
          assessmentType: typingData.type,
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
